<?php

namespace OPNsense\AutomaticShutdown\Api;

use OPNsense\AutomaticShutdown\AutomaticShutdown;
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
                $mdl = new AutomaticShutdown();
                $result['message'] = $mdl->getNodes();
                return $result;
            }
        }
        return $result;
    }
    public function statusAction()
    {
        if ($this->request->isGet()) {
            $backend = new Backend();
            //add current parameters
            $mdl = new AutomaticShutdown();
            $result['message'] = $mdl->getNodes();
            $address = $result['message']['addresses']['address'];
            if (count($address) > 0) {
                $startHour = strval($address['StartHour']);
                $endHour = strval($address['EndHour']);
            }
            $bckresult = trim($backend->configdRun("automaticshutdown status " . $startHour . " " . $endHour));
            if ($bckresult !== null) {
                return $bckresult;
            }
        }
        return array("message" => "unable to run config action");
    }
}
