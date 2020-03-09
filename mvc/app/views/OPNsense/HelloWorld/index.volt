<script>
    $( document ).ready(function() {
        var data_get_map = {'frm_GeneralSettings':"/api/helloworld/settings/get"};
        mapDataToFormUI(data_get_map).done(function(data){
            // place actions to run after load, for example update form styles.
        });

        // link save button to API set action
        $("#saveAct").click(function(){
            saveFormToEndpoint(url="/api/helloworld/settings/set",formid='frm_GeneralSettings',callback_ok=function(){
                // action to run after successful save, for example reconfigure service.
                ajaxCall(url="/api/helloworld/service/reload", sendData={},callback=function(data,status) {
                    // action to run after reload
                });
            });
        });

        $("#testAct").click(function(){
            $("#responseMsg").removeClass("hidden");
            ajaxCall(url="/api/helloworld/service/test", sendData={},callback=function(data,status) {
                // action to run after reload
                $("#responseMsg").html(data['message']);
            });
        });

    });
</script>

<div class="alert alert-info hidden" role="alert" id="responseMsg">

</div>

<div  class="col-md-12">
    {{ partial("layout_partials/base_form",['fields':generalForm,'id':'frm_GeneralSettings'])}}
</div>

<div class="col-md-12">
    <button class="btn btn-primary"  id="saveAct" type="button"><b>{{ lang._('Save') }}</b></button>
    <button class="btn btn-primary"  id="testAct" type="button"><b>{{ lang._('Test') }}</b></button>
</div>
