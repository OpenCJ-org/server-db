-- Optional CoD4 stationary landing areas. Existing radius checkpoints are untouched.
CREATE TABLE IF NOT EXISTS checkpointAreas (
    cpID INT NOT NULL PRIMARY KEY,
    mapID INT NOT NULL,
    routeName VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    ordinal INT NOT NULL,
    vertices VARCHAR(512) CHARACTER SET ascii NOT NULL,
    allowDoubleRPG TINYINT NOT NULL DEFAULT 0,
    UNIQUE KEY routeCheckpoint (mapID, routeName, ordinal),
    FOREIGN KEY (cpID) REFERENCES checkpoints(cpID),
    FOREIGN KEY (mapID) REFERENCES mapids(mapID)
) ENGINE=InnoDB;
