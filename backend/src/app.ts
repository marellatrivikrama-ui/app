import cors from 'cors';
import dotenv from 'dotenv';
import express, {
  type NextFunction,
  type Request,
  type Response,
} from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';

import { assertDatabaseConnection } from './config/db';
import {
  loginUser,
  registerUser,
  verifyEmail,
} from './controllers/auth.controller';
import { evaluateAssessment } from './controllers/engine.controller';

dotenv.config();

const app = express();

app.disable('x-powered-by');
app.set('trust proxy', 1);

function parseCorsOrigin():
  | boolean
  | string
  | RegExp
  | Array<string | RegExp> {
  const rawOrigin = process.env.CORS_ORIGIN?.trim();
  if (!rawOrigin || rawOrigin === '*') {
    return true;
  }

  const origins = rawOrigin
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);

  return origins.length === 1 ? origins[0] : origins;
}

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 25,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
});

const engineLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 120,
  standardHeaders: 'draft-8',
  legacyHeaders: false,
});

function asyncRoute(
  handler: (req: Request, res: Response) => Promise<void>,
) {
  return (req: Request, res: Response, next: NextFunction): void => {
    handler(req, res).catch(next);
  };
}

app.use(
  helmet({
    contentSecurityPolicy: false,
  }),
);
app.use(
  cors({
    origin: parseCorsOrigin(),
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  }),
);
app.use(express.json({ limit: '32kb' }));

app.get('/health', asyncRoute(async (_req, res) => {
  await assertDatabaseConnection();
  res.status(200).json({
    success: true,
    service: 'aayurvani-backend',
    database: 'connected',
  });
}));

app.post('/api/v1/auth/register', authLimiter, asyncRoute(registerUser));
app.get('/api/v1/auth/verify', authLimiter, asyncRoute(verifyEmail));
app.post('/api/v1/auth/login', authLimiter, asyncRoute(loginUser));
app.post('/api/v1/prototype/evaluate', engineLimiter, asyncRoute(evaluateAssessment));

app.use((_req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found.',
  });
});

app.use((error: unknown, _req: Request, res: Response, _next: NextFunction) => {
  const message =
    error instanceof Error ? error.message : 'Unexpected server error.';

  if (process.env.NODE_ENV !== 'test') {
    console.error('[Aayurvani API]', error);
  }

  res.status(500).json({
    success: false,
    message:
      process.env.NODE_ENV === 'production'
        ? 'Internal server error.'
        : message,
  });
});

if (require.main === module) {
  const port = Number.parseInt(process.env.PORT ?? '4000', 10);
  app.listen(port, () => {
    console.log(`Aayurvani backend listening on port ${port}`);
  });
}

export default app;
