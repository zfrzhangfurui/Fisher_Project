CREATE DEFINER=`root`@`localhost` PROCEDURE `report_track`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE same_col varchar(24);

DECLARE track_abbr varchar(4);
DECLARE track_state varchar(4);
DECLARE prisemoney DECIMAL(4,1);
DECLARE rating DECIMAL(5,1);
DECLARE sec_mar varchar(4);
DECLARE cnt INT(11);


DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK,M_STATE, W_RACE_NO, W_HORSE, T_CAT, R_VALUE, A_RATE, SAME FROM temp_valid_filtered;

call horse_1000();        

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS,

(CASE  WHEN T.T_CAT IS NULL                                                THEN   M.M_MET_TYPE
             WHEN T.T_CAT IS NOT NULL AND R.R_VALUE  >= 2 THEN   T.T_CAT
             WHEN T.T_CAT IS NOT NULL AND R.R_VALUE < 2    THEN    'N'  
END) AS T_CAT,

	R.R_VALUE,
     CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1)) AS A_RATE, 
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
	trackabbr T ON T.T_ABBR = M.M_TRACK
        AND T.STATE = M.M_STATE
  " 	
   --     @whereClause
   );



DROP TABLE IF EXISTS scv.temp_valid_filtered;
PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


DROP TABLE IF EXISTS `scv_report`.`temp_horserate`;
CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, T_CAT AS HR_TRACK,A_RATE AS HR_RATE FROM temp_valid_filtered limit 0;
SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
get_rating : LOOP
FETCH work_race_all INTO wdate, track, track_state, raceNo, horsename, track_abbr, prisemoney, rating, same_col;

IF rating = 1200.0 THEN
SELECT DISTINCT(W_BEAT_MAR) INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track 
AND W_RACE_NO = raceNo AND W_FIN_POS = 2;
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
CREATE TABLE `scv_report`.`temp_AvgRating_track` 
SELECT 
T.HR_SAME,
T.HR_HORSE, 
T.HR_TRACK, 
SUM(T.cnt) AS cnt, 
CAST(AVG(T.AVG_RATING) AS DECIMAL(5,1)) AS AVG_RATING,
CAST(MAX(T.MAX_RATING) AS DECIMAL(5,1)) AS MAX_RATING
FROM
(
SELECT 
	HR_SAME,
    HR_HORSE,
    HR_TRACK,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE , HR_TRACK
) AS T

GROUP BY HR_HORSE , HR_TRACK
ORDER BY HR_SAME, HR_TRACK, HR_HORSE;


END