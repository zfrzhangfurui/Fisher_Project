DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `horse_1000`()
BEGIN

DROP TABLE IF EXISTS `scv`.`temp_horsnameT`, `scv`.`temp_horsname`, `scv`.`temp_filtered_all`;


SET  @query_hname = CONCAT("
SELECT 
W.W_HORSE,
W.W_DATE,
W.W_TRACK,
W.W_RACE_NO,"
" ", @reportCol, ", ",
" ", @SAME, " "

"FROM",
    " ", @table_joins_preCond, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ", 
    " ", @TRACKUsed, " ", 
    " ", @DOWUsed, " ", 
    " ", @MAGINUsed, " ",
 
    " ", @whereClause, " ",
    
    "ORDER BY W.W_DATE DESC"
    
);

SET @stmt_text=CONCAT("CREATE TABLE `scv`.`temp_filtered_all` ", @query_hname); 


PREPARE stmt FROM @stmt_text; 
EXECUTE stmt; 
DEALLOCATE PREPARE stmt; 

CREATE TABLE `scv`.`temp_horsnameT`
SELECT 
W_HORSE AS W1_HORSE,
W_DATE AS W1_DATE,
W_TRACK AS W1_TRACK,
W_RACE_NO AS W1_RACE_NO,
W_HORSE AS REPORT,
W_HORSE AS SAME
FROM
`scv`.`workrace`
LIMIT 0;


SELECT COUNT(DISTINCT(REPORT)) INTO @num_report FROM scv.temp_filtered_all;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);

BEGIN
DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE num_result INT(11);
DECLARE horsename varchar(24);
DECLARE reportCol varchar(24);
DECLARE sameCol varchar(24);

DECLARE cur1 CURSOR FOR SELECT * FROM `scv`.`temp_filtered_all`; 

SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';

OPEN cur1;
SELECT FOUND_ROWS() into @row_num;
horse_1000: LOOP
FETCH cur1 INTO horsename, wdate, track, raceNo, reportCol, sameCol;
SET @cnt = @cnt + 1;



IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
		/** New Approach - Select Any */
		IF @dayPreStart >= 36500 THEN
			SET @temp_PreDate = wdate;
		ELSE 
			SELECT MAX(W_DATE) INTO @temp_PreDate FROM scv.workrace WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
		END IF;
        
		IF @temp_PreDate IS NOT NULL AND DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart THEN
			IF @daysBet >= 36500 THEN
				SET @temp_lastRunDate = wdate;
			ELSE
				SELECT MAX(W_DATE) INTO @temp_lastRunDate FROM scv.temp_filtered_all WHERE (W_DATE < wdate AND W_HORSE = horsename AND SAME = sameCol) OR (W_DATE = wdate AND W_HORSE = horsename AND SAME = sameCol AND W_RACE_NO <> raceNo);
			END IF;
               
			IF @temp_lastRunDate IS NOT NULL AND DATEDIFF(wdate, @temp_lastRunDate) <= @daysBet THEN
				SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',wdate,'"', ',', '"',track,'"' , ',', raceNo, ',', '"', reportCol, '"', ',', '"', sameCol, '"', '),');
				SET @_cnt = @_cnt + 1;
			END IF;
		END IF;
		/** New Approach - Select Any */
    
    SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');

    SET @ins_query = CONCAT('INSERT INTO `scv`.`temp_horsnameT`(`W1_HORSE`, `W1_DATE`,`W1_TRACK`, `W1_RACE_NO`, `REPORT`, `SAME`) VALUES', @v_values);
    PREPARE STMT FROM @ins_query;
    EXECUTE STMT;
    DEALLOCATE PREPARE STMT;

    SET @v_values = '';
    SET @ins_query = '';
    SET @_cnt = 0;
-- SET num_result  = @num_result;
IF (@cnt <= 100000) THEN
SELECT COUNT(*) INTO @temp_result
FROM
(
SELECT T1.REPORT
FROM 
scv.temp_horsnameT AS T1
INNER JOIN 
(
SELECT W1_HORSE
FROM scv.temp_horsnameT 
GROUP BY W1_HORSE 
HAVING  COUNT(*) >= @least_run -- AND DATEDIFF(MAX(W1_DATE), MIN(W1_DATE) ) <= @daysBet 
) AS T2
ON T1.W1_HORSE = T2.W1_HORSE
INNER JOIN
(
SELECT DISTINCT(W1_HORSE) AS W1_HORSE
FROM
(SELECT W1_HORSE
FROM scv.temp_horsnameT
GROUP BY W1_HORSE, SAME
HAVING COUNT(DISTINCT(REPORT)) >= 2
) AS _sub
) AS T3
ON T2.W1_HORSE = T3.W1_HORSE
WHERE 1
GROUP BY T1.REPORT, T1.W1_HORSE
HAVING COUNT(*) >= @num_result
) AS sub;
END IF;        
 
    IF (@temp_result >= @num_report) THEN
        LEAVE horse_1000;
    END IF;
    
ELSE 
		/** New Approach - Select Any */
		IF @dayPreStart >= 36500 THEN
			SET @temp_PreDate = wdate;
		ELSE 
			SELECT MAX(W_DATE) INTO @temp_PreDate FROM scv.workrace WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
		END IF;
        
		IF @temp_PreDate IS NOT NULL AND DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart THEN
			IF @daysBet >= 36500 THEN
				SET @temp_lastRunDate = wdate;
			ELSE
				SELECT MAX(W_DATE) INTO @temp_lastRunDate FROM scv.temp_filtered_all WHERE (W_DATE < wdate AND W_HORSE = horsename AND SAME = sameCol) OR (W_DATE = wdate AND W_HORSE = horsename AND SAME = sameCol AND W_RACE_NO <> raceNo);
			END IF;
               
			IF @temp_lastRunDate IS NOT NULL AND DATEDIFF(wdate, @temp_lastRunDate) <= @daysBet THEN
				SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',wdate,'"', ',', '"',track,'"' , ',', raceNo, ',', '"', reportCol, '"', ',', '"', sameCol, '"', '),');
				SET @_cnt = @_cnt + 1;
			END IF;
		END IF;
		/** New Approach - Select Any */
		
    /** Current Approach - Select a number*/
    
    /** Current Approach - Select a number*/
END IF;

IF @cnt = @row_num THEN LEAVE horse_1000; END IF;
END LOOP;
CLOSE cur1;



ALTER TABLE `scv`.`temp_horsnameT`
ADD INDEX `idx_tp_hname_w1_date_track_raceNo` (`W1_HORSE` ASC, `SAME` ASC);

ALTER TABLE `scv`.`temp_horsnameT`
ADD INDEX `idx_tp_hname_w1_horse` (`REPORT` ASC);

-- ALTER TABLE `scv`.`temp_horsnameT`
-- ADD INDEX `idx_tp_hname_w1_report` (`REPORT` ASC);


CREATE TABLE scv.temp_horsname
SELECT S1.W1_HORSE, S1.W1_DATE, S1.W1_TRACK, S1.W1_RACE_NO, S1.REPORT, S1.SAME
FROM
(
SELECT T1.W1_HORSE, T1.W1_DATE, T1.W1_TRACK, T1.W1_RACE_NO, T1.REPORT, T1.SAME
FROM
scv.temp_horsnameT AS T1
INNER JOIN 
(
SELECT W1_HORSE
FROM scv.temp_horsnameT 
GROUP BY W1_HORSE 
HAVING  COUNT(*) >= @least_run -- AND DATEDIFF(MAX(W1_DATE), MIN(W1_DATE) ) <= @daysBet 
) AS T2
ON T1.W1_HORSE = T2.W1_HORSE
INNER JOIN
(
SELECT DISTINCT(W1_HORSE) AS W1_HORSE
FROM(
SELECT W1_HORSE
FROM scv.temp_horsnameT
GROUP BY W1_HORSE, SAME
HAVING COUNT(DISTINCT(REPORT)) >= 2
) AS _t3 
) AS T3
ON T1.W1_HORSE = T3.W1_HORSE
) AS S1;
-- LEFT JOIN
-- (
-- SELECT W1_HORSE, SAME
-- FROM scv.temp_horsnameT
-- GROUP BY W1_HORSE, SAME
-- HAVING COUNT(DISTINCT(REPORT)) < 2
-- ) AS S2
-- ON S1.W1_HORSE = S2.W1_HORSE  AND S1.SAME = S2.SAME
-- WHERE S2.W1_HORSE IS NULL; 


