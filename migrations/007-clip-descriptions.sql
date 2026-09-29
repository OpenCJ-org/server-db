-- Widen existing names without modifying clip metadata or footage.
ALTER TABLE demoClips MODIFY description VARCHAR(32) CHARACTER SET ascii NOT NULL;
