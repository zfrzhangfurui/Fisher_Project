CREATE DEFINER=`root`@`localhost` PROCEDURE `create_result_tables`()
BEGIN

DROP TABLE IF EXISTS scv_report.temp_result_all, scv_report.temp_result_valid,scv_report.temp_result;

CREATE TABLE scv_report.temp_result_all
SELECT T1.HR_SAME,  T1.HR_HORSE,
T1.HR_REPORT AS REPORT1,  T1.AVG_RATING AS RATING1, T1.cnt AS cnt1,
T2.HR_REPORT AS REPORT2, T2.AVG_RATING AS RATING2, T2.cnt AS cnt2,
T1.AVG_RATING - T2.AVG_RATING AS DIFF_AVG,
T1.MAX_RATING - T2.MAX_RATING AS DIFF_MAX
FROM
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T1
INNER JOIN
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T2
ON T1.HR_HORSE = T2.HR_HORSE AND T1.HR_SAME = T2.HR_SAME AND T1.HR_REPORT <> T2.HR_REPORT;

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------
CREATE TABLE scv_report.temp_result_valid
SELECT *
FROM
(
SELECT T1.HR_SAME, -- T1.HR_HORSE,
T1.HR_REPORT AS REPORT1, -- T1.AVG_RATING AS RATING1, T1.cnt AS cnt1,
T2.HR_REPORT AS REPORT2 -- T2.AVG_RATING AS RATING2, T2.cnt AS cnt2,
-- T1.AVG_RATING - T2.AVG_RATING AS DIFF_AVG
FROM
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T1
INNER JOIN
(
SELECT * FROM
 scv_report.temp_AvgRating
) AS T2
ON T1.HR_HORSE = T2.HR_HORSE AND T1.HR_SAME = T2.HR_SAME AND T1.HR_REPORT <> T2.HR_REPORT
WHERE 1
GROUP BY T1.HR_SAME, T1.HR_REPORT, T2.HR_REPORT
HAVING COUNT(*) > 1

) AS SUB1;

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------

CREATE TABLE scv_report.temp_result_diff
SELECT 
T2.HR_SAME,  T2.HR_HORSE,
T2.REPORT1,  T2.RATING1, T2.cnt1,
T2.REPORT2, T2.RATING2, T2.cnt2,
T2.DIFF_AVG,
T2.DIFF_MAX
FROM
scv_report.temp_result_valid T1
INNER JOIN 
scv_report.temp_result_all  T2
 ON
T1.HR_SAME = T2.HR_SAME  AND T1.REPORT1 = T2.REPORT1 AND T1.REPORT2 = T2.REPORT2;

-- ---- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- ----------- -------
CREATE TABLE scv_report.temp_result
SELECT T1.REPORT1, T1.REPORT2, 
CAST(AVG(T1.AV) AS DECIMAL(5,1)) AS DIFF_AVG, CAST(AVG(T1.MA) AS DECIMAL(5,1)) AS DIFF_MAX
FROM 
(
SELECT HR_SAME, REPORT1, REPORT2, AVG(DIFF_AVG) AS AV, AVG(DIFF_MAX) AS MA FROM scv_report.temp_result_diff
GROUP BY HR_SAME, REPORT1, REPORT2
) AS T1
GROUP BY T1.REPORT1, T1.REPORT2;

END