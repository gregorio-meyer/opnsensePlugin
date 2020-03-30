<?php

namespace OPNsense\TrafficBlocker\Api;

use OPNsense\Base\ApiControllerBase;
use OPNsense\Core\Backend;
use OPNsense\TrafficBlocker\TrafficBlocker;

/**
 * Class ServiceController
 * @package OPNsense\Cron
 */
class ServiceController extends ApiControllerBase
{
    protected static $internalServiceClass = '\OPNsense\TrafficBlocker\TrafficBlocker';
    protected static $internalServiceTemplate = 'OPNsense/TrafficBlocker';
    protected static $internalServiceEnabled = 'general.enabled';
    protected static $internalServiceName = 'trafficblocker';
    // The reconfigureForceRestart overwrite tells the controller if it should always stop the service before trying a start,
    protected function reconfigureForceRestart()
    {
        return 0;
    }
    /**
     * reconfigure TrafficBlocker
     */
    public function startAction()
    {
        if ($this->request->isPost()) {
            $backend = new Backend();
            #$mdl = new TrafficBlocker();
            #$result['message'] = $mdl->getNodes();
            #$ip = strval($result['message']['general']['Ip']);
            #$result['message']['general']['Enabled'] = True;
            $bckresult = trim($backend->configdRun('trafficblocker start'));
            if ($bckresult !== null) {
                return $bckresult;
            }
        }
    }
    public function reloadAction()
    {
        //     $status = "failed";
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = trim($backend->configdRun('template reload OPNsense/TrafficBlocker'));
            if ($bckresult == "OK") {
                $mdl = new TrafficBlocker();
                $result['message'] = $mdl->getNodes();
                $ip = strval($result['message']['general']['Ip']);
                $backend->configdRun('trafficblocker start ' . $ip);
                $status = "ok";
            }
        }
        return array("message" => $status);
        // return $result;
    }
    public function statusAction()
    {
          

        if ($this->request->isGet()) {
            $backend = new Backend();
            $mdl = new TrafficBlocker();
            $result['message'] = $mdl->getNodes();
            $enabled = strval($result['message']['general']['Enabled']);
            $bckresult = trim($backend->configdRun("trafficblocker status " . $enabled));
            if ($bckresult !== null) {
                return $bckresult;
            }
            
        }
        return array("message" => "Error while running configd action");
    }
}
