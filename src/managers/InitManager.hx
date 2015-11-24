package managers;

import js.Browser;
import js.Error;
import js.html.Event;
import js.html.ObjectElement;
import Main;
import pixi.loaders.Loader;
import pixi.loaders.Resource;


/**
 * Classe de définition de variables relative au jeu
 * @author ToTos
 */
typedef Config = {
	var images:Array<String>;
	var tileSize:Array<Int>;
	var tileTypes:Dynamic;
	var champions:Dynamic;
	var mapSize:Array<Int>;
	var camera:Map<String,Float>;
}
 
 
class InitManager
{
	private static var instance: InitManager;
	private static inline var CONFIG_PATH:String = "assets/config/";
	private static inline var ASSETS_PATH:String = "assets/";

	public static var data:Dynamic;
	
	public function new() 
	{
		var lConfig:Loader = new Loader();
		lConfig.add("config", CONFIG_PATH + "config.json");
		lConfig.add("hero_animations", "assets/animations/" + "hero.json");
		
		
		/* maps */
		lConfig.add("testMapZig",ASSETS_PATH + "maps/testMapZig.json");
		
		
		lConfig.once("complete", untyped LoadedJson);
		lConfig.load();
	}
	
	function LoadedJson (loader:Loader, resource:Dynamic):Void {
		data = {};

		for (i in Reflect.fields(resource)) {
			if (Reflect.field(resource, i).data == null)
				throw new Error("/!\\ [ERROR] while loading json /!\\ ");
			data[untyped i] = Reflect.field(resource, i).data;
		}
			
		// SHOW DATA
		if(Main.DEBUGMODE)
			untyped Browser.window.data = data;
		Browser.window.requestAnimationFrame(cast Main.getInstance().Start);
	}
		
	public static function getInstance (): InitManager {
		if (instance == null) instance = new InitManager();
		return instance;
	}
}