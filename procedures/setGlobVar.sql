CREATE DEFINER=`root`@`localhost` PROCEDURE `setGlobVar`(IN whereClause varchar(255), IN whereClause_WFA varchar(255), IN whereClause_track varchar(255), IN whereClause_dow varchar(255), IN horsmastUsed INT(1), IN num_result INT(11))
BEGIN

SET @whereClause  = whereClause;
SET @whereClause_WFA = whereClause_WFA;
SET @whereClause_track = whereClause_track;
SET @whereClause_dow = whereClause_dow;
SET @num_result = num_result;

IF horsmastUsed = 1 THEN
    SET @horsmastUsed = "INNER JOIN `scv`.`horsmast` H ON H.H_HORSE = W.W_HORSE";
ELSE
    SET @horsmastUsed = "";
END IF;

IF LENGTH(whereClause_WFA) > 0 THEN
    call preCond_WFA();
    SET @WFAUsed = "INNER JOIN `scv_report`.`temp_WFA` WFA ON W.W_HORSE = WFA.WFA_HORSE AND W.W_DATE = WFA.WFA_DATE AND W.W_TRACK = WFA.WFA_TRACK AND W.W_RACE_NO = WFA.WFA_RACE_NO";
ELSE
    SET @WFAUsed = "";
END IF;

IF LENGTH(whereClause_track) > 0  THEN
    call preCond_track();
    SET @TRACKUsed = "INNER JOIN `scv_report`.`temp_track` T ON W.W_HORSE = T.T_HORSE AND W.W_DATE = T.T_DATE AND W.W_TRACK = T.T_TRACK AND W.W_RACE_NO = T.T_RACE_NO";
ELSE
    SET @TRACKUsed = "";
END IF;

IF LENGTH(whereClause_dow) > 0 THEN
    -- call preCond_dow();
    SET @DOWUsed = "INNER JOIN `scv_report`.`temp_dow` D ON W.W_HORSE = D.D_HORSE AND W.W_DATE = D.D_DATE AND W.W_TRACK = D.D_TRACK AND W.W_RACE_NO = D.D_RACE_NO";
ELSE
    SET @DOWUsed = "";
END IF;

END