ALTER TABLE `scv`.`temp_horsname`
ADD INDEX `idx_tp_hname_w1_horse_date_track_raceNo` (`W1_HORSE` ASC, `W1_DATE` ASC, `W1_TRACK` ASC, `W1_RACE_NO` ASC);

END;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `horse_1000_old`()
BEGIN


SET  @query_hname = CONCAT("
CREATE TABLE scv.temp_horsname
SELECT W.W_HORSE AS W1_HORSE
        FROM 
    meetmast M
        INNER JOIN
    racemast R ON M.M_DATE = R.R_DATE
        AND M.M_TRACK = R.R_TRACK
        INNER JOIN
    workrace W ON R.R_DATE = W.W_DATE
        AND R.R_TRACK = W.W_TRACK 
        AND R.R_RACE_NO = W.W_RACE_NO",

    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ", 
    " ", @TRACKUsed, " ", 
    " ", @DOWUsed, " ", 
    " ", @MAGINUsed, " ",
 
    " ", @whereClause, " ",
    "GROUP BY W_HORSE HAVING COUNT(W_HORSE) >= ",
    " ", @least_run, " ",
    "ORDER BY W_DATE DESC LIMIT ", @num_result
    
    );

DROP TABLE IF EXISTS scv.temp_horsname;
PREPARE STMT_HNAME FROM @query_hname;
EXECUTE STMT_HNAME; 
DEALLOCATE PREPARE STMT_HNAME;

ALTER TABLE `scv`.`temp_horsname` 
ADD INDEX `idx_tp_hname_w1_horse` (`W1_HORSE` ASC);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_magin`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE beat_mar varchar(6);
DECLARE fin_pos INT(11);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE sec_mar varchar(6);

DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BEAT_MAR, W_FIN_POS FROM temp_filtered_all;

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BEAT_MAR, W.W_FIN_POS

FROM",
    
    " ", @table_joins_preCond, " ",
	" ", @horsmastUsed, " ",
	
        @whereClause
);

DROP TABLE IF EXISTS `scv`.`temp_filtered_all`;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_magin`
SELECT W_HORSE AS MA_HORSE, W_DATE AS MA_DATE, W_TRACK AS MA_TRACK, W_RACE_NO AS MA_RACE_NO, W_BEAT_MAR AS MAGIN FROM temp_filtered_all limit 0;
SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
pre_cond_track : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, beat_mar, fin_pos;
SET @cnt = @cnt + 1;

IF beat_mar = 'WON' THEN
SELECT W_BEAT_MAR INTO beat_mar FROM workrace  WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
END IF;

IF (LENGTH(@whereClause_magin) > 0 AND FIND_IN_SET(beat_mar, @whereClause_magin)) OR  (LENGTH(@whereClause_magin) = 0 AND (@SAME LIKE '%MA.MAGIN%' OR @reportCol LIKE '%MA.MAGIN%') ) THEN
    SET @_cnt = @_cnt + 1;
    SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', wdate, '"', ',', '"', track, '"', ',', raceNo, ',', '"', beat_mar,'"', '),');
END IF;

IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
    SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');
         IF @v_values <> ';' THEN
            SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_magin`(`MA_HORSE`, `MA_DATE`, `MA_TRACK`, `MA_RACE_NO`, `MAGIN`) VALUES', @v_values);
            PREPARE STMT FROM @ins_query;
            EXECUTE STMT; 
            DEALLOCATE PREPARE STMT;
         END IF;
         SET @v_values = '';
	     SET @ins_query = '';
END IF;


IF @cnt = @row_num THEN 
    LEAVE pre_cond_track;
END IF;

END LOOP pre_cond_track;
CLOSE work_race_all;

ALTER TABLE `scv_report`.`temp_magin`
ADD INDEX `idx_tp_mar_t_horse` (`MA_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_magin`
ADD INDEX `idx_tp_mar_t_date_track_race` (`MA_DATE` ASC, `MA_TRACK` ASC, `MA_RACE_NO` ASC);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `create_result_tables`()
BEGIN

DROP TABLE IF EXISTS scv_report.temp_result_all, scv_report.temp_result_valid,scv_report.temp_result;

ALTER TABLE `scv_report`.`temp_AvgRating`
ADD INDEX `idx_avg_rate` (`HR_HORSE` ASC, `HR_SAME` ASC, `HR_REPORT` ASC);


CREATE TABLE scv_report.temp_result_all
SELECT T1.HR_SAME,  T1.HR_HORSE,
T1.HR_REPORT AS REPORT1,  T1.AVG_RATING AS RATING1, T1.cnt AS cnt1,
T2.HR_REPORT AS REPORT2, T2.AVG_RATING AS RATING2, T2.cnt AS cnt2,
T1.AVG_RATING - T2.AVG_RATING AS DIFF_AVG,
T1.MAX_RATING - T2.MAX_RATING AS DIFF_MAX
FROM
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T1
INNER JOIN
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T2
ON T1.HR_HORSE = T2.HR_HORSE AND T1.HR_SAME = T2.HR_SAME AND T1.HR_REPORT <> T2.HR_REPORT;

ALTER TABLE `scv_report`.`temp_result_all`
ADD INDEX `idx_avg_rate` (`HR_SAME` ASC, `REPORT1` ASC, `REPORT2` ASC);

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------
CREATE TABLE scv_report.temp_result_valid
SELECT *
FROM
(
SELECT T1.HR_SAME, -- T1.HR_HORSE,
T1.HR_REPORT AS REPORT1, -- T1.AVG_RATING AS RATING1, T1.cnt AS cnt1,
T2.HR_REPORT AS REPORT2 -- T2.AVG_RATING AS RATING2, T2.cnt AS cnt2,
-- T1.AVG_RATING - T2.AVG_RATING AS DIFF_AVG
FROM
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T1
INNER JOIN
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T2
ON T1.HR_HORSE = T2.HR_HORSE AND T1.HR_SAME = T2.HR_SAME AND T1.HR_REPORT <> T2.HR_REPORT
WHERE 1
GROUP BY T1.HR_SAME, T1.HR_REPORT, T2.HR_REPORT
HAVING COUNT(*) > 1

) AS SUB1;

ALTER TABLE `scv_report`.`temp_result_valid`
ADD INDEX `idx_avg_rate` (`HR_SAME` ASC, `REPORT1` ASC, `REPORT2` ASC);

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------

CREATE TABLE scv_report.temp_result_diff
SELECT 
T2.HR_SAME,  T2.HR_HORSE,
T2.REPORT1,  T2.RATING1, T2.cnt1,
T2.REPORT2, T2.RATING2, T2.cnt2,
T2.DIFF_AVG,
T2.DIFF_MAX
FROM
scv_report.temp_result_valid T1
INNER JOIN 
scv_report.temp_result_all  T2
 ON
T1.HR_SAME = T2.HR_SAME  AND T1.REPORT1 = T2.REPORT1 AND T1.REPORT2 = T2.REPORT2;


ALTER TABLE `scv_report`.`temp_result_diff`
ADD INDEX `idx_avg_rate` (`HR_SAME` ASC, `REPORT1` ASC, `REPORT2` ASC);

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------
CREATE TABLE scv_report.temp_result
SELECT 
CONCAT(T1.REPORT1, ', ', T1.REPORT2) AS DIFF, 
CAST(AVG(T1.AV) AS DECIMAL(5,1)) AS DIFF_AVG, 
CAST(AVG(T1.MA) AS DECIMAL(5,1)) AS DIFF_MAX,
T2.HORSE_CNT,
CONCAT(T3.CNT1, ' / ', T3.CNT2) AS RACE_CNT
FROM 
(
SELECT HR_SAME, REPORT1, REPORT2, 
AVG(DIFF_AVG) AS AV,
AVG(DIFF_MAX) AS MA
FROM scv_report.temp_result_diff
GROUP BY HR_SAME, REPORT1, REPORT2
) AS T1
INNER JOIN
(
SELECT REPORT1, REPORT2, COUNT(DISTINCT(HR_HORSE)) AS HORSE_CNT
FROM 
scv_report.temp_result_diff
GROUP BY REPORT1, REPORT2
) AS T2
ON T1.REPORT1 = T2.REPORT1 AND T1.REPORT2 = T2.REPORT2
INNER JOIN
(
SELECT REPORT1, REPORT2, SUM(cnt1) AS CNT1, SUM(cnt2) AS CNT2 FROM scv_report.temp_result_diff GROUP BY REPORT1,REPORT2
) AS T3
ON T3.REPORT1 = T2.REPORT1 AND T3.REPORT2 = T2.REPORT2
GROUP BY T1.REPORT1, T1.REPORT2;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_DOW`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);

