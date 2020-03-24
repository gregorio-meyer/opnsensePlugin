<script>
    $(document).ready(function () {


        var data_get_map = { 'DialogAddress': "/api/automaticshutdown/settings/get" };
        // load initial data
        mapDataToFormUI(data_get_map).done(function () {
        });
        $("#grid-addresses").UIBootgrid(
            {
                search: '/api/automaticshutdown/settings/searchItem/',
                get: '/api/automaticshutdown/settings/getItem/',
                set: '/api/automaticshutdown/settings/setItem/',
                add: '/api/automaticshutdown/settings/addItem/',
                del: '/api/automaticshutdown/settings/delItem/',
                toggle: '/api/automaticshutdown/settings/toggleItem/',
            }
        );
        //Search job example :Stop Firewall
        function search(phrase) {
            ajaxCall(url = "/api/cron/settings/searchJobs/*?searchPhrase=" + phrase, sendData = {}, callback = function (data, status) {
                console.log(JSON.stringify(data));
                console.log(status);
            });
        }
        //remove cron jobs with an AJAX call
        function remove(uuid) {
            ajaxCall(url = "/api/cron/settings/delJob/" + uuid, sendData = {}, callback = function (data, status) {
                console.log(data);
                console.log(status);
            });
            ajaxCall(url = "/api/cron/settings/delJob/" + d['uuid'], sendData = {}, callback = function (data, status) {
                console.log(data);
                console.log(status);
            });
        }
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

    $(document).on('click', "#btn_DialogAddress_save", function () {
        var startHour = $("#hour\\.StartHour").val();
        var endHour = $("#hour\\.EndHour").val();
        alert("Planned shutdown between " + startHour + " and " + endHour);
        $("#shutdownMsg").html("")
        saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'formDialogAddress', callback_ok = function () {
            addJobs(startHour, endHour);
            ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                $("#shutdownMsg").removeClass("hidden");
            });
        });
    });
    $(document).on('show.bs.modal', '#DialogAddress', function (event) {
        /* alert(event);
        var trigger = $(event.target)
        alert("Triggered " + trigger.nodeName); */
    });
    $(document).on('click', ".command-delete", function () {
        console.log("Delete clicked");
        alert("Delete clicked");
    });
    $(document).on('click', ".bootstrap-dialog-footer .bootstrap-dialog-footer-buttons .btn.btn-warning", function () {
        alert("Deleted");
    });
    $(document).on('click', ":button", function (event) {
        console.log("Edit " + event.srcElement);
        alert("Edit " + event.srcElement);
        target = event.target
        alert("Edit " + target.tagName.constructor.name);
    });
    $(document).on('click', ".command-copy", function () {
        console.log("Copy");
        alert("Copy");
    });
    $(document).on('click', ".command-delete-selected", function () {
        console.log("Delete selected");
        alert("Delete selected");
    });
    $(document).on('hidden.bs.modal', '#DialogAddress', function () {
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