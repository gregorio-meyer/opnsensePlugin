<?php 
namespace OPNsense\TrafficBlocker\Api;
use \OPNsense\Base\ApiMutableModelControllerBase;

class SettingsController extends ApiMutableModelControllerBase
{
    protected static $internalModelName = 'trafficblocker';
    protected static $internalModelClass = 'OPNsense\TrafficBlocker\TrafficBlocker';
}