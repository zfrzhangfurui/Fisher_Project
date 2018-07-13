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
     W.W_DATE, W.W_TRACK, M.M_STATE, W.W_RACE_NO, W.W_HORSE, W.W_BAR_POS, W.W_BEAT_MAR, W.W_FIN_POS, IF(R_VALUE >= 2,T.T_CAT,'N') AS T_CAT

FROM",
    
    " ", @table_joins_preCond, " ",
    " ", @horsmastUsed, " ",

        "INNER JOIN
            trackabbr T ON T.T_ABBR = W.W_TRACK
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

IF FIND_IN_SET(track_abbr, @whereClause_track) OR @SAME = 'T.TRACK AS SAME' THEN
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

END