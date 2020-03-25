<script>
    var edit = false;
    var toDelete = null;
    $(document).ready(function() {
                var data_get_map = {
                    'DialogAddress': "/api/automaticshutdown/settings/get"
                };
                // load initial data
                mapDataToFormUI(data_get_map).done(function() {});
                //save grid items
                saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function() {
                    ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function(data, status) {});
                });
                //grid
                var grid = $("#grid-addresses").UIBootgrid({
                    search: '/api/automaticshutdown/settings/searchItem/',
                    get: '/api/automaticshutdown/settings/getItem/',
                    set: '/api/automaticshutdown/settings/setItem/',
                    add: '/api/automaticshutdown/settings/addItem/',
                    del: '/api/automaticshutdown/settings/delItem/',
                    toggle: '/api/automaticshutdown/settings/toggleItem/',
                }).on("loaded.rs.jquery.bootgrid", function(e) {
                    //edit event handler
                    grid.find(".command-edit").on("click", function(e) {
                        var id = $(this).data("row-id")
                        console.log("You pressed edit on row: " + id);
                        //get item since we can only retrieve row-id from click event
                        ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                console.log("Element to edit " + JSON.stringify(data));
                                edit = true;
                            } else {
                                console.log("Error while retrieving element to edit, status: " + status);
                            }
                        }); //delete event handler
                    }).end().find(".command-delete").on("click", function(e) {
                        var id = $(this).data("row-id")
                        ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                var str = JSON.stringify(data);
                                var item = JSON.parse(str)["hour"];
                                if (item !== null) {
                                    //if we found the row to delete save it and set the delete flag
                                    //the element will be removed if the user press "Yes"
                                    toDelete = item;
                                } else {
                                    alert("An unexpected error occured, couldn't find element to delete!");
                                }
                            } else {
                                console.log("Error status: " + status);
                            }
                        }).end().find(".command-copy").on("click", function(e) {
                            var id = $(this).data("row-id")
                            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                                if (status === "success") {
                                    var str = JSON.stringify(data);
                                    var item = JSON.parse(str)["hour"];
                                    if (item !== null) {
                                        var startHour = item['StartHour'];
                                        var endHour = item['EndHour'];
                                        alert("Copied schedule with start hour: " + startHour + " and end hour: " + endHour);
                                    } else {
                                        alert("An unexpected error occured, couldn't find element to copy!");
                                    }
                                } else {
                                    console.log("Error while retrieving element to copy, status: " + status);
                                }
                            });
                        });
                    });
                });

                function editJobs(startHour, endHour) {
                    alert("Editing...")
                }
                //add cron jobs to stop and restart the firewall
                function addJobs(startHour, endHour) {
                    ajaxCall(url = "/api/cron/settings/addJob", sendData = {
                        "job": {
                            "enabled": "1",
                            "minutes": "0",
                            "hours": startHour,
                            "days": "*",
                            "months": "*",
                            "weekdays": "*",
                            "command": "automaticshutdown start",
                            "parameters": "",
                            "description": "Stop Firewall"
                        }
                    }, callback = function(data, status) {
                        console.log("Add start hour " + startHour);
                        //add cron job if enabled
                        ajaxCall(url = "/api/cron/settings/addJob", sendData = {
                            "job": {
                                "enabled": "1",
                                "minutes": "0",
                                "hours": endHour,
                                "days": "*",
                                "months": "*",
                                "weekdays": "*",
                                "command": "automaticshutdown stop",
                                "parameters": "",
                                "description": "Start Firewall"
                            }
                        }, callback = function(data, status) {
                            console.log("Add end hour " + endHour);
                        });
                    });
                }
                //on save get data from modal input fields and add jobs to schedule
                $(document).on('click', "#btn_DialogAddress_save", function() {

                    var startHour = $("#hour\\.StartHour").val();
                    var endHour = $("#hour\\.EndHour").val();
                    if (!edit) {
                        alert("Planned shutdown between " + startHour + " and " + endHour);
                        addJobs(startHour, endHour);
                    } else {
                        alert("Modified planned shutdown to run between " + startHour + " and " + endHour);
                        editJobs(startHour, endHour);
                        edit = false;
                    }
                });
                /*
                        $(document).on('show.bs.modal', '#OPNsenseStdWaitDialog', function (event) {
                            var e = $(event.relatedTarget);
                            alert("Event " + e);
                            alert("Event " + event.constructor.name);
                    
                        }); */
                // TODO split function
                //search and remove job
                function search(hour, cmd, descr) {
                    //?searchPhrase= per cercare testo
                    ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
                        //get all cron jobs 
                        if (status === "success") {
                            //loop and find the ones that match
                            var json_str = JSON.stringify(data);
                            var rows = JSON.parse(json_str)["rows"];
                            for (row of rows) {
                                //id of the cron job searched
                                var enabled = row['enabled'];
                                var hours = row['hours'];
                                var description = row['description'];
                                var command = row['command'];
                                if (hour == hours && descr == description && cmd === command) {
                                    //delete first occurence (it doesn't matter which job we delete since they're equals)
                                    var uuid = row['uuid'];
                                    var deleted = false;
                                    setTimeout(function() {
                                        ajaxCall(url = "/api/cron/settings/delJob/" + uuid, sendData = {}, callback = function(data, status) {
                                            if (status === "success") {
                                                console.log("Removed " + descr + " job" + JSON.stringify(data));
                                                deleted = true;
                                            }
                                        });
                                    }, 100);
                                    if (deleted) break;
                                }
                            }
                        } else
                            console.log("Error while searching jobs");
                    });
                }
                //TODO add enabled
                //delete start and stop cron jobs for item
                function remove(item) {
                    var enabled = item['enabled'];
                    var startHour = item['StartHour'];
                    var endHour = item['EndHour'];
                    //remove cron jobs with an AJAX call
                    search(startHour, "Shutdown firewall", "Stop Firewall");
                    search(endHour, "Start firewall", "Start Firewall");;
                }
                $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function() {
                    var btnText = $(this).text();
                    if (btnText === "Yes") {
                        if (toDelete !== null) {
                            remove(toDelete);
                            alert("Deleted!");
                        } else {
                            alert("Error no element set to delete")
                        }
                    } else {
                        //the user doesn't want to delete
                        toDelete = null;
                    }
                });
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
                <button data-action="deleteSelected" id="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
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