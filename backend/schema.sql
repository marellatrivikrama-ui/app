CREATE DATABASE IF NOT EXISTS aayurvani
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE aayurvani;

CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(254) NOT NULL,
  age TINYINT UNSIGNED NOT NULL,
  gender ENUM('Male', 'Female', 'Other') NOT NULL,
  mobile_number VARCHAR(20) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_verified BOOLEAN NOT NULL DEFAULT FALSE,
  verification_token CHAR(64) NULL,
  verification_token_expires_at DATETIME NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_mobile_number (mobile_number),
  UNIQUE KEY uq_users_verification_token (verification_token),
  KEY idx_users_verified_email (is_verified, email),
  CONSTRAINT chk_users_age CHECK (age BETWEEN 1 AND 120)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS clinical_matrix (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  module_title VARCHAR(120) NOT NULL,
  answer_vector_combination VARCHAR(20) NOT NULL,
  ayurvedic_name VARCHAR(160) NOT NULL,
  root_cause TEXT NOT NULL,
  problem TEXT NOT NULL,
  generalized_plan JSON NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_clinical_matrix_lookup (module_title, answer_vector_combination),
  KEY idx_clinical_matrix_module (module_title)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO clinical_matrix (
  module_title,
  answer_vector_combination,
  ayurvedic_name,
  root_cause,
  problem,
  generalized_plan
) VALUES
('Prakruthi Analysis', '0-0-0', 'Vata Prakruthi - High Affinity', 'Dry, light, mobile, and cold baseline qualities dominate the structural, metabolic, and cognitive vector.', 'The user is likely to experience variable appetite, lighter sleep, sensitivity to cold, and nervous-system overactivity when routines are unstable.', JSON_ARRAY('Use warm, cooked, lightly oiled meals at regular times.', 'Prefer grounding routines: fixed sleep window, slow breathing, and gentle mobility.', 'Avoid cold drinks, excessive raw foods, late nights, and overstimulation.')),
('Prakruthi Analysis', '0-0-1', 'Vata-Pitta Prakruthi - Vata Led', 'A Vata structural base is supported by sharper metabolic and analytical traits.', 'Dryness and irregularity remain primary, while heat, acidity, or intensity may appear under workload pressure.', JSON_ARRAY('Anchor meals and sleep before adding cooling interventions.', 'Use warm foods with mild cooling herbs such as coriander or fennel.', 'Avoid fasting, excessive caffeine, and high-spice meals during stress.')),
('Prakruthi Analysis', '0-1-0', 'Vata-Pitta Prakruthi - Mobile Cognitive Dominance', 'Vata mobility is reinforced by quick processing and moderate Pitta metabolic drive.', 'The user may alternate between rapid productivity and fatigue, with dry skin, mental pacing, or digestive irregularity.', JSON_ARRAY('Keep consistent hydration and warm meals through the day.', 'Use slow nasal breathing and low-intensity evening routines.', 'Reduce dry snacks, skipped meals, and late-night screen exposure.')),
('Prakruthi Analysis', '1-1-1', 'Pitta Prakruthi - High Affinity', 'Hot, sharp, penetrating, and transformative qualities dominate the baseline vector.', 'The user is likely to show strong digestion, decisive cognition, heat sensitivity, and inflammatory tendency when overloaded.', JSON_ARRAY('Favor cooling foods, bitter greens, coconut water, and moderate meal spice.', 'Schedule work blocks with recovery pauses to prevent intensity stacking.', 'Avoid excessive heat, harsh competition, alcohol, and very spicy meals.')),
('Prakruthi Analysis', '1-1-0', 'Pitta-Vata Prakruthi - Sharp Mobile Pattern', 'Pitta metabolic precision combines with Vata nervous-system speed.', 'The user may show focused drive with rapid depletion, acidity, dry tension, or sleep fragmentation under pressure.', JSON_ARRAY('Use regular meals with cooling, moist, cooked foods.', 'Pair productivity blocks with cooling breathwork and evening decompression.', 'Avoid fasting, overheating, and abrupt sleep schedule changes.')),
('Prakruthi Analysis', '1-0-1', 'Pitta-Vata Prakruthi - Analytical Light-Sleep Pattern', 'Sharp cognition and moderate frame are accompanied by lighter Vata sleep qualities.', 'Heat, irritability, and mental overactivity may appear together during high workload or irregular food timing.', JSON_ARRAY('Eat on time and include soothing fats in moderation.', 'Use cooling routines before sleep and reduce late-night analysis.', 'Avoid hot environments, skipped meals, and excessive stimulants.')),
('Prakruthi Analysis', '2-2-2', 'Kapha Prakruthi - High Affinity', 'Heavy, stable, cool, moist, and cohesive qualities dominate the baseline vector.', 'The user is likely to show endurance, slower metabolic rhythm, heavier sleep, and accumulation tendency when inactive.', JSON_ARRAY('Favor light, warm, dry meals with ginger, black pepper, and legumes.', 'Use daily vigorous movement and early waking when possible.', 'Avoid daytime sleep, heavy dairy, fried foods, and excess sweets.')),
('Prakruthi Analysis', '2-2-1', 'Kapha-Pitta Prakruthi - Stable Metabolic Pattern', 'Kapha structure and moisture combine with moderate Pitta transformation.', 'The user may have strong endurance but can accumulate heaviness, congestion, or heat when diet is dense.', JSON_ARRAY('Use warm, light meals while keeping spice moderate.', 'Maintain cardio and strength movement without overheating.', 'Avoid creamy foods, overeating, and long sedentary periods.')),
('Prakruthi Analysis', '2-1-2', 'Kapha-Pitta Prakruthi - Stable Cognitive Pattern', 'Stable Kapha retention is supported by Pitta organization and metabolic drive.', 'The user may be resilient but prone to inertia, heaviness, or inflammatory stagnation after over-rich meals.', JSON_ARRAY('Use bitter, astringent, and warming foods in balanced portions.', 'Prioritize morning activity and avoid prolonged inactivity.', 'Limit sugar, heavy oils, and late dinners.')),
('Vikruthi Deviances', '0-0-0', 'Vata Vikruthi - Acute Dryness and Irregularity', 'Current symptoms cluster around dry evacuation, cold extremities, low perspiration, anxiety, and interrupted sleep.', 'The active imbalance suggests Vata aggravation affecting digestive motility, tissue moisture, and nervous-system regulation.', JSON_ARRAY('Use warm fluids, cooked meals, sesame oil self-massage, and strict sleep regularity.', 'Reduce raw foods, cold exposure, travel strain, and erratic work patterns.', 'Escalate to a licensed clinician if pain, persistent constipation, or severe insomnia continues.')),
('Vikruthi Deviances', '0-0-1', 'Vata-Kapha Vikruthi - Dryness with Fatigue Overlay', 'Dry Vata markers combine with fatigue and mild Kapha withdrawal patterns.', 'The active state may alternate between anxious activation and heavy exhaustion, often after poor sleep or irregular meals.', JSON_ARRAY('Use warm, moist meals with light digestive spices.', 'Add gentle morning movement and calming evening oil routines.', 'Avoid cold foods, daytime sleep, and long periods without meals.')),
('Vikruthi Deviances', '0-1-0', 'Vata-Pitta Vikruthi - Dry Heat Reactivity', 'Vata irregularity is mixed with Pitta inflammatory skin or heat signs.', 'The user may experience bloating, anxious thought speed, dryness, and episodic heat or irritation.', JSON_ARRAY('Use warm but not spicy meals, with fennel, coriander, and adequate fluids.', 'Practice cooling breathwork after work and grounding routines before bed.', 'Avoid chili-heavy meals, fasting, and late-night stimulation.')),
('Vikruthi Deviances', '1-1-1', 'Pitta Vikruthi - Heat and Inflammatory Load', 'Symptoms cluster around acidity, redness, excessive heat, irritability, and mental exhaustion.', 'The active imbalance suggests Pitta aggravation across digestive acid, skin inflammation, and stress reactivity.', JSON_ARRAY('Favor cooling meals, coconut water, coriander, fennel, and bitter greens.', 'Avoid alcohol, excess spice, midday sun, and high-conflict work periods.', 'Seek licensed care for persistent burning pain, spreading rashes, or fever.')),
('Vikruthi Deviances', '1-1-0', 'Pitta-Vata Vikruthi - Heat with Nervous Activation', 'Pitta heat and acidity combine with Vata anxiety or sleep disruption.', 'The user may cycle between sharp irritability, digestive burning, racing thoughts, and depletion.', JSON_ARRAY('Use regular cooling meals and avoid skipping breakfast or lunch.', 'Schedule decompression breaks and reduce evening heat exposure.', 'Avoid stimulants, intense late workouts, and very spicy foods.')),
('Vikruthi Deviances', '1-0-1', 'Pitta-Kapha Vikruthi - Heat with Congestive Fatigue', 'Inflammatory Pitta signs are accompanied by Kapha heaviness or withdrawal.', 'The active state may present as heat, skin irritation, low drive, and sluggish recovery after heavy foods.', JSON_ARRAY('Use light cooling foods and moderate pungent spices only if acidity is absent.', 'Keep daily movement consistent without overheating.', 'Avoid fried foods, dairy-heavy meals, alcohol, and long sedentary blocks.')),
('Vikruthi Deviances', '2-2-2', 'Kapha Vikruthi - Stagnation and Lethargic Load', 'Symptoms cluster around heavy digestion, clammy skin, congestion, withdrawal, and prolonged fatigue.', 'The active imbalance suggests Kapha accumulation affecting lymphatic movement, digestive speed, and motivational tone.', JSON_ARRAY('Favor warm, dry, light meals with ginger, black pepper, and legumes.', 'Use vigorous morning movement and avoid daytime sleep.', 'Seek licensed care if fatigue, edema, breathing congestion, or depressive symptoms persist.')),
('Vikruthi Deviances', '2-2-1', 'Kapha-Pitta Vikruthi - Congested Heat Pattern', 'Kapha heaviness combines with irritability, heat, or skin reactivity.', 'The user may experience sluggish digestion, sweat pore congestion, fatigue, and inflammatory flare patterns.', JSON_ARRAY('Use light warm meals, bitter vegetables, and controlled spices.', 'Move early in the day and keep evenings light.', 'Avoid creamy foods, fried meals, excess sugar, and overheating.')),
('Vikruthi Deviances', '2-1-2', 'Kapha-Vata Vikruthi - Stagnation with Variable Motility', 'Kapha heaviness is mixed with Vata irregular movement and stress vulnerability.', 'The active state may show bloating, sluggishness, fatigue, and alternating mental restlessness.', JSON_ARRAY('Use warm soups, digestive spices, and regular meal timing.', 'Combine brisk walking with calming breathwork.', 'Avoid cold heavy foods, inactivity, and chaotic sleep timing.'))
ON DUPLICATE KEY UPDATE
  ayurvedic_name = VALUES(ayurvedic_name),
  root_cause = VALUES(root_cause),
  problem = VALUES(problem),
  generalized_plan = VALUES(generalized_plan),
  updated_at = CURRENT_TIMESTAMP;
