-- Match the finish snapshot consumed by the CoD4 leaderboard and GSC caller.
ALTER TABLE playerRuns
    ADD COLUMN FPSMode ENUM('125','mix','hax') NOT NULL DEFAULT 'hax',
    ADD COLUMN ele TINYINT NOT NULL DEFAULT 0,
    ADD COLUMN anyPct TINYINT NOT NULL DEFAULT 0,
    ADD COLUMN hb TINYINT NOT NULL DEFAULT 1,
    ADD COLUMN hardTAS TINYINT NOT NULL DEFAULT 0;

-- Preserve known historical categories. Old records have no halfbeat snapshot;
-- conservatively keep them out of the no-halfbeat category.
UPDATE playerRuns r JOIN checkpointStatistics s
    ON s.runID=r.runID AND s.cpID=r.finishcpID
SET r.FPSMode=s.FPSMode, r.ele=s.ele, r.anyPct=s.anyPct, r.hardTAS=s.hardTAS;

DROP FUNCTION IF EXISTS runFinished;
DELIMITER //
CREATE FUNCTION runFinished(
    _runID INT, _cpID INT, _FPSMode VARCHAR(3), _usedEle TINYINT,
    _usedAnyPct TINYINT, _allowHb TINYINT, _usedTAS TINYINT, _instanceNumber INT
) RETURNS INT
MODIFIES SQL DATA
BEGIN
    UPDATE playerRuns r JOIN checkpointStatistics s ON s.runID=r.runID AND s.cpID=_cpID
    SET r.finishcpID=_cpID, r.finishTimeStamp=NOW(), r.FPSMode=_FPSMode,
        r.ele=_usedEle, r.anyPct=_usedAnyPct, r.hb=_allowHb, r.hardTAS=_usedTAS
    WHERE r.finishcpID IS NULL AND r.runID=_runID AND r.instanceNumber=_instanceNumber;
    IF ROW_COUNT() > 0 THEN
        RETURN _instanceNumber;
    END IF;
    RETURN NULL;
END//
DELIMITER ;
