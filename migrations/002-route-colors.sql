-- One exact RGB color per route, anchored to its first checkpoint.
ALTER TABLE routes ADD COLUMN colorRGB MEDIUMINT UNSIGNED DEFAULT NULL;

-- Existing editor routes retain their name-based default until explicitly edited.
INSERT INTO routes (cpID, routeName, colorRGB)
SELECT cpID, routeName, CASE LOWER(routeName)
    WHEN 'easy' THEN 65280 WHEN 'inter' THEN 16776960
    WHEN 'inter+' THEN 16746496 WHEN 'hard' THEN 16742263
    WHEN 'hard+' THEN 11141120 WHEN 'adv' THEN 11163135
    WHEN 'advanced' THEN 11163135 WHEN 'adv+' THEN 16742348
    WHEN 'advanced+' THEN 16742348 ELSE 52479 END
FROM checkpointAreas WHERE ordinal = 0
ON DUPLICATE KEY UPDATE colorRGB = COALESCE(routes.colorRGB, VALUES(colorRGB));
