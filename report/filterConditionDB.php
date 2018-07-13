<?php

class filterConditionDB {
    private $selectResults_sql = "SELECT * FROM `temp_result`";
    private $getPreviousStartDate = "SELECT MAX(M_DATE) FROM scv.meetmast";
    private $getRaceClasses = "SELECT category, class FROM scv.race_class WHERE 1 ORDER BY category";
    
    private $insert_reportSetting_sql = "INSERT INTO `filter_conditions` (settingName ,barrier,WFA,"
             . "raceClass,state,sex,trackcat,DOW,age,trackCon,r_tc_long,jockey,magin,finishPos,priseMoney"
             . ",day,daysBewRaceDay,dateFrom,dateTo,distanceFrom,distanceTo,handicap,leastRaceHorse,report_on,same)"
             . " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
     
    private $update_reportSetting_sql = "UPDATE `filter_conditions` SET settings = ? WHERE settingName = ?";
    private $load_reportSetting_sql = "SELECT * FROM `filter_conditions` ORDER BY `date_time` DESC";
    private $delete_reportSetting_sql = "DELETE FROM `filter_conditions` WHERE settingName = ?";
   
   // NOT USED
   function getCurrentSheet($searchType,$HR_RATE, $mysqli){
        $mysqli->query('SET NAMES utf8');       

        //Prepare
        switch($searchType){
            case Variable::$barrier: 
                $stmt = $mysqli->prepare($this->selectBarrier_sql); 
            break;

            case Variable::$track:$stmt = $mysqli->prepare($this->selectTrack_sql); 
            break;

            case Variable::$raceClass:
                $stmt = $mysqli->prepare($this->selectClass_sql); 
            break;

            case Variable::$WFA: 
                $stmt = $mysqli->prepare($this->selectWFA_sql); 
            break;

            case Variable::$sex: 
                $stmt = $mysqli->prepare($this->selectSex_sql);
            break;

            case Variable::$state:
                $stmt = $mysqli->prepare($this->selectState_sql);
            break;

            case Variable::$DOW:
                $stmt = $mysqli->prepare($this->selectDow_sql);
            break;
        }

        if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }

        //Bind
        if (!$stmt->bind_param('d', $HR_RATE)) {
            echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
        }

        /* execute query */
        $stmt->execute();
        switch ($searchType) {
            case Variable::$barrier:
                $stmt->bind_result($same, $horse, $barrier, $rating); 
            break;

            case Variable::$track:
                $stmt->bind_result($same, $horse,$track,$rating); 
            break;

            case Variable::$raceClass:
                $stmt->bind_result($same, $horse,$raceClass,$rating); 
            break;

            case Variable::$WFA: 
                $stmt->bind_result($same, $horse,$HWD,$rating); 
            break;

            case Variable::$sex:
                $stmt->bind_result($same, $horse,$sex,$rating);
            break;

            case Variable::$state:
                $stmt->bind_result($same, $horse,$state,$rating);
            break;

            case Variable::$DOW:
                $stmt->bind_result($same, $horse, $DOW, $rating);
            break;
        }

        /* now you can fetch the results into an array - NICE */
        $result = [];
        $instance = [];
        while ($rows = $stmt->fetch()) { 
            if(isset($sex)){
                if($sex == " "){
                    $sex = "open";
                }
            }

            switch ($searchType) {
                case Variable::$barrier:
                    $instance["barrier"] = $barrier; 
                break;
                case Variable::$track:
                    $instance["track"] = $track; 
                break;
                case Variable::$raceClass:
                    $instance["raceClass"] = $raceClass; 
                break;
                case Variable::$WFA: 
                    $instance["HWD"] = $HWD; 
                break;
                case Variable::$sex:
                    $instance["sex"] = $sex;
                break;
                case Variable::$state:
                    $instance["state"] = $state;
                break;
                case Variable::$DOW:
                    $instance["DOW"] = $DOW;
            }

            $instance["rating"] = $rating;  

            $result[$same][$horse][] = $instance;

        }

