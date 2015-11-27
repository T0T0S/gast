package utils;
import js.Browser;
import managers.StateManager;

/**
 * ...
 * @author ToTos
 */
class Debug{
	
	public static function log(message:Dynamic, ?color:String) {
		StateManager.debugText.text = message;
	}
	
}