 <!doctype html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <meta name="description" content="">
        <meta name="author" content="">
        
        <link href="./horse_js/lib/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="bootstrap/css/bootstrap.css">
        <link rel="stylesheet" href="./horse_js/lib/w3.css">
        <link href="./../vendor/fontawesome-free-5.0.8/web-fonts-with-css/css/fontawesome-all.min.css" rel="stylesheet" type="text/css">
        <link href="./../css/modal-raceclass.css" rel="stylesheet" type="text/css">
        <link href="./../css/loader.css" rel="stylesheet" type="text/css">
        <link href="./../css/index.css" rel="stylesheet" type="text/css">
        
        <script src="./horse_js/lib/jquery.min.js"></script>
        <script src="./horse_js/lib/angular.js"></script>
        <script src="./horse_js/lib/angular-animate.js"></script>
        <script src="./horse_js/lib/angular-sanitize.js"></script>
        <script src="./horse_js/lib/ui-bootstrap-tpls-2.5.0.js"></script>
        <script src="./horse_js/lib/bootstrap.min.js"></script>
        
        <script src="./horse_js/index.js"></script>
        
    </head>
    <body>
        <div class="container" ng-app="horseRacing" ng-controller="ButtonsCtrl">
            
            <div class="cubes loading_animation" style="display:none" id="cubes">
                <div class="sk-cube sk-cube1"></div>
                <div class="sk-cube sk-cube2"></div>
                <div class="sk-cube sk-cube3"></div>
                <div class="sk-cube sk-cube4"></div>
                <div class="sk-cube sk-cube5"></div>
                <div class="sk-cube sk-cube6"></div>
                <div class="sk-cube sk-cube7"></div>
                <div class="sk-cube sk-cube8"></div>
                <div class="sk-cube sk-cube9"></div>
            </div>
            
            <div class="loading" style="display:none" id="loading">    
            </div>
             <!-- begin cubes modal -->
 
            
            <!--**********************************************************barrier**********************************************************-->
            <div>
                <br>
                <center>
                    <h3><strong>Filter Conditions</strong></h3>
                </center>
                <hr>
                <div class="row">
                    <div class="col-3">
                        <select class="form-control selectedReport" ng-model="oldSettingUserchoosed">
                            <option ng-repeat="x in loadedsettings" value="{{x}}">{{x}}</option>
                        </select>
                    </div>
                    <div class="col-2">
                        <i class="fas fa-trash-alt w3-hover-shadow" ng-click="deleteSettings()"></i>
                    </div>
                    <div class="col-6">
                        <!--<input type="checkbox" ng-model="testModel"> test model-->
                        <a class="w3-btn w3-black w3-small w3-theme w3-hover-black w3-hover-shadow run-btn-s pull-right" ng-click="openSaveModal()">Save Filters</a>
                    </div>

                </div>

                <hr>
                <div class="row row-top">
                    <div class="col-3" ><h4>Barrier</h4></div>
                    <div class="col-8"><div class="selectedCond pull-left">[{{barrierCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label  class="btn btn-primary overWritePrimary" ng-model="SAME.barrier" uib-btn-checkbox>SAME</label>
                            <label  class="btn btn-primary overWritePrimary" ng-model="barrierRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label  class="btn btn-primary overWritePrimary" ng-model="barrierRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                    <div class="col-8">
                        <input  type="text" type=“number” class="form-control" ng-model="barrierCheckModel" ng-disabled="barrierRadioModel !== 'Select'"/>      
                    </div>
                </div>
            </div>


            <!--**********************************************************WFA**********************************************************-->

            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>WFA</h4></div>
                    <div class="col-8"><div class="selectedCond pull-left">[{{WFACheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.WFA" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="WFARadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="WFARadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                    <div class="col-8">
                        <input  type="text" class="form-control" ng-model="WFACheckModel" ng-disabled="WFARadioModel !== 'Select'"/>      
                    </div>
                </div>
            </div>


            <!--**********************************************************class**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>raceClass</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{classCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.raceClass" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="raceClassRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="raceClassRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                    <div class="col-7">
                        <input  type="text" class="form-control" ng-model="raceClassCheckModel" ng-disabled="raceClassRadioModel !== 'Select'"/>
                        <!--                                    <button type="button" class="btn btn-primary overWritePrimary" ng-model="classModalModel" uib-btn-radio="'B'" data-toggle="modal" data-target=".bd-example-modal-lg"  ng-disabled="classRadioModel !== 'Select'">B</button>
                                                             <button type="button" class="btn btn-primary overWritePrimary" ng-model="classModalModel" uib-btn-radio="'R'" data-toggle="modal" data-target=".bd-example-modal-lg" ng-disabled="classRadioModel !== 'Select'">R</button>-->
                    </div>
                    <div class="col-1">
                        <center><i class="fas fa-clipboard-list w3-hover-shadow" ng-click="openRaceClassModal()"></i></center>
                    </div>
                </div>
            </div>



            <!--**********************************************************state**********************************************************-->

            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>State</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{stateCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.state" uib-btn-checkbox >SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="stateRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="stateRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                    <div class="col-8">
                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.NT" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">NT</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.NSW" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'"> NSW</button>

                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.QLD" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">QLD</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.SA" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">SA</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.TAS" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">TAS</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.VIC" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">VIC</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.WA" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">WA</button>


                            &nbsp;&nbsp; 
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.NZ" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">NZ</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.JAP" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">JAP</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="stateCheckModel.HK" uib-btn-checkbox ng-disabled="stateRadioModel !== 'Select'">HK</button>
                        </div>

                    </div>
                </div>
            </div>


            <!--**********************************************************sex**********************************************************-->     

            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>Gender</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{sexCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.sex" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="sexRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="sexRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.FM" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'"> FM</button>
                            <!--<button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.CHG" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">CHG</button>-->
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.EG" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">EG</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.F" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">F</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.CG" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">CG</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.M" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">M</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.HGM" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">HGM</button>
                            <!--<button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.HG" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">HG</button>-->
                            <button class="btn btn-primary overWritePrimary" ng-model="sexCheckModel.Open" uib-btn-checkbox ng-disabled="sexRadioModel !== 'Select'">Open</button>
                        </div>

                    </div>
                </div>
            </div>



            <!--**********************************************************trackcat**********************************************************-->

            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>track Category</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{trackcatCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.trackCat" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="trackcatRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="trackcatRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="trackcatCheckModel.M" uib-btn-checkbox ng-disabled="trackcatRadioModel !== 'Select'"> M</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackcatCheckModel.P" uib-btn-checkbox ng-disabled="trackcatRadioModel !== 'Select'">P</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackcatCheckModel.C" uib-btn-checkbox ng-disabled="trackcatRadioModel !== 'Select'">C</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackcatCheckModel.N" uib-btn-checkbox ng-disabled="trackcatRadioModel !== 'Select'">N</button>

                        </div>

                    </div>
                </div>
            </div> 


            <!--**********************************************************DOW**********************************************************-->  
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>DOW</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{DOWCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.DOW" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="DOWRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="DOWRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.MetroSat" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Saturday</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.MetroMidWeek" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Mid Week</button>
<!--                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.ProSat" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Pro Sat</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.ProMidWeek" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Pro Mid Week</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.CountrySat" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Country Sat</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.CountryMidWeek" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Country Mid Week</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="DOWCheckModel.Picnic" uib-btn-checkbox ng-disabled="DOWRadioModel !== 'Select'">Picnic</button>-->

                        </div>

                    </div>
                </div>
            </div> 


            <!--*******************************************************age*************************************************************-->          
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>age</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{ageCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.age" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="ageRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="ageRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age2" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">2</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age3" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">3</button> 
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age4" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">4</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age5" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">5</button>
                            
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age23" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">23</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age24" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">24</button> 
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age25" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">25</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age34" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">34</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age35" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">35</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age45" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">45</button> 
                            
                            &nbsp;&nbsp; 
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age2plus" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">2+</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age3plus" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">3+</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age4plus" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">4+</button>
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.age5plus" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">5+</button> 
                            <button class="btn btn-primary overWritePrimary minwidth45" ng-model="ageCheckModel.ageopen" uib-btn-checkbox ng-disabled="ageRadioModel !== 'Select'">open</button>
                            &nbsp;&nbsp; 
                        </div>
                            
                        <!--</div>-->

                    </div>
                </div>
            </div>     

           
            <!--**********************************************************trackcondition**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>track Condition</h4></div>
                    <div class="col-8"><div class="selectedCond pull-left">[{{trackconditionCheckResults}}]</div></div>

                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.trackCond" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="trackConditionRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="trackConditionRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>
                    </div>


                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="trackconditionCheckModel.F" uib-btn-checkbox ng-disabled="trackConditionRadioModel !== 'Select'">F</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackconditionCheckModel.G" uib-btn-checkbox ng-disabled="trackConditionRadioModel !== 'Select'">G</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackconditionCheckModel.D" uib-btn-checkbox ng-disabled="trackConditionRadioModel !== 'Select'">D</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackconditionCheckModel.S" uib-btn-checkbox ng-disabled="trackConditionRadioModel !== 'Select'">S</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="trackconditionCheckModel.H" uib-btn-checkbox ng-disabled="trackConditionRadioModel !== 'Select'">H</button>

                        </div>
                    </div>
                </div>
            </div>

            <!--**********************************************************R_tc_long**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>R_TC_LONG</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{rTcLongCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.rTcLong" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="rTcLongRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="rTcLongRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>
                    </div>

                    <div class="col-8">

                        <div class="btn-group">
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.F1" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">F1</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.F2" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">F2</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.G3" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">G3</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.G4" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">G4</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.S5" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">S5</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.S6" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">S6</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.S7" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">S7</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.H8" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">H8</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.H9" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">H9</button>
                            <button class="btn btn-primary overWritePrimary" ng-model="rTcLongCheckModel.H10" uib-btn-checkbox ng-disabled="rTcLongRadioModel !== 'Select'">H10</button>
                        </div>
                    </div>
                </div>
            </div>


            <!--**********************************************************diffdistance**********************************************************-->    
            <!--     <div>
                    <div class="row row-top">
                        <div class="col-3" ><h4>difference in Distance</h4></div>
            
                        <div class="col-8"><div class="selectedCond pull-left">DiD {{diffdistanceRadioModel}}: [{{diffdistanceCheckResults}}]</div></div>
                    </div>
                    <div class="row">
                        <div class="col-3">
                           <div class="btn-group">
                               <label class="btn btn-primary overWritePrimary" ng-model="diffdistanceRadioModel" uib-btn-radio="'Same'">SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="diffdistanceRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="diffdistanceRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                            </div>     
                        </div>
                       
                        <div class="col-2">
                                                <input  type="text"class="form-control" placeholder="      eg:300" ng-model="diffdistanceMinModel" ng-disabled="diffdistanceRadioModel !== 'Select'"/>
                        </div>
                        <div class="col-auto"><h6><=</h6></div>
                        <div class="col-2">
                      <input  type="text" class="form-control" placeholder="    Baseline" ng-model="diffdistanceBaseModel" ng-disabled="diffdistanceRadioModel !== 'Select'"/> 
                        </div>
                        <div class="col-auto"><h6>>=</h6> </div>
                      
                        <div class="col-2">
                      <input  type="text" class="form-control" placeholder="      eg:400" ng-model="diffdistanceMaxModel" ng-disabled="diffdistanceRadioModel !== 'Select'"/> 
                        </div>
                    </div>
                 </div>   -->
            <!--**********************************************************Jockey**********************************************************--> 
            <div>
                <div class="row  row-top">
                    <div class="col-3" ><h4>jockey</h4></div>
                    <div class="col-8"><div class="selectedCond pull-left">[{{jockeyCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.jockey" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="jockeyRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="jockeyRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="text" class="form-control" ng-model="jockeyCheckModel" ng-disabled="jockeyRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  

            <!--**********************************************************start**********************************************************-->   
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>Magin</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{maginCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.magin" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="maginRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="maginRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="text" class="form-control" ng-model="maginCheckModel" ng-disabled="maginRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  

            <!--**********************************************************finishpos**********************************************************-->  



            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>finishPos</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{finishPosCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.finishPos" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="finishPosRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="finishPosRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="text" class="form-control" ng-model="finishPosCheckModel" ng-disabled="finishPosRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  

            <!--**********************************************************money**********************************************************-->  
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>prise Money</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{moneyCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.prise" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="priseRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="priseRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="text" class="form-control" ng-model="priseCheckModel" ng-disabled="priseRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  
            
             
             <!--**********************************************************days**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>day Since Pre Start</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{dayCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="same" uib-btn-checkbox="'day'" disabled style='pointer-events: none'>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="dayRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="dayRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="number" min=0 class="form-control" ng-model="dayCheckModel" ng-disabled="dayRadioModel !== 'Select'"/>
                    </div>
                </div>
            </div> 
            
            <!--**********************************************************start**********************************************************--> 
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>days Betw Race</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{daysBewRaceCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="same" uib-btn-checkbox="'daysBewt'" disabled style='pointer-events: none'>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="daysBewRaceRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="daysBewRaceRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                        
                    <div class="col-8">
                        <input  type="number" min=0 placeholder="" class="form-control" ng-model="daysBewDay" ng-disabled="daysBewRaceRadioModel !== 'Select'"/>  
                    </div>
                </div>
            </div>  

            <!--**********************************************************date**********************************************************-->
              <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>Date</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{dateCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.date" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="dateRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="dateRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-1">
                        FROM
                    </div>
                    <div class="col-3">
                        <input  type="date" placeholder="yyyy-MM-DD" id="dateFrom" class="form-control" ng-model="dateFrom" ng-disabled="dateRadioModel !== 'Select'" ng-change="dateFHanlder();" />   
                    </div>
                    <div class="col-1">
                        <span style='margin-left:-10px'>TO</span>
                    </div>
                    <div class="col-3">
                        <input  type="date" min=0 placeholder="yyyy-MM-DD" id="dateTo" class="form-control" ng-model="dateTo" ng-disabled="dateRadioModel !== 'Select'" ng-change="dateTHanlder();"/>   
                    </div>
                </div>
            </div> 
            
            <!--**********************************************************start**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>distance</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{distanceCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.distance" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="distanceRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="distanceRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>
                    <div class="col-1">
                        FROM
                    </div>
                    <div class="col-3">
                        <input  type="number" min=0 class="form-control" ng-model="distanceFrom" ng-disabled="distanceRadioModel !== 'Select'"/>   
                    </div>
                    <div class="col-1">
                        TO
                    </div>
                    <div class="col-3">
                        <input  type="number" min=0 class="form-control" ng-model="distanceTo" ng-disabled="distanceRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  


            <!--**********************************************************handicap**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>handicap</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{handicapCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="SAME.handicap" uib-btn-checkbox>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="handicapRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="handicapRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <div class="btn-group">
                        <button class="btn btn-primary overWritePrimary" ng-model="handicapCheckModel.S" uib-btn-checkbox ng-disabled="handicapRadioModel !== 'Select'">S</button>
                        <button class="btn btn-primary overWritePrimary" ng-model="handicapCheckModel.W" uib-btn-checkbox ng-disabled="handicapRadioModel !== 'Select'">W</button> 
                        <button class="btn btn-primary overWritePrimary" ng-model="handicapCheckModel.P" uib-btn-checkbox ng-disabled="handicapRadioModel !== 'Select'">P</button>
                        <button class="btn btn-primary overWritePrimary" ng-model="handicapCheckModel.OPEN" uib-btn-checkbox ng-disabled="handicapRadioModel !== 'Select'">OPEN</button>
                        </div>    
                        <!--<input  type="text" class="form-control" ng-model="handicapCheckModel" ng-disabled="handicapRadioModel !== 'Select'"/>-->   
                    </div>
                </div>
            </div>  
            
            <!--**********************************************************handicap**********************************************************-->
            <div>
                <div class="row row-top">
                    <div class="col-3" ><h4>The least races/horse</h4></div>

                    <div class="col-8"><div class="selectedCond pull-left">[{{leastRunCheckResults}}]</div></div>
                </div>
                <div class="row">
                    <div class="col-3">
                        <div class="btn-group">
                            <label class="btn btn-primary overWritePrimary" ng-model="same" uib-btn-checkbox="'least'" disabled style='pointer-events: none'>SAME</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="leastRunRadioModel" uib-btn-radio="'Any'">ANY</label>
                            <label class="btn btn-primary overWritePrimary" ng-model="leastRunRadioModel"  uib-btn-radio="'Select'">SELECT</label>
                        </div>     
                    </div>

                    <div class="col-8">
                        <input  type="number" min=2 class="form-control" value=2 ng-model="leastRunCheckModel" ng-disabled="leastRunRadioModel !== 'Select'"/>   
                    </div>
                </div>
            </div>  


            <!--**********************************************************start**********************************************************-->

            <hr>
            <div class="row">
                <div class="col-3">
                    <select class="form-control selectedReport" ng-model="selectedReport" ng-options="x for x in reports">
                        <option value="">Select Report</option>
                    </select>
                </div>
                <div class="col-6" >
                    <a class="pull-right" style="text-decoration: underline;" ng-click="openSetNumOfHorseModal()">Stop at a different number of horse?</a>
                </div>
                <div class="col-2">
                    <div><a class="w3-btn w3-green w3-theme w3-hover-green w3-hover-shadow run-btn-s pull-right" ng-click="startReport()">Run Report</span></a></div>
                    <div class="fixedpos">
                        <input type="checkbox" id="testModel" ng-model="testModel"> <label for="testModel">test model</label><br>
                        <div><a class="w3-btn w3-green w3-theme w3-hover-green w3-hover-shadow run-btn pull-right" ng-click="startReport()">Run Report</span></a></div>
                    </div>
                </div>

            </div>
            <!--ng-controller="startReport"-->

            
<?php include("modal.php"); ?>   
            
</div>
<br><br><br><br><br><br><br><br><br>


        

        
</body>
</html>
