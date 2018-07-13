CREATE DEFINER=`root`@`localhost` PROCEDURE `preCond_WFA`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE CWT DECIMAL(4,1);
DECLARE sex varchar(24);

DECLARE dist INT(11);
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
SELECT W_HORSE AS WFA_HORSE, W_DATE AS WFA_DATE, W_TRACK AS WFA_TRACK, W_RACE_NO AS WFA_RACE_NO, W_WGHT_CAR AS HWD FROM temp_filtered_all LIMIT 0;


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
        SET @year_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%Y' );
        SET @month_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%m' );
        SET @date_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%d' );
        
        IF dist < 1000 THEN
			SET dist = 1000;
		END IF;
            
         IF dist%200 <> 0 THEN
           SET dist =  FLOOR(dist/200) * 200 + 200;
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
        
        
        SET @HWD = CAST(@WFA - CWT AS DECIMAL(3,1));
        IF FIND_IN_SET(@HWD, @whereClause_WFA) OR @SAME = 'WFA.HWD AS SAME' THEN
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

END LOOP loop_race; 
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_WFA`
ADD INDEX `idx_tp_dow_wfa_horse` (`WFA_HORSE` ASC);

ALTER TABLE `scv_report`.`temp_WFA`
ADD INDEX `idx_tp_dow_wfa_date_track_race` (`WFA_DATE` ASC, `WFA_TRACK` ASC, `WFA_RACE_NO` ASC);



END