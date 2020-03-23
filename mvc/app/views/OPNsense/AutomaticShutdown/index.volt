<script>
    $(document).ready(function () {
        $("#grid-addresses").UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',
                responseHandler: function (response) {
                    console.log(JSON.stringify(response));
                }
            }
        );
        //remove cron jobs with an AJAX call
        function remove() {
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
            });
        }
        function addStartJob(startHour) {
            console.log("Start hour: " + startHour)
            $.post(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown start", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
                $.post(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function (data, status) {
                    console.log("Add start hour " + JSON.stringify(data));
                    console.log(status);
                    console.log(JSON.stringify(data));
                    console.log(status);
                });
            });
        }
        function addEndJob(endHour) {
            console.log("End hour: " + endHour);
            //add cron job if enabled
            $.post(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown stop", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                console.log("Add end hour " + JSON.stringify(data));
                console.log(status);
                $.post(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function (data, status) {
                    console.log(JSON.stringify(data));
                    console.log(status);
                });
            });
            //   $("#shutdownMsg").append('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');
        }
        /*       ajaxCall(url = "/api/cron/service/reconfigure", sendData = {}, callback = function (data, status) {
                        console.log(JSON.stringify(data));
                        console.log(status);
                    });*/
        function save() {
            $("#shutdownMsg").html("")
            saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                    $("#shutdownMsg").removeClass("hidden");
                });
            });
        }
        function addJobs() {
            var rows = $("#grid-addresses").bootgrid('getCurrentRows');
            rows.forEach(h => {
                //remove it should only enable/disable scheduling                    
                if (h['enabled'] == 1) {
                    addStartJob(h['StartHour']);
                    addEndJob(h['EndHour']);
                }
            });
        }
        $("#saveAct").on('click', function () {
            //remove()
            save()
            addJobs()
            alert("Saved")
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
<div class="col-md-12">
    <br><br>
    <button class="btn btn-primary" id="saveAct" type="button"><b>Apply</b><i id="saveAct_progress" class=""></i>
    </button>
</div>
{{ partial("layout_partials/base_dialog",['fields':formDialogAddress,'id':'DialogAddress','label':lang._('Edit hour')])}}