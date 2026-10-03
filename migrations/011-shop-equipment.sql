-- Serialize purchases per account, including purchases made on different servers.
CREATE TABLE IF NOT EXISTS shopAccounts (playerID INT NOT NULL PRIMARY KEY) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS shopCatalog (
 itemKey VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
 category TINYINT UNSIGNED NOT NULL,
 slot VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 price INT UNSIGNED NOT NULL,
 available BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS shopEquipped (
 playerID INT NOT NULL,
 category TINYINT UNSIGNED NOT NULL,
 slot VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 itemKey VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 PRIMARY KEY(playerID,slot),
 FOREIGN KEY(playerID,itemKey) REFERENCES shopPurchases(playerID,itemKey)
) ENGINE=InnoDB;
DROP PROCEDURE IF EXISTS shopBuyOrEquip;
DELIMITER //
CREATE PROCEDURE shopBuyOrEquip(IN accountID INT, IN requestedKey VARCHAR(64), IN equipOnly BOOLEAN, IN quotedPrice INT)
shop: BEGIN
 DECLARE lockedID INT;
 DECLARE itemPrice INT DEFAULT NULL;
 DECLARE itemCategory INT;
 DECLARE itemSlot VARCHAR(64);
 DECLARE enabled BOOLEAN;
 DECLARE earned BIGINT DEFAULT 0;
 DECLARE spent BIGINT DEFAULT 0;
 DECLARE owned BOOLEAN DEFAULT FALSE;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SELECT 'error'; END;
 IF NOT EXISTS(SELECT 1 FROM playerInformation WHERE playerID=accountID) THEN SELECT 'account'; LEAVE shop; END IF;
 START TRANSACTION;
 INSERT INTO shopAccounts(playerID) VALUES(accountID) ON DUPLICATE KEY UPDATE playerID=VALUES(playerID);
 SELECT playerID INTO lockedID FROM shopAccounts WHERE playerID=accountID FOR UPDATE;
 SELECT price,category,slot,available INTO itemPrice,itemCategory,itemSlot,enabled FROM shopCatalog WHERE itemKey=requestedKey LOCK IN SHARE MODE;
 IF itemPrice IS NULL THEN ROLLBACK; SELECT 'unavailable'; LEAVE shop; END IF;
 SELECT EXISTS(SELECT 1 FROM shopPurchases WHERE playerID=accountID AND itemKey=requestedKey) INTO owned;
 IF equipOnly AND NOT owned THEN ROLLBACK; SELECT 'not_owned'; LEAVE shop; END IF;
 IF NOT equipOnly THEN
  IF owned THEN ROLLBACK; SELECT 'owned'; LEAVE shop; END IF;
  IF NOT enabled THEN ROLLBACK; SELECT 'unavailable'; LEAVE shop; END IF;
  IF itemPrice<>quotedPrice THEN ROLLBACK; SELECT 'price_changed'; LEAVE shop; END IF;
  SELECT COALESCE(SUM(c.points),0) INTO earned FROM challengeCompletions a JOIN challenges c ON c.challengeKey=a.challengeKey AND c.active=1 WHERE a.playerID=accountID;
  SELECT COALESCE(SUM(pointsSpent),0) INTO spent FROM shopPurchases WHERE playerID=accountID;
  IF earned-spent<itemPrice THEN ROLLBACK; SELECT 'balance'; LEAVE shop; END IF;
  INSERT INTO shopPurchases(playerID,itemKey,pointsSpent) VALUES(accountID,requestedKey,itemPrice);
 END IF;
 INSERT INTO shopEquipped(playerID,category,slot,itemKey) VALUES(accountID,itemCategory,itemSlot,requestedKey) ON DUPLICATE KEY UPDATE itemKey=VALUES(itemKey);
 COMMIT;
 SELECT 'ok';
END//
DELIMITER ;
