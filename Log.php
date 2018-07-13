<?php

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 * Description of Log
 *
 * @author yuxingw
 */
class Log {
    
    private $file_name;
    private $filerCondition;
    
    function __construct($filerCondition){
       $this->file_name = "./../log/filters". date("-Y-m", time()). ".log";
       $this->filerCondition = $filerCondition;
    }
   
    function logFilterConditions(){
        
        $file = fopen($this->file_name, "a");
        
        $content = "Filters:" . date("Y-m-d H:i:s", time()) . PHP_EOL;
        
        fwrite($file, $content);
        
        foreach($this->filerCondition as $key=>$value){
           fwrite($file, $key. "=> " .$value . PHP_EOL); 
        }
        
        fwrite($file, PHP_EOL);
        
        fclose($file);
    }
}
