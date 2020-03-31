<?php
namespace OPNsense\AutomaticShutdown;
class IndexController extends \OPNsense\Base\IndexController
{
    public function indexAction()
    {
        // pick the template to serve to our users.
        $this->view->pick('OPNsense/AutomaticShutdown/index');
        $this->view->formDialogAddress = $this->getForm("dialogAddress");
        //$this->view->generalForm = $this->getForm("general");
    }
}