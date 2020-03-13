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
                    // action to run after reload
                    $("#shutdownMsg").html('<h1> Shutdown scheduled at </h1>');
                    $("#responseMsg").html("<h1>Message: </h1>" + JSON.stringify(data));;
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