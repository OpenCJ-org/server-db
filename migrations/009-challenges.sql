-- Challenge definitions are maintained by opencj/challenges.gsc. Awards survive definition edits.
CREATE TABLE IF NOT EXISTS challenges (
 challengeKey VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
 tier TINYINT UNSIGNED NOT NULL,
 points SMALLINT UNSIGNED NOT NULL,
 mapName VARCHAR(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 routeLabel VARCHAR(64) NOT NULL,
 routeName VARCHAR(64) DEFAULT NULL,
 maxTimeMs INT UNSIGNED NOT NULL DEFAULT 0,
 maxRPG INT NOT NULL DEFAULT -1,
 allowedModes TINYINT UNSIGNED NOT NULL DEFAULT 0,
 requiredModes TINYINT UNSIGNED NOT NULL DEFAULT 0,
 fpsModes VARCHAR(16) NOT NULL DEFAULT '125,mix',
 active TINYINT NOT NULL DEFAULT 1,
 KEY map_route (mapName,routeName)
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS challengeCompletions (
 playerID INT NOT NULL,
 challengeKey VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 runID INT DEFAULT NULL,
 completedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY(playerID,challengeKey),
 KEY challenge_players(challengeKey,playerID)
) ENGINE=InnoDB;
