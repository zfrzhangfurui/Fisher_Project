<?php
error_reporting(0);
//ini_set('display_errors', 1);
//ini_set('display_startup_errors', 1);
//error_reporting(E_ALL);
include('includes.php');
include('./../serv-components/PHPExcel-1.8/Classes/PHPExcel.php');
include('./../serv-components/spout-2.7.3/src/Spout/Autoloader/autoload.php');
include('./../serv-components/Log.php');


$dbconnection = new DBConnection();
$dbconnection ->setAddress($dbaddress);
$dbconnection ->setUsername($dbusername);
$dbconnection ->setPassword($dbpassword);
$dbconnection ->dbConnect($dbname);
$mysqli = $dbconnection ->getConnection();

$action = $_POST['action'];

if($action == "startReport") {

$testModel = $_POST['testModel'];
        
$result = json_decode($_POST['report']);
$selectedReport = $_POST['selectedReport'];
$reportCol = getReportColumn($selectedReport);
$same = getSameAsOneElement(json_decode($_POST['same']), $selectedReport);

$num_result = $_POST['numOfHorse'] * 1;

$arr = [];
$whereClause = ["WHERE"];
$whereClause_trackcat = $whereClause_DOW = $whereClause_WFA = $whereClause_magin = "";
   
foreach ($result as $key => $value) {
       $arr[$key] = (!$value || $value == "NaN-undefined-NaN" || $value == "NaN-undefined-aN" || $value == "NULL" || $value == "null")? 0 : $value; 	
       if(is_array($arr[$key]))
       {
           foreach($arr[$key] as $k=>$val){
               $arr[$key][$k] = trim(trim(trim($val), ","));
               
               if($key == "DOW")
               {
                   $arr[$key][$k] = getDOWForShort($val);
               }
               
               if($arr[$key][$k] == "" || !$arr[$key][$k]) 
               {
                   unset($arr[$key][$k]);
                   if(sizeof($arr[$key]) == 0)
                   {
                       $arr[$key] = 0;
                   }
               }
           }
       }
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
    
if($arr['state'] !== 0){
    $i = 0;
    //$arrayLongth = count($arr['state']);
    foreach ($arr['state'] as $value){ 
        if($i == 0){
            $state ='\'' .$value.'\'';
        }else if($i > 0){
            $state = $state.','.'\'' .$value.'\'';
        }
        $i++;
    }  
    $state = 'AND M.M_STATE IN ('.$state.')';
    $whereClause[] = $state;
}


if($arr['age'] !== 0){
    $i = 0;
    foreach ($arr['age'] as $value){ 
        $value = ($value == "open")? '  ' : $value;
        if($i == 0){
            $ages ='\'' .$value.'\'';
        }else if($i > 0){
            $ages .= ','.'\'' .$value.'\'';
        }
        $i++;
        
    }
    
    $age = "AND SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -3), '.', 1) IN ($ages)";
    $whereClause[] = $age;
} 
      

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['barrier'] !== 0){
    $i = 0;
    $range = [];
    foreach ($arr['barrier'] as $key=>$value){
        if(strpos($value, '-') !== FALSE)
        {
           $n = explode('-', $value);
           
           if(is_numeric($n[0]) && is_numeric($n[1]) ){
               $n[0] = (int)$n[0]; 
               $n[1] = (int)$n[1]; 
               $range[] = [$n[0], $n[1]];
           }
        }
        else if($i == 0){
            $barrier = (int)$value;
        }else if($i > 0){
            $barrier = $barrier.','.(int)$value;
        }
        $i++;
    }
    
    $barrier = trim($barrier, ',');
    if(sizeof($range) == 0)
    {
        $whereClause_barrier = "AND W.W_BAR_POS IN ($barrier)"; 
    }
    else if(strlen($barrier) == 0)
    {
        $whereClause_barrier = "AND (";
        foreach($range as $val){
            $whereClause_barrier .= "(W.W_BAR_POS >= $val[0] AND W.W_BAR_POS <= $val[1]) OR ";
        }
        $whereClause_barrier = trim(trim($whereClause_barrier), "OR");
        $whereClause_barrier .= ")";
    }
    else
    {
        $whereClause_barrier = "AND (";
        $whereClause_barrier .= "W.W_BAR_POS IN ($barrier)";
        foreach($range as $val){
            $whereClause_barrier .= " OR (W.W_BAR_POS >= $val[0] AND W.W_BAR_POS <= $val[1])";
        }
        $whereClause_barrier .= ")";
    }
   $whereClause[] = $whereClause_barrier;
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['WFA'] !== 0){
    
    $i = 0;
    foreach ($arr['WFA'] as $key=>$value){
        
        if(is_numeric($value) && $value < 0)
        {
            $value = number_format((float)$value, 1, '.', '');
            ($i == 0)? $WFA = $value : $WFA = $WFA.",".$value;
        }
        else if(strpos($value, '--') !== FALSE) // 
        {
           $n = explode('--', $value);
           if(is_numeric($n[0]) && is_numeric($n[1])){
                for($m=0; $m<=abs($n[1]*-1 - $n[0]);$m = $m+0.5){
                    $hVal = number_format((float)($m*-1 + $n[0]), 1, '.', '');
                    ($i==0 && $m==0)? $WFA = $hVal : $WFA = $WFA.",".$hVal;
                }
           }
        }
        else if(sizeof(explode('-', $value)) > 2 )
        {
           $n = explode('-', $value);
           if(is_numeric($n[1]) && is_numeric($n[2])){
                for($m=0; $m<=abs($n[1] + $n[2]);$m = $m+0.5){
                    $hVal = number_format((float)($m - $n[1]), 1, '.', '');
                    ($i==0 && $m==0)? $WFA = $hVal : $WFA = $WFA.",".$hVal;
                }
           }
        }
        else if(strpos($value, '-') !== FALSE)
        {
           $n = explode('-', $value);
           
           if(is_numeric($n[0]) && is_numeric($n[1])){
                for($m=0; $m<=$n[1]-$n[0];$m = $m+0.5){
                    $hVal = number_format((float)($m+$n[0]), 1, '.', '');
                    ($i==0 && $m==0)? $WFA = $hVal : $WFA = $WFA.",".$hVal;
                }
           }
        }
        else if($i == 0){
            $value = number_format((float)$value, 1, '.', '');
            $WFA = $value;
        }else if($i > 0){
            $value = number_format((float)$value, 1, '.', '');
            $WFA = $WFA.",".$value;
        }
        $i++;
    }
   $whereClause_WFA = ($WFA)? $WFA : "";   
    
     
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['raceClass'] !== 0){
    $i = 0;
    foreach ($arr['raceClass'] as $value){
                if($i == 0){
                    $raceClass = "(R.R_CLASS LIKE '$value%' ";
                }else if($i > 0){
                    $raceClass .= "OR R.R_CLASS LIKE '$value%' ";
                }
                
                $i++;
            }
            $raceClass .= ")";
    $whereClause_raceClass = "AND $raceClass";   
    $whereClause[] = $whereClause_raceClass;
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['sex'] !== 0){
    $i = 0;
    foreach ($arr['sex'] as $value){
        ($value == "Open")? $value = ' ' : 1;
        if($i == 0){
            $sex ='\'' .$value.'\'';
        }else if($i > 0){
            $sex = $sex.','.'\'' .$value.'\'';
        }
        $i++;
    }
    
    $whereClause_sex = "AND R.R_SEX IN ($sex)";  
    $whereClause[] = $whereClause_sex;
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
 
if($arr['trackcat'] !== 0){
    $i = 0;
    foreach ($arr['trackcat'] as $value){
        if($i == 0){
            $trackcat =$value;
        }else if($i > 0){
            $trackcat = $trackcat.','.$value;
        }
        $i++;
    }
    
    $whereClause_trackcat = $trackcat; 
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['DOW'] !== 0){
    $i = 0;
    foreach ($arr['DOW'] as $value){
        if($i == 0){
            $DOW = $value;
        }else if($i > 0){
            $DOW = $DOW. ',' .$value ;
        }
        $i++;
    }
    
    $whereClause_DOW = $DOW;   
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
//    if($arr['finishPos'] !== 0){
//        $i = 0;
//        foreach ($arr['finishPos'] as $key=>$value){
//            if(strpos($value, '-') !== FALSE){
//                $n = explode('-', $value);
//                if(is_numeric($n[0]) && is_numeric($n[1])){
//                    for($m=0; $m<=$n[1]-$n[0];$m++){
//                        $finishPos .= ($i==0 && $m==0)? $m+$n[0] : ",".($m+$n[0]);
//                    }
//                }
//            }
//            else if($i == 0){
//                $finishPos = $value;
//            }else if($i > 0){
//                $finishPos = $finishPos.",".$value;
//            }
//
//            $i++;
//        }
//
//        $whereClause_finishPos = $finishPos;
//        $whereClause[] = "AND W.W_FIN_POS IN ($whereClause_finishPos)";
//    }
if($arr['day'] !== 0){
    $dayPreStart = $arr['day'];
}else{
    $dayPreStart = 36500;
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['daysBewRaceDay'] !== 0){
    $daysBet = $arr['daysBewRaceDay'];
}else{
    $daysBet = 36500;
}

if($arr['dateFrom'] !== 0){
    $dateFrom = $arr['dateFrom'];
    
    $whereClause_dateFrom = "AND M.M_DATE >= '$dateFrom'";
    $whereClause[] = $whereClause_dateFrom;
    
}

if($arr['dateTo'] !== 0){
    $dateTo = $arr['dateTo'];
    
    $whereClause_dateTo = "AND M.M_DATE <= '$dateTo'";
    $whereClause[] = $whereClause_dateTo;
    
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['trackcondition'] !== 0){
    $i = 0;
    foreach ($arr['trackcondition'] as $value){
        if($i == 0){
            $trackcondition ='\'' .$value.'\'';
        }else if($i > 0){
            $trackcondition = $trackcondition.','.'\'' .$value.'\'';
        }
        $i++;
    }
    
    $whereClause_trackcondition = "AND R.R_TR_COND IN ($trackcondition)";   
    $whereClause[] = $whereClause_trackcondition;
}
/*-----------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['rTcLong'] !== 0){
    $i = 0;
    foreach ($arr['rTcLong'] as $value){
        if($i == 0){
            $r_tc_long ='\'' .$value.'\'';
        }else if($i > 0){
            $r_tc_long = $r_tc_long.','.'\'' .$value.'\'';
        }
        $i++;
    }

    $whereClause_r_tc_long = "AND R.R_TC_LONG IN ($r_tc_long)";
    $whereClause[] = $whereClause_r_tc_long;
}
/*-----------------------------------------------------------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['jockey'] !== 0){
    $i = 0;
    foreach ($arr['jockey'] as $value){
        if($i == 0){
            $jockey ='\'' .$value.'\'';
        }else if($i > 0){
            $jockey = $jockey.','.'\'' .$value.'\'';
        }
        $i++;
    }
    
    $whereClause_jockey = $jockey;   
    $whereClause[] = "AND W.W_JOCKEY IN ($whereClause_jockey)";
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['magin'] !== 0){
    
    $i = 0;
    foreach ($arr['magin'] as $key=>$value){
        if(strpos($value, '-') !== FALSE){
           $n = explode('-', $value);
           
           if(is_numeric($n[0]) && is_numeric($n[1])){
                for($m=0; $m<= (float)($n[1]-$n[0]);$m = $m+0.1){
                    $hVal = getFormattedMagin($m+$n[0]);
                    ($i==0 && $m==0)? $magin = $hVal : $magin = $magin.",".$hVal;
                }
                //Do not know why? (float)?
                if($n[1]-$n[0] > 1){
                    $hVal = number_format((float)($m+$n[0]), 1, '.', '');
                    ($hVal < 1 && $hVal != 0)? $hVal = ".".($hVal*10) . ','. $hVal . ",.".($hVal*10)."+" : 1;
                    ($hVal == 0)? $hVal = '0,0.0' : 1;
                    ($hVal >= 1)? $hVal =  $hVal . ",".$hVal."+" : 1;
                    if($hVal*10%10 == 0 && $hVal != 0){
                        $hVal = number_format((float)($m+$n[0]), 1, '.', '');
                        $hVal = (int)$hVal. ',' .$hVal . ",".$hVal."+";
                    }
                    $magin = $magin.",".$hVal;
                }
           }
        }
        else if($i == 0){
            $value = number_format((float)$value, 1, '.', '');
            $hVal = getFormattedMagin($value);
            $magin = $hVal;
        }else if($i > 0){
            $value = number_format((float)$value, 1, '.', '');
            $hVal = getFormattedMagin($value);
            $magin = $magin.",".$hVal;
        }
        
        $i++;
    }
    
    $whereClause_magin = ($magin)? $magin : ""; 
}
/*-----------------------------------------------------------------------------------------------------------------------------*/

if($arr['finishPos'] !== 0){
    $i = 0;
    foreach ($arr['finishPos'] as $key=>$value){
        if(strpos($value, '-') !== FALSE){
           $n = explode('-', $value);
           if(is_numeric($n[0]) && is_numeric($n[1])){
                for($m=0; $m<=$n[1]-$n[0];$m++){
                    $finishPos .= ($i==0 && $m==0)? $m+$n[0] : ",".($m+$n[0]);
                }
           }
        }
        else if($i == 0){
            $finishPos = $value;
        }else if($i > 0){
            $finishPos = $finishPos.",".$value;
        }
        
        $i++;
    }
    
    $whereClause_finishPos = $finishPos; 
    $whereClause[] = "AND W.W_FIN_POS IN ($whereClause_finishPos)";
}
/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['prise'] !== 0){
    $i = 0;
    $range = [];
    foreach ($arr['prise'] as $key=>$value){
        if(strpos($value, '-') !== FALSE)
        {
           $n = explode('-', $value);
           if(is_numeric($n[0]) && is_numeric($n[1]) ){
                $n[0] = number_format((float)($n[0]), 1, '.', '');
                $n[1] = number_format((float)($n[1]), 1, '.', '');
                $range[] = [$n[0], $n[1]];
           }
        }
        else if($i == 0){
            $value = number_format((float)($value), 1, '.', '');
            $prise = $value;
        }else if($i > 0){
            $value = number_format((float)($value), 1, '.', '');
            $prise = $prise.','.$value;
        }
        $i++;
    }
    $prise = trim($prise, ',');
    if(sizeof($range) == 0)
    {
        $prise = "AND R.R_VALUE IN ($prise)"; 
    }
    else if(strlen($prise) == 0)
    {
        $prise = "AND (";
        foreach($range as $val){
            $prise .= "(R.R_VALUE >= $val[0] AND R.R_VALUE <= $val[1]) OR ";
        }
        $prise = trim(trim($prise), "OR");
        $prise .= ")";
    }
    else
    {
        $prise = "AND (R.R_VALUE IN ($prise)"; 
        foreach($range as $val){
            $prise .= " OR (R.R_VALUE >= $val[0] AND R.R_VALUE <= $val[1])";
        }
        $prise .= ")";
    }
    
    $whereClause_prise = $prise;  
    $whereClause[] = $whereClause_prise;
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['distanceFrom'] !== 0){
    $distanceFrom = $arr['distanceFrom'];
     $whereClause[] = "AND R.R_DISTANCE >= $distanceFrom";
}

if($arr['distanceTo'] !== 0){
    $distanceTo = $arr['distanceTo'];
    $whereClause[] = "AND R.R_DISTANCE <= $distanceTo";
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['handicap'] !== 0){
    $i = 0;
    foreach ($arr['handicap'] as $value){
        ($value == "OPEN")? $value="." : 1;
        if($i == 0){
            $handicap = "(R.R_CLASS LIKE '%$value' ";
        }else if($i > 0){
            $handicap .= "OR R.R_CLASS LIKE '%$value' ";
        }
        $i++;
    }
    $handicap .= ")";
    $whereClause_handicap = "AND $handicap";
    $whereClause[] = $whereClause_handicap;
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
if($arr['leastRun'] !== 0){
    $least_run = $arr['leastRun'];
}

$whereClause[] = "AND W.W_WGHT_CAR NOT IN ('uk', 'PEND')";
if($arr['WFA'] !== 0 || $selectedReport == Variable::$WFA || strpos($same, 'WFA.HWD') !== FALSE){
    $horsmastUsed = 1;
	$whereClause[] = "AND H.H_WIN_AGE <> 0";
}else{
    $horsmastUsed = 0;
}

if(sizeof($whereClause) == 1)
{
    $whereClause = "WHERE 1";
}
else 
{
    $whereClause[1] = trim($whereClause[1], "AND ");
    $whereClause = implode(" ", $whereClause);
 }





//exit;

/*-----------------------------------------------------------------------------------------------------------------------------*/

}


if($action == "getRaceClasses"){
    
    $filter = new filterConditionDB();
    $result = $filter->getRaceClasses($mysqli);
    
    foreach($result as $categ=>$classes){
        $category[] = $categ;
    }
    
    $return = [$category, $result];
    echo json_encode($return);
}

if($action == "getReportVariables"){
    $var = new Variable();
    echo json_encode($var->getVariables());
}

function getDOWForShort($dow)
{
    switch($dow)
    {
        case 'MetroSat':
            $return = "Sat";
        break;
        case 'MetroMidWeek':
            $return = "Mid Week";
        break;
        case 'ProSat':
            $return = "P";
        break;
        case 'ProMidWeek':
            $return = "P";
        break;
        case 'CountrySat':
            $return = "C";
        break;
        case 'CountryMidWeek':
            $return = "C";
        break;
        case 'Picnic':
            $return = "N";
        break;
        
        default: $return = $dow;
    }
    
    return $return;
}

function getFormattedMagin($value){
    $hVal = number_format((float)($value), 1, '.', '');
    ($hVal < 1 && $hVal != 0)? $hVal = ".".($hVal*10) . ','. $hVal . ",.".($hVal*10)."+" : 1;
    ($hVal == 0)? $hVal = '0,0.0' : 1;
    ($hVal >= 1)? $hVal =  $hVal . ",".$hVal."+" : 1;
    if($hVal*10%10 == 0 && $hVal != 0){
        $hVal = number_format((float)($value), 1, '.', '');
        $hVal = (int)$hVal. ',' .$hVal . ",".$hVal."+";
    }
    
    return $hVal;
}

function getSameAsOneElement($array, $selectedReport){

    $hasSetSame = false;
    foreach($array as $key=>$value){
        if($value){
            $same .= getSameColumnName($key) . ",'::',";
            $hasSetSame = true;
        }
    }
    if(!$hasSetSame){
        $same = "'$selectedReport' AS SAME";
    }else{
        $same = trim($same, ",'::',");
//        $same = trim($same,"'.',");
        $same = "CONCAT(" . $same . ") AS SAME";
    }
    
    return  $same;
}

function getSameColumnName($element){
    switch($element){
        case "barrier":
            $same = "W.W_BAR_POS";
        break;
        case "WFA":
            $same = "WFA.HWD";
        break;
        case "raceClass":
            $same = "LEFT(R.R_CLASS, LOCATE('.',R.R_CLASS) - 1)";
        break;
        case "state":
            $same = "M.M_STATE";
        break;
        case "sex":
            $same = "R.R_SEX";
        break;
        case "trackCat":
            $same = "T.TRACK";
        break;     
        case "DOW":
            $same = "D.DOW";
        break; 
        case "age":
            $same = "SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.', -3), '.', 1)";
        break; 
        case "trackCond":
            $same = "R.R_TR_COND";
        break; 
        case "jockey":
            $same = "W.W_JOCKEY";
        break; 
        case "magin":
            $same = "MA.MAGIN";
        break; 
        case "finishPos":
            $same = "W.W_FIN_POS";
        break; 
        case "prise":
            $same = "R.R_VALUE";
        break; 
        case "date":
            $same = "W.W_DATE";
        break; 
        case "distance":
            $same = "R.R_DISTANCE";
        break; 
        case "handicap":
            $same = "SUBSTRING_INDEX( SUBSTRING_INDEX(R.R_CLASS, '.' , -1), '.'' , 1)";
        break; 
    }
    
    return $same;
}

function getReportColumn($report){
    switch($report){
        case Variable::$barrier:
            $element = "W.W_BAR_POS AS REPORT";
        break;
        
        case Variable::$track:
            $element = "T.TRACK AS REPORT";
        break;

        case Variable::$raceClass:
            $element = "LEFT(R.R_CLASS, LOCATE('.',R.R_CLASS) - 1) AS REPORT";
        break;

        case Variable::$WFA: 
            $element = "WFA.HWD AS REPORT";
        break;

        case Variable::$sex: 
            $element = "R.R_SEX AS REPORT";
        break;

        case Variable::$state:
            $element = "M.M_STATE AS REPORT";
        break;

        case Variable::$DOW:
            $element = "D.DOW AS REPORT";
        break;
		
		case Variable::$prise:
			$element = "R.R_VALUE AS REPORT";
        break;

        case Variable::$trackCond:
            $element = "R.R_TR_COND AS REPORT";
        break;
    }
        
        return $element;
}