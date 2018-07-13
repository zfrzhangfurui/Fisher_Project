CREATE DEFINER=`root`@`localhost` PROCEDURE `horse_1000`()
BEGIN


SET  @query_hname = CONCAT("
CREATE TABLE scv.temp_horsname
SELECT W.W_HORSE AS W1_HORSE
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
    " ", @WFAUsed, " ", 
    " ", @TRACKUsed, " ", 
    " ", @DOWUsed, " ", 
    " ", @MAGINUsed, " ",
 
    " ", @whereClause, " ",
    "GROUP BY W_HORSE HAVING COUNT(W_HORSE) >= ",
    " ", @least_run, " ",
    "ORDER BY W_DATE DESC LIMIT ", @num_result
    
    );

DROP TABLE IF EXISTS scv.temp_horsname;
PREPARE STMT_HNAME FROM @query_hname;
EXECUTE STMT_HNAME; 
DEALLOCATE PREPARE STMT_HNAME;

ALTER TABLE `scv`.`temp_horsname` 
ADD INDEX `idx_tp_hname_w1_horse` (`W1_HORSE` ASC);

END