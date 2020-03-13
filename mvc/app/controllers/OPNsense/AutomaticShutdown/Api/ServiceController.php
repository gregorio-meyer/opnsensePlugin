<?php

namespace OPNsense\AutomaticShutdown\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;

class ServiceController extends ApiControllerBase
{
    public function reloadAction()
    {
        $status = "failed";
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = trim($backend->configdRun('template reload OPNsense/AutomaticShutdown'));
            if ($bckresult == "OK") {
                $mdl = new TrafficBlocker();
                $result['message'] = $mdl->getNodes();
                return $result;
                //$status = "ok";
            }
        }
        //    return array("status" => $status);
        return $result;
    }
}
