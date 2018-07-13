CREATE DEFINER=`root`@`localhost` PROCEDURE `report_barrier`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE barrier INT(11);

DECLARE sec_mar varchar(4);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);

DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BAR_POS, A_RATE FROM temp_filtered_all;
-- DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS
     CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1)) AS A_RATE

FROM
    meetmast M
        INNER JOIN
    racemast R ON M.M_DATE = R.R_DATE
        AND M.M_TRACK = R.R_TRACK
        INNER JOIN
    workrace W ON R.R_DATE = W.W_DATE
        AND R.R_TRACK = W.W_TRACK 
        AND R.R_RACE_NO = W.W_RACE_NO 
        INNER JOIN
    temp_horsname W1 ON W1.W1_HORSE = W.W_HORSE",

    " ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",

        " INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS ", 
        
        @whereClause);


DROP TABLE IF EXISTS temp_filtered_all, scv_report.temp_horserate, scv_report.temp_AvgRating_barrier;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT W_HORSE AS HR_HORSE, W_BAR_POS AS HR_BAR_POS, A_RATE AS HR_RATE FROM temp_filtered_all LIMIT 0;



SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, barrier, rating;
        SET @cnt = @cnt + 1;
        IF rating = 1200 THEN
            SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
            SET rating = 200 + sec_mar * 30 + @BaseRating;
        END IF;
        
    /** Error Check */
    IF horsename IS NULL OR barrier IS NULL OR rating IS NULL THEN
            SELECT "NULL VALUE FOUND" AS `Error`, horsename, barrier, rating;
            LEAVE loop_race;
    END IF;  
    
    IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
        SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', barrier, ',' ,rating,' );');
        SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_BAR_POS`, `HR_RATE`) VALUES', @v_values);
        PREPARE STMT FROM @ins_query;
        EXECUTE STMT; -- USING @v_values;
        DEALLOCATE PREPARE STMT;

        SET @v_values = '';
        SET @ins_query = '';
    ELSE 
        SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', barrier, ',' ,rating,' ),');

    END IF;

    /** leave loop */
    IF @cnt = @row_num THEN 
        LEAVE loop_race;
    END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_bar_pos` (`HR_HORSE` ASC, `HR_BAR_POS` ASC);

/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating_barrier`
SELECT 
    HR_HORSE,
    HR_BAR_POS,
    CAST(AVG(HR_RATE) AS DECIMAL (5, 1 )) AS AVG_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_HORSE , HR_BAR_POS
ORDER BY HR_HORSE , HR_BAR_POS;

END