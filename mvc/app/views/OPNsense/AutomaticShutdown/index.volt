<!--     var data_get_map = { 'frm_GeneralSettings': "/api/automaticshutdown/settings/get" };
        mapDataToFormUI(data_get_map).done(function (data) {
            // place actions to run after load, for example update form styles.
        });
    
        // link save button to API set action
      

<div class="col-md-12">
    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_GeneralSettings'])}}
</div>

<div class="col-md-12">
    <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Save') }}</b></button>
</div> -->
<script>
    $(document).ready(function () {
        console.log("Ready")
        $("#grid-addresses").UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/'
            });
        //add
        $("#grid-addresses").bootgrid()
            .on("appended.rs.jquery.bootgrid", function (e) {
                console.log("Appended")
                saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
                    // action to run after successful save, for example reconfigure service.
                    ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                        //add cron job
                        var startHour = data['message']['general']['StartHour'];
                        var endHour = data['message']['general']['EndHour'];
                        //plan firewall stop
                        ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown start", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
                            console.log(data);
                            console.log(status);
                            ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown stop", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                                console.log(data);
                                console.log(status);
                            });
                        });
                        //$.get("/api/automaticshutdown/service/status"){ }
                        // action to run after reload
                        $("#shutdownMsg").html('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');
                        $("#shutdownMsg").removeClass("hidden");
                    });
                });
            });
        // delete
        $("#grid-addresses").bootgrid()
            .on("removed.rs.jquery.bootgrid", function (e) {
                console.log("Removed")
                $("#shutdownMsg").html('<p> Scheduled shutdown removed ' + startHour + ' and ' + endHour + '</p>');
                $("#shutdownMsg").removeClass("hidden");
            });
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
{{ partial("layout_partials/base_dialog",['fields':formDialogAddress,'id':'DialogAddress','label':lang._('Edit hour')])}}