DECLARE track_abbr varchar(4);
DECLARE track_state varchar(4);
DECLARE prisemoney DECIMAL(7,1);

DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK,M_STATE, W_RACE_NO, W_HORSE, T_CAT, R_VALUE FROM temp_filtered_all;

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS,IF(R.R_VALUE >= 2,T.T_CAT,'N') AS T_CAT, R.R_VALUE

FROM",

    " ", @table_joins_preCond, " ",
	" ", @horsmastUsed, " ",

        "INNER JOIN
            trackabbr T ON T.T_ABBR = M.M_TRACK
        AND T.STATE = M.M_STATE ", 
	
        @whereClause
);

DROP TABLE IF EXISTS `scv`.`temp_filtered_all`;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_dow`
SELECT W_HORSE AS D_HORSE, W_DATE AS D_DATE, W_TRACK AS D_TRACK, W_RACE_NO AS D_RACE_NO, W_HORSE AS DOW FROM temp_filtered_all limit 0;
SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
pre_cond_track : LOOP
FETCH work_race_all INTO wdate, track, track_state, raceNo, horsename, track_abbr, prisemoney;
SET @year_race = date_format( str_to_date( wdate, '%Y-%m-%d' ), '%Y' );
SET @cnt = @cnt + 1;

SET @DOW = track_abbr;
IF(track_abbr = 'P' OR track_abbr = 'C' OR track_abbr = 'M') THEN
    SELECT PRISE INTO @prise_dow FROM scv.dow WHERE `STATE` = track_state AND `YEAR` = @year_race;
    IF prisemoney >= @prise_dow THEN 
        SET @DOW = 'Sat';
    ELSE 
        SET @DOW = 'Mid Week';
    END IF;
ELSE
    SET @DOW = 'Mid Week';
END IF;

/** Error Check */
IF horsename IS NULL OR @DOW IS NULL THEN
	SELECT "NULL VALUE FOUND" AS `Error`, horsename, @DOW;
	LEAVE pre_cond_track;
END IF;
IF (LENGTH(@whereClause_dow) > 0 AND FIND_IN_SET(@DOW, @whereClause_dow)) OR  (LENGTH(@whereClause_dow) = 0 AND (@SAME LIKE '%D.DOW%' OR @reportCol LIKE '%D.DOW%') ) THEN
    SET @_cnt = @_cnt + 1;
    SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', wdate, '"', ',', '"', track, '"', ',', raceNo, ',', '"', @DOW,'"', '),');
END IF;

IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
    SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');
         IF @v_values <> ';' THEN
            SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_dow`(`D_HORSE`, `D_DATE`, `D_TRACK`, `D_RACE_NO`, `DOW`) VALUES', @v_values);
            PREPARE STMT FROM @ins_query;
            EXECUTE STMT; 
            DEALLOCATE PREPARE STMT;
         END IF;
         SET @v_values = '';
	     SET @ins_query = '';
END IF;


IF @cnt = @row_num THEN 
    LEAVE pre_cond_track;
END IF;

END LOOP pre_cond_track;
CLOSE work_race_all;

