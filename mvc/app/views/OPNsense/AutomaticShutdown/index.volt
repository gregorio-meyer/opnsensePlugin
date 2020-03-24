<script>
    $(document).ready(function () {
        var data_get_map = { 'DialogAddress': "/api/automaticshutdown/settings/get" };

        // load initial data
        mapDataToFormUI(data_get_map).done(function () {
            /*            formatTokenizersUI();
                       $('.selectpicker').selectpicker('refresh');
                       // request service status on load and update status box
                       ajaxCall(url = "/api/automaticshutdown/service/status", sendData = {}, callback = function (data, status) {
                           updateServiceStatusUI(data['status']);
                       }); */
        });
        $("#grid-addresses").UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',
            }
        );
        //remove cron jobs with an AJAX call
        /* function remove() {
            ajaxCall(url = "/api/cron/settings/searchJobs/*?searchPhrase=Stop Firewall", sendData = {}, callback = function (data, status) {
                console.log(JSON.stringify(data));
                console.log(status);
                console.log("Stop: ")
                data['rows'].forEach(d => {
                    ajaxCall(url = "/api/cron/settings/delJob/" + d['uuid'], sendData = {}, callback = function (data, status) {
                        console.log(data);
                        console.log(status);
                    });
                })
                ajaxCall(url = "/api/cron/settings/searchJobs/*?searchPhrase=Start Firewall", sendData = {}, callback = function (data, status) {
                    console.log("Start: ")
                    data['rows'].forEach(d => {
                        ajaxCall(url = "/api/cron/settings/delJob/" + d['uuid'], sendData = {}, callback = function (data, status) {
                            console.log(data);
                            console.log(status);
                        });
                    })
                });
                ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function (data, status) {
                    console.log("Result: ")
                    data['rows'].forEach(d => {
                        console.log(JSON.stringify(d));
                    });
                })
            }); */
        //}

        //   $("#shutdownMsg").append('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');

        /*       */

        $("#saveAct").click(function () {
            //remove()
            save();
            //save()
            // alert("Saved");
        });

    });
    function addJobs(startHour, endHour) {
        ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown start", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
            console.log("Add start hour " + startHour);
            //add cron job if enabled
            ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown stop", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                console.log("Add end hour " + endHour);
            });
        });
    }

    $(document).on('click', "#btn_DialogAddress_save", function () {
     //   var enabled = $("#hour\\.enabled");
        var startHour = $("#hour\\.StartHour").val();
        var endHour = $("#hour\\.EndHour").val();
        alert("Planned shutdown between " + startHour + " and " + endHour);
        $("#shutdownMsg").html("")
        saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
            // action to run after successful save, for example reconfigure service.
            //remove it should only enable/disable scheduling                    
           // if (enabled == 1) {
                addJobs(startHour, endHour);
            //}
            ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                $("#shutdownMsg").removeClass("hidden");
            });
        });
    })
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function () {
        alert("Deleted");
        // save();
    })
    $(document).on('click', "btn btn-xs btn-default command-edit", function () {
        console.log("Edit");
        alert("Edit");
        // save();
    })
    $(document).on('hidden.bs.modal', '#DialogAddress', function () {
        //  alert("Hidden");


    });
</script>

<div class="alert alert-info hidden" role="alert" id="shutdownMsg">

</div>

<table id="grid-addresses" class="table table-condensed table-hover table-striped" data-editDialog="DialogAddress">
    <thead>
        <tr>
            <th data-column-id="uuid" data-type="string" data-identifier="true" data-visible="false">{{ lang._('ID') }}
            </th>
            <th data-column-id="enabled" data-width="6em" data-type="string" data-formatter="rowtoggle">
                {{ lang._('Enabled') }}</th>
            <th data-column-id="StartHour" data-type="int">{{ lang._('StartHour') }}</th>
            <th data-column-id="EndHour" data-type="int">{{ lang._('EndHour') }}</th>
            <th data-column-id="commands" data-width="7em" data-formatter="commands" data-sortable="false">
                {{ lang._('Commands') }}</th>
        </tr>
    </thead>
    <tbody>
    </tbody>
    <tfoot>
        <tr>
            <td></td>
            <td>
                <button data-action="add" type="button" class="btn btn-xs btn-default"><span
                        class="fa fa-plus"></span></button>
                <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span
                        class="fa fa-trash-o"></span></button>
            </td>
        </tr>
    </tfoot>
</table>
<div class="col-md-12">
    <br><br>
    <button class="btn btn-primary" id="saveAct" type="button"><b>Apply</b><i id="saveAct_progress" class=""></i>
    </button>
</div>
{{ partial("layout_partials/base_dialog",['fields':formDialogAddress,'id':'DialogAddress','label':lang._('Edit hour')])}}