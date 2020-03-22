<?php 
namespace OPNsense\AutomaticShutdown\Api;
use \OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'automaticshutdown';
    protected static $internalModelClass = 'OPNsense\AutomaticShutdown\AutomaticShutdown';
    public function searchItemAction()
    {
        return $this->searchBase("addresses.address", array('enabled', 'startHour'), "startHour");
    }

    public function setItemAction($uuid)
    {
        return $this->setBase("address", "addresses.address", $uuid);
    }

    public function addItemAction()
    {
        return $this->addBase("address", "addresses.address");
    }

    public function getItemAction($uuid = null)
    {
        return $this->getBase("address", "addresses.address", $uuid);
    }

    public function delItemAction($uuid)
    {
        return $this->delBase("addresses.address", $uuid);
    }

    public function toggleItemAction($uuid, $enabled = null)
    {
        return $this->toggleBase("addresses.address", $uuid, $enabled);
    }
}