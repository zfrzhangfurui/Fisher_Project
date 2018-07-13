<?php
error_reporting(0);
include 'includes.php';
$dbconnection = new DBConnection();
$dbconnection ->setAddress($dbaddress);
$dbconnection ->setUsername($dbusername);
$dbconnection ->setPassword($dbpassword);
$dbconnection ->dbConnect($dbname);
$mysqli = $dbconnection ->getConnection();


if(isset($_REQUEST['loadSetting'])) {
    
   $FilterCondition = new filterConditionDB();
   
   $reportName = "test name";
   $result = $FilterCondition ->settingManagement('load', $reportName, 0, $mysqli);
   echo json_encode($result);
   //print_r($result);
}

if(isset($_REQUEST['insertSetting'])) {
   $settings = json_decode($_POST['settings'], true);
   if(sizeof($settings['same']) == 0)
   {
       $settings['same'] = (object)[];
   }
//   echo var_dump($settings);exit;
   
   
   $reportName =$settings['reportName'];  
    
   $FilterCondition = new filterConditionDB();
   
   $result = $FilterCondition ->settingManagement('insert', $reportName, $settings, $mysqli);
   echo $result;
  
}

if(isset($_REQUEST['updateSetting'])) {
   $result = json_decode($_POST['settings']);
   // echo  $_POST['settings'];
   $arr = [];
   foreach ($result as $key => $value) {
   $arr[$key] = $value; 
   }

   $reportName =$arr['reportName'];  
   $FilterCondition = new filterConditionDB();
   $result = $FilterCondition ->settingManagement('update',$reportName,$_POST['settings'], $mysqli);
   
  
}


if(isset($_REQUEST['deleteSetting'])) {
   
   $reportName =$_POST['deletedSettingName'];  
   $FilterCondition = new filterConditionDB();
   $result = $FilterCondition ->settingManagement('delete',$reportName,$_POST['settings'], $mysqli);
   
  
}



