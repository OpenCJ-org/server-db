-- Run once against the OpenCJ database. Existing routes retain their colors.
CREATE TABLE checkpointSectionColors (
    mapID INT NOT NULL,
    sectionName VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
    colorRGB INT UNSIGNED NOT NULL,
    PRIMARY KEY (mapID, sectionName),
    FOREIGN KEY (mapID) REFERENCES mapids(mapID)
) ENGINE=InnoDB;
ALTER TABLE checkpointAreas ADD COLUMN sectionName VARCHAR(20) CHARACTER SET ascii COLLATE ascii_bin NULL;
