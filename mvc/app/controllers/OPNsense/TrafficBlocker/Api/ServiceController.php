<?php

namespace OPNsense\TrafficBlocker\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;
use OPNsense\HelloWorld\HelloWorld;
use OPNsense\TrafficBlocker\TrafficBlocker;

/**
 * Class ServiceController
 * @package OPNsense\Cron
 */
class ServiceController extends ApiControllerBase
{
    /**
     * reconfigure HelloWorld
     */
    public function reloadAction()
    {
        $status = "failed";
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = trim($backend->configdRun('template reload OPNsense/TrafficBlocker'));
            if ($bckresult == "OK") {
                //    $model = new TrafficBlocker();
                $result['message'] = 'Hello';
                // $this->request->getPost("trafficblocker");
                // $status = "ok";
            }
        }
        //return array("message" => $status);
        return $result;
    }
}
