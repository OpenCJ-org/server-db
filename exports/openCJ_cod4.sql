-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.33-0ubuntu0.20.04.4 - (Ubuntu)
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for openCJ_cod4
CREATE DATABASE IF NOT EXISTS `openCJ_cod4` /*!40100 DEFAULT CHARACTER SET ascii COLLATE ascii_bin */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `openCJ_cod4`;

-- Dumping structure for table openCJ_cod4.checkpointBrothers
CREATE TABLE IF NOT EXISTS `checkpointBrothers` (
  `cpID` int NOT NULL,
  `bigBrotherID` int NOT NULL,
  UNIQUE KEY `cpID` (`cpID`) USING BTREE,
  KEY `bigBrotherID` (`bigBrotherID`) USING BTREE,
  CONSTRAINT `FK__checkpoints` FOREIGN KEY (`cpID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK__checkpoints_2` FOREIGN KEY (`bigBrotherID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.checkpointConnections
CREATE TABLE IF NOT EXISTS `checkpointConnections` (
  `cpID` int NOT NULL,
  `childcpID` int NOT NULL,
  KEY `cpID` (`cpID`),
  KEY `childcpID` (`childcpID`),
  CONSTRAINT `FK__import_checkpoints` FOREIGN KEY (`cpID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK__import_checkpoints_2` FOREIGN KEY (`childcpID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.checkpointPassed
DELIMITER //
CREATE FUNCTION `checkpointPassed`(
	`_runID` INT,
	`_cpID` INT,
	`_timePlayed` INT,
	`_saveCount` INT,
	`_loadCount` INT,
	`_explosiveJumps` INT,
	`_explosiveLaunches` INT,
	`_doubleExplosives` INT,
	`_FPSMode` ENUM('125','mix','hax'),
	`_usedEle` TINYINT,
	`_usedAnyPct` TINYINT,
	`_usedTAS` TINYINT,
	`__instanceNumber` INT
) RETURNS int
BEGIN
	DECLARE _instanceNumber INT DEFAULT NULL;
	SELECT instanceNumber INTO _instanceNumber FROM playerRuns WHERE runID = _runID;
	IF(__instanceNumber = _instanceNumber) THEN
		INSERT INTO checkpointStatistics (cpID, runID, timePlayed, saveCount, loadCount, explosiveJumps, explosiveLaunches, doubleExplosives, FPSMode, ele, anyPct, hardTAS) VALUES
		(_cpID, _runID, _timePlayed, _saveCount, _loadCount, _explosiveJumps, _explosiveLaunches, _doubleExplosives, _FPSMode, _usedEle, _usedAnyPct, _usedTAS) ON DUPLICATE KEY UPDATE
		timePlayed = IF(timePlayed < _timePlayed, _timePlayed, timePlayed),
		saveCount = IF(timePlayed < _timePlayed, _saveCount, saveCount),
		loadCount = IF(timePlayed < _timePlayed, _loadCount, loadCount),
		explosiveJumps = IF(timePlayed < _timePlayed, _explosiveJumps, explosiveJumps),
		explosiveLaunches = IF(timePlayed < _timePlayed, _explosiveLaunches, explosiveLaunches),
		doubleExplosives = IF(timePlayed < _timePlayed, _doubleExplosives, doubleExplosives),
		FPSMode = IF(timePlayed < _timePlayed, _FPSMode, FPSMode),
		ele = IF(timePlayed < _timePlayed, _usedEle, ele),
		anyPct = IF(timePlayed < _timePlayed, _usedAnyPct, anyPct),
		hardTAS = IF(timePlayed < _timePlayed, _usedTAS, hardTAS);
		RETURN _instanceNumber;
	END IF;
	RETURN Null;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.checkpoints
CREATE TABLE IF NOT EXISTS `checkpoints` (
  `cpID` int NOT NULL AUTO_INCREMENT,
  `x` int NOT NULL DEFAULT '0',
  `y` int NOT NULL DEFAULT '0',
  `z` int NOT NULL DEFAULT '0',
  `radius` int DEFAULT '0',
  `onGround` tinyint NOT NULL DEFAULT '0',
  `mapID` int NOT NULL DEFAULT '0',
  `ender` char(64) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `elevate` tinyint NOT NULL DEFAULT '0',
  `endShaderColor` enum('blue','cyan','green','orange','purple','red','yellow') CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  PRIMARY KEY (`cpID`),
  KEY `mapID` (`mapID`),
  KEY `ender` (`ender`),
  CONSTRAINT `FK_import_checkpoints_import_mapids` FOREIGN KEY (`mapID`) REFERENCES `mapids` (`mapID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32375 DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.checkpointStatistics
CREATE TABLE IF NOT EXISTS `checkpointStatistics` (
  `runID` int NOT NULL,
  `cpID` int NOT NULL,
  `timePlayed` int NOT NULL,
  `saveCount` int NOT NULL,
  `loadCount` int NOT NULL,
  `explosiveJumps` int NOT NULL,
  `explosiveLaunches` int NOT NULL,
  `doubleExplosives` int NOT NULL,
  `FPSMode` enum('125','mix','hax') COLLATE ascii_bin NOT NULL DEFAULT 'hax',
  `ele` tinyint NOT NULL DEFAULT '0',
  `anyPct` tinyint NOT NULL DEFAULT '0',
  `hardTAS` tinyint NOT NULL DEFAULT '0',
  UNIQUE KEY `runID_cpID` (`runID`,`cpID`),
  KEY `runID` (`runID`),
  KEY `cpID` (`cpID`),
  KEY `timePlayed` (`timePlayed`),
  KEY `saveCount` (`saveCount`),
  KEY `loadCount` (`loadCount`),
  KEY `RPGJumps` (`explosiveJumps`) USING BTREE,
  KEY `RPGShots` (`explosiveLaunches`) USING BTREE,
  KEY `doubleRPGs` (`doubleExplosives`) USING BTREE,
  KEY `FPSMode` (`FPSMode`),
  KEY `ele` (`ele`),
  KEY `anyPct` (`anyPct`),
  KEY `hardTAS` (`hardTAS`),
  CONSTRAINT `FK_checkpointStatistics_checkpoints` FOREIGN KEY (`cpID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_checkpointStatistics_playerRuns` FOREIGN KEY (`runID`) REFERENCES `playerRuns` (`runID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.createEvent
DELIMITER //
CREATE FUNCTION `createEvent`(
	`_rpg` TINYINT,
	`_saveNum` INT,
	`_loadNum` INT
) RETURNS int
BEGIN
	DECLARE _eventID INT DEFAULT NULL;
	SELECT LAST_INSERT_ID(NULL) INTO _eventID;
	INSERT INTO demoEvents (rpg, saveNum, loadNum) VALUES (_rpg, _saveNum, _loadNum);
	SELECT LAST_INSERT_ID() INTO _eventID;
	RETURN _eventID;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.createNewAccount
DELIMITER //
CREATE FUNCTION `createNewAccount`(
	`_uid1` INT,
	`_uid2` INT,
	`_uid3` INT,
	`_uid4` INT,
	`_playerName` CHAR(64)
) RETURNS int
BEGIN
	DECLARE _playerID INT UNSIGNED DEFAULT NULL;
	DECLARE _rows INT UNSIGNED DEFAULT NULL;
	SELECT LAST_INSERT_ID(NULL) INTO _playerID; 
	INSERT INTO playerInformation (playerName) VALUES (_playerName);
	SELECT LAST_INSERT_ID() INTO _playerID;
	IF(_playerID = 0)
	THEN
		RETURN NULL;
	END IF;
	INSERT IGNORE INTO playerLogin (playerID, uid1, uid2, uid3, uid4) VALUES (_playerID, _uid1, _uid2, _uid3, _uid4);
	SELECT ROW_COUNT() INTO _rows;
	IF(_rows = 0)
	THEN
		DELETE FROM playerInformation WHERE playerID = _playerID;
		RETURN NULL;
	ELSE
		RETURN _playerID;
	END IF;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.createRunID
DELIMITER //
CREATE FUNCTION `createRunID`(
	`_playerID` INT,
	`_mapID` INT
) RETURNS int
BEGIN
	DECLARE _runID INT  DEFAULT NULL;
	SELECT LAST_INSERT_ID(NULL) INTO _runID;
	INSERT INTO playerRuns (playerID, mapID, startTimeStamp) VALUES (_playerID, _mapID, NOW());
	SELECT LAST_INSERT_ID() INTO _runID;
	return _runID;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.createRunInstance
DELIMITER //
CREATE FUNCTION `createRunInstance`(
	`_runID` INT
) RETURNS int
BEGIN
	DECLARE _instanceNumber INT DEFAULT NULL;
	UPDATE playerRuns SET instanceNumber = instanceNumber + 1 WHERE runID = _runID;
	SELECT instanceNumber INTO _instanceNumber FROM playerRuns WHERE runID = _runID;
	RETURN _instanceNumber;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.demoEvents
CREATE TABLE IF NOT EXISTS `demoEvents` (
  `eventID` int NOT NULL AUTO_INCREMENT,
  `rpg` tinyint DEFAULT NULL,
  `saveNum` int DEFAULT NULL,
  `loadNum` int DEFAULT NULL,
  PRIMARY KEY (`eventID`),
  KEY `saveNum` (`saveNum`),
  KEY `loadNum` (`loadNum`)
) ENGINE=InnoDB AUTO_INCREMENT=4840 DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.geoIP
CREATE TABLE IF NOT EXISTS `geoIP` (
  `ip` int unsigned NOT NULL,
  `country` char(2) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.getCountry
DELIMITER //
CREATE FUNCTION `getCountry`(
	`_ip` INT UNSIGNED
) RETURNS char(130) CHARSET ascii COLLATE ascii_bin
BEGIN
	DECLARE _country CHAR(2) DEFAULT 'UK';
	DECLARE _longCountry CHAR(128) DEFAULT 'Unknown';
	SELECT country INTO _country FROM geoIP WHERE ip < _ip ORDER BY ip DESC LIMIT 1;
	SELECT longCountry INTO _longCountry FROM longCountry WHERE country = _country;
	RETURN CONCAT(_country, _longCountry);
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.getIgnoredBy
DELIMITER //
CREATE FUNCTION `getIgnoredBy`(
	`_playerID` INT
) RETURNS varchar(1024) CHARSET ascii COLLATE ascii_bin
BEGIN
	DECLARE _ignoredBy VARCHAR(1024) DEFAULT NULL;
	SELECT GROUP_CONCAT(ignoreID) INTO _ignoredBy FROM playerIgnore WHERE playerID = _playerID;
	RETURN _ignoredBy;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.getMapID
DELIMITER //
CREATE FUNCTION `getMapID`(
	`_mapname` CHAR(128)
) RETURNS char(128) CHARSET ascii COLLATE ascii_bin
BEGIN
	DECLARE _mapid INT DEFAULT NULL;
	INSERT IGNORE INTO mapids (mapname) VALUES (_mapname);
	SELECT mapid INTO _mapid FROM mapids WHERE mapname = _mapname;
	RETURN _mapid;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.getPlayerID
DELIMITER //
CREATE FUNCTION `getPlayerID`(
	`_uid1` INT,
	`_uid2` INT,
	`_uid3` INT,
	`_uid4` INT
) RETURNS int
BEGIN
	DECLARE _playerID INT DEFAULT NULL;
	SELECT playerID INTO _playerID FROM playerLogin WHERE uid1 = _uid1 AND uid2 = _uid2 AND uid3 = _uid3 AND uid4 = _uid4;
	RETURN _playerID;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.historyLoad
DELIMITER //
CREATE FUNCTION `historyLoad`(
	`_mapID` INT,
	`_playerID` INT,
	`_runID` INT
) RETURNS int
BEGIN
	DECLARE _rows INT DEFAULT NULL;
	DECLARE _instanceNumber INT DEFAULT NULL;
	UPDATE playerRuns SET instanceNumber = instanceNumber + 1 WHERE runID = _runID AND playerID = _playerID AND mapID = _mapID AND finishcpID IS NULL AND finishTimeStamp IS NULL;
	SELECT ROW_COUNT() INTO _rows;
	IF(_rows = 0)
	THEN
		RETURN NULL;
	ELSE
		SELECT instanceNumber INTO _instanceNumber FROM playerRuns WHERE runID = _runID;
		RETURN _instanceNumber;
	END IF;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.longCountry
CREATE TABLE IF NOT EXISTS `longCountry` (
  `country` char(2) COLLATE ascii_bin NOT NULL,
  `longCountry` varchar(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'Unknown',
  `continent` char(2) COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `country` (`country`),
  KEY `continent` (`continent`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.mapids
CREATE TABLE IF NOT EXISTS `mapids` (
  `mapID` int NOT NULL AUTO_INCREMENT,
  `mapname` char(128) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `releaseDate` date DEFAULT NULL,
  `inRotation` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`mapID`),
  UNIQUE KEY `mapname` (`mapname`),
  KEY `releaseDate` (`releaseDate`),
  KEY `inRotation` (`inRotation`)
) ENGINE=InnoDB AUTO_INCREMENT=3967 DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.mapMappers
CREATE TABLE IF NOT EXISTS `mapMappers` (
  `mapID` int NOT NULL,
  `mapperID` int NOT NULL,
  UNIQUE KEY `mapID_mapperID` (`mapID`,`mapperID`) USING BTREE,
  KEY `mapID` (`mapID`) USING BTREE,
  KEY `mapperID` (`mapperID`) USING BTREE,
  CONSTRAINT `FK_mapMappers_mapids` FOREIGN KEY (`mapID`) REFERENCES `mapids` (`mapID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mapMappers_mappers` FOREIGN KEY (`mapperID`) REFERENCES `mappers` (`mapperID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.mappers
CREATE TABLE IF NOT EXISTS `mappers` (
  `mapperID` int NOT NULL AUTO_INCREMENT,
  `name` char(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`mapperID`) USING BTREE,
  UNIQUE KEY `name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=443 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.messages
CREATE TABLE IF NOT EXISTS `messages` (
  `messageID` int NOT NULL AUTO_INCREMENT,
  `playerID` int NOT NULL,
  `message` varchar(1024) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  `server` char(50) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`messageID`) USING BTREE,
  KEY `playerID` (`playerID`) USING BTREE,
  KEY `server` (`server`) USING BTREE,
  CONSTRAINT `FK_messages_playerInformation` FOREIGN KEY (`playerID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4943 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerIgnore
CREATE TABLE IF NOT EXISTS `playerIgnore` (
  `playerID` int NOT NULL,
  `ignoreID` int NOT NULL,
  UNIQUE KEY `playerID_ignoreID` (`playerID`,`ignoreID`) USING BTREE,
  KEY `playerID` (`playerID`) USING BTREE,
  KEY `ignoreID` (`ignoreID`) USING BTREE,
  CONSTRAINT `FK__playerInformation_ignore` FOREIGN KEY (`playerID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_playerIgnore_playerInformation` FOREIGN KEY (`ignoreID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerInformation
CREATE TABLE IF NOT EXISTS `playerInformation` (
  `playerID` int NOT NULL AUTO_INCREMENT,
  `playerName` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  `adminLevel` int unsigned NOT NULL DEFAULT '0',
  `mutedUntil` datetime DEFAULT NULL,
  PRIMARY KEY (`playerID`),
  KEY `playerName` (`playerName`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerLogin
CREATE TABLE IF NOT EXISTS `playerLogin` (
  `playerID` int NOT NULL,
  `uid1` int NOT NULL,
  `uid2` int NOT NULL,
  `uid3` int NOT NULL,
  `uid4` int NOT NULL,
  UNIQUE KEY `uid1_uid2_uid3_uid4` (`uid1`,`uid2`,`uid3`,`uid4`),
  KEY `playerID` (`playerID`),
  CONSTRAINT `FK_playerLogin_playerInformation` FOREIGN KEY (`playerID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerRecordings
CREATE TABLE IF NOT EXISTS `playerRecordings` (
  `runID` int NOT NULL,
  `instanceID` int NOT NULL,
  `frameNum` int NOT NULL,
  `x` float NOT NULL DEFAULT '0',
  `y` float NOT NULL DEFAULT '0',
  `z` float NOT NULL DEFAULT '0',
  `a` smallint unsigned NOT NULL DEFAULT '0',
  `b` smallint unsigned NOT NULL DEFAULT '0',
  `c` smallint unsigned NOT NULL DEFAULT '0',
  `flags` smallint unsigned NOT NULL DEFAULT '0',
  `isKeyFrame` int NOT NULL DEFAULT '0',
  `eventID` int DEFAULT NULL,
  `frameTime` tinyint unsigned NOT NULL DEFAULT '1',
  UNIQUE KEY `runID_frameNum` (`runID`,`frameNum`),
  KEY `instanceID` (`instanceID`),
  KEY `isKeyFrame` (`isKeyFrame`),
  KEY `eventID` (`eventID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerRuns
CREATE TABLE IF NOT EXISTS `playerRuns` (
  `runID` int NOT NULL AUTO_INCREMENT,
  `playerID` int NOT NULL,
  `mapID` int NOT NULL,
  `finishcpID` int DEFAULT NULL,
  `runLabel` char(64) COLLATE ascii_bin NOT NULL DEFAULT '',
  `archived` bit(1) NOT NULL DEFAULT b'0',
  `timePlayed` int NOT NULL DEFAULT '0',
  `saveCount` int NOT NULL DEFAULT '0',
  `loadCount` int NOT NULL DEFAULT '0',
  `explosiveLaunches` int NOT NULL DEFAULT '0',
  `instanceNumber` int NOT NULL DEFAULT '0',
  `lastParsed` int NOT NULL DEFAULT '0',
  `startTimeStamp` timestamp NOT NULL DEFAULT '2023-08-08 13:22:00',
  `finishTimeStamp` timestamp NULL DEFAULT NULL,
  `lastUsedTimeStamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`runID`),
  KEY `playerID` (`playerID`),
  KEY `mapID` (`mapID`),
  KEY `finishcpID` (`finishcpID`),
  KEY `instanceID` (`instanceNumber`) USING BTREE,
  KEY `parsed` (`lastParsed`) USING BTREE,
  KEY `timePlayed` (`timePlayed`),
  KEY `saveCount` (`saveCount`),
  KEY `loadCount` (`loadCount`),
  KEY `explosiveLaunches` (`explosiveLaunches`),
  KEY `finishTimeStamp` (`finishTimeStamp`),
  KEY `archived` (`archived`) USING BTREE,
  KEY `runLabel` (`runLabel`),
  KEY `startTimeStamp` (`startTimeStamp`),
  KEY `lastUsedTimeStamp` (`lastUsedTimeStamp`),
  CONSTRAINT `FK__playerInformation` FOREIGN KEY (`playerID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_playerRuns_openCJ_cod4.checkpoints` FOREIGN KEY (`finishcpID`) REFERENCES `checkpoints` (`cpID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_playerRuns_openCJ_cod4.mapids` FOREIGN KEY (`mapID`) REFERENCES `mapids` (`mapID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3258 DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerSaves
CREATE TABLE IF NOT EXISTS `playerSaves` (
  `runID` int NOT NULL,
  `saveNumber` int NOT NULL,
  `x` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `y` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `z` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `alpha` int NOT NULL,
  `beta` int NOT NULL,
  `gamma` int NOT NULL,
  `explosiveJumps` int NOT NULL,
  `doubleExplosives` int NOT NULL,
  `checkpointID` int DEFAULT NULL,
  `flags` int NOT NULL,
  `entTargetName` varchar(50) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `numOfEnt` int DEFAULT NULL,
  `FPSMode` enum('125','mix','hax') CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'hax',
  UNIQUE KEY `runID_saveNumber` (`runID`,`saveNumber`),
  KEY `runID` (`runID`),
  KEY `saveNumber` (`saveNumber`),
  CONSTRAINT `FK_playerSaves_playerRuns` FOREIGN KEY (`runID`) REFERENCES `playerRuns` (`runID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerSaves_test
CREATE TABLE IF NOT EXISTS `playerSaves_test` (
  `runID` int NOT NULL,
  `saveNumber` int NOT NULL,
  `x` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `y` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `z` decimal(10,4) NOT NULL DEFAULT '0.0000',
  `alpha` int NOT NULL,
  `beta` int NOT NULL,
  `gamma` int NOT NULL,
  `explosiveJumps` int NOT NULL,
  `doubleExplosives` int NOT NULL,
  `checkpointID` int DEFAULT NULL,
  `flags` int NOT NULL,
  `entTargetName` varchar(50) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `numOfEnt` int DEFAULT NULL,
  `FPSMode` enum('125','mix','hax') CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'hax',
  UNIQUE KEY `runID_saveNumber` (`runID`,`saveNumber`) USING BTREE,
  KEY `runID` (`runID`) USING BTREE,
  KEY `saveNumber` (`saveNumber`) USING BTREE,
  CONSTRAINT `playerSaves_test_ibfk_1` FOREIGN KEY (`runID`) REFERENCES `playerRuns` (`runID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin ROW_FORMAT=DYNAMIC;

-- Data exporting was unselected.

-- Dumping structure for table openCJ_cod4.playerSettings
CREATE TABLE IF NOT EXISTS `playerSettings` (
  `playerID` int NOT NULL,
  `settingID` int NOT NULL,
  `value` varchar(256) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  UNIQUE KEY `playerID_settingID` (`playerID`,`settingID`),
  KEY `value` (`value`),
  KEY `FK_playerSettings_settings` (`settingID`),
  CONSTRAINT `FK_playerSettings_playerInformation` FOREIGN KEY (`playerID`) REFERENCES `playerInformation` (`playerID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_playerSettings_settings` FOREIGN KEY (`settingID`) REFERENCES `settings` (`settingID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin COMMENT='Stores the configured (non-default) settings of players';

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.prepareAllDemos
DELIMITER //
CREATE FUNCTION `prepareAllDemos`() RETURNS int
BEGIN
	DECLARE _done INT DEFAULT FALSE;
	DECLARE _foobar INT DEFAULT NULL;
	DECLARE _runID INT DEFAULT NULL;
	DECLARE _cursor CURSOR FOR SELECT pr.runID FROM playerRuns pr INNER JOIN (SELECT MAX(frameNum) frame, runID FROM playerRecordings GROUP BY runID) mx ON mx.runID = pr.runID WHERE pr.finishcpID IS NOT NULL AND (pr.lastParsed IS NULL OR pr.lastParsed != mx.frame);

	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _done = TRUE;
	OPEN _cursor;
	read_loop: LOOP
		FETCH _cursor INTO _runID;
		IF _done THEN
			LEAVE read_loop;
		END IF;
		SELECT prepareDemo(_runID) INTO _foobar;
	END LOOP read_loop;
	CLOSE _cursor;
	RETURN 0;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.prepareDemo
DELIMITER //
CREATE FUNCTION `prepareDemo`(
	`_runID` INT
) RETURNS int
BEGIN
	DECLARE _done INT DEFAULT FALSE;
	DECLARE _keySaveNum INT DEFAULT NULL;
	DECLARE _saveNum INT DEFAULT NULL;
	DECLARE _frameNum INT DEFAULT NULL;
	DECLARE _loadNum INT DEFAULT NULL;
	DECLARE _lastParsed INT DEFAULT NULL;
	DECLARE _lastFrame INT DEFAULT NULL;
	DECLARE _cursor CURSOR FOR SELECT pr.frameNum, ev.saveNum, ev.loadNum FROM playerRecordings pr LEFT JOIN demoEvents ev ON pr.eventID = ev.eventID WHERE runID = _runID ORDER BY frameNum DESC;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET _done = TRUE;

	SELECT lastParsed INTO _lastParsed FROM playerRuns WHERE finishcpID IS NOT NULL AND runID = _runID;
	SELECT MAX(frameNum) INTO _lastFrame FROM playerRecordings WHERE runID = _runID;
	IF _lastParsed IS NULL THEN
		RETURN 1;
	ELSEIF _lastParsed = _lastFrame THEN
		RETURN 2;
	END IF;

	OPEN _cursor;
	read_loop: LOOP
		FETCH _cursor INTO _frameNum, _saveNum, _loadNum;
		IF _done THEN
			LEAVE read_loop;
		END IF;
		IF _keySaveNum IS NOT NULL AND (_saveNum IS NOT NULL AND _saveNum = _keySaveNum) THEN
			SELECT NULL INTO _keySaveNum;
			UPDATE playerRecordings SET isKeyFrame = 0 WHERE frameNum = _frameNum AND runID = _runID;
		ELSEIF _keySaveNum IS NULL THEN
			UPDATE playerRecordings SET isKeyFrame = 1 WHERE frameNum = _frameNum AND runID = _runID;
		ELSE
			UPDATE playerRecordings SET isKeyFrame = 0 WHERE frameNum = _frameNum AND runID = _runID;
		END IF;
		IF _keySaveNum IS NULL AND _loadNum IS NOT NULL THEN
			SET _keySaveNum = _loadNum;
		END IF;
	END LOOP read_loop;
	CLOSE _cursor;
	UPDATE playerRuns SET lastParsed = _lastFrame WHERE runID = _runID;
	RETURN 0;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.routes
CREATE TABLE IF NOT EXISTS `routes` (
  `cpID` int NOT NULL,
  `routeName` varchar(50) COLLATE ascii_bin DEFAULT NULL,
  `routeType` enum('normal','bonus','secret') CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT 'normal',
  `difficulty` tinyint DEFAULT NULL COMMENT '0-10',
  `routeShaderColor` enum('blue','cyan','green','orange','purple','red','yellow') CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  UNIQUE KEY `cpID` (`cpID`),
  KEY `difficulty` (`difficulty`),
  KEY `routeType` (`routeType`),
  KEY `routeName` (`routeName`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.runFinished
DELIMITER //
CREATE FUNCTION `runFinished`(
	`_runID` INT,
	`_cpID` INT,
	`_instanceNumber` INT
) RETURNS int
BEGIN
	DECLARE _rows INT DEFAULT NULL;
	UPDATE playerRuns SET finishcpID = _cpID, finishTimeStamp = NOW() WHERE finishcpID IS NULL AND runID = _runID AND instanceNumber = _instanceNumber;
	SET _rows = ROW_COUNT();
	IF _rows > 0 THEN
		RETURN _instanceNumber;
	END IF;
	RETURN NULL;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.runLabels
CREATE TABLE IF NOT EXISTS `runLabels` (
  `runID` int NOT NULL,
  `runLabel` char(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (`runID`),
  KEY `label` (`runLabel`) USING BTREE,
  CONSTRAINT `FK_runLabels_playerRuns` FOREIGN KEY (`runID`) REFERENCES `playerRuns` (`runID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin;

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.savePosition
DELIMITER //
CREATE FUNCTION `savePosition`(
	`_runID` INT,
	`_instanceNumber` INT,
	`_x` DECIMAL(10,4),
	`_y` DECIMAL(10,4),
	`_z` DECIMAL(10,4),
	`_alpha` INT,
	`_beta` INT,
	`_gamma` INT,
	`_timePlayed` INT,
	`_saveCount` INT,
	`_loadCount` INT,
	`_explosiveLaunches` INT,
	`_explosiveJumps` INT,
	`_doubleExplosives` INT,
	`_checkpointID` INT,
	`_FPSMode` ENUM('125','mix', 'hax'),
	`_flags` INT,
	`_entTargetName` CHAR(64),
	`_numOfEnt` INT
) RETURNS int
BEGIN
	DECLARE _rows INT DEFAULT NULL;
	DECLARE _saveNumber INT DEFAULT NULL;
	UPDATE playerRuns SET timePlayed = _timePlayed, saveCount = _saveCount, loadCount = _loadCount, explosiveLaunches = _explosiveLaunches WHERE runID = _runID AND instanceNumber = _instanceNumber;
	SET _rows = ROW_COUNT();
	IF _rows > 0 THEN
		SELECT MAX(saveNumber) + 1 INTO _saveNumber FROM playerSaves WHERE runID = _runID;
		IF _saveNumber IS NULL THEN
			SET _saveNumber = 0;
		END IF;
		INSERT INTO playerSaves (saveNumber, runID, x, y, z, alpha, beta, gamma, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, entTargetName, numOfEnt) VALUES (_saveNumber, _runID, _x, _y, _z, _alpha, _beta, _gamma, _explosiveJumps, _doubleExplosives, _checkpointID, _FPSMode, _flags, _entTargetName, _numOfEnt);
		RETURN _instanceNumber;
	ELSE
		RETURN NULL;
	END IF;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.savePosition_test
DELIMITER //
CREATE FUNCTION `savePosition_test`(
	`_runID` INT,
	`_instanceNumber` INT,
	`_x` DECIMAL(10,4),
	`_y` DECIMAL(10,4),
	`_z` DECIMAL(10,4),
	`_alpha` INT,
	`_beta` INT,
	`_gamma` INT,
	`_timePlayed` INT,
	`_saveCount` INT,
	`_loadCount` INT,
	`_explosiveLaunches` INT,
	`_explosiveJumps` INT,
	`_doubleExplosives` INT,
	`_checkpointID` INT,
	`_FPSMode` ENUM('125','mix', 'hax'),
	`_flags` INT,
	`_entTargetName` CHAR(64),
	`_numOfEnt` INT
) RETURNS int
BEGIN
	DECLARE _rows INT DEFAULT NULL;
	DECLARE _saveNumber INT DEFAULT NULL;
	UPDATE playerRuns SET timePlayed = _timePlayed, saveCount = _saveCount, loadCount = _loadCount, explosiveLaunches = _explosiveLaunches WHERE runID = _runID AND instanceNumber = _instanceNumber;
	SET _rows = ROW_COUNT();
	IF _rows > 0 THEN
		SELECT MAX(saveNumber) + 1 INTO _saveNumber FROM playerSaves_test WHERE runID = _runID;
		IF _saveNumber IS NULL THEN
			SET _saveNumber = 0;
		END IF;
		INSERT INTO playerSaves_test (saveNumber, runID, x, y, z, alpha, beta, gamma, explosiveJumps, doubleExplosives, checkpointID, FPSMode, flags, entTargetName, numOfEnt) VALUES (_saveNumber, _runID, _x, _y, _z, _alpha, _beta, _gamma, _explosiveJumps, _doubleExplosives, _checkpointID, _FPSMode, _flags, _entTargetName, _numOfEnt);
		RETURN _instanceNumber;
	ELSE
		RETURN NULL;
	END IF;
END//
DELIMITER ;

-- Dumping structure for function openCJ_cod4.saveRun
DELIMITER //
CREATE FUNCTION `saveRun`(
	`_runID` INT,
	`_instanceNumber` INT,
	`_runLabel` CHAR(64)
) RETURNS int
    MODIFIES SQL DATA
    COMMENT 'Allow user to save their run with an optional runlabel'
BEGIN
	DECLARE __runID INT DEFAULT NULL;
	SELECT runID INTO __runID FROM playerRuns WHERE runID = _runID AND instanceNumber = _instanceNumber;
	IF(__runID IS NOT NULL) THEN
		INSERT IGNORE INTO runLabels (runID, runLabel) VALUES (__runID, _runLabel) ON DUPLICATE KEY UPDATE runLabel = _runLabel;
	END IF;
	RETURN __runID;
END//
DELIMITER ;

-- Dumping structure for procedure openCJ_cod4.setMapInfo
DELIMITER //
CREATE PROCEDURE `setMapInfo`(
	IN `_mapname` CHAR(128),
	IN `_mapper1` CHAR(128),
	IN `_mapper2` CHAR(128),
	IN `_mapper3` CHAR(128),
	IN `_releaseDate` DATE
)
BEGIN
	DECLARE _mapper1ID INT DEFAULT NULL;
	DECLARE _mapper2ID INT DEFAULT NULL;
	DECLARE _mapper3ID INT DEFAULT NULL;
	DECLARE _mapID INT DEFAULT NULL;
	SELECT getMapID(_mapname) INTO _mapID;
	IF(_mapper1 IS NOT NULL) THEN
		INSERT IGNORE INTO mappers (`name`) VALUES (_mapper1);
		SELECT mapperID INTO _mapper1ID FROM mappers WHERE `name` = _mapper1;
		INSERT IGNORE INTO mapMappers (mapID, mapperID) VALUES (_mapID, _mapper1ID);
	END IF;
	IF(_mapper2 IS NOT NULL) THEN
		INSERT IGNORE INTO mappers (`name`) VALUES (_mapper2);
		SELECT mapperID INTO _mapper1ID FROM mappers WHERE `name` = _mapper2;
		INSERT IGNORE INTO mapMappers (mapID, mapperID) VALUES (_mapID, _mapper2ID);
	END IF;
	IF(_mapper3 IS NOT NULL) THEN
		INSERT IGNORE INTO mappers (`name`) VALUES (_mapper3);
		SELECT mapperID INTO _mapper1ID FROM mappers WHERE `name` = _mapper3;
		INSERT IGNORE INTO mapMappers (mapID, mapperID) VALUES (_mapID, _mapper1ID);
	END IF;
	IF(_releaseDate IS NOT NULL) THEN
		UPDATE mapids SET releaseDate = _releaseDate WHERE mapID = _mapID;
	END IF;
END//
DELIMITER ;

-- Dumping structure for procedure openCJ_cod4.setName
DELIMITER //
CREATE PROCEDURE `setName`(
	IN `_playerID` INT,
	IN `_playerName` CHAR(64)
)
BEGIN
	UPDATE playerInformation SET playerName = _playerName WHERE playerID = _playerID;
END//
DELIMITER ;

-- Dumping structure for procedure openCJ_cod4.setPlayerSetting
DELIMITER //
CREATE PROCEDURE `setPlayerSetting`(
	IN `_playerID` INT,
	IN `_setting` VARCHAR(256),
	IN `_value` VARCHAR(256)
)
BEGIN
	DECLARE _settingID INT DEFAULT NULL;
	INSERT IGNORE INTO settings (settingName) VALUES (_setting);
	SELECT settingID INTO _settingID FROM settings WHERE settingName = _setting;
	IF _settingID IS NOT NULL THEN
		REPLACE INTO playerSettings (playerID, settingID, `value`) VALUES (_playerID, _settingID, _value);
	END IF;
END//
DELIMITER ;

-- Dumping structure for table openCJ_cod4.settings
CREATE TABLE IF NOT EXISTS `settings` (
  `settingID` int NOT NULL AUTO_INCREMENT,
  `settingName` varchar(256) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '',
  PRIMARY KEY (`settingID`),
  UNIQUE KEY `settingName` (`settingName`)
) ENGINE=InnoDB AUTO_INCREMENT=7904 DEFAULT CHARSET=ascii COLLATE=ascii_bin COMMENT='List of setting ids and names';

-- Data exporting was unselected.

-- Dumping structure for function openCJ_cod4.storeDemoFrame
DELIMITER //
CREATE FUNCTION `storeDemoFrame`(
	`_runID` INT,
	`_instanceID` INT,
	`_frameNum` INT,
	`_x` INT,
	`_y` INT,
	`_z` INT,
	`_a` INT,
	`_b` INT,
	`_c` INT,
	`_flags` INT,
	`_eventID` INT,
	`_frameTime` INT
) RETURNS tinyint
BEGIN
	DECLARE _affectedRows INT DEFAULT NULL;
	INSERT INTO playerRecordings (runID, instanceID, frameNum, `x`, `y`, `z`, a, b, c, flags, eventID, frameTime) VALUES (_runID, _instanceID, _frameNum, _x, _y, _z, _a, _b, _c, _flags, _eventID, _frameTime) ON DUPLICATE KEY UPDATE instanceID = IF(instanceID <= _instanceID, VALUES(instanceID), instanceID), `x` = IF(instanceID <= _instanceID, VALUES(`x`), `x`),  `y` = IF(instanceID <= _instanceID, VALUES(`y`), `y`),  `z` = IF(instanceID <= _instanceID, VALUES(`z`), `z`),  a = IF(instanceID <= _instanceID, VALUES(a), a),   b = IF(instanceID <= _instanceID, VALUES(b), b),   c = IF(instanceID <= _instanceID, VALUES(c), c),   flags = IF(instanceID <= _instanceID, VALUES(flags), flags), eventID = IF(instanceID <= _instanceID, VALUES(eventID), eventID), frameTime = IF(instanceID <= _instanceID, VALUES(frameTime), frameTime); 
	SELECT ROW_COUNT() INTO _affectedRows;
	RETURN _affectedRows; #is 2 if on duplicate kye, 0 if nothing affected (=nothing inserted, =instanceID has been upped)
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
