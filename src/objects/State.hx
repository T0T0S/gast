package objects;
import js.Browser;
import js.html.Event;
import managers.DrawManager;
import managers.InitManager;
import managers.StateManager;
import pixi.interaction.EventTarget;
import pixi.loaders.Loader;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.loaders.Resource;

/**
 * @author ToTos
 */

/** 
 * cette classe est la classe mere de tout les autres States qui devront l'extend. 
 * */
class State{
	public static var FTUEStateBool:Bool = false;
	private var StateLoaded:Bool = false;
	public var name:String = "default";
	public var canPlaceBuildings:Bool = false;
	public var LoadingText:Text = new Text("", { "fill":"white", "font":"30px gastFont" } );
	public var ButtonText:Text = new Text("", { "fill":"black", "font":"30px gastFont" } );
	/**
	 * le tableau de nom d'asset a loader:
	 * pusher les assets en faisant: elementsToLoad.push("assets/decor/cadre.png");
	 */
	public var loadJson:Map<String,String> = new Map.Map();
	
	public function new(newName:String) {
		name = newName;
		
		LoadingText.x = LoadingText.y = 300;
		ButtonText.x = ButtonText.y = 300;
	}
	
	public function _StartLoading():Void {
		Preload();
		
		if (Lambda.count(StateManager.jsonToPreload) != 0)
		{
			for (key in StateManager.jsonToPreload.keys())
			{
				loadJson.set(key, StateManager.jsonToPreload.get(key));
			}
		}
		
		if (Lambda.count(loadJson) == 0) {
			StateLoaded = true;
			Start();
			StateManager.loadingState = false;
			return;
		}
		
		
		var jsonLoader:Loader = new Loader();
		
		for (i in loadJson.iterator()) {
			jsonLoader.add(i,loadJson[i]); 
		}
		
		jsonLoader.once("complete", _assetLoaded);
		jsonLoader.on("progress",untyped _onAssetLoadProgress);
		jsonLoader.load();
	};
	
	private function _onAssetLoadProgress (loader:Loader, resource:Resource):Void {		
		AssetLoad(loader);
		
		if (Lambda.count(StateManager.jsonToPreload) != 0 && resource.isJson)
		{
			for (resourceName in StateManager.jsonToPreload.keys())
			{
				if (resource.url == StateManager.jsonToPreload.get(resourceName))
				{
					InitManager.data[untyped resourceName] = resource.data;
					StateManager.jsonToPreload.remove(resourceName);
					break;
				}
			}
		}
	}
	
	private function _assetLoaded (loader:Loader):Void {
		AllAssetsLoaded(loader);
		StateLoaded = true;
		Start();
		StateManager.loadingState = false;
	}
	
	public function Preload():Void { };
	
	public function AssetLoad(loader:Loader):Void { };

	public function AllAssetsLoaded(loader:Loader):Void { };
	
	public function _PrepareUpdate():Void{
		if (StateLoaded)
			Update();
	}
	
	public function Start():Void { };
	
	public function Update():Void { };
	
	public function LateUpdate():Void { };	
	
	public function switchState():Void { };
}