ALTER TABLE `scv_report`.`temp_dow`
ADD INDEX `idx_tp_dow_d_horse` (`D_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_dow`
ADD INDEX `idx_tp_dow_d_date_track_race` (`D_DATE` ASC, `D_TRACK` ASC, `D_RACE_NO` ASC);


END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_WFA`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE CWT DECIMAL(4,1);
DECLARE sex varchar(24);

DECLARE dist varchar(11);
DECLARE age_now INT(11);
DECLARE cnt INT(11);

DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_WGHT_CAR, R_DISTANCE, H_WIN_AGE, R_SEX FROM temp_filtered_all;


SET @query_all = CONCAT("
CREATE TABLE `scv`.`temp_filtered_all` 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_WGHT_CAR, R.R_DISTANCE, W.W_BEAT_MAR, W.W_FIN_POS, H.H_WIN_AGE, R.R_SEX

FROM",
    
    " ", @table_joins_preCond, " ",
    " ", @horsmastUsed, " ", 

    " ", @whereClause, " "
);


DROP TABLE IF EXISTS `scv`.`temp_filtered_all`, `scv_report`.`temp_WFA`;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;


ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_WFA`
SELECT W_HORSE AS WFA_HORSE, W_DATE AS WFA_DATE, W_TRACK AS WFA_TRACK, W_RACE_NO AS WFA_RACE_NO, W_HORSE AS HWD FROM temp_filtered_all LIMIT 0;


SET @year_now = date_format(str_to_date( NOW(), '%Y-%m-%d %H:%i:%s' ) , '%Y' );
SET @WFA = NULL;
SET @allowance = 0;
SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, CWT, dist, age_now, sex;
        SET @cnt = @cnt + 1;
		IF age_now <> 0 THEN
        SET @year_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%Y' );
        SET @month_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%m' );
        SET @date_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%d' );
        
        IF dist LIKE '%A' THEN
			SET dist = LEFT(dist, LENGTH(dist)-1);
        END IF;
        IF dist < 1000 THEN
			SET dist = 1000;
		END IF;
            
         IF dist%200 <> 0 THEN
           SET dist = FLOOR(dist/200) * 200 + 200;
		END IF;

        IF @month_race >= 8 THEN
           SET @age_race = @year_race - @year_now + age_now  + 1;
        ELSE
           SET @age_race = @year_race - @year_now + age_now; 
        END IF;
        
        IF @age_race >= 6 THEN
            SET @age_race = '6+';
        END IF;

        IF @date_race <= 15 THEN
            SET @date_race = 0;
        ELSE
            SET @date_race = 1;
        END IF;
        
        IF wdate < '1990-08-01' THEN
            SELECT `1.8.77` into @WFA FROM scv.WFA WHERE DISTANCE = dist AND AGE = @age_race AND `MONTH` = @month_race AND `DATE` = @date_race;
        ELSEIF wdate >= '1990-08-01' AND wdate < '2007-01-01' THEN
            SELECT `1.8.98` into @WFA FROM scv.WFA WHERE DISTANCE = dist AND AGE = @age_race AND `MONTH` = @month_race AND `DATE` = @date_race;
        ELSE
            SELECT `1.1.07` into @WFA FROM scv.WFA WHERE DISTANCE = dist AND AGE = @age_race AND `MONTH` = @month_race AND `DATE` = @date_race;
        END IF;
        
        IF(sex = 'F' OR sex = 'M' OR sex = 'FM') THEN
            IF wdate >= '1977-08-01' AND wdate < '1998-08-01'  THEN
                SELECT `1.8.77` into @allowance FROM scv.WFA_allowance WHERE `MONTH` = @month_race;
            ELSEIF wdate >= '1998-08-01' AND wdate < '2007-01-01' THEN
                SELECT `1.8.98` into @allowance FROM scv.WFA_allowance WHERE `MONTH` = @month_race;
            ELSE
                SELECT `1.1.07` into @allowance FROM scv.WFA_allowance WHERE `MONTH` = @month_race;
            END IF;    
        ELSE 
            SET @allowance = 0;
        END IF;
        SET @WFA = @WFA - @allowance;


        IF wdate >= '1999-12-01' THEN
            SET CWT = CWT + 1;
            SET @WFA = @WFA + 1;
        END IF;
        
        /** Error Check */
        IF horsename IS NULL OR CWT IS NULL OR @WFA IS NULL THEN
            SELECT "NULL VALUE FOUND" AS `Error`, CWT, @WFA;
            LEAVE loop_race;
        END IF;
        
        
        SET @HWD = CAST(@WFA - CWT AS DECIMAL(5,1));
        IF (LENGTH(@whereClause_WFA) > 0 AND FIND_IN_SET(@HWD, @whereClause_WFA)) OR  (LENGTH(@whereClause_WFA) = 0 AND @SAME LIKE '%WFA.HWD%') OR (LENGTH(@whereClause_WFA) = 0 AND @reportCol LIKE '%WFA.HWD%')THEN
       
			SET @_cnt = @_cnt + 1;
			SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', wdate, '"', ',', '"', track, '"', ',', raceNo, ',',  '"', @HWD, '"', '),');
        END IF;
        
         IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
             SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');
			 IF @v_values <> ';' THEN
				SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_WFA`(`WFA_HORSE`, `WFA_DATE`, `WFA_TRACK`, `WFA_RACE_NO`, `HWD`) VALUES ', @v_values);
                PREPARE STMT FROM @ins_query;
				EXECUTE STMT; 
				DEALLOCATE PREPARE STMT;
			 END IF;
		    
             SET @v_values = '';
             SET @ins_query = '';
         END IF;
        
        /** leave loop */
        IF @cnt = @row_num THEN 
            LEAVE loop_race;
        END IF;
        
        ELSEIF @cnt = @row_num THEN 
			 LEAVE loop_race;
        END IF;
        

END LOOP loop_race; 
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_WFA`
ADD INDEX `idx_tp_dow_wfa_horse` (`WFA_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_WFA`
ADD INDEX `idx_tp_dow_wfa_date_track_race` (`WFA_DATE` ASC, `WFA_TRACK` ASC, `WFA_RACE_NO` ASC);



END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_track`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);

DECLARE track_abbr varchar(4);
DECLARE track_state varchar(4);

DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK,M_STATE, W_RACE_NO, W_HORSE, T_CAT FROM temp_filtered_all;

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS,  

(CASE        WHEN T.T_CAT IS NULL THEN M.M_MET_TYPE
             WHEN T.T_CAT IS NOT NULL AND R.R_VALUE  >= 2 THEN   T.T_CAT
             WHEN T.T_CAT IS NOT NULL AND R.R_VALUE < 2   THEN   'N'  
END) AS T_CAT
       
FROM",
    
    " ", @table_joins_preCond, " ",
	" ", @horsmastUsed, " ",

        "LEFT JOIN
            trackabbr T ON T.T_ABBR = M.M_TRACK
        AND T.STATE = M.M_STATE ", 
	
        @whereClause
);

DROP TABLE IF EXISTS `scv`.`temp_filtered_all`, `scv_report`.`temp_track`;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_track`
SELECT W_HORSE AS T_HORSE, W_DATE AS T_DATE, W_TRACK AS T_TRACK, W_RACE_NO AS T_RACE_NO, T_CAT AS TRACK FROM temp_filtered_all limit 0;
SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
pre_cond_track : LOOP
FETCH work_race_all INTO wdate, track, track_state, raceNo, horsename, track_abbr;
SET @cnt = @cnt + 1;


IF (LENGTH(@whereClause_track) > 0 AND FIND_IN_SET(track_abbr, @whereClause_track)) OR  (LENGTH(@whereClause_track) = 0 AND (@SAME LIKE '%T.TRACK%' OR @reportCol LIKE '%T.TRACK%') ) THEN
    SET @_cnt = @_cnt + 1;
    SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', wdate, '"', ',', '"', track, '"', ',', raceNo, ',', '"', track_abbr,'"', '),');
END IF;

IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
    SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');
         IF @v_values <> ';' THEN
            SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_track`(`T_HORSE`, `T_DATE`, `T_TRACK`, `T_RACE_NO`, `TRACK`) VALUES', @v_values);
            PREPARE STMT FROM @ins_query;
            EXECUTE STMT; 
            DEALLOCATE PREPARE STMT;
         END IF;
         SET @v_values = '';
	     SET @ins_query = '';
END IF;


IF @cnt = @row_num THEN 
    LEAVE pre_cond_track;
END IF;

END LOOP pre_cond_track;
CLOSE work_race_all;

ALTER TABLE `scv_report`.`temp_track`
ADD INDEX `idx_tp_track_t_horse` (`T_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_track`
ADD INDEX `idx_tp_track_t_date_track_race` (`T_DATE` ASC, `T_TRACK` ASC, `T_RACE_NO` ASC);

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_DOW`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE same_col varchar(24);

DECLARE vDOW varchar(24);
DECLARE rating DECIMAL(5,1);
DECLARE sec_mar varchar(6);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, DOW, A_RATE, SAME FROM temp_valid_filtered;

call horse_1000();        

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, D.DOW,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME ",

"FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",
    
        " INNER JOIN
		alg_rating A ON A.A_FIN_POS = W.W_FIN_POS"
        
    --    @whereClause
        );



DROP TABLE IF EXISTS scv.temp_valid_filtered;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, W_HORSE AS HR_DOW, A_RATE AS HR_RATE FROM temp_valid_filtered limit 0;
SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, vDOW, rating, same_col;
SET @year_race = date_format( str_to_date( wdate, '%Y-%m-%d' ), '%Y' );

/** Error Check 
        IF horsename IS NULL OR track_abbr IS NULL OR @DOW IS NULL OR rating IS NULL OR @same IS NULL THEN
                SELECT "NULL VALUE FOUND" AS `Error`, horsename, track_abbr, @DOW, rating, @same;
                LEAVE get_rating;
        END IF;
*/
        
IF rating = 1200.0 THEN
SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;


IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"',',', '"',vDOW,'"', ',', rating,',','"', same_col, '"', ' );');
SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`,  `HR_DOW`, `HR_RATE`, `HR_SAME`) VALUES', @v_values);
PREPARE STMT FROM @ins_query;
EXECUTE STMT; -- USING @v_values;
    

SET @v_values = '';
SET @ins_query = '';

ELSE 

     SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"',',', '"',vDOW,'"', ',', rating,',','"', same_col, '"', ' ),');
END IF;



IF @cnt = @row_num THEN LEAVE get_rating;
END IF;
END LOOP get_rating;
CLOSE work_race_all;
DEALLOCATE PREPARE STMT;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_dow` (`HR_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);


CREATE TABLE `scv_report`.`temp_AvgRating` 
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_DOW AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_DOW
ORDER BY HR_SAME, HR_DOW, HR_HORSE;


END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_WFA`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE vHWD DECIMAL(4,1);
DECLARE sex varchar(24);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);

DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, HWD, A_RATE, SAME FROM temp_valid_filtered;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BEAT_MAR, W.W_FIN_POS, WFA.HWD,
     
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,

     W1.SAME ", 
     
"FROM",
    
    " ", @table_joins, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",

        "INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS "
        
        -- @whereClause

);


