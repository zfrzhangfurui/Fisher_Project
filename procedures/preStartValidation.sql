CREATE DEFINER=`root`@`localhost` PROCEDURE `horse_1000`()
BEGIN


BEGIN
DECLARE wdate date;
DECLARE track varchar(4);
DECLARE raceNo INT(11);
DECLARE num_result INT(11);
DECLARE horsename varchar(24);

DECLARE cur1 CURSOR FOR SELECT * FROM `scv`.`temp_horsename`; 

SET @cnt = 0;
SET @_cnt = 0;
SET @v_values = '';
OPEN cur1;
SELECT FOUND_ROWS() into @row_num;
horse_1000: LOOP
FETCH cur1 INTO horsename, wdate, track, raceNo;
SET @cnt = @cnt + 1;

CREATE TABLE scv_report.preStartValidation
SELECT W1_HORSE, W1_DATE, W1_TRACK, W1_RACE_NO, W1_HORSE, W1_DATE, W1_TRACK, W1_RACE_NO FROM temp_horsename LIMIT 0;

IF (@_cnt%1000 = 0 AND @_cnt <> 0) OR (@cnt = @row_num) THEN
    SELECT COUNT(*) INTO @temp_sameDayRun FROM `scv`.`workrace` WHERE W_DATE = wdate AND W_HORSE = horsename;
    SELECT W_DATE, W_HORSE, W_TRACK, W_RACE_NO INTO @temp_PreDate FROM `scv`.`workrace` WHERE W_DATE < wdate AND W_HORSE = horsename ORDER BY W_DATE DESC LIMIT 1;

    IF DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart OR @temp_sameDayRun >=2 THEN
        SELECT MAX(W1_DATE), MIN(W1_DATE) INTO @max_date, @min_date FROM `scv`.`temp_horsnameT` WHERE W1_HORSE = horsename;
        IF(@max_date IS NULL OR (wdate >= @min_date AND wdate <= @max_date) OR (wdate < @min_date AND DATEDIFF(@max_date, wdate) <= @daysBet) OR (wdate > @max_date AND DATEDIFF(wdate, @min_date) <= @daysBet)) THEN
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',wdate,'"', ',', '"',track,'"' , ',', raceNo, '),');
            SET @_cnt = @_cnt + 1;
        END IF;
    END IF;
    
    SET @v_values = CONCAT(LEFT(@v_values, LENGTH(@v_values)-1), ';');
    
    
    SET @ins_query = CONCAT('INSERT INTO `scv`.`temp_horsnameT`(`W1_HORSE`, `W1_DATE`,`W1_TRACK`, `W1_RACE_NO`) VALUES', @v_values);
    PREPARE STMT FROM @ins_query;
    EXECUTE STMT;

    SET @v_values = '';
    SET @ins_query = '';

    SELECT COUNT(*) INTO @temp_least FROM (SELECT W1_HORSE FROM scv.temp_horsnameT GROUP BY W1_HORSE HAVING COUNT(*) >= @least_run AND DATEDIFF(MAX(W1_DATE), MIN(W1_DATE) ) <= @daysBet) as TAB;
    
    IF (@temp_least >= @num_result) THEN
        LEAVE horse_1000;
    END IF;
ELSE 
    SELECT COUNT(*) INTO @temp_sameDayRun FROM `scv`.`workrace` WHERE W_DATE = wdate AND W_HORSE = horsename;
    SELECT W_DATE INTO @temp_PreDate FROM `scv`.`workrace` WHERE W_DATE < wdate AND W_HORSE = horsename ORDER BY W_DATE DESC LIMIT 1;
    IF DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart OR @temp_sameDayRun >=2 THEN
        SELECT MAX(W1_DATE), MIN(W1_DATE) INTO @max_date, @min_date FROM `scv`.`temp_horsnameT` WHERE W1_HORSE = horsename;
        IF(@max_date IS NULL OR (wdate >= @min_date AND wdate <= @max_date) OR (wdate < @min_date AND DATEDIFF(@max_date, wdate) <= @daysBet) OR (wdate > @max_date AND DATEDIFF(wdate, @min_date) <= @daysBet))THEN
            SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',wdate,'"', ',', '"',track,'"' , ',', raceNo, '),');
            SET @_cnt = @_cnt + 1;
        END IF;
        
    END IF;
    
END IF;

IF @cnt = @row_num THEN LEAVE horse_1000; END IF;

SET @p_date = wdate;
END LOOP;
CLOSE cur1;
DEALLOCATE PREPARE STMT;


SET num_result  = @num_result;
CREATE TABLE scv.temp_horsname
SELECT  T1.W1_HORSE, T1.W1_DATE, T1.W1_TRACK, T1.W1_RACE_NO
FROM 
scv.temp_horsnameT AS T1
INNER JOIN 
(
SELECT W1_HORSE
FROM scv.temp_horsnameT 
GROUP BY W1_HORSE HAVING COUNT(*) >= @least_run AND DATEDIFF(MAX(W1_DATE), MIN(W1_DATE) ) <= @daysBet ORDER BY COUNT(*) DESC LIMIT num_result
) AS T2
ON T1.W1_HORSE = T2.W1_HORSE;



ALTER TABLE `scv`.`temp_horsname`
ADD INDEX `idx_tp_hname_w1_horse_date_track_raceNo` (`W1_HORSE` ASC, `W1_DATE` ASC, `W1_TRACK` ASC, `W1_RACE_NO` ASC);

END;
END