<script>
    var edit = false;
    //var toDelete = null;
    var copyMessage = null;
    //var elementsToDelete = null;
    var oldStartHour = null;
    var oldEndHour = null;
    var startCommand = "automaticshutdown start";
    var startCommandDescr = "Shutdown firewall";
    var startDescr = "Stop Firewall";
    var endCommand = "automaticshutdown stop";
    var endCommandDescr = "Start firewall";
    var endDescr = "Start Firewall"
        // var jobs = null;
    var selectedJobs = [];
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
            setEventHandlers();
        });

        function setEdit(id) {
            //get item since we can only retrieve row-id from click event
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    item = data['hour'];
                    //TODO delete
                    if (selectedJobs.length != 0) {
                        console.log("Setting selected jobs to null")
                        selectedJobs = [];
                    }
                    if (item != null) {
                        searchJobs(item);
                        edit = true;
                        console.log("Item to edit " + JSON.stringify(data))
                    }
                } else {
                    console.log("Error while retrieving element to edit, status: " + status);
                }
            });
        }

        function searchJobs(item) {
            enabled = item['enabled']
            startHour = item['StartHour']
            endHour = item['EndHour']
            ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var rows = data['rows'];
                    var startUUID = null;
                    var endUUID = null;
                    for (row of rows) {
                        var skip = false;
                        for (job of selectedJobs) {
                            if (job.includes(row['uuid'])) {
                                skip = true;
                            }
                        }
                        if (skip) {
                            console.log("skipping..")
                            continue;
                        }
                        //if cron job searched matches and is not in already saved jobs
                        if (enabled == row['enabled'] && startHour == row['hours'] && startDescr == row['description'] && startCommandDescr === row['command']) {
                            startUUID = row['uuid'];
                        } else if (enabled == row['enabled'] && endHour == row['hours'] && endDescr == row['description'] && endCommandDescr === row['command']) {
                            endUUID = row['uuid'];
                        }
                        if (startUUID != null && endUUID != null) {
                            selectedJobs.push([startUUID, endUUID])
                                //console.log("Found! " + JSON.stringify(selectedJobs));
                            break;
                        }
                    }

                } else {
                    alert("An unexpected error occured, couldn't find element to delete!");
                }
            });
        }
        //ok
        function setDelete(uuid) {
            //get item since we only have uuid
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        //if we found the row to delete save the related cron jobs that will be removed if the user press "Yes"
                        searchJobs(item);
                    }
                } else {
                    console.log("Error status: " + status);
                }
            });
        }
        //ok
        function setCopy(id) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        copyMessage = "Copied schedule with start hour: " + item['StartHour'] + " and end hour: " + item['EndHour'];
                    } else {
                        alert("An unexpected error occured, couldn't find element to copy!");
                    }
                } else {
                    console.log("Error while retrieving element to copy, status: " + status);
                }
            });
        }
        //TODO complete
        function setToggle(id) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                var rows = data['rows'];
                                var startUUID = null;
                                var endUUID = null;
                                for (row of rows) {
                                    var enabled = row['enabled'];
                                    if (item['StartHour'] == row['hours'] && "Stop Firewall" == row['description'] && "Shutdown Firewall" === row['command']) {
                                        startUUID = uuid;
                                    }
                                    if (item['EndHour'] == row['hours'] && "Start Firewall" == row['description'] && "Start Firewall" === row['command']) {
                                        endUUID = uuid;
                                    }
                                    if (startUUID != null && endUUID != null) {
                                        break;
                                    }
                                }
                                if (startUUID != null && endUUID != null) {
                                    ajaxCall(url = "/api/cron/settings/toggleJob/" + startUUID, sendData = {}, callback = function(data, status) {
                                        if (status === "success") {
                                            alert("Toggled " + startUUID);
                                            ajaxCall(url = "/api/cron/settings/toggleJob/" + endUUID, sendData = {}, callback = function(data, status) {
                                                if (status === "success") {
                                                    alert("Toggled " + endUUID);
                                                }
                                            });
                                        }
                                    });
                                }
                            } else {
                                console.log("Error while retrieving element to copy, status: " + status);
                            }
                        });
                    }
                }
            });
        }

        function setDeleteSelected() {
            //Tcheck if necessary
            var selectedRows = null;
            do {
                selectedRows = $("#grid-addresses").bootgrid("getSelectedRows");
            } while (selectedRows == null);
            for (uuid of selectedRows) {
                setDelete(uuid)
            }
        }

        function setEventHandlers() {
            grid.find(".command-edit").on("click", function(e) {
                    var id = $(this).data("row-id")
                    setEdit(id);
                }).end().find(".command-delete").on("click", function(e) {
                    var id = $(this).data("row-id");
                    setDelete(id);
                }).end().find(".command-copy").on("click", function(e) {
                    var id = $(this).data("row-id");
                    setCopy(id);
                }).end().find(".command-toggle").on("click", function(e) {
                    var id = $(this).data("row-id");
                    // var item = getItem(id);
                    console.log("Item " + id);
                    setToggle(id);
                })
                .end().find(".command-delete-selected").on("click", function(e) {
                    setDeleteSelected();
                });
        }
    });
    //save values before editing 
    $(document).on('focusin', "#hour\\.StartHour", function() {
        oldStartHour = $("#hour\\.StartHour").val();
    });
    $(document).on('focusin', "#hour\\.EndHour", function() {
        oldEndHour = $("#hour\\.EndHour").val();
    });

    //TODO add enabled
    //get previous settings jobs when clicking, save also the value of textfields
    //set jobs with new data on save click

    //edit an existing cron job
    function editJobs(oldStartHour, newStartHour, oldEndHour, newEndHour) {
        //this will save the job under selected jobs and should be done when clicking the pencil
        /*  if (selectedJobs != null) {
             console.log("Setting selected jobs to null")
             selectedJobs = null;
         }
         searchJobs(item); */
        /* ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
            //get all cron jobs 
            if (status === "success") {
                //loop and find the ones that match
                var rows = data['rows'];
                var startJobUUID = null;
                var endJobUUID = null;
                for (row of rows) {
                    var enabled = row['enabled'];
                    var uuid = row['uuid'];
                    if (oldStartHour == row['hours'] && startDescr == row['description'] && startCommandDescr === row['command']) {
                        startJobUUID = uuid;
                    }
                    if (oldEndHour == row['hours'] && endDescr == row['description'] && endCommandDescr === row['command']) {
                        endJobUUID = uuid;
                    }
                    //edit first occurence (it doesn't matter which job we delete since they're equals        
                    if (startJobUUID !== null && endJobUUID !== null) {
                        break;
                    }
                }
         */

        //at this point selected jobs should contain the old job to edit
        jobs = null;
        if (selectedJobs.length == 1) {
            jobs = selectedJobs[0];
        } else {
            console.log("Too many jobs selected " + JSON.stringify(selectedJobs));
        }
        if (jobs != null) {
            startUUID = jobs[0];
            endUUID = jobs[1];
            if (startUUID != null && endUUID != null) {
                //setTimeout(function() {
                ajaxCall(url = "/api/cron/settings/setJob/" + startUUID, sendData = getData(newStartHour, startCommand, startDescr), callback = function(data, status) {
                    if (status === "success") {
                        console.log("Edited " + startDescr + " oldHour " + oldStartHour + " new hour " + newStartHour + " result: " + JSON.stringify(data));
                        //           setTimeout(function() {
                        ajaxCall(url = "/api/cron/settings/setJob/" + endUUID, sendData = getData(newEndHour, endCommand, endDescr), callback = function(data, status) {
                            if (status === "success") {
                                console.log("Edited " + endDescr + " oldHour " + oldEndHour + " new hour " + newEndHour + " result: " + JSON.stringify(data));
                            }
                        });

                    }
                    //, 100);
                });
            }
            //);
            //}, 100);
        }
    }


    //on save get data from modal input fields and add jobs to schedule
    $(document).on('click', "#btn_DialogAddress_save", function() {
        var startHour = $("#hour\\.StartHour").val();
        var endHour = $("#hour\\.EndHour").val();
        if (!edit) {
            //copy or add new job
            if (copyMessage == null)
                alert("Planned shutdown between " + startHour + " and " + endHour);
            else
                alert(copyMessage);
            //TODO add cron job if enabled
            addJobs(startHour, endHour);
        } else {
            //if none was selected take val from textbox
            if (oldStartHour == null) oldStartHour = startHour;
            if (oldEndHour == null) oldEndHour = endHour;
            //setTimeout(function() {
            editJobs(oldStartHour, startHour, oldEndHour, endHour);
            //}, 100);
            edit = false;
            alert("Modified planned shutdown to run between " + startHour + " and " + endHour + " instead of " + oldStartHour + " and " + oldEndHour);
        }
    });

    //ok
    function removeJobs(startUUID, endUUID) {
        if (startUUID !== null && endUUID !== null) {
            ajaxCall(url = "/api/cron/settings/delJob/" + startUUID, sendData = {}, callback = function(data, status) {
                //check if not found 
                if (status === "success") {
                    console.log("Removed " + startDescr + " job" + JSON.stringify(data) + " uuid " + startUUID);
                    ajaxCall(url = "/api/cron/settings/delJob/" + endUUID, sendData = {}, callback = function(data, status) {
                        if (status === "success") {
                            console.log("Removed " + endDescr + " job" + JSON.stringify(data) + " uuid " + endUUID);
                            return true;
                        }
                    });
                }
            });
        }
    }
    //ok
    function removeAll() {
        if (selectedJobs != null && selectedJobs.length > 1) {
            for (jobs of selectedJobs) {
                removeJobs(jobs[0], jobs[1]);
            }
        } else {
            alert("An unexpected error occured, couldn't find element to remove!");
        }
    }
    //fix
    //event handler for remove confirmation dialog button TODO simplify
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function() {
        //TODO one delete function
        if (selectedJobs.length == 1) {
            jobs = selectedJobs[0]
                //console.log("Jobs " + jobs)
            removeJobs(jobs[0], jobs[1]);
            alert("Deleted!");
            toDelete = null;
        } else if (selectedJobs.length > 1) {
            console.log("Delete all selected")
            removeAll();
            alert("All deleted!");
            selectedJobs = [];
        } else {
            alert("Error no element set to delete")
        }
    });
    //ok
    function getData(hour, command, description) {
        return {
            "job": {
                "enabled": "1",
                "minutes": "0",
                "hours": hour,
                "days": "*",
                "months": "*",
                "weekdays": "*",
                "command": command,
                "parameters": "",
                "description": description
            }
        }
    }
    //ok
    //add cron jobs to stop and restart the firewall
    function addJobs(startHour, endHour) {
        ajaxCall(url = "/api/cron/settings/addJob", sendData = getData(startHour, startCommand, startDescr), callback = function(data, status) {
            console.log("Add start hour " + startHour);
            ajaxCall(url = "/api/cron/settings/addJob", sendData = getData(endHour, endCommand, endDescr), callback = function(data, status) {
                console.log("Add end hour " + endHour);
            });
        });
    }
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
                <button data-action="deleteSelected" type="button" class="btn btn-xs btn-default"><span class="fa fa-trash-o"></span></button>
            </td>
        </tr>
    </tfoot>
</table>
{{ partial("layout_partials/base_dialog",['fields':formDialogAddress,'id':'DialogAddress','label':lang._('Edit hour')])}}