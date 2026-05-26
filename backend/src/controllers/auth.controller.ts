import bcrypt from 'bcrypt';
import { createHash, randomBytes, randomUUID } from 'crypto';
import type { Request, Response } from 'express';
import jwt, { type SignOptions } from 'jsonwebtoken';
import type { RowDataPacket } from 'mysql2';
import { z } from 'zod';

import { executeStatement, queryRows } from '../config/db';
import { dispatchDualVerificationEmails } from '../services/email.service';

interface UserRow extends RowDataPacket {
  id: string;
  name: string;
  email: string;
  age: number;
  gender: 'Male' | 'Female' | 'Other';
  mobile_number: string;
  password_hash: string;
  is_verified: number | boolean;
  verification_token_expires_at: Date | string | null;
}

const passwordMinimumLength = 8;

const registerSchema = z.object({
  name: z.string().trim().min(2).max(120),
  email: z.string().trim().email().max(254).toLowerCase(),
  age: z.coerce.number().int().min(1).max(120),
  gender: z
    .string()
    .trim()
    .min(1)
    .max(32)
    .transform((value) => value.toLowerCase())
    .refine((value) => ['male', 'female', 'other'].includes(value), {
      message: 'gender must be Male, Female, or Other',
    })
    .transform((value) =>
      value === 'male' ? 'Male' : value === 'female' ? 'Female' : 'Other',
    ),
  mobileNumber: z
    .string()
    .trim()
    .regex(/^\+?[0-9]{8,15}$/, 'mobile number must contain 8 to 15 digits'),
  password: z.string().min(passwordMinimumLength).max(128),
});

const loginSchema = z.object({
  identifier: z.string().trim().min(3).max(254),
  password: z.string().min(1).max(128),
});

function pickBodyValue(body: unknown, keys: string[]): unknown {
  if (!body || typeof body !== 'object') {
    return undefined;
  }

  const record = body as Record<string, unknown>;
  for (const key of keys) {
    if (record[key] !== undefined) {
      return record[key];
    }
  }

  return undefined;
}

function sendValidationError(res: Response, error: z.ZodError): void {
  res.status(400).json({
    success: false,
    message: 'Invalid request payload.',
    errors: error.issues.map((issue) => ({
      path: issue.path.join('.'),
      message: issue.message,
    })),
  });
}

function sha256Hex(value: string): string {
  return createHash('sha256').update(value, 'utf8').digest('hex');
}

function readJwtSecret(): string {
  const secret = process.env.JWT_SECRET?.trim();
  if (!secret || secret.length < 32) {
    throw new Error('JWT_SECRET must be set and contain at least 32 characters.');
  }
  return secret;
}

function readVerificationTokenTtlMinutes(): number {
  const rawValue = process.env.VERIFICATION_TOKEN_TTL_MINUTES?.trim();
  if (!rawValue) {
    return 30;
  }

  const parsed = Number.parseInt(rawValue, 10);
  if (!Number.isFinite(parsed) || parsed < 5 || parsed > 1440) {
    throw new Error(
      'VERIFICATION_TOKEN_TTL_MINUTES must be an integer between 5 and 1440.',
    );
  }
  return parsed;
}

function buildVerificationUrl(token: string): string {
  const apiBaseUrl = (process.env.API_BASE_URL ?? 'http://localhost:4000').trim();
  const normalizedBaseUrl = apiBaseUrl.replace(/\/+$/, '');
  return `${normalizedBaseUrl}/api/v1/auth/verify?token=${encodeURIComponent(token)}`;
}

function signSessionToken(user: Pick<UserRow, 'id' | 'email' | 'name'>): string {
  const options: SignOptions = {
    subject: user.id,
    issuer: 'aayurvani-api',
    audience: 'aayurvani-client',
    expiresIn: (process.env.JWT_EXPIRES_IN ?? '12h') as SignOptions['expiresIn'],
  };

  return jwt.sign(
    {
      email: user.email,
      name: user.name,
    },
    readJwtSecret(),
    options,
  );
}

function publicUser(user: UserRow) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    age: user.age,
    gender: user.gender,
    mobileNumber: user.mobile_number,
    isVerified: Boolean(user.is_verified),
  };
}

