<script>
    $(document).ready(function () {
        var data_get_map = { 'DialogAddress': "/api/automaticshutdown/settings/get" };
        // load initial data
        mapDataToFormUI(data_get_map).done(function () {
        });
        saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
            ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
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
        //Search job example :Stop Firewall
        function search(hour, cmd, descr) {
            //?searchPhrase= per cercare testo
            ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function (data, status) {
                //get all cron jobs 
                if (status === "success") {
                    //loop and find the ones that match
                    var json_str = JSON.stringify(data);
                    // console.log("Found: " + json_str);
                    var rows = JSON.parse(json_str)["rows"];
                    for (row of rows) {
                        var enabled = row['enabled'];
                        var hours = row['hours'];
                        var description = row['description'];
                        var command = row['command'];
                        if (hour === hours) {
                            console.log("enabled=== " + enabled);
                            console.log("hours=== " + hours);
                        }
                        if (hour == hours) {
                            console.log("enabled== " + enabled);
                            console.log("hours== " + hours);
                        }
                        if (cmd === command) {
                            console.log("command: " + command);
                        }
                        if (descr == description) {
                            console.log("description: " + description);
                            console.log("-------------------------------");
                        }
                    }
                }
                else
                    console.log("Error");
            });
        }
        function getStartUUID(startHour) {
            search(startHour, "automatic shutdown start", "Stop Firewall");
        }
        function getEndUUID(endHour) {

        }
        function remove(elements) {
            console.log("Element to delete " + elements);
            var enabled = elements['hour']['enabled'];
            var startHour = elements['hour']['StartHour'];
            var endHour = elements['hour']['EndHour'];
            console.log("Element to delete " + enabled);
            console.log("Element to delete " + startHour);
            console.log("Element to delete " + endHour);
            //   search(enabled + " " + startHour + " " + endHour + "")
            //remove cron jobs with an AJAX call
            var startUUID = getStartUUID(startHour);
            var endUUID = getEndUUID(endHour);
            // ajaxCall(url = "/api/cron/settings/delJob/" + startUUID, sendData = {}, callback = function (data, status) {
            //     if (status === "success") {
            //         console.log("Removed start hour " + JSON.stringify(data));
            //     }
            // });

            // ajaxCall(url = "/api/cron/settings/delJob/" + endUUID, sendData = {}, callback = function (data, status) {
            //     console.log(data);
            //     console.log(status);
            // });
        }
        var grid = $("#grid-addresses").UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',
            }
        ).on("loaded.rs.jquery.bootgrid", function (e) {
            console.log("Loaded")
            grid.find(".command-edit").on("click", function (e) {
                var id = $(this).data("row-id")
                console.log("You pressed edit on row: " + id);
                //get item since we can only retrieve row-id from click event
                ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function (data, status) {
                    if (status === "success") {
                        console.log("Element to edit " + JSON.stringify(data));
                    }
                    else {
                        console.log("Error status: " + status);
                    }
                });
            }).end().find(".command-delete").on("click", function (e) {
                var id = $(this).data("row-id")
                console.log("You pressed delete on row: " + id);
                ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function (data, status) {
                    if (status === "success") {
                        var item = JSON.stringify(data);
                        console.log("Element to delete " + item);
                        remove(JSON.parse(item));
                    }
                    else {
                        console.log("Error status: " + status);
                    }
                });
            });
        });

    });


    $(document).on('click', "#btn_DialogAddress_save", function () {
        var startHour = $("#hour\\.StartHour").val();
        var endHour = $("#hour\\.EndHour").val();
        alert("Planned shutdown between " + startHour + " and " + endHour);
        $("#shutdownMsg").html("")
        addJobs(startHour, endHour);

    });

    $(document).on('show.bs.modal', '#OPNsenseStdWaitDialog', function (event) {
        var e = $(event.relatedTarget);
        alert("Event " + e);
        alert("Event " + event.constructor.name);

    });
/*     $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function () {
                                                                                                                                                                                                alert("Deleted");
                                                                                                                                                                                            }); */
</script>

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
                <button data-action="deleteSelected" id="deleteSelected" type="button"
                    class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
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