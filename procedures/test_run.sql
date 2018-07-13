/** New Approach - Select Any */
IF @dayPreStart >= 36500 THEN
        SET @temp_PreDate = wdate;
ELSE 
        SELECT MAX(W_DATE) INTO @temp_PreDate FROM scv.workrace WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
END IF;

IF @temp_PreDate IS NOT NULL AND DATEDIFF(wdate, @temp_PreDate) <= @dayPreStart THEN
        IF @daysBet >= 36500 THEN
                SET @temp_lastRunDate = wdate;
        ELSE
                SELECT MAX(W_DATE) INTO @temp_lastRunDate FROM scv.temp_filtered_all WHERE (W_DATE < wdate AND W_HORSE = horsename) OR (W_DATE = wdate AND W_HORSE = horsename AND W_RACE_NO <> raceNo);
        END IF;

        IF @temp_lastRunDate IS NOT NULL AND DATEDIFF(wdate, @temp_lastRunDate) <= @daysBet THEN
                SET @v_values = CONCAT(@v_values, '(', '"', horsename, '"', ',', '"',wdate,'"', ',', '"',track,'"' , ',', raceNo, ',', '"', reportCol, '"', ',', '"', sameCol, '"', '),');
                SET @_cnt = @_cnt + 1;
        END IF;
END IF;
/** New Approach - Select Any */