export async function registerUser(req: Request, res: Response): Promise<void> {
  const parsed = registerSchema.safeParse({
    name: pickBodyValue(req.body, ['name']),
    email: pickBodyValue(req.body, ['email']),
    age: pickBodyValue(req.body, ['age']),
    gender: pickBodyValue(req.body, ['gender']),
    mobileNumber: pickBodyValue(req.body, ['mobileNumber', 'mobile_number']),
    password: pickBodyValue(req.body, ['password']),
  });

  if (!parsed.success) {
    sendValidationError(res, parsed.error);
    return;
  }

  const input = parsed.data;

  const existingUsers = await queryRows<UserRow[]>(
    `SELECT id, name, email, age, gender, mobile_number, password_hash, is_verified, verification_token_expires_at
     FROM users
     WHERE email = ? OR mobile_number = ?
     LIMIT 1`,
    [input.email, input.mobileNumber],
  );

  if (existingUsers.length > 0) {
    res.status(409).json({
      success: false,
      message: 'An account already exists for this email or mobile number.',
    });
    return;
  }

  const userId = randomUUID();
  const rawVerificationToken = randomBytes(32).toString('hex');
  const verificationTokenHash = sha256Hex(rawVerificationToken);
  const adminAlertToken = randomBytes(24).toString('hex');
  const tokenTtlMinutes = readVerificationTokenTtlMinutes();
  const passwordHash = await bcrypt.hash(input.password, 12);

  await executeStatement(
    `INSERT INTO users (
       id,
       name,
       email,
       age,
       gender,
       mobile_number,
       password_hash,
       is_verified,
       verification_token,
       verification_token_expires_at
     ) VALUES (?, ?, ?, ?, ?, ?, ?, FALSE, ?, DATE_ADD(UTC_TIMESTAMP(), INTERVAL ? MINUTE))`,
    [
      userId,
      input.name,
      input.email,
      input.age,
      input.gender,
      input.mobileNumber,
      passwordHash,
      verificationTokenHash,
      tokenTtlMinutes,
    ],
  );

  const createdAt = new Date();
  const expiresAt = new Date(createdAt.getTime() + tokenTtlMinutes * 60_000);

  await dispatchDualVerificationEmails({
    userEmail: {
      toEmail: input.email,
      name: input.name,
      verificationUrl: buildVerificationUrl(rawVerificationToken),
      token: rawVerificationToken,
      expiresAtIso: expiresAt.toISOString(),
    },
    adminAlert: {
      userId,
      name: input.name,
      email: input.email,
      age: input.age,
      gender: input.gender,
      mobileNumber: input.mobileNumber,
      alertToken: adminAlertToken,
      createdAtIso: createdAt.toISOString(),
    },
  });

  res.status(201).json({
    success: true,
    message:
      'Registration accepted. Verification emails were dispatched to the user and administrator.',
    user: {
      id: userId,
      name: input.name,
      email: input.email,
      age: input.age,
      gender: input.gender,
      mobileNumber: input.mobileNumber,
      isVerified: false,
    },
  });
}

export async function verifyEmail(req: Request, res: Response): Promise<void> {
  const token = typeof req.query.token === 'string' ? req.query.token.trim() : '';

  if (!/^[a-f0-9]{64}$/i.test(token)) {
    res.status(400).json({
      success: false,
      message: 'A valid verification token is required.',
    });
    return;
  }

  const tokenHash = sha256Hex(token);
  const matchingUsers = await queryRows<UserRow[]>(
    `SELECT id, name, email, age, gender, mobile_number, password_hash, is_verified, verification_token_expires_at
     FROM users
     WHERE verification_token = ?
     LIMIT 1`,
    [tokenHash],
  );

  if (matchingUsers.length === 0) {
    res.status(400).json({
      success: false,
      message: 'Verification token is invalid or has already been used.',
    });
    return;
  }

  const user = matchingUsers[0];
  const expiresAt = user.verification_token_expires_at
    ? new Date(user.verification_token_expires_at)
    : null;

  if (!expiresAt || expiresAt.getTime() <= Date.now()) {
    res.status(410).json({
      success: false,
      message: 'Verification token has expired. Register again to receive a new token.',
    });
    return;
  }

  await executeStatement(
    `UPDATE users
     SET is_verified = TRUE,
         verification_token = NULL,
         verification_token_expires_at = NULL
     WHERE id = ?`,
    [user.id],
  );

  const sessionToken = signSessionToken(user);

  res.status(200).json({
    success: true,
    message: 'Email verified successfully.',
    token: sessionToken,
    user: {
      ...publicUser(user),
      isVerified: true,
    },
  });
}

export async function loginUser(req: Request, res: Response): Promise<void> {
  const parsed = loginSchema.safeParse({
    identifier: pickBodyValue(req.body, ['identifier', 'email', 'mobileNumber', 'mobile_number']),
    password: pickBodyValue(req.body, ['password']),
  });

  if (!parsed.success) {
    sendValidationError(res, parsed.error);
    return;
  }

  const identifier = parsed.data.identifier.toLowerCase();
  const users = await queryRows<UserRow[]>(
    `SELECT id, name, email, age, gender, mobile_number, password_hash, is_verified, verification_token_expires_at
     FROM users
     WHERE email = ? OR mobile_number = ?
     LIMIT 1`,
    [identifier, parsed.data.identifier],
  );

  if (users.length === 0) {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials.',
    });
    return;
  }

  const user = users[0];
  const passwordMatches = await bcrypt.compare(parsed.data.password, user.password_hash);

  if (!passwordMatches) {
    res.status(401).json({
      success: false,
      message: 'Invalid credentials.',
    });
    return;
  }

  if (!Boolean(user.is_verified)) {
    res.status(403).json({
      success: false,
      message: 'Email verification is required before login.',
    });
    return;
  }

  res.status(200).json({
    success: true,
    message: 'Login successful.',
    token: signSessionToken(user),
    user: publicUser(user),
  });
}