       return $result;
    }
    
   function getResults($mysqli){
        //Prepare
        $stmt = $mysqli->prepare($this->selectResults_sql); 

        if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }

        /* execute query */
        $stmt->execute();
        
        $stmt->bind_result($diff, $avg, $max, $horse_cnt, $race_cnt); 
        
        /* now you can fetch the results into an array - NICE */
        $return = [];
        
        while ($rows = $stmt->fetch()) { 
            $instance = [];
            $instance[] = $diff; 
            $instance[] = $avg;  
            $instance[] = $max;  
            $instance[] = $horse_cnt; 
            $instance[] = $race_cnt; 

            $return[] = $instance;
        }
        
       return $return;
    }
    
   function getPreviousStartDate($mysqli){
        
         $stmt = $mysqli->prepare($this->getPreviousStartDate);
         
         if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
        
        $stmt->execute();
        
        $stmt->bind_result($max_date); 
        
        while ($stmt->fetch()) { 
            $return = $max_date;
        }
        
        return $return;
    }
    
   function getRaceClasses($mysqli){
        
         $stmt = $mysqli->prepare($this->getRaceClasses);
         
         if(!$stmt){
            echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
        }
        
        $stmt->execute();
        
        $stmt->bind_result($categ, $class); 
        
        $return = [];
        while ($stmt->fetch()) { 
            $return[$categ][] = $class;
        }
        
        return $return;
    }
    
   function settingManagement($searchType,$settingName,$settings, $mysqli){
            $mysqli->query('SET NAMES utf8');       

            //Prepare
            switch($searchType){
                case "insert":$stmt = $mysqli->prepare($this->insert_reportSetting_sql); break;
                case "load":$stmt =   $mysqli->prepare($this->load_reportSetting_sql); break;
                case "update":$stmt = $mysqli->prepare($this->update_reportSetting_sql); break;
                case "delete":$stmt = $mysqli->prepare($this->delete_reportSetting_sql); break;
            }
            
            if(!$stmt){
                echo "Prepare failed: (" . $mysqli->errno . ") " . $mysqli->error;
            }
            
            if(gettype($settings) === 'array'){
                $barrier = json_encode($settings['barrier']);
                $WFA = json_encode($settings['WFA']);
                $raceClass = json_encode($settings['raceClass']);
                $state = json_encode($settings['state']);
                $sex = json_encode($settings['sex']);
                $trackcat = json_encode($settings['trackcat']);
                $DOW = json_encode($settings['DOW']);
                $age = json_encode($settings['age']);
                $trackcondition = json_encode($settings['trackcondition']);
                $r_tc_long = json_encode($settings['rTcLong']);
                $jockey = json_encode($settings['jockey']);
                $magin = json_encode($settings['magin']);
                $finishPos = json_encode($settings['finishPos']);
                $prise = json_encode($settings['prise']);
                $day = json_encode($settings['day']);
                $daysBewRaceDay = json_encode($settings['daysBewRaceDay']);
                $dateFrom = json_encode($settings['dateFrom']);
                $dateTo = json_encode($settings['dateTo']);
                $distanceFrom = json_encode($settings['distanceFrom']);
                $distanceTo = json_encode($settings['distanceTo']);
                $handicap = json_encode($settings['handicap']);
                $leastRun = json_encode($settings['leastRun']);
                $report_on = json_encode($settings['report_on']);
                $same = json_encode($settings['same']);
            }

            //Bind
            if($searchType === 'insert'){
                 if (!$stmt->bind_param('sssssssssssssssssssssssss',
                         $settingName,
                         $barrier,
                         $WFA,
                         $raceClass,
                         $state,
                         $sex,
                         $trackcat,
                         $DOW,
                         $age,$trackcondition,$r_tc_long,$jockey,$magin,$finishPos,$prise,$day,$daysBewRaceDay, $dateFrom, $dateTo,
                         $distanceFrom,$distanceTo,$handicap,$leastRun,$report_on,$same)) {
                    echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
                }
            }
            
            if($searchType == 'update'){
                 if (!$stmt->bind_param('ss', $settings,$settingName)) {
                    echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
                }
            }
            if($searchType == 'delete'){
                 if (!$stmt->bind_param('s',$settingName)) {
                    echo "Binding parameters failed: (" . $stmt->errno . ") " . $stmt->error;
                }
            }
           
            
            /* execute query */
            $result = $stmt->execute();
            
            if($searchType == 'insert' || $searchType == 'update' ||$searchType == 'delete'){
                return $result;
            }
            
            switch ($searchType) {
                                case "load": $stmt->bind_result($name,$barrier,$WFA,$raceClass,$state,$sex,$trackcat,$DOW
                                ,$age,$trackcondition,$rTcLong,$jockey,$magin,$finishPos,$prise,$day,$daysBewRaceDay,$dateFrom,$dateTo,
                                 $distanceFrom,$distanceTo,$handicap,$leastRun, $report_on, $same, $date_time); break; 
                              }
                $result = [];
                $instance = [];
            while ($rows = $stmt->fetch()) { 
                
                
               $instance['barrier'] = $barrier;  $instance['WFA'] = $WFA;  $instance['raceClass'] = $raceClass;
               $instance['state'] = $state;$instance['sex'] = $sex;$instance['trackcat'] = $trackcat;
               $instance['DOW'] = $DOW;$instance['age'] = $age;$instance['trackcondition'] = $trackcondition;
               $instance['rTcLong'] = $rTcLong;
               $instance['jockey'] = $jockey;$instance['magin'] = $magin;$instance['finishPos'] = $finishPos;
               $instance['prise'] = $prise;$instance['day'] = $day;
               $instance['daysBewRaceDay'] = $daysBewRaceDay;
               $instance['dateFrom'] = $dateFrom;$instance['dateTo'] = $dateTo;
               $instance['distanceFrom'] = $distanceFrom;$instance['distanceTo'] = $distanceTo;
               $instance['handicap'] = $handicap;$instance['leastRun'] = $leastRun;  
               $instance['report_on'] = $report_on; $instance['same'] = $same; 
               $result[$name] = $instance;
            }
            return $result;
   }
    
}









?>