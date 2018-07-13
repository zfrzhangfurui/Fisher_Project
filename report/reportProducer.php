<?php
class reportProducer{
    
    function getDiffReport($plainData, $MAX, $cntArray){
        $i = 0;
        $j = 0;
        $arrayLongth = count($plainData);
        foreach ($plainData as $key => $value){
            //if(++$i === $arrayLongth)break;// 
            foreach ($plainData as $subkey =>$subvalue){
                ++$j;
                //if($j !== 1 ) //
                if($key != $subkey)
                {
                    $report[] = [($key.", ".$subkey), round($value - $subvalue, 1), round($MAX[$key] - $MAX[$subkey], 1), $cntArray[$key]." / ".$cntArray[$subkey]];
                }
                if($j === $arrayLongth) $j = 0;
                
            }
            
        }
        
        return $report;
    }
    
    function DowloadExcel($objPHPExcel, $ExcelData){  
        $horseCnt = $ExcelData["summary"];
        $report   = $ExcelData["report"];
        $dataCheck = $ExcelData["dataCheck"];
        $horseCheck = $ExcelData["horseCheck"];
        $report_grouped = [];
        
        $objPHPExcel->setActiveSheetIndex(0);
        
//        $objPHPExcel->getActiveSheet()
//            ->getStyle('A1:E1')
//            ->getFill()
//            ->setFillType(PHPExcel_Style_Fill::FILL_SOLID)
//            ->getStartColor()
//            ->setARGB('FF808080');
//        $objPHPExcel->getActiveSheet()->getStyle("A1:E1")->getFont()->setBold( true );
//        $worksheet = $objPHPExcel->getActiveSheet();
//        

        $i=0;
        $summary = [ ["Found horses", "Matches find"], [$horseCnt[0], $horseCnt[1]] ];
        $worksheet = $objPHPExcel->createSheet($i++);
        $worksheet->setTitle("Summary");
        $worksheet->getColumnDimension('A')->setWidth(13);
        $worksheet->getStyle('A:A')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->getColumnDimension('B')->setWidth(13);
        $worksheet->getStyle('B:B')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->getColumnDimension('C')->setWidth(13);
        $worksheet->getStyle('C:C')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->fromArray($summary, NULL, "A1", true);
        
        
        $worksheet = $objPHPExcel->createSheet($i++);
        $worksheet->setTitle("Results");
        $worksheet->getColumnDimension('E')->setWidth(13);
        $worksheet->getStyle("1:1")->getFont()->setBold( true );
        $worksheet->getStyle('E:E')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->getStyle('B1:E1')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
        $worksheet->fromArray($report, NULL, "A1", true);
        
        $worksheet = $objPHPExcel->createSheet($i++);
        $worksheet->setTitle("Data-Check");
        $worksheet->getColumnDimension('A')->setWidth(12);
        $worksheet->getColumnDimension('B')->setWidth(19);
        $worksheet->getStyle("1:1")->getFont()->setBold( true );
        $worksheet->fromArray($dataCheck, NULL, "A1", true);
        
        $worksheet = $objPHPExcel->createSheet($i++);
        $worksheet->setTitle("Horse-Check");
        $worksheet->getColumnDimension('A')->setWidth(11);
        $worksheet->getColumnDimension('D')->setWidth(19);
        $worksheet->getStyle("1:1")->getFont()->setBold( true );
        $worksheet->fromArray($horseCheck, NULL, "A1", true);
        
        
        if(sizeof($report_grouped) > 1)
        {
            foreach($report_grouped as $groupName=> $array)
            {
                $worksheet = $objPHPExcel->createSheet($i++);
                $worksheet->setTitle("$groupName");
                $worksheet->getColumnDimension('C')->setWidth(13);
                $worksheet->getStyle('C:C')->getAlignment()->setHorizontal(PHPExcel_Style_Alignment::HORIZONTAL_RIGHT);
                $worksheet->fromArray($array, NULL, "A1", true);
            }
        }
        
        $objPHPExcel->removeSheetByIndex($i);
        $objPHPExcel->setActiveSheetIndex(0);
        
        header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        header('Content-Disposition: attachment;filename=overload_test.xlsx');
        header('Cache-Control: max-age=0');
        header('Cache-Control: max-age=1');
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); 
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); 
        header ('Cache-Control: cache, must-revalidate'); 
        header ('Pragma: public'); 
        
        $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, "Excel2007");
        
        
        ob_start();
        $objWriter->save('php://output');
        $xlsData = ob_get_contents();
        ob_end_clean();

        $response =  array(
                'op' => 'ok',
                'file' => "data:application/vnd.ms-excel;base64,".base64_encode($xlsData)
            );
        
        session_start();
        $_SESSION['body'] = $report;
        $_SESSION['horseCnt'] = $horseCnt;
        
        return $response;
    }
    
    function spoutDownloadExcel($writer, $ExcelData){
        //http://opensource.box.com/spout/docs/
        $horseCnt = $ExcelData["summary"];
        $report   = $ExcelData["report"];
        $dataCheck = $ExcelData["dataCheck"];
        $horseCheck = $ExcelData["horseCheck"];
        $summary = [ ["Found horses", "Matches find"], [$horseCnt[0], $horseCnt[1]] ];
        
        $firstSheet = $writer->getCurrentSheet();
        $firstSheet->setName('Summary');
        
        $writer->addRows($summary);

        $newSheet = $writer->addNewSheetAndMakeItCurrent();
        $writer->addRows($report);
        $newSheet->setName('Results');
        
        $newSheet = $writer->addNewSheetAndMakeItCurrent();
        $writer->addRows($dataCheck);
        $newSheet->setName('Data-Check');
        
        $newSheet = $writer->addNewSheetAndMakeItCurrent();
        $writer->addRows($horseCheck);
        $newSheet->setName('Horse-Check');
        
        $writer->setCurrentSheet($firstSheet);
        $writer->close();
        
    }
    
    function getAlphasByIndex($index){
        $Alphas = range('A', 'Z');
        return $Alphas[$index % 26];
    }
}

?>