DROP TABLE IF EXISTS temp_valid_filtered;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, HWD AS HR_HWD, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;


SET @year_now = date_format(str_to_date( NOW(), '%Y-%m-%d %H:%i:%s' ) , '%Y' );
SET @WFA = NULL;
SET @allowance = 0;
SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, vHWD, rating, same_col;
		IF rating = 1200.0 THEN
			SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
			AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
			SET rating = 200 + sec_mar * 30 + @BaseRating;
		END IF;
        SET @cnt = @cnt + 1;
        
        /** Error Check */
        IF horsename IS NULL OR vHWD IS NULL OR rating IS NULL THEN
                SELECT "NULL VALUE FOUND" AS `Error`, vHWD, rating;
                LEAVE loop_race;
        END IF;
            
        IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
             SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', vHWD, '"', ',', rating,',','"', same_col, '"', ' );');
             SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_HWD`, `HR_RATE`, `HR_SAME`) VALUES ', @v_values);
             PREPARE STMT FROM @ins_query;
             EXECUTE STMT; -- USING @v_values;
             DEALLOCATE PREPARE STMT;

			 SET @v_values = '';
             SET @ins_query = '';
        ELSE 
       
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', vHWD, '"', ',', rating,',','"', same_col, '"', ' ),');

        END IF;

        /** leave loop */
        IF @cnt = @row_num THEN 
            LEAVE loop_race;
        END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_wfa` (`HR_HORSE` ASC, `HR_HWD` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);


/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating`
SELECT 
    HR_SAME,
    HR_HORSE,
    CAST( (HR_HWD) AS DECIMAL (5, 1 ))  AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE, HR_HWD
ORDER BY HR_SAME, HR_HWD, HR_HORSE;


END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_barrier`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE barrier INT(11);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);

DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BAR_POS, A_RATE, SAME FROM temp_valid_filtered;
-- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, 
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME ", 

 "FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
	" ", @MAGINUsed, " ",
    
        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS "
        
        -- @whereClause
        
        );


DROP TABLE IF EXISTS temp_valid_filtered;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, W_BAR_POS AS HR_BAR_POS, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;



SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, barrier, rating, same_col;
        SET @cnt = @cnt + 1;
        IF rating = 1200 THEN
            SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
			AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
            SET rating = 200 + sec_mar * 30 + @BaseRating;
        END IF;
        
    /** Error Check */
    IF horsename IS NULL OR barrier IS NULL OR rating IS NULL THEN
            SELECT "NULL VALUE FOUND" AS `Error`, horsename, barrier, rating;
            LEAVE loop_race;
    END IF;  
    
    IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
        SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', barrier, ',' ,rating,',','"', same_col, '"', ' );');
        SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_BAR_POS`, `HR_RATE`, `HR_SAME`) VALUES', @v_values);
        PREPARE STMT FROM @ins_query;
        EXECUTE STMT; -- USING @v_values;
        DEALLOCATE PREPARE STMT;

        SET @v_values = '';
        SET @ins_query = '';
    ELSE 
        SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', barrier, ',' ,rating,',','"', same_col, '"', ' ),');

    END IF;

    /** leave loop */
    IF @cnt = @row_num THEN 
        LEAVE loop_race;
    END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_bar_pos` (`HR_HORSE` ASC, `HR_BAR_POS` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);

/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating`
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_BAR_POS AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_BAR_POS
ORDER BY HR_SAME, HR_BAR_POS, HR_HORSE;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_prise`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE prise varchar(7);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);

DECLARE DONE INT DEFAULT FALSE;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, R_VALUE, A_RATE, SAME FROM temp_valid_filtered;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;

call horse_1000();  

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BEAT_MAR, W.W_FIN_POS, R.R_VALUE,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME ", 

 "FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
	" ", @MAGINUsed, " ",
    
        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS "
        
        -- @whereClause
        
        );
        
DROP TABLE IF EXISTS temp_valid_filtered, scv_report.temp_horserate, scv_report.temp_AvgRating;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, R_VALUE AS HR_VALUE, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;

SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race;
SELECT FOUND_ROWS() INTO @row_num; 
get_rating: LOOP

IF DONE THEN
	LEAVE get_rating;
END IF;

FETCH work_race INTO wdate, track, raceNo, horsename, prise, rating, same_col;
IF rating = 1200.0 THEN
	SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
	SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
	SET @v_values = CONCAT(@v_values, '(', '"', same_col, '"', ',','"',horsename,'"',',','"',prise,'"',',' ,rating, ');' );
	SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_SAME`, `HR_HORSE`,`HR_VALUE`,`HR_RATE`) VALUES', @v_values);
	PREPARE STMT FROM @ins_query;
	EXECUTE STMT; -- USING @v_values;
		
	SET @v_values = '';
	SET @ins_query = '';

ELSE 
	SET @v_values = CONCAT(@v_values, '(', '"', same_col, '"', ',','"',horsename,'"',',','"',prise,'"',',' ,rating, '),' );
END IF;


END LOOP;
CLOSE work_race;

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_prise` (`HR_HORSE` ASC, `HR_VALUE` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);

CREATE TABLE `scv_report`.`temp_AvgRating` 
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_VALUE AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_VALUE
ORDER BY HR_SAME, HR_VALUE, HR_HORSE;


END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_raceclass`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE barrier INT(11);
DECLARE class varchar(4);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BAR_POS,R_CLASS, A_RATE, SAME FROM scv.temp_valid_filtered;

call horse_1000();   

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, LEFT(R.R_CLASS,LOCATE('.',R.R_CLASS) - 1) AS R_CLASS,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME",

" FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",
    
        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS " 
	
        -- @whereClause
);


DROP TABLE IF EXISTS temp_valid_filtered;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; -- USING @whereClause;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, R_CLASS AS HR_CLASS, A_RATE AS HR_RATE FROM temp_valid_filtered limit 0;



SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, barrier, class, rating, same_col;


/** Error Check */
IF horsename IS NULL OR class IS NULL OR barrier IS NULL  THEN
    SELECT "NULL VALUE FOUND" AS `Error`, horsename,class,barrier;
    LEAVE get_rating;
END IF;

IF rating = 1200.0 THEN

SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

   CASE class
      WHEN '80U' THEN  SET class = '80+';
      WHEN '74U' THEN  SET class = '74+';
      WHEN '68U' THEN  SET class = '68+';
      WHEN '53U' THEN  SET class = '53+';
      WHEN 'B68' THEN  SET class = '68B';
      WHEN '110' THEN  SET class = '110B';
      ELSE  SET class = TRIM(class);
    END CASE;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',class,'"',',' ,rating,',','"', same_col, '"', ' );');
SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_CLASS`,`HR_RATE`, `HR_SAME`) VALUES', @v_values);
PREPARE STMT FROM @ins_query;
EXECUTE STMT;
    

SET @v_values = '';
SET @ins_query = '';

