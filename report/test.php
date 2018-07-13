<?php 
ini_set('memory_limit','3000M');
ini_set('max_execution_time', 30000);
ini_set('max_input_time',3000);
include("ajaxFilterCondition.php");

//$whereClause = "WHERE M.M_STATE IN ('TAS', 'NSW') AND ((W.W_BAR_POS >= 1 AND W.W_BAR_POS <= 9) ) AND (R.R_CLASS LIKE '95B%' OR R.R_CLASS LIKE '90B%' OR R.R_CLASS LIKE '85B%' OR R.R_CLASS LIKE '80B%' OR R.R_CLASS LIKE 'OPN%' ) AND M.M_DATE >= '2016-04-05' AND M.M_DATE <= '2017-08-01' ";
//$whereClause_WFA = "";
//$whereClause_trackcat = "M";
//$whereClause_DOW = "Sat";
//$whereClause_magin = "";
//$horsmastUsed = 1;
//$num_result = 1000;
//$least_run = 3;
//$same = "CONCAT(M.M_STATE,'.',T.TRACK) AS SAME";
//$reportCol = "LEFT(R.R_CLASS, LOCATE('.',R.R_CLASS) - 1) AS REPORT";
//$selectedReport = Variable::$raceClass;

$parameters = ["whereClause"=>$whereClause . " (". strlen($whereClause) . ")", 
             "whereClause_WFA"=>$whereClause_WFA, 
             "whereClause_trackcat"=>$whereClause_trackcat, 
             "whereClause_DOW"=>$whereClause_DOW, 
             "whereClause_magin"=>$whereClause_magin, 
             "horsmastUsed"=>$horsmastUsed, 
             "num_result"=>$num_result, 
             "least_run"=>$least_run, 
             "same"=>$same,
             "daysBet"=>$daysBet,
             "dayPreStart"=>$dayPreStart,
             "selectedReport"=>$selectedReport,
             "reportCol"=>$reportCol];

if($testModel && $testModel != "false"){
    echo json_encode($parameters);
    exit;
}

$log = new Log($parameters);
$log->logFilterConditions();

foreach($parameters as $cond=>$para){
    if($cond == "whereClause" && strlen($para) >= 65535){
        echo 2;
        exit;
    }else if($cond != "whereClause" && strlen($para) >= 8000){
        echo 2;
        exit;
    }
}

$proc = new scvProcedureDB();

$proc->setGlobVar($whereClause, $whereClause_WFA, $whereClause_trackcat, $whereClause_DOW, $whereClause_magin, $horsmastUsed, $num_result, $least_run, $same, $daysBet, $dayPreStart, $reportCol, $mysqli);
$proc->runReport($selectedReport, $mysqli);
$proc->createResultTables($mysqli);


$dbconnection ->dbConnect("scv_report");
$mysqli = $dbconnection ->getConnection();
$horseCnt = $proc->isEmptyResult($mysqli);

if($horseCnt === true || ($horseCnt[0] == 0 && $horseCnt[1] == 0)){
    echo 1;
    exit;
}

$FilterCondition = new filterConditionDB();
$reportProducer = new reportProducer();

$result = $FilterCondition->getGroupedAvgRatingData($selectedReport, 0, $mysqli);    
$result_grouped = $result[0];
$result_all = $result[1];     

/******************************** ********************************/

foreach($result_grouped as $horsename=>$horseRaces)  
{
    
    
    foreach($horseRaces as $sameCond=>$horseRace)
    {
        (!trim($sameCond))?  $sameCond = "OPEN" : 1;  
        $cntArray = [];
        $dataAVG = $dataMax = [];
        $AVG = $MAX = [];
        foreach($horseRace as $race)
        {  
            $attr = $race[0];
            $cnt =  $race[1];
            $rateAvg = $race[2];
            $rateMax = $race[3];
            $dataAVG[$attr][] = $rateAvg; 
            $dataMax[$attr][] = $rateMax;
            $cntArray[$attr] += $cnt;
        }

        foreach($dataAVG as $report=>$value ){
            $AVG[$report][] = array_sum ($dataAVG[$report]) / sizeof($dataAVG[$report]);
            $MAX[$report][] = array_sum ($dataMax[$report]) / sizeof($dataMax[$report]);
        }

        foreach($AVG as $report=>$value )
        {
            $AVG[$report] = array_sum($AVG[$report]) / sizeof($AVG[$report]);
            $MAX[$report] = array_sum($MAX[$report]) / sizeof($MAX[$report]);
        }
        $AVG_SAMECOND[$sameCond][] = $reportProducer->getDiffReport($AVG, $MAX, $cntArray);
    }
}

foreach($AVG_SAMECOND as $sameCond => $mergeArray){
    if(sizeof($mergeArray > 1))
    {
       foreach($mergeArray as $mIndex => $diffArray){
            foreach($diffArray as $index => $diff){
                $instance = $diff[0];
                $AVG = $diff[1];
                $MAX = $diff[2];
                $fCnt = explode(" / ", $diff[3])[0];
                $sCnt = explode(" / ", $diff[3])[1];
                $diff_grouped[$sameCond][$instance][] = [$AVG, $MAX, $fCnt, $sCnt]; 
            }
        } 
    }
}

foreach($diff_grouped as $sameCond => $Array){
    foreach($Array as $instance => $instanceArray){
        if(sizeof($instanceArray) > 1){
            $AVG = $MAX = $fCnt = $sCnt = $cnt = 0;
            foreach($instanceArray as $index => $diff){
                $AVG += $diff[0];
                $MAX += $diff[1];
                $fCnt += $diff[2];
                $sCnt += $diff[3];
                $cnt++;
            }
            $data[$instance][] = [$AVG/$cnt, $MAX/$cnt, $fCnt, $sCnt];
        }
    }
}

foreach($data as $instanceName=> $instanceArray){
    $AVG = $MAX = $fCnt = $sCnt = [];
    foreach($instanceArray as $instance)
    {
        $AVG[] = $instance[0];
        $MAX[] = $instance[1];
        $fCnt[] = $instance[2];
        $sCnt[] = $instance[3];
    }
    $report_all[] = [$instanceName, round(array_sum($AVG)/sizeof($AVG), 1), round(array_sum($MAX) / sizeof($MAX), 1), array_sum($fCnt) . ' / '. array_sum($sCnt)];
}

usort($report_all, function($a, $b) {
    return strcasecmp($a[0], $b[0]);
});
array_unshift($report_all, ["DIFF", "AVG", "MAX", "CNT"]);



/******************************** ********************************/

$report_grouped = [];
$horseCnt[]= array_sum($cntArray);
$individualReport=[];
$summaryInfo = [$horseCnt, $individualReport];


/******************************** ********************************/


$PHPExcel = new PHPExcel();
$ExcelContent  = $reportProducer->DowloadExcel($PHPExcel, $summaryInfo, $report_grouped, $report_all);
echo json_encode([memory_get_peak_usage(), $ExcelContent, time() - $_SERVER['REQUEST_TIME_FLOAT']."(s) "]);

?>