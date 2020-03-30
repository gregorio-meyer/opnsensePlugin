<script>
    $(document).ready(function() {
        var data_get_map = {
            'frm_GeneralSettings': "/api/trafficblocker/settings/get"
        };
        mapDataToFormUI(data_get_map).done(function(data) {
            // place actions to run after load, for example update form styles.
        });

        // link save button to API set action
        $("#saveAct").click(function() {
            saveFormToEndpoint(url = "/api/trafficblocker/settings/set", formid = 'frm_GeneralSettings', callback_ok = function() {
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url = "/api/trafficblocker/service/start", sendData = {}, callback = function(data, status) {
                    console.log(data['status'])
                    if (data['status'] == 200) {
                        $("#responseMsg").append("<h3>" + data['responseText'] + "</h3>");
                        //$("#responseMsg").append("<h3> Status: " + status + "</h3>");
                        $("#responseMsg").removeClass("hidden");
                    }
                });
                ajaxCall(url = "/api/trafficblocker/service/reload", sendData = {}, callback = function(data, status) {

                });
            });
        });

    });
</script>
<div class="alert alert-info hidden" role="alert" id="responseMsg">

</div>
<div class="col-md-12">
    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_GeneralSettings'])}}
</div>

<div class="col-md-12">
    <button class="btn btn-primary" id="saveAct" type="button"><b>{{ lang._('Save') }}</b></button>
</div>