ELSE 
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',class,'"',',' ,rating,',','"', same_col, '"', ' ),');
END IF;

IF @cnt = @row_num THEN LEAVE get_rating;
END IF;

END LOOP get_rating;
CLOSE work_race_all;

DEALLOCATE PREPARE STMT;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_class` (`HR_HORSE` ASC, `HR_CLASS` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);


CREATE TABLE `scv_report`.`temp_AvgRating`
-- SELECT 
-- T.HR_SAME,
-- T.HR_HORSE, 
-- T.HR_CLASS AS HR_REPORT, 
-- SUM(T.cnt) AS cnt, 
-- CAST(AVG(T.AVG_RATING) AS DECIMAL(5,1)) AS AVG_RATING,
-- CAST(MAX(T.MAX_RATING) AS DECIMAL(5,1)) AS MAX_RATING
-- FROM
-- (
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_CLASS AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE, HR_CLASS
-- ) AS T

-- GROUP BY HR_HORSE , HR_CLASS
ORDER BY HR_SAME, HR_CLASS, HR_HORSE;



END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_sex`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE barrier INT(11);
DECLARE class varchar(4);
DECLARE sex_restriction varchar(4);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BAR_POS,R_CLASS,R_SEX,A_RATE, SAME FROM scv.temp_valid_filtered;

call horse_1000();  

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, 
     IF(   SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -2), '.', 1) = '   ', 'OPEN', SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -2), '.', 1) ) AS R_CLASS,
	 IF(   R.R_SEX = ' ', 'OPEN', R.R_SEX) AS R_SEX,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME ",

"FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",
    
        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS ", 
	    	
        @whereClause);




DROP TABLE IF EXISTS scv.temp_valid_filtered;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; -- USING @whereClause;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);

CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, R_CLASS AS HR_CLASS,R_SEX AS HR_SEX,A_RATE AS HR_RATE FROM scv.temp_valid_filtered limit 0;


SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, barrier, class,sex_restriction,rating, same_col;
IF rating = 1200.0 THEN
SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',','"',class,'"',',','"',sex_restriction,'"',',' ,rating,',','"', same_col, '"', ' );');
SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_CLASS`,`HR_SEX`,`HR_RATE`, `HR_SAME`) VALUES', @v_values);
PREPARE STMT FROM @ins_query;
EXECUTE STMT; -- USING @v_values;
    

SET @v_values = '';
SET @ins_query = '';

ELSE 
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',','"',class,'"',',','"',sex_restriction,'"',',' ,rating,',','"', same_col, '"', ' ),');
END IF;

IF @cnt = @row_num THEN LEAVE get_rating;
END IF;

END LOOP get_rating;
CLOSE work_race_all;

DEALLOCATE PREPARE STMT;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_sex` (`HR_HORSE` ASC, `HR_SEX` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);


CREATE TABLE `scv_report`.`temp_AvgRating` 
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_SEX AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_SEX
ORDER BY HR_SAME, HR_SEX, HR_HORSE;



END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_state`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE same_col varchar(24);

DECLARE statename varchar(24); 
DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);


DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, M_STATE, A_RATE, SAME FROM temp_valid_filtered;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, M.M_STATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE,  W.W_BEAT_MAR, W.W_FIN_POS,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME",

" FROM", 
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",
    
    " INNER JOIN
    alg_rating A ON A.A_FIN_POS = W.W_FIN_POS ", 

    @whereClause

);


DROP TABLE IF EXISTS scv.temp_valid_filtered;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, M_STATE AS HR_STATE, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;


SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, statename, rating, same_col;
        SET @cnt = @cnt + 1;

        IF rating = 1200 THEN
            SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
            SET rating = 200 + sec_mar * 30 + @BaseRating;

        END IF;
        
        /** Error Check */
        IF horsename IS NULL OR statename IS NULL OR rating IS NULL THEN
                SELECT "NULL VALUE FOUND" AS `Error`, horsename, statename, rating;
                LEAVE loop_race;
        END IF;  
    
        IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
        
             SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', statename, '"', ',', rating,',','"', same_col, '"', ' );');
             SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_STATE`, `HR_RATE`, `HR_SAME`) VALUES ', @v_values);
             PREPARE STMT FROM @ins_query;
             EXECUTE STMT; -- USING @v_values;
             DEALLOCATE PREPARE STMT;

             SET @v_values = '';
             SET @ins_query = '';
        ELSE 
       
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', statename, '"', ',', rating,',','"', same_col, '"', ' ),');

        END IF;

        /** leave loop */
        IF @cnt = @row_num THEN 
            LEAVE loop_race;
        END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_state` (`HR_HORSE` ASC, `HR_STATE` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);
/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating`
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_STATE AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_STATE
ORDER BY HR_SAME, HR_STATE, HR_HORSE;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_track`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE same_col varchar(24);

DECLARE track_abbr varchar(4);
DECLARE rating DECIMAL(5,1);
DECLARE sec_mar varchar(6);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, T_CAT, A_RATE, SAME FROM temp_valid_filtered;

call horse_1000();        

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
	W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS,
	T.TRACK AS T_CAT,
	R.R_VALUE,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
	W1.SAME "

"FROM",
    
    " ", @table_joins, " ",
	" ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",
    
        " INNER JOIN
		alg_rating A ON A.A_FIN_POS = W.W_FIN_POS
	    INNER JOIN
	trackabbr TABB ON TABB.T_ABBR = M.M_TRACK
        AND TABB.STATE = M.M_STATE
  " 	
   --     @whereClause
   );



DROP TABLE IF EXISTS scv.temp_valid_filtered;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);

CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, T_CAT AS HR_TRACK,A_RATE AS HR_RATE FROM temp_valid_filtered limit 0;
SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, track_abbr, rating, same_col;

IF rating = 1200.0 THEN
SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"',',','"',track_abbr,'"',',' ,rating,',','"', same_col, '"', ' );');
SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`,`HR_TRACK`,`HR_RATE`, `HR_SAME`) VALUES', @v_values);
PREPARE STMT FROM @ins_query;
EXECUTE STMT; -- USING @v_values;
    

SET @v_values = '';
SET @ins_query = '';

ELSE 
    SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"',',','"',track_abbr,'"',',' ,rating,',','"', same_col, '"', ' ),');
END IF;



IF @cnt = @row_num THEN LEAVE get_rating;
END IF;
END LOOP get_rating;
CLOSE work_race_all;
DEALLOCATE PREPARE STMT;

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_track` (`HR_HORSE` ASC, `HR_TRACK` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);

DROP TABLE IF EXISTS `scv_report`.`temp_AvgRating_track`;
CREATE TABLE `scv_report`.`temp_AvgRating` 
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_TRACK AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_TRACK
ORDER BY HR_SAME, HR_TRACK, HR_HORSE;


END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `report_track_condition`()
BEGIN
DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE trackCond varchar(1);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(6);
DECLARE rating DECIMAL(5,1);

DECLARE DONE INT DEFAULT FALSE;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, R_TR_COND, A_RATE, SAME FROM temp_valid_filtered;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;


call horse_1000();  

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BEAT_MAR, W.W_FIN_POS, R.R_TR_COND,
(CASE        WHEN W.W_BEAT_MAR='WON'     THEN 1200
             WHEN W.W_BEAT_MAR LIKE '%+' THEN CAST( (1000 + A.A_POINTS - LEFT(W.W_BEAT_MAR, LENGTH(W.W_BEAT_MAR)-1) * A.A_MRJ) AS DECIMAL(5,1))
             ELSE						 CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1))
END) AS A_RATE,
     W1.SAME ", 

 "FROM",
    
    " ", @table_joins, " ",
    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
	" ", @MAGINUsed, " ",
    
        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS "
        
        -- @whereClause
        
        );
        
DROP TABLE IF EXISTS temp_valid_filtered, scv_report.temp_horserate, scv_report.temp_AvgRating;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, R_TR_COND AS HR_TR_COND, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;

SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race;
SELECT FOUND_ROWS() INTO @row_num; 
get_rating: LOOP

IF DONE THEN
	LEAVE get_rating;
END IF;

FETCH work_race INTO wdate, track, raceNo, horsename, trackCond, rating, same_col;
IF rating = 1200.0 THEN
	SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
	SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
	SET @v_values = CONCAT(@v_values, '(', '"', same_col, '"', ',','"',horsename,'"',',','"',trackCond,'"',',' ,rating, ');' );
	SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_SAME`, `HR_HORSE`,`HR_TR_COND`,`HR_RATE`) VALUES', @v_values);
	PREPARE STMT FROM @ins_query;
	EXECUTE STMT; -- USING @v_values;
		
	SET @v_values = '';
	SET @ins_query = '';

