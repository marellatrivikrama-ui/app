import dotenv from 'dotenv';
import mysql, {
  type Pool,
  type ResultSetHeader,
  type RowDataPacket,
} from 'mysql2/promise';

dotenv.config();

function readRequiredEnv(name: string): string {
  const value = process.env[name]?.trim();
  if (!value) {
    throw new Error(`Missing required environment variable: ${name}`);
  }
  return value;
}

function readOptionalIntEnv(name: string, fallback: number): number {
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

export const pool: Pool = mysql.createPool({
  host: readRequiredEnv('DB_HOST'),
  port: readOptionalIntEnv('DB_PORT', 3306),
  user: readRequiredEnv('DB_USER'),
  password: process.env.DB_PASSWORD ?? '',
  database: readRequiredEnv('DB_NAME'),
  waitForConnections: true,
  connectionLimit: readOptionalIntEnv('DB_CONNECTION_LIMIT', 10),
  queueLimit: 0,
  enableKeepAlive: true,
  keepAliveInitialDelay: 10_000,
  namedPlaceholders: true,
  timezone: 'Z',
});

export async function queryRows<T extends RowDataPacket[]>(
  sql: string,
  params: unknown[] = [],
): Promise<T> {
  const [rows] = await pool.execute<T>(sql, params as never[]);
  return rows;
}

export async function executeStatement(
  sql: string,
  params: unknown[] = [],
): Promise<ResultSetHeader> {
  const [result] = await pool.execute<ResultSetHeader>(sql, params as never[]);
  return result;
}

export async function assertDatabaseConnection(): Promise<void> {
  const connection = await pool.getConnection();
  try {
    await connection.ping();
  } finally {
    connection.release();
  }
}
