<script>
    var startCommand = "automaticshutdown start";
    var startCommandDescr = "Shutdown firewall";
    var startDescr = "Stop Firewall";
    var endCommand = "automaticshutdown stop";
    var endCommandDescr = "Start firewall";
    var endDescr = "Start Firewall"
    var selectedJobs = [];
    var itemToEdit = null;
    var copyMessage = null;
    //if the current row was already added to selectedJobs skip it
    function isToSkip(row) {
        for (job of selectedJobs) {
            if (job.includes(row['uuid']))
                return true;
        }
        return false;
    }
    $(function() {
        //var to get data from api and map it to the dialog
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
        //set actions event handlers
        function setEventHandlers() {
            grid.find(".command-edit").on("click", function(e) {
                    setEdit($(this).data("row-id"));
                }).end().find(".command-delete").on("click", function(e) {
                    setDelete($(this).data("row-id"));
                }).end().find(".command-copy").on("click", function(e) {
                    setCopy($(this).data("row-id"));
                }).end().find(".command-toggle").on("click", function(e) {
                    setToggle($(this).data("row-id"));
                })
                .end().find(".command-delete-selected").on("click", function(e) {
                    setDeleteSelected(getRowIds());
                });
        }
        //get the clicked element and save it for future editing
        function setEdit(uuid) {
            //get item since we can only retrieve row-id from click event
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    item = data['hour'];
                    if (item != null) {
                        searchJobs(item);
                        itemToEdit = item;
                    }
                } else {
                    console.log("Error while retrieving element to edit, status: " + status);
                }
            });
        }
        //get the clicked element and save it in selected jobs for future deletion
        function setDelete(uuid) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        searchJobs(item);
                    }
                } else {
                    console.log("Error status: " + status);
                }
            });
        }
        //If copy was clicked save a different alert
        function setCopy(uuid) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        copyMessage = "Copied schedule with start hour: " + item['startHour'] + " and end hour: " + item['endHour'];
                    } else {
                        alert("An unexpected error occured, couldn't find element to copy!");
                    }
                } else {
                    console.log("Error while retrieving element to copy, status: " + status);
                }
            });
        }

        //if toggle was pressed toggle the related cron job
        function setToggle(uuid) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + uuid, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var item = data['hour'];
                    if (item !== null) {
                        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                var rows = data['rows'];
                                var startUUID = null;
                                var endUUID = null;
                                for (row of rows) {
                                    if (isToSkip(row)) {
                                        continue;
                                    }
                                    //if related cron jobs for searched item matches 
                                    if (isEqual(item, row, "start")) {
                                        startUUID = row['uuid'];
                                    } else if (isEqual(item, row, "end")) {
                                        endUUID = row['uuid'];
                                    }
                                    if (startUUID != null && endUUID != null) {
                                        //save it
                                        selectedJobs.push([startUUID, endUUID])
                                        break;
                                    }
                                }
                                //TODO andrebbe spostato
                                if (selectedJobs.length == 1) {
                                    jobs = selectedJobs[0];
                                    startUUID = jobs[0];
                                    endUUID = jobs[1];
                                    toggleJobs(startUUID, endUUID);

                                }
                            } else {
                                console.log("Error while retrieving element to toggle, status: " + status);
                            }
                        });
                    }
                }
            });
        }

        //save selected elements for future deletion
        function setDeleteSelected(uuids) {
            for (uuid of uuids) {
                setDelete(uuid)
            }
        }
        //returns the selected rows
        function getRowIds() {
            //check if necessary
            var rowIds = null;
            do {
                rowIds = $("#grid-addresses").bootgrid("getSelectedRows");
            } while (rowIds == null);
            return rowIds;
        }
        //get json data for cron api AJAX calls
        function getData(enabled, hour, command, description) {
            return {
                "job": {
                    "enabled": enabled,
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
        //check if two cron jobs are equals
        function isEqual(item, row, part) {
            if (part == "start") {
                return item['enabled'] == row['enabled'] && item['startHour'] == row['hours'] && startDescr === row['description'] && startCommandDescr === row['command'];
            } else if (part == "end") {
                return item['enabled'] == row['enabled'] && item['endHour'] == row['hours'] && endDescr === row['description'] && endCommandDescr === row['command'];
            } else {
                console.log("Error while looking for equal jobs")
            }
        }
    });
    //search matching cron jobs and save them in selected jobs
    function searchJobs(item) {
        enabled = item['enabled']
        startHour = item['startHour']
        endHour = item['endHour']
        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
            if (status === "success") {
                var rows = data['rows'];
                var startUUID = null;
                var endUUID = null;
                for (row of rows) {
                    if (isToSkip(row)) {
                        continue;
                    }
                    //if related cron jobs for searched item matches 
                    if (isEqual(item, row, "start")) {
                        startUUID = row['uuid'];
                    } else if (isEqual(item, row, "end")) {
                        endUUID = row['uuid'];
                    }
                    if (startUUID != null && endUUID != null) {
                        //save it
                        selectedJobs.push([startUUID, endUUID])
                        break;
                    }
                }
            } else {
                alert("An unexpected error occured, couldn't find the searched element!");
            }
        });
    }
    //edit cron jobs
    function editJobs(enabled, newStartHour, newEndHour) {
        if (itemToEdit == null) {
            alert("Error no item set to edit");
        }
        jobs = null;
        if (selectedJobs.length == 1) {
            jobs = selectedJobs[0];
        } else {
            console.log("Too many jobs selected for edit: " + JSON.stringify(selectedJobs));
        }
        if (jobs != null) {
            startUUID = jobs[0];
            endUUID = jobs[1];
            if (startUUID != null && endUUID != null) {
                ajaxCall(url = "/api/cron/settings/setJob/" + startUUID, sendData = getData(enabled, newStartHour, startCommand, startDescr), callback = function(data, status) {
                    if (status === "success") {
                        console.log("Edited " + startDescr + " oldHour " + itemToEdit['startHour'] + " new hour " + newStartHour + " result: " + JSON.stringify(data));
                        ajaxCall(url = "/api/cron/settings/setJob/" + endUUID, sendData = getData(enabled, newEndHour, endCommand, endDescr), callback = function(data, status) {
                            if (status === "success") {
                                console.log("Edited " + endDescr + " oldHour " + itemToEdit['endHour'] + " new hour " + newEndHour + " result: " + JSON.stringify(data));
                            }
                        });
                    }
                });
            }
        }
        selectedJobs = []
        alert("Modified planned shutdown to run between " + startHour + " and " + endHour + " instead of " + itemToEdit['startHour'] + " and " + itemToEdit['endHour']);
    }
    //add cron jobs to stop and restart the firewall
    function addJobs(enabled, startHour, endHour) {
        ajaxCall(url = "/api/cron/settings/addJob", sendData = getData(enabled, startHour, startCommand, startDescr), callback = function(data, status) {
            console.log("Added start hour " + startHour);
            ajaxCall(url = "/api/cron/settings/addJob", sendData = getData(enabled, endHour, endCommand, endDescr), callback = function(data, status) {
                console.log("Added end hour " + endHour);
            });
        });
    }
    //remove cron jobs
    function removeJobs() {
        for (jobs of selectedJobs) {
            startUUID = jobs[0];
            endUUID = jobs[1];
            if (startUUID !== null && endUUID !== null) {
                ajaxCall(url = "/api/cron/settings/delJob/" + startUUID, sendData = {}, callback = function(data, status) {
                    if (status === "success") {
                        console.log("Removed " + startDescr + " job" + JSON.stringify(data) + " uuid " + startUUID);
                        ajaxCall(url = "/api/cron/settings/delJob/" + endUUID, sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                console.log("Removed " + endDescr + " job" + JSON.stringify(data) + " uuid " + endUUID);
                            }
                        });
                    }
                });
            }
        }
        selectedJobs = [];
        alert("Deleted!");
    }
    //toggle cron jobs
    function toggleJobs(startUUID, endUUID) {
        if (startUUID != null && endUUID != null) {
            ajaxCall(url = "/api/cron/settings/toggleJob/" + startUUID, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    ajaxCall(url = "/api/cron/settings/toggleJob/" + endUUID, sendData = {}, callback = function(data, status) {
                        if (status === "success") {
                            alert("Toggled");
                        }
                    });
                }
            });
        }
    }

    //on save get data from dialog input fields and add/edit/copy jobs 
    $(document).on('click', "#btn_DialogAddress_save", function() {
        var enabled = $('#hour\\.enabled').val()
        if (enabled === "on") {
            enabled = 1;
        } else {
            enabled = 0;
        }
        console.log("Enabled " + enabled)
        var startHour = $("#hour\\.startHour").val();
        var endHour = $("#hour\\.endHour").val();
        //edit
        if (itemToEdit != null) {
            editJobs(enabled, startHour, endHour);
        } else {
            //copy
            if (copyMessage != null)
                alert(copyMessage);
            //add
            else
                alert("Planned shutdown between " + startHour + " and " + endHour);
            addJobs(enabled, startHour, endHour);
        }
    });

    //event handler for remove confirmation dialog button 
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function() {
        if (selectedJobs.length > 0) {
            removeJobs();
        } else {
            alert("Error no element set to delete")
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
            <!-- lang._('name') is the name that will appear in the view -->
            <th data-column-id="startHour" data-type="int">{{ lang._('Start hour') }}</th>
            <th data-column-id="endHour" data-type="int">{{ lang._('End hour') }}</th>
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
<!-- TODO rename dialog -->
{{ partial("layout_partials/base_dialog",['fields':formDialogAddress,'id':'DialogAddress','label':lang._('Edit hour')])}}