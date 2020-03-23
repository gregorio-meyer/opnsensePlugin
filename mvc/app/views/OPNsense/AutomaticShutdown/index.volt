<script>
    $(document).ready(function () {
        console.log("Ready")
        var original_rows = null
        $("#grid-addresses").on("initialize.rs.jquery.bootgrid", function (e) {
            // ...
            //alert("Initilize: ");
        }).on("loaded.rs.jquery.bootgrid", function (e, columns, row) {
            if (original_rows == null) {
                original_rows = $("#grid-addresses").bootgrid('getCurrentRows');
            }
            console.log("Original " + JSON.stringify(original_rows))
        }).on("removed.rs.jquery.bootgrid", function (e, removedRows) {
            // save()
            console.log("Removed");
        }).on("appended.rs.jquery.bootgrid", function (e, appendedRows) {
            console.log("Append");
            save();
        }).on("selected.rs.jquery.bootgrid", function (e, rows) {
            //    save();
        }).on("deselected.rs.jquery.bootgrid", function (e, rows) {
            //alert("Deselect: ");
        }).UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',

            }
        );

        function remove() {
            console.log("Removing...")
            console.log("Original rows " + JSON.stringify(original_rows))
            var current = $("#grid-addresses").bootgrid('getCurrentRows');
            console.log("Current rows " + JSON.stringify(current))
            var toRemove = Array.from(original_rows)
            current.forEach(x => {
                uuid = x['uuid'];
                var pos = original_rows.map(function (e) {
                    return e.uuid;
                }).indexOf(uuid);
                console.log("Index "+pos)
              /*   original_rows.forEach(r => {
                    if (r['uuid'] == uuid) {
                        console.log("Deleted: " + JSON.stringify(r))
                        toRemove.push(r)
                    }
                }); */
            }); 
            //remove cron jobs with an AJAX call
        }
        function save() {

            $("#shutdownMsg").html("")
            saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                    var rows = $("#grid-addresses").bootgrid('getSelectedRows');
                    var length = rows.length
                    if (length == 0) {
                        rows = Object.values(data['message']['hours']['hour']);
                    }
                    rows.forEach(i => {
                        var h = i;
                        //if a selection was made get the selected element
                        if (length != 0) {
                            h = data['message']['hours']['hour'][i]
                        }
                        var enabled = h['enabled']
                        if (enabled == 1) {
                            var startHour = h['StartHour'];
                            var endHour = h['EndHour'];
                            console.log("Start hour: " + startHour);
                            console.log("End hour: " + endHour);
                            //add cron job if enabled
                            ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown start", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
                                console.log(data);
                                console.log(status);
                                ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "automaticshutdown stop", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                                    console.log(data);
                                    console.log(status);
                                });
                            });
                            $("#shutdownMsg").append('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');
                        }
                        else {
                            console.log("Not enabled")
                        }
                    });
                    $("#shutdownMsg").removeClass("hidden");
                });
            });
        }
        $("#saveAct").on('click', function () {
            remove()
            save()
            alert("Saved")
        });
        $("#btn_DialogAddress_save").unbind('click').click(function () {
            save()
            alert("Saved")
        })
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