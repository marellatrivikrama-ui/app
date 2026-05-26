# Aayurvani Backend

## Status

Before this backend folder was added, the app only had a Flutter front end. There was no secure server, no persistent user database, no password hashing, no email verification workflow, and no deterministic server-side clinical matrix. This backend adds those pieces without using any third-party AI model.

## Request Lifecycle And Routing Pipeline

The Flutter client should call the API over HTTPS in production. TLS normally terminates at a managed reverse proxy or load balancer, then forwards sanitized HTTP traffic to this Express service. The service disables `x-powered-by`, enables security headers with Helmet, applies CORS allow-listing, rate-limits authentication and engine routes, and parses JSON with a small request size limit.

Every endpoint reads payload values explicitly instead of trusting arbitrary request shapes. Controllers validate structure with Zod before touching MySQL. Invalid payloads return `400` with field-level messages. Authentication routes hash passwords with bcrypt, store only the hash, and issue JWT session tokens only after email verification succeeds.

Public endpoints:

- `POST /api/v1/auth/register`
- `GET /api/v1/auth/verify?token=...`
- `POST /api/v1/auth/login`
- `POST /api/v1/prototype/evaluate`
- `GET /health`

## Deterministic Expert Rule Engine

The Flutter questionnaire sends a structural payload:

```json
{
  "moduleTitle": "Prakruthi Analysis",
  "selectedOptionIndices": [0, 1, 0]
}
```

The backend validates that the module title is a bounded string and that the answer vector contains exactly three integers from `0` to `2`. It preserves question order and concatenates the vector into a lookup key such as `0-1-0`. Preserving order is important because sorting would make different clinical answer sequences collapse into the same key.

The rule engine then performs a fast relational lookup:

```sql
SELECT ...
FROM clinical_matrix
WHERE module_title = ?
  AND answer_vector_combination = ?
LIMIT 1;
```

The result is deterministic: identical module title plus identical vector always returns the same approved row. No text-generation model is called, so there is no hallucination surface, no prompt injection surface, and no variable model latency. If the vector is valid but unmapped, the controller returns a pre-approved safe fallback object so Flutter rendering never crashes.

## Dual-Channel Email Verification

Registration requires `name`, `email`, `age`, `gender`, `mobileNumber`, and `password`.

The server flow is:

1. Validate and normalize payload fields.
2. Reject duplicate email or mobile number.
3. Hash the password with bcrypt cost factor `12`.
4. Generate a cryptographically random 32-byte verification token.
5. Store only the SHA-256 hash of that token in `users.verification_token`.
6. Insert the inactive user with `is_verified = FALSE` and an expiry timestamp.
7. Dispatch two transactional emails with Nodemailer:
   - User email: verification link and token.
   - Admin email: operational registration alert with user details, never password material.
8. `GET /api/v1/auth/verify?token=...` hashes the presented token and activates the matching unexpired user.
9. Login succeeds only for verified users and returns a signed JWT.

## Database Setup

Create a MySQL user/database, then run:

```powershell
mysql -u root -p < backend/schema.sql
```

The schema creates:

- `users`: UUID identity, email, mobile, bcrypt hash, verification status/token hash, timestamps.
- `clinical_matrix`: deterministic answer-vector lookup rows with JSON plan arrays.

## Local Run

```powershell
cd backend
npm install
Copy-Item .env.example .env
npm run typecheck
npm run build
npm run dev
```

Edit `.env` with real MySQL, SMTP, and JWT values before using registration or login.

## Flutter Integration Notes

The current Flutter UI still stores assessment state locally. To use this backend, add an email field to registration, send auth calls to `/api/v1/auth/*`, and replace local clinical synthesis generation with `POST /api/v1/prototype/evaluate`. The response already returns display-ready fields: `ayurvedicName`, `rootCause`, `problem`, and `generalizedPlan`.
