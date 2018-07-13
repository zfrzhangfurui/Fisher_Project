CREATE DEFINER=`root`@`localhost` PROCEDURE `report_WFA`()
BEGIN

DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE horsename varchar(24);
DECLARE CWT DECIMAL(4,1);
DECLARE sex varchar(24);
DECLARE same_col varchar(24);

DECLARE sec_mar varchar(4);
DECLARE dist INT(11);
DECLARE rating DECIMAL(5,1);
DECLARE age_now INT(11);
DECLARE cnt INT(11);

DECLARE done INT DEFAULT 0;
DECLARE work_race CURSOR FOR SELECT W_DATE, W_TRACK, W_RACE_NO, W_HORSE, W_WGHT_CAR, R_DISTANCE, H_WIN_AGE, A_RATE, R_SEX, SAME FROM temp_valid_filtered;


call horse_1000();    

SET @query_all = CONCAT("
CREATE TABLE temp_valid_filtered 
SELECT 
     W.W_DATE, W.W_TRACK, W.W_RACE_NO, W.W_HORSE, W.W_WGHT_CAR, R.R_DISTANCE, W.W_BEAT_MAR, W.W_FIN_POS, H.H_WIN_AGE,
     
     CAST( (1000 + A.A_POINTS - W.W_BEAT_MAR * A.A_MRJ) AS DECIMAL(5,1)) AS A_RATE, 
     
     R.R_SEX, W1.SAME ", 
     
"FROM",
    
    " ", @table_joins, " ",
	" ", @horsmastUsed, " ",
    " ", @WFAUsed, " ",
    " ", @TRACKUsed, " ",
    " ", @DOWUsed, " ",
    " ", @MAGINUsed, " ",

        "INNER JOIN
	alg_rating A ON A.A_FIN_POS = W.W_FIN_POS ", 
        
        @whereClause

);


DROP TABLE IF EXISTS temp_valid_filtered, scv_report.temp_horserate, scv_report.temp_AvgRating_WFA;


PREPARE STMT_ALL FROM @query_all;
EXECUTE STMT_ALL;
DEALLOCATE PREPARE STMT_ALL;

ALTER TABLE `scv`.`temp_valid_filtered` 
ADD INDEX `idx_tp_filt_all_w_date_track_race` (`W_DATE` ASC, `W_TRACK` ASC, `W_RACE_NO` ASC);


CREATE TABLE `scv_report`.`temp_horserate`
SELECT SAME AS HR_SAME, W_HORSE AS HR_HORSE, W_WGHT_CAR AS HR_WGHT_CAR, W_WGHT_CAR AS HR_WFA, A_RATE AS HR_RATE FROM temp_valid_filtered LIMIT 0;


SET @year_now = date_format(str_to_date( NOW(), '%Y-%m-%d %H:%i:%s' ) , '%Y' );
SET @WFA = NULL;
SET @allowance = 0;
SET @BaseRating = 1000;
SET @cnt = 0;
SET @v_values = '';


OPEN work_race;
SELECT FOUND_ROWS() into @row_num;
loop_race: LOOP
    FETCH work_race INTO wdate, track, raceNo, horsename, CWT, dist, age_now, rating, sex, same_col;
        SET @cnt = @cnt + 1;
        SET @year_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%Y' );
        SET @month_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%m' );
        SET @date_race = date_format( str_to_date( wdate, '%Y-%m-%d' ) , '%d' );
        IF rating = 1200 THEN
            SELECT W_BEAT_MAR INTO sec_mar FROM workrace WHERE W_DATE = wdate AND W_TRACK = track AND W_RACE_NO = raceNo AND W_FIN_POS = 2 LIMIT 1;
            SET rating = 200 + sec_mar * 30 + @BaseRating;

        END IF;
        
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
        
        IF wdate >= '1977-08-01' AND wdate < '1998-08-01'  THEN
            SELECT `1.8.77` into @WFA FROM scv.WFA WHERE DISTANCE = dist AND AGE = @age_race AND `MONTH` = @month_race AND `DATE` = @date_race;
        ELSEIF wdate >= '1998-08-01' AND wdate < '2007-01-01' THEN
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
        IF horsename IS NULL OR CWT IS NULL OR @WFA IS NULL OR rating IS NULL THEN
                SELECT "NULL VALUE FOUND" AS `Error`, CWT, @WFA, rating;
                LEAVE loop_race;
        END IF;
            
        IF (@cnt%1000 = 0) OR (@cnt = @row_num) THEN
             SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', CWT, '"', ',', '"', @WFA, '"', ',', rating,',','"', same_col, '"', ' );');
             SET @ins_query = CONCAT('INSERT INTO `scv_report`.`temp_horserate`(`HR_HORSE`, `HR_WGHT_CAR`, `HR_WFA`, `HR_RATE`, `HR_SAME`) VALUES ', @v_values);
             PREPARE STMT FROM @ins_query;
             EXECUTE STMT; -- USING @v_values;
             DEALLOCATE PREPARE STMT;

			 SET @v_values = '';
             SET @ins_query = '';
        ELSE 
       
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"', CWT, '"', ',', '"', @WFA, '"', ',', rating,',','"', same_col, '"', ' ),');

        END IF;

        /** leave loop */
        IF @cnt = @row_num THEN 
            LEAVE loop_race;
        END IF;

END LOOP loop_race;
CLOSE work_race;


ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_horse_wfa` (`HR_HORSE` ASC, `HR_WGHT_CAR` ASC, `HR_WFA` ASC);

ALTER TABLE `scv_report`.`temp_horserate`
ADD INDEX `idx_HR_same` (`HR_SAME` ASC);


/** AVG Rating */
CREATE TABLE `scv_report`.`temp_AvgRating_WFA`
SELECT 
T.HR_SAME,
T.HR_HORSE, 
T.HR_HWD, 
SUM(T.cnt) AS cnt, 
CAST(AVG(T.AVG_RATING) AS DECIMAL(5,1)) AS AVG_RATING,
CAST(MAX(T.MAX_RATING) AS DECIMAL(5,1)) AS MAX_RATING
FROM
(
SELECT 
    HR_SAME,
    HR_HORSE,
    CAST( (HR_WFA - HR_WGHT_CAR) AS DECIMAL (5, 1 ))  AS HR_HWD,
    COUNT(*) AS cnt,
    AVG(HR_RATE) AS AVG_RATING,
    MAX(HR_RATE) AS MAX_RATING
FROM
    scv_report.temp_horserate
GROUP BY HR_SAME, HR_HORSE, HR_HWD
) AS T

GROUP BY HR_HORSE , HR_HWD
ORDER BY HR_SAME, HR_HWD, HR_HORSE;


END