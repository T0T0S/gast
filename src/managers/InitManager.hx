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
 * 
 * 
@:deprecated("Needs to be a preloadManager")

 */
class InitManager
{
	private static var instance: InitManager;
	private static inline var CONFIG_PATH:String = "assets/config/";
	private static inline var ASSETS_PATH:String = "assets/";

	public static var data:Dynamic;
	
	@:deprecated("ServSide")
	public function new() 
	{
		var lConfig:Loader = new Loader();
		lConfig.add("config", CONFIG_PATH + "config.json");
		lConfig.add("hero", CONFIG_PATH +"/" + "hero.json");
		lConfig.add("victim", CONFIG_PATH +"/" + "victim.json");
		
		
		/* maps */
		loadMap("map_diamondIso");
		
		lConfig.once("complete", untyped LoadedJson);
		lConfig.load();
	}
	
	private function loadMap(mapName:String)
	{
		StateManager.jsonToPreload.set(mapName, ASSETS_PATH + "maps/"+mapName +".json" );
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
			
		Main.tileSize = data.config.tileSize;
		Browser.window.requestAnimationFrame(cast Main.getInstance().Start);
	}
		
	public static function getInstance (): InitManager {
		if (instance == null) instance = new InitManager();
		return instance;
	}
}