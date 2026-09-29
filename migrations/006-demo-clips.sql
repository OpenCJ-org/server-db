-- Clip metadata and compressed footage. Run demos remain unchanged.
CREATE TABLE IF NOT EXISTS demoClipSessions (
    sessionID CHAR(36) CHARACTER SET ascii COLLATE ascii_bin PRIMARY KEY,
    heartbeat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS demoClips (
    clipID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    uploadToken CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL UNIQUE,
    mapID INT NOT NULL,
    playerID INT NOT NULL,
    description VARCHAR(16) CHARACTER SET ascii NOT NULL,
    scopeKey VARCHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    sessionID CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NULL,
    slot TINYINT UNSIGNED NOT NULL,
    originX FLOAT NOT NULL, originY FLOAT NOT NULL, originZ FLOAT NOT NULL,
    frameCount INT NOT NULL,
    recordedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ready TINYINT NOT NULL DEFAULT 0,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (slot BETWEEN 1 AND 5),
    CHECK (frameCount BETWEEN 1 AND 1200),
    UNIQUE KEY ownerSlot (playerID,mapID,scopeKey,slot),
    KEY browser (mapID,scopeKey,ready,clipID),
    FOREIGN KEY (mapID) REFERENCES mapids(mapID),
    FOREIGN KEY (playerID) REFERENCES playerInformation(playerID),
    FOREIGN KEY (sessionID) REFERENCES demoClipSessions(sessionID) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS demoClipChunks (
    clipID INT NOT NULL,
    chunkNum INT NOT NULL,
    payload BLOB NOT NULL,
    PRIMARY KEY (clipID,chunkNum),
    FOREIGN KEY (clipID) REFERENCES demoClips(clipID) ON DELETE CASCADE
) ENGINE=InnoDB;