ELSE 
	SET @v_values = CONCAT(@v_values, '(', '"', same_col, '"', ',','"',horsename,'"',',','"',trackCond,'"',',' ,rating, '),' );
END IF;


END LOOP;
CLOSE work_race;

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_trackCond` (`HR_HORSE` ASC, `HR_TR_COND` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);

CREATE TABLE `scv_report`.`temp_AvgRating` 
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_TR_COND AS HR_REPORT,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_TR_COND
ORDER BY HR_SAME, HR_TR_COND, HR_HORSE;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `setGlobVar`(IN whereClause TEXT, IN whereClause_WFA VARCHAR(8000), IN whereClause_track VARCHAR(8000), IN whereClause_dow VARCHAR(8000), IN whereClause_magin VARCHAR(8000), IN horsmastUsed INT(1), IN num_result INT(11), IN least_run INT(11), IN SAME varchar(255), IN daysBet INT(11), IN dayPreStart INT(11), IN reportCol varchar(255))
BEGIN

SET @whereClause  = whereClause;
SET @whereClause_WFA = whereClause_WFA;
SET @whereClause_track = whereClause_track;
SET @whereClause_dow = whereClause_dow;
SET @whereClause_magin = whereClause_magin;
SET @num_result = num_result;
SET @least_run = least_run;
SET @SAME = SAME;
SET @daysBet = daysBet;
SET @dayPreStart = dayPreStart;
SET @reportCol = reportCol;

SET @table_joins_preCond = '
meetmast M
        INNER JOIN
    racemast R ON M.M_DATE = R.R_DATE
        AND M.M_TRACK = R.R_TRACK
        INNER JOIN
    workrace W ON R.R_DATE = W.W_DATE
        AND R.R_TRACK = W.W_TRACK 
        AND R.R_RACE_NO = W.W_RACE_NO';
        
SET @table_joins = '
meetmast M
        INNER JOIN
    racemast R ON M.M_DATE = R.R_DATE
        AND M.M_TRACK = R.R_TRACK
        INNER JOIN
    workrace W ON R.R_DATE = W.W_DATE
        AND R.R_TRACK = W.W_TRACK 
        AND R.R_RACE_NO = W.W_RACE_NO 
        INNER JOIN
    temp_horsname W1 ON W1.W1_HORSE = W.W_HORSE
		AND W1.W1_DATE = W.W_DATE AND W1.W1_TRACK = W.W_TRACK AND W1.W1_RACE_NO = W.W_RACE_NO';


  DROP DATABASE scv_report;
  CREATE DATABASE scv_report;
  DROP TABLE IF EXISTS scv.temp_horsnameT, scv.temp_horsname, scv.temp_filtered_all, scv.temp_valid_filtered;

ALTER TABLE `scv`.`racemast` 
CHANGE COLUMN `R_CLASS` `R_CLASS` VARCHAR(15) NULL DEFAULT NULL ;
SELECT COUNT(*) INTO @cnt_invalid_class FROM scv.racemast
WHERE 
(R_CLASS LIKE '%W' OR R_CLASS LIKE '%S' OR R_CLASS LIKE '%P' ) AND R_LIM_WGHT REGEXP '^[0-9]*[.]?[0-9]+$';

IF @cnt_invalid_class > 0 THEN
UPDATE scv.racemast AS R SET R_CLASS = CONCAT(SUBSTRING_INDEX(R_CLASS, '.', 3), '.', R_LIM_WGHT)
WHERE 
(R_CLASS LIKE '%W' OR R_CLASS LIKE '%S' OR R_CLASS LIKE '%P' ) AND R_LIM_WGHT REGEXP '^[0-9]*[.]?[0-9]+$';
END IF;

SELECT COUNT(W_HORSE) INTO @quote_in_w FROM scv.workrace  WHERE W_HORSE LIKE '%"%';
SELECT COUNT(H_HORSE) INTO @quote_in_h FROM scv.horsmast  WHERE H_HORSE LIKE '%"%';

IF @quote_in_w > 0 THEN
	UPDATE scv.workrace SET W_HORSE = REPLACE(W_HORSE,'"','') WHERE W_HORSE LIKE "%\"%";
END IF;

IF @quote_in_h > 0 THEN
	UPDATE scv.horsmast SET H_HORSE = REPLACE(H_HORSE,'"','') WHERE H_HORSE LIKE "%\"%";
END IF;



IF horsmastUsed = 1 THEN
    SET @horsmastUsed = "INNER JOIN `scv`.`horsmast` H ON H.H_HORSE = W.W_HORSE";
ELSE
    SET @horsmastUsed = "";
END IF;


IF LENGTH(whereClause_WFA) > 0 OR @SAME LIKE '%WFA.HWD%' OR @reportCol LIKE '%WFA.HWD%' THEN
	call preCond_WFA();
    SET @WFAUsed = "INNER JOIN `scv_report`.`temp_WFA` WFA ON W.W_HORSE = WFA.WFA_HORSE AND W.W_DATE = WFA.WFA_DATE AND W.W_TRACK = WFA.WFA_TRACK AND W.W_RACE_NO = WFA.WFA_RACE_NO";
ELSE
    SET @WFAUsed = "";
END IF;

IF LENGTH(whereClause_track) > 0  OR @SAME LIKE '%T.TRACK%' OR @reportCol LIKE '%T.TRACK%'  THEN
    call preCond_track();
    SET @TRACKUsed = "INNER JOIN `scv_report`.`temp_track` T ON W.W_HORSE = T.T_HORSE AND W.W_DATE = T.T_DATE AND W.W_TRACK = T.T_TRACK AND W.W_RACE_NO = T.T_RACE_NO";
ELSE
    SET @TRACKUsed = "";
END IF;

IF LENGTH(whereClause_dow) > 0 OR @SAME LIKE '%D.DOW%'  OR @reportCol LIKE '%D.DOW%' THEN
    call preCond_DOW();
    SET @DOWUsed = "INNER JOIN `scv_report`.`temp_dow` D ON W.W_HORSE = D.D_HORSE AND W.W_DATE = D.D_DATE AND W.W_TRACK = D.D_TRACK AND W.W_RACE_NO = D.D_RACE_NO";
ELSE
    SET @DOWUsed = "";
END IF;

IF LENGTH(whereClause_magin) > 0 OR @SAME LIKE '%MA.MAGIN%' OR @reportCol LIKE '%MA.MAGIN%'  THEN
	 call preCond_magin();
    SET @MAGINUsed = "INNER JOIN `scv_report`.`temp_magin` MA ON W.W_HORSE = MA.MA_HORSE AND W.W_DATE = MA.MA_DATE AND W.W_TRACK = MA.MA_TRACK AND W.W_RACE_NO = MA.MA_RACE_NO";
ELSE
    SET @MAGINUsed = "";
END IF;



END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test`()
BEGIN


