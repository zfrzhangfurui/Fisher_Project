CREATE TABLE scv.temp_horsname
SELECT S1.W1_HORSE, S1.W1_DATE, S1.W1_TRACK, S1.W1_RACE_NO, S1.REPORT, S1.SAME
FROM
(
SELECT T1.W1_HORSE, T1.W1_DATE, T1.W1_TRACK, T1.W1_RACE_NO, T1.REPORT, T1.SAME
FROM
scv.temp_horsnameT AS T1
INNER JOIN 
(
SELECT W1_HORSE
FROM scv.temp_horsnameT 
GROUP BY W1_HORSE 
HAVING  COUNT(*) >= @least_run -- AND DATEDIFF(MAX(W1_DATE), MIN(W1_DATE) ) <= @daysBet 
) AS T2
ON T1.W1_HORSE = T2.W1_HORSE
INNER JOIN
(
SELECT DISTINCT(W1_HORSE) AS W1_HORSE
FROM(
SELECT W1_HORSE
FROM scv.temp_horsnameT
GROUP BY W1_HORSE, SAME
HAVING COUNT(DISTINCT(REPORT)) >= 2
) AS _t3 
) AS T3
ON T1.W1_HORSE = T3.W1_HORSE
) AS S1
LEFT JOIN
(
SELECT W1_HORSE, SAME
FROM scv.temp_horsnameT
GROUP BY W1_HORSE, SAME
HAVING COUNT(DISTINCT(REPORT)) < 2
) AS S2
ON S1.W1_HORSE = S2.W1_HORSE  AND S1.SAME = S2.SAME
WHERE S2.W1_HORSE IS NULL; 