CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_magin`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE beat_mar varchar(4);
DECLARE fin_pos INT(11);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE sec_mar varchar(4);

DECLARE work_race_all CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_BEAT_MAR, W_FIN_POS FROM temp_filtered_all;

SET @query_all = CONCAT("
CREATE TABLE temp_filtered_all 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_BEAT_MAR, W.W_FIN_POS

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
	
        @whereClause
);

DROP TABLE IF EXISTS `scv`.`temp_filtered_all`, `scv_report`.`temp_magin`;

PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL; 
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_horse` (`W_HORSE` ASC);

ALTER TABLE `scv`.`temp_filtered_all` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_magin`
SELECT W_HORSE AS T_HORSE, W_DATE AS T_DATE, W_TRACK AS T_TRACK, W_RACE_NO AS T_RACE_NO, W_BEAT_MAR AS MAGIN FROM temp_filtered_all limit 0;
SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';

OPEN work_race_all;
SELECT FOUND_ROWS() into @row_num;
pre_cond_track : LOOP
FETCH work_race_all INTO wdate, track, raceNo, horsename, beat_mar, fin_pos;
SET @cnt = @cnt + 1;

IF beat_mar = 'WON' THEN
SELECT DISTINCT(W_BEAT_MAR) INTO beat_mar FROM workrace  WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2;
END IF;

IF FIND_IN_SET(beat_mar, @whereClause_magin) OR @SAME = 'MA.MAGIN AS SAME' THEN
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
ADD INDEX `idx_tp_track_t_horse` (`T_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_magin`
ADD INDEX `idx_tp_track_t_date_track_race` (`T_DATE` ASC, `T_TRACK` ASC, `T_RACE_NO` ASC);

END