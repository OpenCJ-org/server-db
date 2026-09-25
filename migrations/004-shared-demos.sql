-- Compressed demo payloads shared by all game servers. No per-frame SQL rows.
CREATE TABLE IF NOT EXISTS demoRuns (
    runID INT NOT NULL PRIMARY KEY,
    mapID INT NOT NULL,
    routeName VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    FPSMode ENUM('125','mix','hax') NOT NULL,
    modeMask TINYINT UNSIGNED NOT NULL,
    timePlayed INT NOT NULL,
    explosiveJumps INT NOT NULL,
    frameCount INT NOT NULL,
    ready TINYINT NOT NULL DEFAULT 0,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (runID) REFERENCES playerRuns(runID),
    FOREIGN KEY (mapID) REFERENCES mapids(mapID)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS demoChunks (
    runID INT NOT NULL,
    chunkNum INT NOT NULL,
    payload BLOB NOT NULL,
    PRIMARY KEY (runID,chunkNum),
    FOREIGN KEY (runID) REFERENCES demoRuns(runID) ON DELETE CASCADE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS demoWinners (
    mapID INT NOT NULL,
    routeName VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    FPSMode ENUM('125','mix','hax') NOT NULL,
    modeMask TINYINT UNSIGNED NOT NULL,
    kind ENUM('speedrun','lowrpg','walkthrough') NOT NULL,
    runID INT NOT NULL,
    PRIMARY KEY (mapID,routeName,FPSMode,modeMask,kind),
    FOREIGN KEY (runID) REFERENCES demoRuns(runID)
) ENGINE=InnoDB;
