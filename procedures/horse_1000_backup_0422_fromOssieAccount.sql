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
    SELECT MAX(W_DATE) INTO @temp_PreDate FROM scv.workrace WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
    IF @temp_PreDate IS NOT NULL AND DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart THEN
        SELECT MAX(W_DATE) INTO @temp_lastRunDate FROM scv.temp_filtered_all WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
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
    SELECT MAX(W_DATE) INTO @temp_PreDate FROM scv.workrace WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
    IF @temp_PreDate IS NOT NULL AND DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart THEN
        SELECT MAX(W_DATE) INTO @temp_lastRunDate FROM scv.temp_filtered_all WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
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
END