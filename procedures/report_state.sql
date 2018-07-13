CREATE DEFINER=`root`@`localhost` PROCEDURE `report_state`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);

DECLARE statename varchar(24); 
DECLARE sec_mar varchar(4);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);


DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, M_STATE, A_RATE FROM temp_filtered_all;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, M.M_STATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE,  W.W_BEAT_MAR, W.W_FIN_POS,
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

    @whereClause

);


DROP TABLE IF EXISTS scv.temp_filtered_all, scv_report.temp_horserate, scv_report.temp_AvgRating_state;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT W_HORSE AS HR_HORSE, M_STATE AS HR_STATE, A_RATE AS HR_RATE FROM temp_filtered_all LIMIT 0;


SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, statename, rating;
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
        
             SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', statename, '"', ',', rating,' );');
             SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_STATE`, `HR_RATE`) VALUES ', @v_values);
             PREPARE STMT FROM @ins_query;
             EXECUTE STMT; -- USING @v_values;
             DEALLOCATE PREPARE STMT;

             SET @v_values = '';
             SET @ins_query = '';
        ELSE 
       
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', statename, '"', ',', rating,' ),');

        END IF;

        /** leave loop */
        IF @cnt = @row_num THEN 
            LEAVE loop_race;
        END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_state` (`HR_HORSE` ASC, `HR_STATE` ASC);

/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating_state`
SELECT 
    HR_HORSE,
    HR_STATE,
    CAST(AVG(HR_RATE) AS DECIMAL (5, 1 )) AS AVG_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_HORSE, HR_STATE
ORDER BY HR_HORSE, HR_STATE;

END