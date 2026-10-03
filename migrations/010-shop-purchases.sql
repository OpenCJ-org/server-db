-- Ownership and the price actually paid; challenge points and rank remain unchanged.
-- Catalogue keys must stay stable even if an item is retired or repriced.
CREATE TABLE IF NOT EXISTS shopPurchases (
 playerID INT NOT NULL,
 itemKey VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
 pointsSpent INT UNSIGNED NOT NULL,
 purchasedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (playerID,itemKey)
) ENGINE=InnoDB;