IF '999A' < 1000 OR 1=1 THEN
select FLOOR('1350A'/200) * 200 + 200, '1350A'%200 , FLOOR('1350A'/200);
END IF;

END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_run`()
BEGIN

SET @whereClause = "WHERE SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -3), '.', 1) IN ('  ','5+','4+','3+','2+') AND R.R_SEX IN (' ') AND M.M_DATE >= '2016-08-01' AND (R.R_CLASS LIKE '%.' ) AND W.W_WGHT_CAR NOT IN ('uk', 'PEND') ";
SET @whereClause_WFA =  "";
SET @whereClause_track =  "";
SET @whereClause_dow = ""; -- "Mid Week";
SET @whereClause_magin = "0,0.0,.1,0.1,.1+,.2,0.2,.2+,.3,0.3,.3+,.4,0.4,.4+,.5,0.5,.5+,.6,0.6,.6+,.7,0.7,.7+,.8,0.8,.8+,.9,0.9,.9+,1,1.0,1.0+,1.1,1.1+,1.2,1.2+,1.3,1.3+,1.4,1.4+,1.5,1.5+,1.6,1.6+,1.7,1.7+,1.8,1.8+,1.9,1.9+,2,2.0,2.0+,2.1,2.1+,2.2,2.2+,2.3,2.3+,2.4,2.4+,2.5,2.5+,2.6,2.6+,2.7,2.7+,2.8,2.8+,2.9,2.9+,3,3.0,3.0+,3.1,3.1+,3.2,3.2+,3.3,3.3+,3.4,3.4+,3.5,3.5+,3.6,3.6+,3.7,3.7+,3.8,3.8+,3.9,3.9+,4,4.0,4.0+,4.1,4.1+,4.2,4.2+,4.3,4.3+,4.4,4.4+,4.5,4.5+,4.6,4.6+,4.7,4.7+,4.8,4.8+,4.9,4.9+,5,5.0,5.0+,5.1,5.1+,5.2,5.2+,5.3,5.3+,5.4,5.4+,5.5,5.5+,5.6,5.6+,5.7,5.7+,5.8,5.8+,5.9,5.9+,6,6.0,6.0+,6.1,6.1+,6.2,6.2+,6.3,6.3+,6.4,6.4+,6.5,6.5+,6.6,6.6+,6.7,6.7+,6.8,6.8+,6.9,6.9+,7,7.0,7.0+,7.1,7.1+,7.2,7.2+,7.3,7.3+,7.4,7.4+,7.5,7.5+,7.6,7.6+,7.7,7.7+,7.8,7.8+,7.9,7.9+,8,8.0,8.0+,8.1,8.1+,8.2,8.2+,8.3,8.3+,8.4,8.4+,8.5,8.5+,8.6,8.6+,8.7,8.7+,8.8,8.8+,8.9,8.9+,9,9.0,9.0+,9.1,9.1+,9.2,9.2+,9.3,9.3+,9.4,9.4+,9.5,9.5+,9.6,9.6+,9.7,9.7+,9.8,9.8+,9.9,9.9+,10,10.0,10.0+,10.1,10.1+,10.2,10.2+,10.3,10.3+,10.4,10.4+,10.5,10.5+,10.6,10.6+,10.7,10.7+,10.8,10.8+,10.9,10.9+,11,11.0,11.0+,11.1,11.1+,11.2,11.2+,11.3,11.3+,11.4,11.4+,11.5,11.5+,11.6,11.6+,11.7,11.7+,11.8,11.8+,11.9,11.9+,12,12.0,12.0+,12.1,12.1+,12.2,12.2+,12.3,12.3+,12.4,12.4+,12.5,12.5+,12.6,12.6+,12.7,12.7+,12.8,12.8+,12.9,12.9+,13,13.0,13.0+,13.1,13.1+,13.2,13.2+,13.3,13.3+,13.4,13.4+,13.5,13.5+,13.6,13.6+,13.7,13.7+,13.8,13.8+,13.9,13.9+,14,14.0,14.0+,14.1,14.1+,14.2,14.2+,14.3,14.3+,14.4,14.4+,14.5,14.5+,14.6,14.6+,14.7,14.7+,14.8,14.8+,14.9,14.9+,15,15.0,15.0+,15.1,15.1+,15.2,15.2+,15.3,15.3+,15.4,15.4+,15.5,15.5+,15.6,15.6+,15.7,15.7+,15.8,15.8+,15.9,15.9+,16,16.0,16.0+,16.1,16.1+,16.2,16.2+,16.3,16.3+,16.4,16.4+,16.5,16.5+,16.6,16.6+,16.7,16.7+,16.8,16.8+,16.9,16.9+,17,17.0,17.0+,17.1,17.1+,17.2,17.2+,17.3,17.3+,17.4,17.4+,17.5,17.5+,17.6,17.6+,17.7,17.7+,17.8,17.8+,17.9,17.9+,18,18.0,18.0+,18.1,18.1+,18.2,18.2+,18.3,18.3+,18.4,18.4+,18.5,18.5+,18.6,18.6+,18.7,18.7+,18.8,18.8+,18.9,18.9+,19,19.0,19.0+,19.1,19.1+,19.2,19.2+,19.3,19.3+,19.4,19.4+,19.5,19.5+,19.6,19.6+,19.7,19.7+,19.8,19.8+,19.9,19.9+,20,20.0,20.0+,20.1,20.1+,20.2,20.2+,20.3,20.3+,20.4,20.4+,20.5,20.5+,20.6,20.6+,20.7,20.7+,20.8,20.8+,20.9,20.9+,21,21.0,21.0+,21.1,21.1+,21.2,21.2+,21.3,21.3+,21.4,21.4+,21.5,21.5+,21.6,21.6+,21.7,21.7+,21.8,21.8+,21.9,21.9+,22,22.0,22.0+,22.1,22.1+,22.2,22.2+,22.3,22.3+,22.4,22.4+,22.5,22.5+,22.6,22.6+,22.7,22.7+,22.8,22.8+,22.9,22.9+,23,23.0,23.0+,23.1,23.1+,23.2,23.2+,23.3,23.3+,23.4,23.4+,23.5,23.5+,23.6,23.6+,23.7,23.7+,23.8,23.8+,23.9,23.9+,24,24.0,24.0+,24.1,24.1+,24.2,24.2+,24.3,24.3+,24.4,24.4+,24.5,24.5+,24.6,24.6+,24.7,24.7+,24.8,24.8+,24.9,24.9+,25,25.0,25.0+";

SET @horsmastUsed = 0;
SET @least_run = 2;
SET @num_result  = 1000;
-- SET @SAME = "R.R_DISTANCE AS SAME";
-- SET @SAME = "WFA.HWD AS SAME";
-- SET @SAME = "MA.MAGIN AS SAME";
set @SAME = "'Prise Money (Testing)' AS SAME";


SET @dayPreStart = 22;
SET @daysBet = 43;
SET @reportCol = "R.R_VALUE AS REPORT";


 call setGlobVar(@whereClause, @whereClause_WFA, @whereClause_track, @whereClause_dow, @whereClause_magin, @horsmastUsed, @num_result, @least_run, @SAME, @daysBet, @dayPreStart, @reportCol);


-- call horse_1000();
-- call report_barrier();

-- call report_state();

-- call report_track();

 -- call report_WFA();
 -- call report_raceclass();

-- call report_sex();

-- call report_DOW();
 
 call report_prise();
 
 call create_result_tables();
END$$
DELIMITER ;
