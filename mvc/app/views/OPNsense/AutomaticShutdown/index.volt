<script>
    $(document).ready(function () {
        console.log("Ready")
        //add
        function save() {
            console.log("Saved")

            saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
                console.log("Set")
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                    //add cron job
                    console.log("Reload")
                    console.log(JSON.stringify(data))
                    var hour = data['message']['hours']['hour'];
                    var startHour = data['message']['hours']['hour']['StartHour'];
                    var endHour = data['message']['hours']['hour']['EndHour'];
                    console.log("Start hour: "+startHour)
                    console.log("End hour: "+endHour)
                    console.log("Data: "+JSON.stringify(data))
                    console.log("Status: "+status)
                    console.log("hour: "+JSON.stringify(hour))
                    console.log("hour0: "+hour[0]['StartHour'])
                    //plan firewall stop
                    ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown start", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
                        console.log(data);
                        console.log(status);
                        ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown stop", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                            console.log(data);
                            console.log(status);
                        });
                    });
                    $("#shutdownMsg").html('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');
                    $("#shutdownMsg").removeClass("hidden");
                });
            });
        }
        $("#grid-addresses").on("initialize.rs.jquery.bootgrid", function (e) {
            // ...
            //alert("Initilize: ");

        }).on("initialized.rs.jquery.bootgrid", function (e, columns, row) {
            // ...
            //alert("Initialized ");
        }).on("selected.rs.jquery.bootgrid", function (e, rows) {
            alert("Select: ");
            save();
        }).on("deselected.rs.jquery.bootgrid", function (e, rows) {

            alert("Deselect: ");
        }).UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',

            }
        ).on("removed.rs.jquery.bootgrid", function (e, rows) {
            // save()
            alert("Removed: ");
        }).on("appended.rs.jquery.bootgrid", function (e, rows) {
            save()
            alert("Appended: ");
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