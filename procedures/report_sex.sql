CREATE DEFINER=`root`@`localhost` PROCEDURE `report_sex`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE barrier INT(11);
DECLARE class varchar(4);
DECLARE sex_restriction varchar(4);

DECLARE sec_mar varchar(4);
DECLARE rating DECIMAL(5,1);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BAR_POS,R_CLASS,R_SEX,A_RATE FROM scv.temp_filtered_all;

call horse_1000();  

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, 
     IF(   SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -2), '.', 1) = '   ', 'OPEN', SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -2), '.', 1) ) AS R_CLASS,
	 IF(   R.R_SEX = ' ', 'OPEN', R.R_SEX) AS R_SEX,
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




DROP TABLE IF EXISTS scv.temp_filtered_all;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; -- USING @whereClause;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


DROP TABLE IF EXISTS `scv_report`.`temp_horserate`;
CREATE TABLE `scv_report`.`temp_horserate`
SELECT W_HORSE AS HR_HORSE, R_CLASS AS HR_CLASS,R_SEX AS HR_SEX,A_RATE AS HR_RATE FROM scv.temp_filtered_all limit 0;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_bar_pos` (`HR_HORSE` ASC);


SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, barrier, class,sex_restriction,rating;
    IF rating = 1200.0 THEN

SELECT DISTINCT(W_BEAT_MAR) INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2;
SET rating = 200 + sec_mar * 30 + @BaseRating;
END IF;
SET @cnt = @cnt + 1;

IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',','"',class,'"',',','"',sex_restriction,'"',',' ,rating,' );');
SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_CLASS`,`HR_SEX`,`HR_RATE`) VALUES', @v_values);
PREPARE STMT FROM @ins_query;
EXECUTE STMT; -- USING @v_values;
    

SET @v_values = '';
SET @ins_query = '';

ELSE 
SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',','"',class,'"',',','"',sex_restriction,'"',',' ,rating,' ),');
END IF;

IF @cnt = @row_num THEN LEAVE get_rating;
END IF;

END LOOP get_rating;
CLOSE work_race_all;

DEALLOCATE PREPARE STMT;


DROP TABLE IF EXISTS scv_report.temp_AvgRating_sex;
CREATE TABLE `scv_report`.`temp_AvgRating_sex` 
SELECT HR_HORSE, HR_SEX, CAST(avg(HR_RATE) as DECIMAL (5, 1 ))as HR_RATE
FROM scv_report.temp_horserate GROUP BY HR_HORSE, HR_SEX;


END