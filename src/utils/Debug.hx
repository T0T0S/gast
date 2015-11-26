package utils;
import js.Browser;
import managers.StateManager;

/**
 * ...
 * @author ToTos
 */
class Debug{
	
	public static function log(message:Dynamic, ?color:String) {
		if(color != null)
			Browser.window.console.log(message, color);
		else
			Browser.window.console.log(message);
		StateManager.debugText.text = message;
	}
	
}