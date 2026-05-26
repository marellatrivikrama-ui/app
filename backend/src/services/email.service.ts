import nodemailer, { type Transporter } from 'nodemailer';

interface UserVerificationEmailInput {
  toEmail: string;
  name: string;
  verificationUrl: string;
  token: string;
  expiresAtIso: string;
}

interface AdminRegistrationAlertInput {
  userId: string;
  name: string;
  email: string;
  age: number;
  gender: string;
  mobileNumber: string;
  alertToken: string;
  createdAtIso: string;
}

interface DualVerificationInput {
  userEmail: UserVerificationEmailInput;
  adminAlert: AdminRegistrationAlertInput;
}

let transporter: Transporter | null = null;

function readRequiredEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function readBooleanEnv(name: string, fallback: boolean): boolean {
  const rawValue = process.env[name]?.trim().toLowerCase();
  if (!rawValue) {
    return fallback;
  }
  return rawValue === 'true' || rawValue === '1' || rawValue === 'yes';
}

function readIntEnv(name: string, fallback: number): number {
  const rawValue = process.env[name]?.trim();
  if (!rawValue) {
    return fallback;
  }
  const parsed = Number.parseInt(rawValue, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer.`);
  }
  return parsed;
}

function getTransporter(): Transporter {
  if (transporter) {
    return transporter;
  }

  transporter = nodemailer.createTransport({
    host: readRequiredEnv('SMTP_HOST'),
    port: readIntEnv('SMTP_PORT', 587),
    secure: readBooleanEnv('SMTP_SECURE', false),
    auth: {
      user: readRequiredEnv('SMTP_USER'),
      pass: readRequiredEnv('SMTP_PASS'),
    },
  });

  return transporter;
}

function escapeHtml(value: string): string {
  return value
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function emailShell(title: string, body: string): string {
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${escapeHtml(title)}</title>
  </head>
  <body style="margin:0;background:#0A0F0D;color:#FFFFFF;font-family:Arial,Helvetica,sans-serif;">
    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background:#0A0F0D;padding:28px 12px;">
      <tr>
        <td align="center">
          <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:640px;background:#121915;border:1px solid #24352D;border-radius:12px;overflow:hidden;">
            <tr>
              <td style="padding:24px 28px;border-bottom:1px solid #24352D;">
                <div style="font-size:12px;line-height:18px;letter-spacing:2px;color:#2A8B5C;font-weight:700;">AAYURVANI</div>
                <div style="font-size:22px;line-height:30px;color:#FFFFFF;font-weight:700;margin-top:6px;">${escapeHtml(title)}</div>
              </td>
            </tr>
            <tr>
              <td style="padding:28px;">
                ${body}
              </td>
            </tr>
            <tr>
              <td style="padding:18px 28px;background:#0F1612;border-top:1px solid #24352D;color:#90A49A;font-size:12px;line-height:18px;">
                Deterministic clinical rule engine notification. No third-party AI model generated this message.
              </td>
            </tr>
          </table>
        </td>
      </tr>
    </table>
  </body>
</html>`;
}

export async function sendUserVerificationEmail(
  input: UserVerificationEmailInput,
): Promise<void> {
  const safeName = escapeHtml(input.name);
  const safeUrl = escapeHtml(input.verificationUrl);
  const safeToken = escapeHtml(input.token);
  const safeExpiry = escapeHtml(input.expiresAtIso);

  const html = emailShell(
    'Verify Your Aayurvani Account',
    `<p style="margin:0 0 16px;color:#DDE8E2;font-size:15px;line-height:24px;">Namaste ${safeName},</p>
     <p style="margin:0 0 18px;color:#90A49A;font-size:14px;line-height:23px;">Your secure Aayurvani account registration has been received. Confirm this email address to activate clinical report access.</p>
     <p style="margin:0 0 22px;">
       <a href="${safeUrl}" style="display:inline-block;background:#164A32;color:#FFFFFF;text-decoration:none;padding:13px 18px;border-radius:8px;font-size:14px;font-weight:700;border:1px solid #2A8B5C;">Verify Account</a>
     </p>
     <div style="background:#0A0F0D;border:1px solid #24352D;border-radius:8px;padding:14px 16px;margin:0 0 18px;">
       <div style="color:#5A7568;font-size:11px;line-height:16px;text-transform:uppercase;letter-spacing:1.4px;">Verification Token</div>
       <div style="color:#FFFFFF;font-family:Consolas,Monaco,monospace;font-size:13px;line-height:20px;word-break:break-all;margin-top:6px;">${safeToken}</div>
     </div>
     <p style="margin:0;color:#90A49A;font-size:13px;line-height:21px;">This token expires at ${safeExpiry}. If you did not initiate this registration, ignore this email.</p>`,
  );

  await getTransporter().sendMail({
    from: readRequiredEnv('EMAIL_FROM'),
    to: input.toEmail,
    subject: 'Verify your Aayurvani account',
    html,
  });
}

export async function sendAdminRegistrationAlert(
  input: AdminRegistrationAlertInput,
): Promise<void> {
  const html = emailShell(
    'New Registration Vector Initiated',
    `<p style="margin:0 0 18px;color:#DDE8E2;font-size:15px;line-height:24px;">A new user registration vector has entered the verification queue.</p>
     <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="border-collapse:collapse;background:#0A0F0D;border:1px solid #24352D;border-radius:8px;overflow:hidden;">
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">User ID</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${escapeHtml(input.userId)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">Name</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${escapeHtml(input.name)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">Email</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${escapeHtml(input.email)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">Age / Gender</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${input.age} / ${escapeHtml(input.gender)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">Mobile</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${escapeHtml(input.mobileNumber)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;border-bottom:1px solid #24352D;">Created</td><td style="padding:10px 14px;color:#FFFFFF;border-bottom:1px solid #24352D;">${escapeHtml(input.createdAtIso)}</td></tr>
       <tr><td style="padding:10px 14px;color:#90A49A;">Alert Token</td><td style="padding:10px 14px;color:#FFFFFF;font-family:Consolas,Monaco,monospace;word-break:break-all;">${escapeHtml(input.alertToken)}</td></tr>
     </table>
     <p style="margin:18px 0 0;color:#90A49A;font-size:13px;line-height:21px;">Password material is never included in operational email alerts.</p>`,
  );

  await getTransporter().sendMail({
    from: readRequiredEnv('EMAIL_FROM'),
    to: readRequiredEnv('ADMIN_ALERT_EMAIL'),
    subject: 'Aayurvani operational alert: new registration',
    html,
  });
}

export async function dispatchDualVerificationEmails(
  input: DualVerificationInput,
): Promise<void> {
  await Promise.all([
    sendUserVerificationEmail(input.userEmail),
    sendAdminRegistrationAlert(input.adminAlert),
  ]);
}
