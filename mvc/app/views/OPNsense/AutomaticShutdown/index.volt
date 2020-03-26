<script>
    var edit = false;
    var toDelete = null;
    var copyMessage = null;
    var elementsToDelete = null;
    var oldStartHour = null;
    var oldEndHour = null;
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
                    edit = true;
                } else {
                    console.log("Error while retrieving element to edit, status: " + status);
                }
            });
        }

        function setDelete(id) {
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
            })
        }

        function setCopy(id) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var str = JSON.stringify(data);
                    var item = JSON.parse(str)["hour"];
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

        function setToggle(id) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + id, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var str = JSON.stringify(data);
                    var item = JSON.parse(str)["hour"];
                    if (item !== null) {
                        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
                            if (status === "success") {
                                var json_str = JSON.stringify(data);
                                var rows = JSON.parse(json_str)["rows"];
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
                                    if (startJobUUID != null && endJobUUID != null) {
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
        //check if necessary
        function setDeleteSelected() {
            do {
                elementsToDelete = $("#grid-addresses").bootgrid("getSelectedRows");
            } while (elementsToDelete == null);
        }
        var searchedItem;

        function getItem(id) {
            $.get("/api/automaticshutdown/settings/getItem/" + id, callback = function(data, status) {
                if (status === "success") {
                    var json_str = JSON.stringify(data);
                    var item = JSON.parse(json_str)["hour"];
                    if (item == null) {
                        alert("An unexpected error occured, couldn't find element to remove!");
                    } else {
                        //  console.log(JSON.stringify(item));
                        searchedItem = item;
                    }
                } else {
                    console.log("Error while retrieving element to remove, status: " + status);
                }
            });
        }

        function setEventHandlers() {
            grid.find(".command-edit").on("click", function(e) {
                    var id = $(this).data("row-id")
                    getItem(id);
                    if (searchedItem != null) {
                        console.log("Item " + JSON.stringify(item));
                    }
                    setEdit(id);
                }).end().find(".command-delete").on("click", function(e) {
                    var id = $(this).data("row-id");
                    getItem(id);
                    if (searchedItem != null) {
                        console.log("Item " + JSON.stringify(searchedItem));
                    }
                    setDelete(id);
                }).end().find(".command-copy").on("click", function(e) {
                    var id = $(this).data("row-id");
                    var item = getItem(id);
                    console.log("Item " + JSON.stringify(item));
                    setCopy(id);
                }).end().find(".command-toggle").on("click", function(e) {
                    var id = $(this).data("row-id");
                    var item = getItem(id);
                    console.log("Item " + JSON.stringify(item));
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
            addJobs(startHour, endHour);
        } else {
            //if none was selected take val from textbox
            if (oldStartHour == null) oldStartHour = startHour;
            if (oldEndHour == null) oldEndHour = endHour;
            setTimeout(function() {
                editJobs(oldStartHour, "Shutdown firewall", "automaticshutdown start", "Stop Firewall", startHour, oldEndHour, "Start firewall", "automaticshutdown stop", "Start Firewall", endHour);
            }, 100);
            edit = false;
            alert("Modified planned shutdown to run between " + startHour + " and " + endHour + " instead of " + oldStartHour + " and " + oldEndHour);
        }
    });
    //event handler for remove confirmation dialog button TODO simplify
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function() {
        if (toDelete !== null) {
            remove(toDelete);
            alert("Deleted!");
            toDelete = null;
        } else if (elementsToDelete != null && JSON.stringify(elementsToDelete) !== "[]") {
            removeAll();
            alert("All deleted!");
            elementsToDelete = null;
        } else {
            alert("Error no element set to delete")
        }
    });
    //add enabled
    //edit an existing cron job
    function editJobs(oldStartHour, oldStartCmd, startCmd, startDescr, startNewHour, oldEndHour, oldEndCmd, endCmd, endDescr, endNewHour) {
        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
            //get all cron jobs 
            if (status === "success") {
                //loop and find the ones that match
                var json_str = JSON.stringify(data);
                var rows = JSON.parse(json_str)["rows"];
                var startJobUUID = null;
                var endJobUUID = null;
                for (row of rows) {
                    var enabled = row['enabled'];
                    var uuid = row['uuid'];
                    if (oldStartHour == row['hours'] && startDescr == row['description'] && oldStartCmd === row['command']) {
                        startJobUUID = uuid;
                    }
                    if (oldEndHour == row['hours'] && endDescr == row['description'] && oldEndCmd === row['command']) {
                        endJobUUID = uuid;
                    }
                    //edit first occurence (it doesn't matter which job we delete since they're equals        
                    if (startJobUUID !== null && endJobUUID !== null) {
                        break;
                    }
                }
                //magari controllare non siano null e al massimo non farlo
                if (startJobUUID != null && endJobUUID != null) {
                    setTimeout(function() {
                        ajaxCall(url = "/api/cron/settings/setJob/" + startJobUUID, sendData = {
                            "job": {
                                "enabled": "1",
                                "minutes": "0",
                                "hours": startNewHour,
                                "days": "*",
                                "months": "*",
                                "weekdays": "*",
                                "command": startCmd,
                                "parameters": "",
                                "description": startDescr
                            }
                        }, callback = function(data, status) {
                            if (status === "success") {
                                console.log("Edited " + startDescr + " oldHour " + oldStartHour + " new hour " + startNewHour + " result: " + JSON.stringify(data));
                                setTimeout(function() {
                                    ajaxCall(url = "/api/cron/settings/setJob/" + endJobUUID, sendData = {
                                        "job": {
                                            "enabled": "1",
                                            "minutes": "0",
                                            "hours": endNewHour,
                                            "days": "*",
                                            "months": "*",
                                            "weekdays": "*",
                                            "command": endCmd,
                                            "parameters": "",
                                            "description": endDescr
                                        }
                                    }, callback = function(data, status) {
                                        if (status === "success") {
                                            console.log("Edited " + endDescr + " oldHour " + oldEndHour + " new hour " + endNewHour + " result: " + JSON.stringify(data));
                                        }
                                    });
                                }, 100);
                            }
                        });
                    }, 100);
                }
            }
        });
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
    // TODO split function
    //search and remove job
    function removeJobs(enabled, hour, cmd, descr, endHour, endCmd, endDescr) {
        //get all cron jobs 
        ajaxCall(url = "/api/cron/settings/searchJobs/*", sendData = {}, callback = function(data, status) {
            if (status === "success") {
                var json_str = JSON.stringify(data);
                var rows = JSON.parse(json_str)["rows"];
                var startUUID = null;
                var endUUID = null;
                for (row of rows) {
                    //if cron job searched
                    if (enabled == row['enabled'] && hour == row['hours'] && descr == row['description'] && cmd === row['command']) {
                        //delete first occurence (it doesn't matter which job we delete since they're equals)
                        startUUID = row['uuid'];
                    } else if (enabled == row['enabled'] && endHour == row['hours'] && endDescr == row['description'] && endCmd === row['command']) {
                        //delete first occurence (it doesn't matter which job we delete since they're equals)
                        endUUID = row['uuid'];
                    }
                }
                if (startUUID !== null && endUUID !== null) {
                    setTimeout(function() {
                        ajaxCall(url = "/api/cron/settings/delJob/" + startUUID, sendData = {}, callback = function(data, status) {
                            //check if not found 
                            if (status === "success") {
                                console.log("Removed " + descr + " job" + JSON.stringify(data) + " uuid " + startUUID);
                                ajaxCall(url = "/api/cron/settings/delJob/" + endUUID, sendData = {}, callback = function(data, status) {
                                    if (status === "success") {
                                        console.log("Removed " + descr + " job" + JSON.stringify(data) + " uuid " + endUUID);
                                        return true;
                                    }
                                });
                            }
                        });
                    }, 100);
                }
            } else
                console.log("Error while searching jobs");
        });
    }
    //delete start and stop cron jobs for item
    function remove(item) {
        if (item != null) {
            removeJobs(item['enabled'], item['StartHour'], "Shutdown firewall", "Stop Firewall", item['EndHour'], "Start firewall", "Start Firewall");
        } else {
            alert("No element to remove " + JSON.stringify(item))
        }
    }

    function removeAll() {
        for (element of elementsToDelete) {
            ajaxCall(url = "/api/automaticshutdown/settings/getItem/" + element, sendData = {}, callback = function(data, status) {
                if (status === "success") {
                    var json_str = JSON.stringify(data);
                    var item = JSON.parse(json_str)["hour"];
                    if (item != null) {
                        remove(item);
                    } else {
                        alert("An unexpected error occured, couldn't find element to remove!");
                    }
                } else {
                    console.log("Error while retrieving element to remove, status: " + status);
                }
            });
        }
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