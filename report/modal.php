<div class="modal fade" id="raceClassModal" role="dialog">
    <div class="modal-dialog  modal-lg">
      <!-- Modal content-->
      <div class="modal-content">
        <div class="modal-header">
          <center><h4 class="modal-title">Race Classes</h4></center>
          <button type="button" class="close" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
            <div class="row" style="padding-right:30px;padding-left:30px">
                <div class="col-sm-4 column margintop20">
                    <ul class="nav nav-pills nav-stacked" id="raceClassCategUl">
                        <li ng-repeat="categ in raceClassCateg track by $index"><a ng-click="getRaceClassCategContent($event)" ><span class="fas fa-angle-right"></span> {{categ}}</a></li>
                    </ul>
                </div>
                <div class="col-sm-8 column margintop201">
                <table class="table" id="raceClassTable">
                    <thead>
                      <tr>
                          <th colspan="5"><label><input type="checkbox" id="select_all" value="select_all" >&nbsp;<span id="selectedRaceClassCateg"></span></label></th> 
                      </tr>
                    </thead>
                    <tbody id="raceClassTbody">
                        <tr ng-repeat="i in array track by $index">
                            <td><label ng-if="selectedRaceClass[$index*col_num+0]"><input type="checkbox" value="{{selectedRaceClass[$index*col_num+0]}}">&nbsp;{{selectedRaceClass[$index*col_num+0]}}</label></td>
                            <td><label ng-if="selectedRaceClass[$index*col_num+1]"><input type="checkbox" value="{{selectedRaceClass[$index*col_num+1]}}">&nbsp;{{selectedRaceClass[$index*col_num+1]}}</label></td>
                            <td><label ng-if="selectedRaceClass[$index*col_num+2]"><input type="checkbox" value="{{selectedRaceClass[$index*col_num+2]}}">&nbsp;{{selectedRaceClass[$index*col_num+2]}}</label></td>
                            <td><label ng-if="selectedRaceClass[$index*col_num+3]"><input type="checkbox" value="{{selectedRaceClass[$index*col_num+3]}}">&nbsp;{{selectedRaceClass[$index*col_num+3]}}</label></td>
                            <td><label ng-if="selectedRaceClass[$index*col_num+4]"><input type="checkbox" value="{{selectedRaceClass[$index*col_num+4]}}">&nbsp;{{selectedRaceClass[$index*col_num+4]}}</label></td>
                        </tr>
                    </tbody>
                </table>
                </div>
                </div>

        </div>
        <div class="modal-footer modalFooter1">
            <button type="button" class="btn btn-default btn-sm pull-left" data-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
</div>
            
            
<!--FilterCondition Saving Modal-->
<div class="modal fade" id="FilterConditionSavingModal" role="dialog">
    <div class="modal-dialog">
      <!-- Modal content-->
      <div class="modal-content">
        <div class="modal-header">
          <center><h4 class="modal-title">Filter Condition Saving</h4></center>
          <button type="button" class="close" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
            <br>
            <div class="row" >
                <div class="col-sm-7">
                    <input type="text" id="filter_name" class="form-control pull-right"  ng-model="newSettingName" placeholder="Give a name">
                </div>
                <div class="col-sm-5">
                    <a class="w3-btn w3-black w3-small w3-theme w3-hover-black w3-hover-shadow run-btn-s pull-left" ng-click="saveSettings()">Save Filters</a>
                </div>
            </div>
        <br>    
        </div>
        <div class="modal-footer modalFooter1">
            
            <div class="pull-left mr-auto" id="error_mess"></div>
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
</div>
<!--ssss-->  


<div class="modal fade" id="numOfHorseModal" role="dialog">
    <div class="modal-dialog">
       Modal content
      <div class="modal-content">
        <div class="modal-header">
          <center><h4 class="modal-title">Input a different number</h4></center>
          <button type="button" class="close" data-dismiss="modal">&times;</button>
        </div>
        <div class="modal-body">
            <br>
            <div class="row" >
                <div class="col-sm-1">
                    
                </div>
                <div class="col-sm-7">
                    <input type="number" id="num_horse" class="form-control pull-right"  ng-model="numofHorse" min=1 value=1000 >
                </div>
                <div class="col-sm-4">
                    <a class="w3-btn w3-black w3-small w3-theme w3-hover-black w3-hover-shadow run-btn-s pull-left" ng-click="setNumofHorse()">Save</a>
                </div>
            </div>
            <br>    
        </div>
        <div class="modal-footer modalFooter1">
            
            <div class="pull-left mr-auto" id="error_mess"></div>
            <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
        </div>
      </div>
    </div>
</div>