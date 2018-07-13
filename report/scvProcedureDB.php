<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of scvProcedure
 *
 * @author yuxingw
 */
use Box\Spout\Writer\WriterFactory;
use Box\Spout\Common\Type;

class scvProcedureDB {
    private $setGlobVar_sql = "call setGlobVar(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    private $runReportBarrier_sql = "call report_barrier()";
    private $runReportState_sql = "call report_state()";
    private $runReportTrack_sql = "call report_track()";
    private $runReportWFA_sql = "call report_WFA()";
    private $runReportRaceClass_sql = "call report_raceclass()";
    private $runReportSex_sql = "call report_sex()";
    private $runReportDow_sql = "call report_DOW()";
	private $runReportPrise_sql = "call report_prise()";
	private $runReportTrackCond_sql = "call report_track_condition()";
    private $createResultTables_sql = "call create_result_tables()";
    private $runReportDayPreStart_sql = "call report_dayPreStart()";
    
    private $isEmptyResult_sql = "SELECT COUNT(DISTINCT(HR_HORSE)) AS horseCnt, SUM(cnt1) AS raceCnt FROM scv_report.temp_result_diff";
//    private $isEmptyResult_sql = "SELECT COUNT(DISTINCT(HR_HORSE)) AS horseCnt, SUM(cnt1) AS raceCnt FROM (SELECT HR_HORSE, cnt1 FROM scv_report.temp_result_diff GROUP BY HR_HORSE, HR_SAME, REPORT1) AS sub";
    private $selectIndividualReportElement_sql = "SELECT REPORT, COUNT(DISTINCT(W1_HORSE)) FROM scv.temp_horsname GROUP BY REPORT";
    
    private $selectTempResultDiff_sql = "SELECT * FROM temp_result_diff";// LIMIT 1000";
    private $selectTempValidFiltered_sql = "SELECT * FROM scv.temp_valid_filtered";// LIMIT 1000";
    
    function setGlobVar($whereClause, $whereClause_WFA, $whereClause_track, $whereClause_dow, $whereClause_magin, $horsmastUsed, $num_result, $least_run, $same, $daysBet, $dayPreStart, $reportCol, $mysqli){
        $stmt = $mysqli->prepare($this->setGlobVar_sql);
        
        if(!$stmt){
                echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
            
        if (!$stmt->bind_param('sssssiiisiis', $whereClause, $whereClause_WFA, $whereClause_track, $whereClause_dow, $whereClause_magin, $horsmastUsed, $num_result, $least_run, $same, $daysBet, $dayPreStart, $reportCol)) {
            echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
        }
            
            /* execute query */
            $stmt->execute();
    }
    
    function runReport($report, $mysqli){
        
        switch($report){
            case Variable::$barrier: 
                $stmt = $mysqli->prepare($this->runReportBarrier_sql); 
            break;
        
            case Variable::$state:
                $stmt = $mysqli->prepare($this->runReportState_sql); 
            break;
        
            case Variable::$raceClass:
                $stmt = $mysqli->prepare($this->runReportRaceClass_sql); 
            break;
        
            case Variable::$WFA: 
                $stmt = $mysqli->prepare($this->runReportWFA_sql); 
            break;
        
            case Variable::$sex:
                $stmt = $mysqli->prepare($this->runReportSex_sql);
            break;
        
            case Variable::$track:
                $stmt = $mysqli->prepare($this->runReportTrack_sql);
            break;
        
            case Variable::$DOW:
                $stmt = $mysqli->prepare($this->runReportDow_sql);
            break;
			
			case Variable::$prise:
				$stmt = $mysqli->prepare($this->runReportPrise_sql);
            break;

            case Variable::$trackCond:
                $stmt = $mysqli->prepare($this->runReportTrackCond_sql);
            break;

            case Variable::$dayPreStart:
                $stmt = $mysqli->prepare($this->runReportDayPreStart_sql);
        }
        
        if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
            
            /* execute query */
            $stmt->execute();
    }
    
    function createResultTables($mysqli){
         $stmt = $mysqli->prepare($this->createResultTables_sql); 
         
         if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
            
            /* execute query */
            $stmt->execute();
    }
    
    /** NOT USED */
    function isEmptyResult($mysqli){
        $stmt = $mysqli->prepare($this->isEmptyResult_sql);
        
        if(!$stmt){
//                echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
                return true;
        }
            
        /* execute query */
        $stmt->execute();
        
        $stmt->bind_result($horse_cnt, $race_cnt);
        
        while($row = $stmt->fetch()){
            $result = [$horse_cnt, $race_cnt];
        }
        
        return $result;
       
    }
    
    function selectIndividualReportElement($mysqli){
         $stmt = $mysqli->prepare($this->selectIndividualReportElement_sql);
         
         if(!$stmt){
                echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
        
        $stmt->execute();
        
        $stmt->bind_result($element, $cnt);
        
        $result = [];
        while($row = $stmt->fetch()){
            $result[] = [$element, $cnt];
        }
        return $result;
    }
    
    function getDataCheckTable($mysqli){
        $stmt = $mysqli->prepare($this->selectTempResultDiff_sql);
        
        if(!$stmt){
                echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
        
        $stmt->execute();
        
        $stmt->bind_result($HR_SAME, $HR_HORSE, $REPORT1, $RATING1, $cnt1, $REPORT2, $RATING2, $cnt2, $DIFF_AVG, $DIFF_MAX);
        
        $result = [];
        while($row = $stmt->fetch()){
            $result[] = [$HR_SAME, $HR_HORSE, $REPORT1, $RATING1, $cnt1, $REPORT2, $RATING2, $cnt2, $DIFF_AVG, $DIFF_MAX];
        }
        
        return $result;
    }
    
    function getHorseCheckTable($mysqli){
        $stmt = $mysqli->prepare("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'scv' AND TABLE_NAME = 'temp_valid_filtered'");
        $stmt->execute();
        $stmt->bind_result($col_name);
        $col = [];
        while($row = $stmt->fetch()){
            $col[] = $col_name;
        }
        $result[0] = $col;
		
        $stmt = $mysqli->prepare($this->selectTempValidFiltered_sql);
       
        $stmt->execute();
        
        $str = '';
        foreach($col as $val){
                $str .= '$' . $val . ',';
        }
        $str = trim($str, ',');
        eval('$stmt->bind_result('. $str . ");");
        
        while($row = $stmt->fetch()){
			eval(' $result[] = ['. $str . "];");
        }
        
        return $result;
    }
}
?>