<?php

/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
include  './../serv-components/PHPExcel-1.8/Classes/PHPExcel.php'; 
session_start();



$body = $_SESSION['body'];
$horseCnt = $_SESSION['horseCnt'];
$filename = "session_store.xlsx";

$objPHPExcel = new PHPExcel();

DowloadExcel($objPHPExcel, $horseCnt, $body);





function DowloadExcel($objPHPExcel, $horseCnt, $body){  
        
        $objPHPExcel->setActiveSheetIndex(0);
        
        $i=0;
        $summary = [ ["Found horses", "Matched races"], [$horseCnt[0], $horseCnt[1]] ];
        $worksheet = $objPHPExcel->createSheet($i++);
        $worksheet->setTitle("Summary");
        $worksheet->getColumnDimension('A')->setWidth(13);
        $worksheet->getStyle('A:A')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->getColumnDimension('B')->setWidth(13);
        $worksheet->getStyle('B:B')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->fromArray($summary, NULL, "A1", true);
        
        foreach($body as $groupName=> $array)
        {
            $worksheet = $objPHPExcel->createSheet($i++);
            $worksheet->setTitle("$groupName");
            $worksheet->getColumnDimension('C')->setWidth(13);
            $worksheet->getStyle('C:C')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
            $worksheet->fromArray($array, NULL, "A1", true);
        }
        
        $objPHPExcel->removeSheetByIndex($i);
        $objPHPExcel->setActiveSheetIndex(0);
        
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename='.$filename);
        header('Cache-Control: max-age=0');
        header('Cache-Control: max-age=1');
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); 
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); 
        header ('Cache-Control: cache, must-revalidate'); 
        header ('Pragma: public'); 
        
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, "Excel2007");
        
        $objWriter->save('php://output');
    }
    
    
//echo "<pre>";
//print_r($objPHPExcel);
//echo "</pre>";
//exit;


?>