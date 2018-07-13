<?php
class DBConnection {
    //put your code here<?php
    public $address;
    public $username;
    public $password;
    
    public $connection;

    function setAddress($address){
        $this->address = $address;
    }
    
    function getAddress(){
        return $this->address;
    }
    
    function setUsername($username){
        $this->username = $username;
    }    
    
    function getUsername(){
        return $this->username;
    }
    
    function setPassword($password){
        $this->password = $password;
    }    
    
    function getPassword(){
        return $this->password;
    }
    
    function dbConnect($dbname) { 
        if($this->address!=null && $this->username!=null && $this->password!=null){
           // print $this->address. ", " . $this->username. ", " . $this->password. ", " . $dbname;
           //exit();
            $this->connection = new mysqli($this->address, $this->username, $this->password, $dbname);
            
//            $this->connection = new PDO('mysql:host='.$this->address.';dbname='.$dbname, $this->username, $this->password);
        } else {
            print "Error!: credential is not set.<br/>";
            die();
        }
    } 

    function getConnection() { 
        return $this->connection;
    } 

    function closeConnection() { 
        $this->connection = null;
    } 
    
//    function setValues($query, $types, $string){
//        
//        $splittedQuery = explode("?", $query);        
//        $splittedTypes = str_split($types);
//        $returnQuery = "";
//        foreach ($splittedQuery as $key => $value){
//            if($splittedTypes[$key]=="s"){
//                $returnQuery .= $value."'".
//            } else if($splittedTypes[$key]=="i"){
//                
//            } else if($splittedTypes[$key]=="d"){
//                
//            }
//        }
//        return $query;
//    }
    
}
?>