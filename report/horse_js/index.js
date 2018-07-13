
var result = {};

/*-----------------------------------------------------------------------------------------------------------------------------*/

angular.module('horseRacing', ['ngAnimate', 'ngSanitize', 'ui.bootstrap']);
angular.module('horseRacing').controller('ButtonsCtrl',['$scope', '$timeout', '$window', function ($scope,$timeout, $window) {


$scope.barrierCheckResults = '';
$scope.barrierRadioModel = "Any";
$scope.$watchCollection('barrierCheckModel', function () {    
if($scope.barrierCheckModel != null){
    result.barrier  = $scope.barrierCheckModel.split(",");
    $scope.barrierCheckResults = $scope.barrierCheckModel.toString();
}
   
   
  });
  
   $scope.$watchCollection('barrierRadioModel', function () {
       if($scope.barrierRadioModel === 'Any'){
            result.barrier = 0;
        //$scope.barrierCheckModel = '';
           $scope.barrierCheckResults = '';
       }
       if($scope.barrierRadioModel === 'Select'){
           if($scope.barrierCheckModel != null ){
               result.barrier  = $scope.barrierCheckModel.split(",");
               $scope.barrierCheckResults = $scope.barrierCheckModel.toString();
           }      
       }
  });
/*-----------------------------------------------------------------------------------------------------------------------------*/
    $scope.WFARadioModel = "Any";   
    $scope.$watchCollection('WFACheckModel', function () {
        if($scope.WFACheckModel != null){
            result.WFA  = $scope.WFACheckModel.split(",");
            $scope.WFACheckResults = result.WFA.toString();
        }

    });
  
    $scope.$watchCollection('WFARadioModel', function () {
        if($scope.WFARadioModel === 'Any'){
            result.WFA = 0;
           $scope.WFACheckResults = '';
       }
       
       if($scope.WFARadioModel === 'Select'){
            if($scope.WFACheckModel != null){
                result.WFA  = $scope.WFACheckModel.split(",");
                $scope.WFACheckResults = result.WFA.toString();
            }
       }
       
  });
 
 /*-----------------------------------------------------------------------------------------------------------------------------*/
    $scope.raceClassRadioModel = "Any";
              
    $scope.$watchCollection('raceClassCheckModel', function () {
        if($scope.raceClassCheckModel != null){
            result.raceClass  = $scope.raceClassCheckModel.split(",");
            $scope.classCheckResults = result.raceClass.toString();
        }

    });
    
    $scope.$watchCollection('raceClassRadioModel', function () {
        if($scope.raceClassRadioModel === 'Any'){
            result.raceClass = 0;
           $scope.classCheckResults = '';
        }
       
       if($scope.raceClassRadioModel === 'Select'){
            if($scope.raceClassCheckModel != null){
                result.raceClass  = $scope.raceClassCheckModel.split(",");
                $scope.classCheckResults = result.raceClass.toString();
                
            }
        }
    });
    
    
 /*-----------------------------------------------------------------------------------------------------------------------------*/
$scope.stateRadioModel = "Any";   
  $scope.$watchCollection('stateCheckModel', function () {
        result.state = [];
        $scope.temp_state = [];
        angular.forEach($scope.stateCheckModel, function (value, key) {
            if (value) {    
              result.state.push(key);
            }
        });
        $scope.stateCheckResults = result.state.toString();
        $scope.temp_state = result.state;
        if($scope.stateCheckModel == null){
            result.state = 0;
            $scope.stateCheckResults = "";
        }
    
  });
  
  
     $scope.$watchCollection('stateRadioModel', function () {
        if($scope.stateRadioModel === 'Any'){
                   result.state = 0;
                  $scope.stateCheckResults = '';
              }
              
            if($scope.stateRadioModel === 'Select'){
            if($scope.stateCheckModel != null){
            result.state = $scope.temp_state;
            $scope.stateCheckResults = result.state.toString();
            }
       }
  });
/*-----------------------------------------------------------------------------------------------------------------------------*/
   $scope.sexRadioModel = "Any";                                
  $scope.sexCheckModel = {
    FM: false,
    CHG: false,
    F: false,
    CG:false,
    M:false,
    HGM:false,
    HG:false,
    Open:false
  };
    $scope.temp_sex = [];
  $scope.$watchCollection('sexCheckModel', function () {
     result.sex = {};
     $scope.sexCheckResults = [];
    angular.forEach($scope.sexCheckModel, function (value, key) {
      if (value) {
        $scope.sexCheckResults.push(key);
      }
    });
    result.sex = $scope.sexCheckResults;
    if($scope.sexCheckModel == null){
        result.sex = 0;
    }
    $scope.temp_sex = result.sex;
    $scope.sexCheckResults = $scope.sexCheckResults.toString();
  });
  
  $scope.$watchCollection('sexRadioModel', function () {
        if($scope.sexRadioModel === 'Any'){
                  result.sex = 0;
                  $scope.sexCheckResults = '';
           }
           
           if($scope.sexRadioModel === 'Select'){ 
                if($scope.sexCheckModel != null){
                result.sex = $scope.temp_sex;
                $scope.sexCheckResults = result.sex.toString();
            }
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.trackcatRadioModel = "Any";    
    $scope.temp_trackcat = [];
    $scope.$watchCollection('trackcatCheckModel', function () {
    $scope.trackcatCheckResults = [];
    angular.forEach($scope.trackcatCheckModel, function (value, key) {
      if (value) {
        $scope.trackcatCheckResults.push(key);
      }
    });
    result.trackcat = $scope.trackcatCheckResults;
    $scope.temp_trackcat = result.trackcat;
    $scope.trackcatCheckResults = $scope.trackcatCheckResults.toString();
    if($scope.trackcatCheckModel == null){
        result.trackcat = 0;
    }
  });
  
  $scope.$watchCollection('trackcatRadioModel', function () {
        if($scope.trackcatRadioModel === 'Any'){
                          result.trackcat = 0;

                         $scope.trackcatCheckResults = '';
                  }
        if($scope.trackcatRadioModel === 'Select'){
            if($scope.trackcatCheckModel!= null){
            result.trackcat = $scope.temp_trackcat;
            $scope.trackcatCheckResults = result.trackcat.toString();
            }
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.DOWRadioModel = "Any"; 
 $scope.temp_trackDOW = [];
  $scope.$watchCollection('DOWCheckModel', function () {
     $scope.DOWCheckResults = [];
    angular.forEach($scope.DOWCheckModel, function (value, key) {
      if (value) {
        $scope.DOWCheckResults.push(key);
      }
    });
   result.DOW = $scope.DOWCheckResults;
   $scope.temp_DOW = result.DOW;
   $scope.DOWCheckResults = $scope.DOWCheckResults.toString();
  });
  
  $scope.$watchCollection('DOWRadioModel', function () {
            if($scope.DOWRadioModel === 'Any'){
                        result.DOW = 0;
                        $scope.DOWCheckResults = '';
            }
                
            if($scope.DOWRadioModel === 'Select'){
                if($scope.DOWCheckModel != null){
                    result.DOW = $scope.temp_DOW;
                    $scope.DOWCheckResults = result.DOW.toString();
                }
            }        
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.ageRadioModel = "Any"; 
 $scope.temp_trackage = [];
 $scope.ageValue = {
     "age2" : "2",
     "age3" : "3",
     "age4" : "4",
     "age5" : "5",
     "age23" : "23",
     "age24" : "24",
     "age25" : "25",
     "age34" : "34",
     "age35" : "35",
     "age45" : "45",
     "age2plus" : "2+",
     "age3plus" : "3+",
     "age4plus" : "4+",
     "age5plus" : "5+",
     "ageopen": "open"
 };
 $scope.ageValue_1 = {
     "2": "age2",
     "3": "age3",
     "4": "age4",
     "5": "age5",
     "23": "age23",
     "24": "age24",
     "25": "age25",
     "34": "age34",
     "35": "age35",
     "45": "age45",
     "2+": "age2plus",
     "3+": "age3plus",
     "4+": "age4plus" ,
     "5+": "age5plus",
     'open': "ageopen"
 }

  $scope.$watchCollection('ageCheckModel', function () {
    $scope.ageCheckResults = [];
    angular.forEach($scope.ageCheckModel, function (value, key) {
      if (value) {
        for(var i in $scope.ageValue){
            if(key == i){
                key = $scope.ageValue[i];
                break;
            }
        }
        
        $scope.ageCheckResults.push(key);
      }
    });
    result.age = $scope.ageCheckResults;
    $scope.temp_age = result.age;
    $scope.ageCheckResults = $scope.ageCheckResults.toString();
   
});
  
   $scope.$watchCollection('ageRadioModel', function () {
        if($scope.ageRadioModel === 'Any'){
            result.age = 0;
            $scope.ageCheckResults = '';
        }


        if($scope.ageRadioModel === 'Select'){
            if($scope.ageCheckModel != null){
                result.age = $scope.temp_age;
                $scope.ageCheckResults = result.age.toString();
            }
       }
  });
  

  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.trackConditionRadioModel = "Any"; 
  $scope.temp_trackcondition = [];
  $scope.$watchCollection('trackconditionCheckModel', function () {
     $scope.trackconditionCheckResults = [];
    angular.forEach($scope.trackconditionCheckModel, function (value, key) {
        
      if (value) {
        $scope.trackconditionCheckResults.push(key);
      }
    });
   result.trackcondition = $scope.trackconditionCheckResults;
   if($scope.trackconditionCheckModel == null){
       result.trackcondition = 0;
   }
   $scope.temp_trackcondition = result.trackcondition;
   $scope.trackconditionCheckResults = $scope.trackconditionCheckResults.toString();
  });
  
   $scope.$watchCollection('trackConditionRadioModel', function () {
        if($scope.trackConditionRadioModel === 'Any'){
            result.trackcondition = 0;
            $scope.trackconditionCheckResults = '';
        }
        if($scope.trackConditionRadioModel === 'Select'){
            if($scope.trackconditionCheckModel != null){
                result.trackcondition = $scope.temp_trackcondition;
                $scope.trackconditionCheckResults = result.trackcondition.toString();
            }
       }
  });

/*-----------------------------------------------------------------------------------------------------------------------------*/
$scope.rTcLongRadioModel = "Any";
$scope.temp_rTcLong = [];
$scope.rTcLongNames = {
    F1: "FIRM 1",
    F2: "FIRM 2",
    G3: "GOOD 3",
    G4: "GOOD 4",
    S5: "SLOW 5",
    S6: "SLOW 6",
    S7: "SLOW 7",
    H8: "HEAVY 8",
    H9: "HEAVY 9",
    H10: "HEAVY 10"
}
$scope.$watchCollection('rTcLongCheckModel', function () {
    $scope.rTcLongCheckResults = [];

    angular.forEach($scope.rTcLongCheckModel, function (value, key) {
        if (value) {
            $scope.rTcLongCheckResults.push($scope.rTcLongNames[key]);
        }
    });
    result.rTcLong = $scope.rTcLongCheckResults;
    if($scope.rTcLongCheckModel == null){
        result.rTcLong = 0;
    }
    $scope.temp_rTcLong = result.rTcLong;
    $scope.rTcLongCheckResults = $scope.rTcLongCheckResults.toString();
});

$scope.$watchCollection('rTcLongRadioModel', function () {
    if($scope.rTcLongRadioModel === 'Any'){
        result.rTcLong = 0;
        $scope.rTcLongCheckResults = '';
    }
    if($scope.rTcLongRadioModel === 'Select'){
        if($scope.rTcLongCheckModel != null){
            result.rTcLong = $scope.temp_rTcLong;
            $scope.rTcLongCheckResults = result.rTcLong.toString();
        }
    }
});
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
//$scope.diffdistanceMinModel = '';
//$scope.diffdistanceBaseModel = '';
//$scope.diffdistanceMaxModel = '';
//
// $scope.diffdistanceRadioModel = "Any"; 
//  
//  $scope.$watchCollection('diffdistanceRadioModel', function () {
//                if($scope.diffdistanceRadioModel === 'Any'){
//                          result.diffdistance = 0;
//                         $scope.diffdistanceCheckResults = '';
//                }
//                
//                if($scope.diffdistanceRadioModel === 'Select'){
//           if(typeof($scope.diffdistanceCheckModel) !== 'undefined' ){
//               result.diffdistance  = $scope.diffdistanceCheckModel.split(",");
//               $scope.diffdistanceCheckResults = $scope.diffdistanceCheckModel.toString();
//           }      
//       }
//  });
 
/*-----------------------------------------------------------------------------------------------------------------------------*/

$scope.jockeyRadioModel = "Any";

$scope.$watchCollection('jockeyCheckModel', function () {
      if($scope.jockeyCheckModel != null){
        result.jockey  = $scope.jockeyCheckModel.split(",");
        $scope.jockeyCheckResults = result.jockey.toString();
    }
  });
  
   $scope.$watchCollection('jockeyRadioModel', function () {
                if($scope.jockeyRadioModel === 'Any'){
                          result.jockey = 0;
                         $scope.jockeyCheckResults = '';
                }
                
                if($scope.jockeyRadioModel === 'Select'){
           if($scope.jockeyCheckModel != null ){
               result.jockey  = $scope.jockeyCheckModel.split(",");
               $scope.jockeyCheckResults = $scope.jockeyCheckModel.toString();
           }      
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 
$scope.maginRadioModel = "Any";

  $scope.$watchCollection('maginCheckModel', function () {
      if($scope.maginCheckModel != null){
        result.magin  = $scope.maginCheckModel.split(",");
        $scope.maginCheckResults = result.magin.toString();
    }
  });
  
  $scope.$watchCollection('maginRadioModel', function () {
                if($scope.maginRadioModel === 'Any'){
                          result.magin = 0;
                         $scope.maginCheckResults = '';
                }
                 if($scope.maginRadioModel === 'Select'){
           if($scope.maginCheckModel != null ){
               result.magin  = $scope.maginCheckModel.split(",");
               $scope.maginCheckResults = $scope.maginCheckModel.toString();
           }      
       }
  });
 
/*-----------------------------------------------------------------------------------------------------------------------------*/
 
$scope.finishPosRadioModel = "Any";
  $scope.$watchCollection('finishPosCheckModel', function () {
      if($scope.finishPosCheckModel != null){
        result.finishPos  = $scope.finishPosCheckModel.split(",");
        $scope.finishPosCheckResults = result.finishPos.toString();
    }
  });
  
   $scope.$watchCollection('finishPosRadioModel', function () {
                if($scope.finishPosRadioModel === 'Any'){
                          result.finishPos = 0;
                         $scope.finishPosCheckResults = '';
                }
                if($scope.finishPosRadioModel === 'Select'){
           if($scope.finishPosCheckModel != null ){
               result.finishPos  = $scope.finishPosCheckModel.split(",");
               $scope.finishPosCheckResults = $scope.finishPosCheckModel.toString();
           }      
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 
$scope.priseRadioModel = "Any";
$scope.$watchCollection('priseCheckModel', function () {
      if($scope.priseCheckModel != null){
        result.prise  = $scope.priseCheckModel.split(",");
        $scope.moneyCheckResults = result.prise.toString();
    }
  });
  
   $scope.$watchCollection('priseRadioModel', function () {
    if($scope.priseRadioModel === 'Any'){
        result.prise = 0;
        $scope.moneyCheckResults = '';
    }
    if($scope.priseRadioModel === 'Select'){
       if($scope.priseCheckModel != null ){
           result.prise  = $scope.priseCheckModel.split(",");
           $scope.moneyCheckResults = $scope.priseCheckModel.toString();
       }      
   }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*//*-----------------------------------------------------------------------------------------------------------------------------*/
$scope.dateRadioModel = "Any";
  $scope.dateFHanlder = function(date=null){
        if(date != null){
            $scope.dateFrom = new Date(date);
        }
      
      if($scope.dateFrom != null){
        result.dateFrom = timeConverter(Date.parse($scope.dateFrom));
        $scope.dateCheckResults = result.dateFrom + " +/- " + result.dateTo;
    }else{
        result.dateFrom = 0;
        $scope.dateCheckResults = $scope.dateFrom + " +/- " + result.dateTo;
    }
  };
  
  $scope.dateTHanlder = function(date=null){
        if(date != null){
            $scope.dateTo = new Date(date);
        }
        
        if($scope.dateTo != null){
            result.dateTo = timeConverter(Date.parse($scope.dateTo));
            $scope.dateCheckResults = result.dateFrom + " +/- " + result.dateTo;
        }else{
            result.dateTo = 0;
            $scope.dateCheckResults = result.dateFrom + " +/- " + $scope.dateTo;
        }
    };
    
  $scope.$watchCollection('dateRadioModel', function () {
    if($scope.dateRadioModel === 'Any'){
        result.dateFrom = result.dateTo = 0;
//        $scope.dateFrom = $scope.dateTo = null;
        $scope.dateCheckResults = '';
    }
                
     if($scope.dateRadioModel === 'Select'){
           if($scope.dateFrom != null || $scope.dateTo != null ){
                result.dateFrom = timeConverter(Date.parse($scope.dateFrom));
                result.dateTo = timeConverter(Date.parse($scope.dateTo));
                $scope.dateCheckResults = result.dateFrom + " +/- " + result.dateTo;
           }      
       }
  });
  
  
  
  /*-----------------------------------------------------------------------------------------------------------------------------*/
   $scope.dayRadioModel = "Any"; 
   $scope.dayCheckModel = '';
   
   $scope.$watchCollection('dayCheckModel', function () {
        if($scope.dayCheckModel != null){
            result.day  =  $scope.dayCheckResults = $scope.dayCheckModel;
        }
        else{
            result.day = 0;
            $scope.dayCheckResults = '';
        }
    });
  
   $scope.$watchCollection('dayRadioModel', function () {
        if($scope.dayRadioModel === 'Any'){
          result.day = 0;
          $scope.dayCheckResults = '';
        }
                
        if($scope.dayRadioModel === 'Select'){
//            $scope.daysBewRaceRadioModel = "Any";
           if($scope.dayCheckModel != null ){
                result.day  =  $scope.dayCheckResults = $scope.dayCheckModel;
           }      
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*//*-----------------------------------------------------------------------------------------------------------------------------*/
$scope.daysBewRaceRadioModel = "Any";
$scope.$watchCollection('daysBewDay', function () {
    if($scope.daysBewDay != null){
        result.daysBewRaceDay = $scope.daysBewDay;
        $scope.daysBewRaceCheckResults = result.daysBewRaceDay;
    }
    else{
        result.daysBewRaceDay = 0;
        $scope.daysBewRaceCheckResults = '';
    }
});
  
  $scope.$watchCollection('daysBewRaceRadioModel', function () {
    if($scope.daysBewRaceRadioModel === 'Any'){
        result.daysBewRaceDay = 0;
        $scope.daysBewRaceCheckResults = '';
    }
                
     if($scope.daysBewRaceRadioModel === 'Select'){
           if($scope.daysBewDay != null){
               result.daysBewRaceDay = $scope.daysBewDay;
               $scope.daysBewRaceCheckResults = result.daysBewRaceDay;
           }      
       }
  });
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 
$scope.distanceRadioModel = "Any";
$scope.$watchCollection('distanceFrom', function () {
       if($scope.distanceFrom != null){
        result.distanceFrom  = $scope.distanceFrom;
        result.distanceTo    = $scope.distanceTo;
        $scope.distanceCheckResults = result.distanceFrom+" - "+result.distanceTo;
    }
  });
  
  $scope.$watchCollection('distanceTo', function () {
       if($scope.distanceTo != null){
        result.distanceFrom  = $scope.distanceFrom;
        result.distanceTo    = $scope.distanceTo;
        $scope.distanceCheckResults = result.distanceFrom+" - "+result.distanceTo;
    }
  });
  
   $scope.$watchCollection('distanceRadioModel', function () {
        if($scope.distanceRadioModel === 'Any'){
            result.distanceFrom = result.distanceTo = 0;
            $scope.distanceCheckResults = '';
        }
                
        if($scope.distanceRadioModel === 'Select'){
            if($scope.distanceFrom != null || $scope.distanceTo != null){
                result.distanceFrom  = $scope.distanceFrom;
                result.distanceTo    = $scope.distanceTo;
                $scope.distanceCheckResults = result.distanceFrom+" - "+result.distanceTo;
                
            }      
        }
  });

/*-----------------------------------------------------------------------------------------------------------------------------*/
 
 $scope.handicapRadioModel = "Any"; 
  $scope.temp_handicapCondition = [];
  $scope.$watchCollection('handicapCheckModel', function () {
    $scope.handicapCheckResults = [];
    angular.forEach($scope.handicapCheckModel, function (value, key) {
        
      if (value) {
        $scope.handicapCheckResults.push(key);
      }
    });
   result.handicap = $scope.handicapCheckResults;
   if($scope.handicapCheckModel == null){
       result.handicap = 0;
   }
   $scope.temp_handicapCondition = result.handicap;
   $scope.handicapCheckResults = $scope.handicapCheckResults.toString();
  });
  
   $scope.$watchCollection('handicapRadioModel', function () {
        if($scope.handicapRadioModel === 'Any'){
            result.handicap = 0;
            $scope.handicapCheckResults = '';
        }
        if($scope.handicapRadioModel === 'Select'){
            if($scope.handicapCheckModel != null){
                
                result.handicap = $scope.temp_handicapCondition;
                $scope.handicapCheckResults = result.handicap.toString();
            }
       }
  });
  
  
/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.leastRunRadioModel = "Any";
$scope.$watchCollection('leastRunCheckModel', function () {
    if($scope.leastRunCheckModel != null){
        result.leastRun = $scope.leastRunCheckResults = $scope.leastRunCheckModel
    }
    
  });
  
   $scope.$watchCollection('leastRunRadioModel', function () {
        if($scope.leastRunRadioModel === 'Any'){
            result.leastRun = 2;
            $scope.leastRunCheckResults = $scope.leastRunCheckModel = 2;
        }
                
        if($scope.leastRunRadioModel === 'Select'){
           if($scope.leastRunCheckModel != null ){
               result.leastRun = $scope.leastRunCheckResults = $scope.leastRunCheckModel;
           }      
       }
  });
/*-----------------------------------------------------------------------------------------------------------------------------*/
$.post("./ajaxFilterCondition.php", {action:"getReportVariables"}, function(list)
{
    $scope.reports = JSON.parse(list).sort();
});

$scope.testModel = false;

$scope.startReport = function() {
    var valid = $scope.isValidForm();
    if(valid !== true){
        alert(valid);
        return;
    }
    
    var json = JSON.stringify(result);
    var same = JSON.stringify($scope.SAME);
//    console.log($scope.SAME);
//    return;
    if($scope.testModel){
        console.log(result);
    }else{
        $("#loading, #cubes").show();
    }
    
    
    $.post("./horseRacing.php", {action: "startReport", report:json, selectedReport:$scope.selectedReport, same:same, numOfHorse: $scope.numofHorse, testModel:$scope.testModel
                            },
        function(data){

            // console.log(data);
            // console.log(JSON.parse(data));

            if($scope.testModel)
            {
                console.log(JSON.parse(data));
                return;
            }

            if(data*1 == 1){
                $("#cubes").hide();
                $("#loading").hide(function(){
                    alert("There is no run macthed for the selected condition");
                });

                return;
            }
            if(data*1 == 2){
                $("#cubes").hide();
                $("#loading").hide(function(){
                    alert("Condition string is too long!");
                });
                return;
            }
            
            $("#loading, #cubes").hide();
            // var $a = $("<a>");
            // $a.attr("href",JSON.parse(data)[1].file);
            // $("body").append($a);
            // $a.attr("download", "Report-"+$scope.selectedReport+".xlsx");
            // $a[0].click();
            // $a.remove();
            window.location.replace(JSON.parse(data)[1])
            console.log(JSON.parse(data)[2]);




            $scope.$apply(); 
        });     
}

$scope.isValidForm = function(){
//    if($scope.testModel){
//        return true;
//    }
    if(!$scope.selectedReport && !$scope.testModel){
        var valid = "Please select a report to run";
        return valid;
    }
    if($scope.selectedReport == "Barrier" && result.barrier != 0 && result.barrier[0] != "" && result.barrier.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [BAR POS]!";
        return valid;
    }
    if($scope.selectedReport == "DOW" && result.DOW != 0 && result.DOW[0] != "" && result.DOW.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [DOW]!";
        return valid;
    }
    if($scope.selectedReport == "Race Class" && result.raceClass != 0 && result.raceClass[0] != "" && result.raceClass.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [Race Clasee]!";
        return valid;
    }
    if($scope.selectedReport == "Sex" && result.sex != 0 && result.sex[0] != "" && result.sex.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [Gender Restriction]!";
        return valid;
    }
    if($scope.selectedReport == "State / Area" && result.state != 0 && result.state[0] != "" && result.state.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [State / Area]!";
        return valid;
    }
    if($scope.selectedReport == "Track Category" && result.trackcat != 0 && result.trackcat[0] != "" && result.trackcat.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [Track Category]!";
        return valid;
    }
    if($scope.selectedReport == "WFA" && result.WFA != 0 && result.WFA[0] != "" && result.WFA.length < 2 && !$scope.testModel){
        var valid = "Please select more than 1 [WFA]!";
        return valid;
    }
    
    return true;
}


function timeConverter(UNIX_timestamp){
    var a = new Date(UNIX_timestamp);
    var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    var months = ['01','02','03','04','05','06','07','08','09','10','11','12'];
    var year = a.getFullYear();
    var month = months[a.getMonth()];
    var date = a.getDate();
    var hour = a.getHours();
    var min = a.getMinutes();
    var sec = a.getSeconds();
    //  var time = date + ' ' + month + ' ' + year + ' ' + hour + ':' + min + ':' + sec ;
    var time = year + '-' + month + '-' + ('0' + date).slice(-2);
    return time;
}


col_num = 5;
$scope.autoLoadSettingSwitch = false;
$scope.col_num = col_num;
//$scope.same = "";
//prev_same = "'" + $scope.same + "'";
//$(".btn-group").click(function(){
//    var current_same = prev_same;
//    var clicked_same = $(this).find("label").eq(0).attr("uib-btn-radio");
//    prev_same = "'" + $scope.same + "'";
//    
//    if(current_same == clicked_same)
//    {
//        $scope.same = null;
//        prev_same = "'" + $scope.same + "'";
//    }
//    $scope.$apply();
//});

$scope.getNumber = function(num) {
    
    return new Array(num);   
}

$scope.getRaceClassCategContent = function(element){
    $("#raceClassCategUl").find("li>a").each(function(){
        $(this).removeClass("active2");
    });
    $(element.target).addClass("active2");
    
    var categ = $(element.target).text().trim();
    $("#selectedRaceClassCateg").text(categ);
    
    $scope.array = [];
    for(var i=0; i<Math.ceil($scope.raceClassContent[categ].length/col_num); i++){
        $scope.array[i] = 1;
    }
    
    $scope.selectedRaceClass = $scope.raceClassContent[categ];
    
    $scope.raceClassSyncCheckBox();
    $scope.removeCheckBoxClickEvent();
    $scope.checkBoxClickEvent();
}

$scope.openRaceClassModal = function(){
    $("#raceClassModal").modal("show");
    $scope.raceClassSyncCheckBox();
}

$scope.raceClassSyncCheckBox = function(){
    $("#raceClassTable").hide();
    $timeout(function(){
        var cnt = 0;
        $("#raceClassTbody").find("input[type=checkbox]").each(function(){
            var toCheck = false;
            for(var i=0;i<result.raceClass.length;i++){
                if($(this).val().trim() === result.raceClass[i]){
                    toCheck = true;
                    cnt++;
                    break;
                }
            }
            $(this).prop("checked", toCheck);
        });
        
        if(cnt >= $scope.selectedRaceClass.length){
            $("#select_all").prop("checked", true);
        }else{
            $("#select_all").prop("checked", false);
        }
        $("#raceClassTable").slideDown();
    },100);
    
}


$.post("./ajaxFilterCondition.php", {action: "getRaceClasses"}, function(data){
    $scope.raceClassCateg = JSON.parse(data)[0];
    $scope.raceClassContent = JSON.parse(data)[1];
    $scope.array = [];//$scope.getNumber( Math.ceil($scope.selectedRaceClass/3) );
    
    $scope.selectedRaceClass = $scope.raceClassContent.Benchmark;
    $("#selectedRaceClassCateg").text($scope.raceClassCateg[0]);
    
    for(var i=0; i<Math.ceil($scope.selectedRaceClass.length/col_num); i++){
        $scope.array[i] = 1;
    }
    
    $timeout(function(){
        $("#raceClassCategUl").find("li:first>a").addClass("active2");
    },50)
    
    $scope.checkBoxClickEvent();
    
    $scope.$apply();
});

$scope.checkBoxClickEvent = function(){
    $timeout(function(){
        $("#raceClassTbody").find("input[type=checkbox]").each(function(){
            $(this).click(function(){
                if($(this).is(":checked")){
                    if(!$scope.raceClassCheckModel){
                        $scope.raceClassCheckModel = $(this).val().trim();
                    }else{
                        $scope.raceClassCheckModel = $scope.raceClassCheckModel + "," + $(this).val().trim(); 
                    }

                }else{
                    var replace1 = ",,";
                    var re1 = new RegExp(replace1,"g");
                    var replace2 = $(this).val().trim();
                    var re2 = new RegExp(replace2,"g");

                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(re2, "");
                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(re1, ",");
                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(/(^[,\s]+)|([,\s]+$)/g, '');
                    
                }
                if($scope.raceClassCheckModel && $scope.raceClassCheckModel.trim().length > 0){
                    $scope.raceClassRadioModel = "Select";
                }else{
                    $scope.raceClassRadioModel = "Any";
                }   
                $scope.$apply();
            });
        });

        $("#select_all").click(function(){
            var isChecked = $(this).is(":checked");
            if(isChecked)
            {
                $("#raceClassTbody").find("input[type=checkbox]").each(function(){
                    if($(this).is(":checked") === false)
                    {
                        $(this).prop("checked", true);
                        if(!$scope.raceClassCheckModel){
                            $scope.raceClassCheckModel = $(this).val().trim();
                        }else 
                        {   
                            $scope.raceClassCheckModel = $scope.raceClassCheckModel + "," + $(this).val().trim(); 
                        }
                    }
                    $scope.$apply();
                });
            }
            else
            {
                $("#raceClassTbody").find("input[type=checkbox]").each(function(){
                    $(this).prop("checked", false);
                    
                    var replace1 = ",,";
                    var re1 = new RegExp(replace1,"g");
                    var replace2 = $(this).val().trim();
                    var re2 = new RegExp(replace2,"g");

                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(re2, "");
                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(re1, ",");
                    $scope.raceClassCheckModel = $scope.raceClassCheckModel.replace(/(^[,\s]+)|([,\s]+$)/g, '');
                    $scope.$apply();
                });
            }
            if($scope.raceClassCheckModel && $scope.raceClassCheckModel.trim().length > 0){
                $scope.raceClassRadioModel = "Select";
            }else{
                $scope.raceClassRadioModel = "Any";
            }  
            $scope.$apply();
        });
         
    },100);
    
    
}

$scope.removeCheckBoxClickEvent = function(){
    
    $timeout(function(){
       $("#raceClassTbody").find("input[type=checkbox]").each(function(){
            $(this).off('click');
       }); 
       
       $("#select_all").off('click');
       
    }, 100);
    
}   


$scope.initSettings = function(){
    
    $.post("./ajaxFilterSettings.php", {loadSetting:1}, function(data){
        $scope.oldSettings = JSON.parse(data);
        $scope.loadedsettings = [];

        angular.forEach($scope.oldSettings, function (value, key) {
            $scope.loadedsettings.push(key);
        });
    });
}

$scope.$watchCollection('oldSettingUserchoosed', function () {
    if(typeof($scope.oldSettingUserchoosed) !== 'undefined' && !$scope.autoLoadSettingSwitch){
        $scope.loadSettings($scope.oldSettingUserchoosed);
    }
    $scope.autoLoadSettingSwitch = false;
});

$scope.loadSettings = function(i){
 
    $scope.oldSettingchoosed = $scope.oldSettings[i]; 
    var date_type = ["dateFrom", "dateTo"];
    
    angular.forEach($scope.oldSettingchoosed, function (value, key) {
        
        if(typeof(value) === 'string'){
            
            if(date_type.indexOf(key) === -1)
            {
                value = JSON.parse(value); 
//                console.log(">>>>>>>>");
//                console.log(typeof(value));
//                console.log(value);
            }
            else{
                if(value != 0)
                {
                    value = new Date(value);
                }
            }
        }
        
        switch (key) {
            case 'barrier': 
                if(value == 0){
                    $scope.barrierRadioModel = "Any";
                    $scope.barrierCheckModel = null;   
                }else{
                    $scope.barrierRadioModel = "Select";
                    $scope.barrierCheckModel = value.toString();  
                    
                }            
              break;

            case 'WFA':     
                if(value == 0){
                    $scope.WFARadioModel = "Any";
                    $scope.WFACheckModel = null;   
                }else{
                    $scope.WFARadioModel = "Select";
                    $scope.WFACheckModel = value.toString();  
                }            
              break;

            case 'raceClass': 
                if(value == 0){
                    $scope.raceClassRadioModel = 'Any';
//                    $scope.raceClassCheckResults = null;
                    $scope.raceClassCheckModel = null;   
                }else{
                    $scope.raceClassRadioModel = 'Select';
                    $scope.raceClassCheckModel = value.toString();  
                }            
            break;

            case 'state' :  
                if(value == 0){
                    $scope.stateRadioModel = "Any";
                    $scope.stateCheckModel = null;    
                }else{
                    $scope.stateRadioModel = "Select";
                    $scope.stateCheckModel = toObject(value);
                }
            break;

            case 'sex' :  
                if(value == 0){
                    $scope.sexRadioModel = 'Any';
                    $scope.sexCheckModel = null;    
                }else{
                    $scope.sexRadioModel = 'Select';
                    $scope.sexCheckModel = toObject(value);
                }
            break;

            case 'trackcat' :  
                if(value == 0){
                    $scope.trackcatRadioModel = 'Any';
                    $scope.trackcatCheckModel = null;    
                }else{
                    $scope.trackcatRadioModel = 'Select';
                    $scope.trackcatCheckModel = toObject(value);
                }
            break; 
            
            case 'DOW' :  
                if(value == 0){
                    $scope.DOWRadioModel = 'Any';
                    $scope.DOWCheckModel = null;    
                }else{
                    $scope.DOWRadioModel = 'Select';
                    $scope.DOWCheckModel = toObject(value);
                }
            break;

            case 'age' :  
                if(value == 0){
                    $scope.ageRadioModel = "Any";
                    $scope.ageCheckModel = null;    
                }else{
                    $scope.ageRadioModel = "Select";
                    $scope.ageCheckModel = toObjectForAge(value);
                }
            break; 

            case 'trackcondition' :  
                if(value == 0){
                    $scope.trackConditionRadioModel = 'Any';
                    $scope.trackconditionCheckModel = null;    
                }else{
                    $scope.trackConditionRadioModel = 'Select';
                    $scope.trackconditionCheckModel = toObject(value);
                }
            break;

            case 'rTcLong' :
                if(value == 0){
                    $scope.rTcLongRadioModel = 'Any';
                    $scope.rTcLongCheckModel = null;
                }else{
                    $scope.rTcLongRadioModel = 'Select';
                    $scope.rTcLongCheckModel = toObjectForRTcLong(value);
                }
            break;

            case 'jockey' :
                if(value == 0){
                    $scope.jockeyRadioModel = 'Any';
                    $scope.jockeyCheckModel = null;   
                }else{
                    $scope.jockeyRadioModel = 'Select';
                    $scope.jockeyCheckModel = value.toString();  
                }            
              ;break;

            case 'magin' :
                if(value == 0){
                    $scope.maginRadioModel = 'Any';
                    $scope.maginCheckModel = null;   
                }else{
                    $scope.maginRadioModel = 'Select';
                    $scope.maginCheckModel = value.toString();  
                }            
            break;  

            case 'finishPos' :
                if(value == 0){
                    $scope.finishPosRadioModel = 'Any';
                    $scope.finishPosCheckModel = null;   
                }else{
                    $scope.finishPosRadioModel = 'Select';
                    $scope.finishPosCheckModel = value.toString();  
                }            
            break;

            case 'prise' :
                if(value == 0){
                    $scope.priseRadioModel = "Any";
                    $scope.priseCheckModel = null;   
                }else{
                    $scope.priseRadioModel = "Select";
                    $scope.priseCheckModel = value.toString();  
                }            
              ;break;   

            case 'day' :
                if(value == 0){
                    $scope.dayRadioModel = 'Any';
                    $scope.dayCheckModel = null;   
                }else{
                    $scope.dayRadioModel = 'Select';
                    $scope.dayCheckModel = value;  
                } 
            break; 
            
            case 'dateFrom' :
                if(value == 0){
                    $scope.dateRadioModel = 'Any';
                    $scope.dateFHanlder(null);
                    dateFromSelected = false;
                }else{
                    $scope.dateRadioModel = 'Select';
                    $scope.dateFHanlder(value);
                    dateFromSelected = true;
                }
            break; 
            
            case 'dateTo' :
                if(value == 0){
                    $scope.dateRadioModel = 'Any';
                    $scope.dateTHanlder(null);
                    dateToSelected = false;
                }else{
                    $scope.dateRadioModel = 'Select';
                    $scope.dateTHanlder(value);
                    dateToSelected = true;
                }
                if(dateFromSelected || dateToSelected){
                     $scope.dateRadioModel = 'Select';
                }
            break; 
            
            case 'daysBewRaceDay' :
                if(value == 0){
                    $scope.daysBewRaceRadioModel = 'Any';
                    $scope.daysBewDay = null;   
                }else{
                    $scope.daysBewRaceRadioModel = 'Select';
                    $scope.daysBewDay = value;  
                }
            break; 
            
            case 'distanceFrom' :
                if(value == 0 && $scope.distanceTo == 0){
                    $scope.distanceRadioModel = 'Any';
                    $scope.distanceFrom = 0;   
                }else{
                    $scope.distanceRadioModel = 'Select';
                    $scope.distanceFrom = value;  
                }
            break;
            
            case 'distanceTo' :
                if(value == 0 && $scope.distanceFrom == 0){
                    $scope.distanceRadioModel = 'Any';
                    $scope.distanceTo = 0;   
                }else{
                    $scope.distanceRadioModel = 'Select';
                    $scope.distanceTo = value;  
                }
            break;
            
            case 'handicap' :
                if(value == 0){
                    $scope.handicapRadioModel = 'Any';
                    $scope.handicapCheckModel = null;   
                }else{
                    $scope.handicapRadioModel = 'Select';
                    $scope.handicapCheckModel = toObject(value); 
                }
            break;
            
            case 'leastRun' :
                if(value == 0){
                    $scope.leastRunRadioModel = 'Any';
                    $scope.leastRunCheckModel = null;   
                }else{
                    $scope.leastRunRadioModel = 'Select';
                    $scope.leastRunCheckModel = value;  
                }
            break;
            
            case 'report_on' :
                $scope.selectedReport = value;
            break;
            
            case 'same' :
                if(value !== 0)
                $scope.SAME = value;
            break;
         }
  });
    
}



function toObject(arr) {
  var rv = {};
  for (var i = 0; i < arr.length; i++){
      var j = arr[i];
      rv[j] =  true;  
  }    
  return rv;
}

function toObjectForAge(arr){
    var rv = {};
    for (var i = 0; i < arr.length; i++){
      var j = arr[i];
      var key = $scope.ageValue_1[j];
      if(key == "agePlus"){
          rv[key] =  j.replace("+","")*1;  
      }else{
          rv[key] = true;
      }
      
    }    
    return rv;
}


function toObjectForRTcLong(arr){
    var rv = {};
    for (var i = 0; i < arr.length; i++){
        angular.forEach($scope.rTcLongNames, function(value, key){
            if(arr[i] == value)
            {
                rv[key] = true;
            }
        })
    }
    return rv;
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
$scope.saveSettings = function(){
    
//   console.log($scope.loadedsettings.indexOf($scope.newSettingName));
//   console.log($scope.newSettingName);
   
   if($scope.loadedsettings.indexOf($scope.newSettingName) !== -1 || !$scope.newSettingName){//$.inArray($scope.newSettingName, $scope.loadedsettings) !== -1){
        $("#error_mess").css("color","red");
        $("#error_mess").text("Duplicated name detected, please try again!");
   }else{
       $scope.insertSetting();
   }
   
    
}

/*-----------------------------------------------------------------------------------------------------------------------------*/
 $scope.insertSetting =function(){
        
    result.reportName = $scope.newSettingName;
    result.report_on = $scope.selectedReport;
    result.same = {};
    if($scope.SAME){
        for(var key in $scope.SAME)
        {
            if($scope.SAME.key)
            {
                result.same = $scope.SAME;
                break;
            }
        }
    }
    
    
    var json = JSON.stringify(result);
    $scope.oldSettings[$scope.newSettingName] = json;
    

    $.post("./ajaxFilterSettings.php", {insertSetting:1,settings:json}, 
        function(data){
            console.log(data); //return;
            if(data == 1){
                $("#error_mess").css("color","green");
                $("#error_mess").text("Success Saved!");
                $timeout(function(){
                    $("#FilterConditionSavingModal").modal("hide");
                },2000);
                $scope.initSettings();
            }

            $scope.$apply(); 
        });
    }
    
$scope.openSaveModal = function(){
    $("#filter_name").val("");
    $("#FilterConditionSavingModal").modal("show");
    $("#error_mess").text("");
}    

$scope.numofHorse = 1000;
$scope.openSetNumOfHorseModal = function(){
    
    $("#numOfHorseModal").modal("show");
}

$scope.setNumofHorse = function(){
    if(!$scope.numofHorse || $scope.numofHorse < 1){
            $scope.numofHorse = 1;
    }
    $("#numOfHorseModal").modal("hide");
}
    
$scope.deleteSettings =function(){

    $scope.arrayIndex = $scope.loadedsettings.indexOf($scope.oldSettingUserchoosed);
    $scope.loadedsettings.splice($scope.arrayIndex, 1);
    $scope.autoLoadSettingSwitch = false;
    $.post("./ajaxFilterSettings.php", {deleteSetting:1,deletedSettingName:$scope.oldSettingUserchoosed}, 
    function(data){
        $scope.$apply(); 
    });
}

$scope.initSettings();
}]);



















