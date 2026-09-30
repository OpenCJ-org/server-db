-- Existing checkpoints retain normal saving behavior. Apply to each game database.
ALTER TABLE checkpoints ADD COLUMN allowSave TINYINT NOT NULL DEFAULT 1;
