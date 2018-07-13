CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_DOW`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);

DECLARE track_abbr varchar(4);
DECLARE track_state varchar(4);
DECLARE prisemoney DECIMAL(4,1);

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

DROP TABLE IF EXISTS `scv`.`temp_filtered_all`, `scv_report`.`temp_dow`;

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
IF(track_abbr = 'P' OR track_abbr = 'C') THEN
    SELECT PRISE INTO @prise_dow FROM scv.dow WHERE `STATE` = track_state AND `YEAR` = @year_race;
    IF prisemoney >= @prise_dow THEN 
        SET @DOW = 'Sat';
    ELSE 
        SET @DOW = 'Mid Week';
    END IF;
ELSEIF track_abbr = 'M' THEN
    IF prisemoney >= @prise_dow THEN 
        SET @DOW = 'Sat';
    ELSE 
        SET @DOW = 'Mid Week';
    END IF;
ELSE
    SET @DOW = 'Mid Week';
END IF;

IF FIND_IN_SET(@DOW, @whereClause_dow) OR @SAME = 'D.DOW AS SAME' THEN
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


END