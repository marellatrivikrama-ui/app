import type { Request, Response } from 'express';
import type { RowDataPacket } from 'mysql2';
import { z } from 'zod';

import { queryRows } from '../config/db';

interface ClinicalMatrixRow extends RowDataPacket {
  module_title: string;
  answer_vector_combination: string;
  ayurvedic_name: string;
  root_cause: string;
  problem: string;
  generalized_plan: unknown;
}

const evaluateSchema = z.object({
  moduleTitle: z.string().trim().min(1).max(120),
  selectedOptionIndices: z.array(z.coerce.number().int().min(0).max(2)).length(3),
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
    message: 'Invalid assessment payload.',
    errors: error.issues.map((issue) => ({
      path: issue.path.join('.'),
      message: issue.message,
    })),
  });
}

function buildAnswerVectorCombination(indices: number[]): string {
  return indices.map((index) => String(index)).join('-');
}

function parsePlan(value: unknown): string[] {
  if (Array.isArray(value)) {
    return value.map((entry) => String(entry));
  }

  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value) as unknown;
      if (Array.isArray(parsed)) {
        return parsed.map((entry) => String(entry));
      }
    } catch {
      return [value];
    }
  }

  return [
    'Maintain stable routines, hydration, and regular meals while awaiting a mapped rule update.',
  ];
}

function fallbackSummary(moduleTitle: string, answerVectorCombination: string) {
  return {
    moduleTitle,
    answerVectorCombination,
    ayurvedicName: 'Generalized Safe Clinical Summary',
    rootCause:
      'The submitted vector did not match a pre-approved clinical matrix row.',
    problem:
      'This is an unmapped deterministic edge case, not an AI-generated interpretation.',
    generalizedPlan: [
      'Maintain regular sleep, hydration, and gentle movement for baseline stability.',
      'Avoid extreme diet changes, fasting, excessive heat, and late-night overstimulation.',
      'Use this result as educational guidance only and consult a licensed clinician for persistent or severe symptoms.',
    ],
    isFallback: true,
  };
}

export async function evaluateAssessment(req: Request, res: Response): Promise<void> {
  const parsed = evaluateSchema.safeParse({
    moduleTitle: pickBodyValue(req.body, ['moduleTitle', 'module_title']),
    selectedOptionIndices: pickBodyValue(req.body, [
      'selectedOptionIndices',
      'selectedIndices',
      'selected_option_indices',
    ]),
  });

  if (!parsed.success) {
    sendValidationError(res, parsed.error);
    return;
  }

  const answerVectorCombination = buildAnswerVectorCombination(
    parsed.data.selectedOptionIndices,
  );

  const rows = await queryRows<ClinicalMatrixRow[]>(
    `SELECT module_title,
            answer_vector_combination,
            ayurvedic_name,
            root_cause,
            problem,
            generalized_plan
     FROM clinical_matrix
     WHERE module_title = ?
       AND answer_vector_combination = ?
     LIMIT 1`,
    [parsed.data.moduleTitle, answerVectorCombination],
  );

  if (rows.length === 0) {
    res.status(200).json({
      success: true,
      engine: {
        type: 'deterministic_relational_lookup',
        aiModelUsed: false,
        matched: false,
      },
      data: fallbackSummary(parsed.data.moduleTitle, answerVectorCombination),
    });
    return;
  }

  const row = rows[0];

  res.status(200).json({
    success: true,
    engine: {
      type: 'deterministic_relational_lookup',
      aiModelUsed: false,
      matched: true,
    },
    data: {
      moduleTitle: row.module_title,
      answerVectorCombination: row.answer_vector_combination,
      ayurvedicName: row.ayurvedic_name,
      rootCause: row.root_cause,
      problem: row.problem,
      generalizedPlan: parsePlan(row.generalized_plan),
      isFallback: false,
    },
  });
}
