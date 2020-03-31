<?php
namespace OPNsense\TrafficBlocker;
class IndexController extends \OPNsense\Base\IndexController
{
    public function indexAction()
    {
        // pick the template to serve to our users.
        $this->view->pick('OPNsense/TrafficBlocker/index');
        $this->view->generalForm = $this->getForm("general");
    }
}