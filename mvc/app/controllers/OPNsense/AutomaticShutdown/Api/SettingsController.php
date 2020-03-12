<?php 
namespace OPNsense\AutomaticShutdown\Api;
use \OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'automaticshutdown';
    protected static $internalModelClass = 'OPNsense\AutomaticShutdown\AutomaticShutdown';
}