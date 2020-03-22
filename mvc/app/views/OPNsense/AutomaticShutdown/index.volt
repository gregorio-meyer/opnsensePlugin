<script>
    $(document).ready(function () {
        var data_get_map = { 'frm_GeneralSettings': "/api/automaticshutdown/settings/get" };
        mapDataToFormUI(data_get_map).done(function (data) {
            // place actions to run after load, for example update form styles.
        });
    
        // link save button to API set action
        $("#saveAct").click(function () {
            saveFormToEndpoint(url = "/api/automaticshutdown/settings/set", formid = 'frm_GeneralSettings', callback_ok = function () {
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url = "/api/automaticshutdown/service/reload", sendData = {}, callback = function (data, status) {
                    //add cron job
                    var startHour = data['message']['general']['StartHour'];
                    var endHour = data['message']['general']['EndHour'];
                    //plan firewall stop
                    ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": startHour, "days": "*", "months": "*", "weekdays": "*", "command": "Shutdown firewall", "parameters": "", "description": "Stop Firewall" } }, callback = function (data, status) {
                        console.log(data);
                        console.log(status);
                        ajaxCall(url = "/api/cron/settings/addJob", sendData = { "job": { "enabled": "1", "minutes": "0", "hours": endHour, "days": "*", "months": "*", "weekdays": "*", "command": "Reboot firewall", "parameters": "", "description": "Start Firewall" } }, callback = function (data, status) {
                        console.log(data2);
                        console.log(status2);
                         

                    });
                    });
                                       
                    //plan firewall start

                    // action to run after reload
                    $("#shutdownMsg").html('<p> Shutdown scheduled between ' + startHour + ' and ' + endHour + '</p>');
                    $("#shutdownMsg").removeClass("hidden");
                });
            });
        });

    });
</script>

<div class="alert alert-info hidden" role="alert" id="shutdownMsg">

</div>

<div class="col-md-12">
    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_GeneralSettings'])}}
</div>

<div class="col-md-12">
    <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Save') }}</b></button>
</div>