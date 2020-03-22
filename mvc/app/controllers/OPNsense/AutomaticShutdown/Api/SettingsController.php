<?php 
namespace OPNsense\AutomaticShutdown\Api;
use \OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'automaticshutdown';
    protected static $internalModelClass = 'OPNsense\AutomaticShutdown\AutomaticShutdown';
    public function searchItemAction()
    {
        return $this->searchBase("hours.hour", array('enabled', 'startHour'), "startHour");
    }

    public function setItemAction($uuid)
    {
        return $this->setBase("hour", "hours.hour", $uuid);
    }

    public function addItemAction()
    {
        return $this->addBase("hour", "hours.hour");
    }

    public function getItemAction($uuid = null)
    {
        return $this->getBase("hour", "hours.hour", $uuid);
    }

    public function delItemAction($uuid)
    {
        return $this->delBase("hours.hour", $uuid);
    }

    public function toggleItemAction($uuid, $enabled = null)
    {
        return $this->toggleBase("hours.hour", $uuid, $enabled);
    }
}