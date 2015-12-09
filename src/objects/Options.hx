package objects;
import haxe.Json;
import js.Browser;

	
/**
 * ...
 * @author ToTos
 */
class Options {
	
	private static var instance: Options;
	
	public static var data:Dynamic = { };

	private function new() {
		setOption("player_showHoverMovement", true);
	}
	
	public function loadOptions():Void {
		var storageString:String = Browser.getLocalStorage().getItem("gastOptions");
		if (storageString.length == 0)
			return;
		
		data = Json.parse(storageString);
	}
	
	public static function setOption(name:String, value:Dynamic):Void{
		data[untyped name] = value;
		saveOptions();
	}
	
	private static function saveOptions():Void{
		Browser.getLocalStorage().setItem("gastOptions", Json.stringify(data));
	}
	
	public static function getInstance (): Options {
		if (instance == null) instance = new Options();
		return instance;
	}
}