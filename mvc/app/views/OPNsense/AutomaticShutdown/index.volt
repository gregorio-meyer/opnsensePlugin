<script>
    //var edit = false;
    var copyMessage = null;

    var startCommand = "automaticshutdown start";
    var startCommandDescr = "Shutdown firewall";
    var startDescr = "Stop Firewall";
    var endCommand = "automaticshutdown stop";
    var endCommandDescr = "Start firewall";
    var endDescr = "Start Firewall"
    var selectedJobs = [];
    var itemToEdit = null;
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

        function setEdit(uuid) {
            //get item since we can only retrieve row-id from click event
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    item = data['hour'];
                    if (item != null) {
                        searchJobs(item);
                        //  edit = true;
                        console.log("Item to edit " + JSON.stringify(data))
                            //save item to edit
                        itemToEdit = item;
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
                    alert("An unexpected error occured, couldn't find the searched element!");
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
        function setCopy(uuid) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
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
        //split
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
                    setToggle(id);
                })
                .end().find(".command-delete-selected").on("click", function(e) {
                    setDeleteSelected();
                });
        }
    });

    //TODO add enabled

    //edit an existing cron job
    function editJobs(newStartHour, newEndHour) {
        if (itemToEdit == null) {
            alert("Error no item set to edit");
        }
        jobs = null;
        //TODO should probably be removed 
        if (selectedJobs.length == 1) {
            jobs = selectedJobs[0];
        } else {
            console.log("Too many jobs selected " + JSON.stringify(selectedJobs));
        }
        if (jobs != null) {
            startUUID = jobs[0];
            endUUID = jobs[1];
            if (startUUID != null && endUUID != null) {
                ajaxCall(url = "/api/cron/settings/setJob/" + startUUID, sendData = getData(newStartHour, startCommand, startDescr), callback = function(data, status) {
                    if (status === "success") {
                        console.log("Edited " + startDescr + " oldHour " + itemToEdit['StartHour'] + " new hour " + newStartHour + " result: " + JSON.stringify(data));
                        ajaxCall(url = "/api/cron/settings/setJob/" + endUUID, sendData = getData(newEndHour, endCommand, endDescr), callback = function(data, status) {
                            if (status === "success") {
                                console.log("Edited " + endDescr + " oldHour " + itemToEdit['EndHour'] + " new hour " + newEndHour + " result: " + JSON.stringify(data));
                            }
                        });
                    }
                });
            }
        }
        selectedJobs = []
    }

    //on save get data from modal input fields and add jobs to schedule
    $(document).on('click', "#btn_DialogAddress_save", function() {
        var startHour = $("#hour\\.StartHour").val();
        var endHour = $("#hour\\.EndHour").val();
        //edit
        if (itemToEdit != null) {
            editJobs(startHour, endHour);
            // edit = false;
            alert("Modified planned shutdown to run between " + startHour + " and " + endHour + " instead of " + itemToEdit['StartHour'] + " and " + itemToEdit['EndHour']);
        } else {
            //copy
            if (copyMessage != null)
                alert(copyMessage);
            //add
            else
                alert("Planned shutdown between " + startHour + " and " + endHour);
            addJobs(startHour, endHour);
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
        for (jobs of selectedJobs) {
            removeJobs(jobs[0], jobs[1]);
        }
    }
    //ok
    //event handler for remove confirmation dialog button 
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function() {
        if (selectedJobs.length > 0) {
            removeAll();
            selectedJobs = [];
            alert("Deleted!");
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