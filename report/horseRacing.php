<?php 
ini_set('memory_limit','3000M');
ini_set('max_execution_time', 0);
ini_set('max_input_time',0);
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

$horseCheck = $proc->getHorseCheckTable($mysqli);
$dataCheck = $proc->getDataCheckTable($mysqli);
array_unshift($dataCheck, ["HR_SAME", "HR_HORSE", "REPORT1", "RATING1", "cnt1", "REPORT2", "RATING2", "cnt2", "DIFF_AVG", "DIFF_MAX"]);

$FilterCondition = new filterConditionDB();
$reportProducer = new reportProducer();

$report = $FilterCondition->getResults($mysqli);    
array_unshift($report, ["DIFF", "AVG", "MAX", "Cnt-Horse", "Cnt-Race"]);
/******************************** ********************************/

$individualReport=[];
$ExcelData = ["summary"=>$horseCnt, "report"=>$report, "dataCheck"=>$dataCheck, "horseCheck"=>$horseCheck];


/******************************** ********************************/


//----------------------------------------------------------------------------------------------------
use Box\Spout\Writer\WriterFactory;
use Box\Spout\Common\Type;
$writer = WriterFactory::create(Type::XLSX);
$writer->openToFile("./../csv/Report-$selectedReport.xlsx"); 
$reportProducer->spoutDownloadExcel($writer, $ExcelData);

echo json_encode([memory_get_peak_usage(), ["./../csv/Report-$selectedReport.xlsx"], time() - $_SERVER['REQUEST_TIME_FLOAT']."(s) "]);
exit;
//----------------------------------------------------------------------------------------------------
        
        
$PHPExcel = new PHPExcel();
$ExcelContent  = $reportProducer->DowloadExcel($PHPExcel, $ExcelData);
echo json_encode([memory_get_peak_usage(), $ExcelContent, time() - $_SERVER['REQUEST_TIME_FLOAT']."(s) "]);

?>