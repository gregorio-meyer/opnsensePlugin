<?php

namespace OPNsense\HelloWorld\Api;

use \OPNsense\Base\ApiControllerBase;
use \OPNsense\HelloWorld\HelloWorld;
use \OPNsense\Core\Config;
use \OPNsense\Core\Backend;

class SettingsController extends ApiControllerBase
{
    /* retrieve HelloWorld general settings
 * @return array general settings
 */
    public function getAction()
    {
        // define list of configurable settings
        $result = array();
        if ($this->request->isGet()) {
            $mdlHelloWorld = new HelloWorld();
            $result['helloworld'] = $mdlHelloWorld->getNodes();
        }
        return $result;
    }
    /**
     * update HelloWorld settings
     * @return array status
     */
    public function setAction()
    {
        $result = array("result" => "failed");
        if ($this->request->isPost()) {
            // load model and update with provided data
            $mdlHelloWorld = new HelloWorld();
            $mdlHelloWorld->setNodes($this->request->getPost("helloworld"));

            // perform validation
            $valMsgs = $mdlHelloWorld->performValidation();
            foreach ($valMsgs as $field => $msg) {
                if (!array_key_exists("validations", $result)) {
                    $result["validations"] = array();
                }
                $result["validations"]["general." . $msg->getField()] = $msg->getMessage();
            }

            // serialize model to config and save
            if ($valMsgs->count() == 0) {
                $mdlHelloWorld->serializeToConfig();
                Config::getInstance()->save();
                $result["result"] = "saved";
            }
        }
        return $result;
    }

    public function reloadAction()
    {
        $status = "failed";
        if ($this->request->isPost()) {
            $backend = new Backend();
            $bckresult = trim($backend->configRun("template reload OPNSense/HelloWorld"));
            if ($bckresult == "OK") {
                $status = "ok";
            }
        }
        return array("status" => $status);
    }
}
