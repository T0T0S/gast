package objects;
import js.Browser;
import js.html.Event;
import managers.DrawManager;
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
	public var loadImage:Map<String,String> = new Map.Map();
	public var loaderReady:Int = 0;
	
	public function new(newName:String) {
		name = newName;
		
		LoadingText.x = LoadingText.y = 300;
		ButtonText.x = ButtonText.y = 300;
	}
	
	public function _StartLoading():Void {
		Preload();
		loaderReady += Lambda.count(loadJson) == 0 ? 1 : 0;
		loaderReady += Lambda.count(loadImage) == 0 ? 1 : 0;
		if (loaderReady == 2) {
			StateLoaded = true;
			Start();
			StateManager.loadingState = false;
			return;
		}
		
		
		var jsonLoader:Loader = new Loader();
		var assetLoader:Loader = new Loader();
		
		for (i in loadJson.iterator()) {
			jsonLoader.add(i,loadJson[i]); 
		}
		
		for (i in loadImage.iterator()) {
			assetLoader.add(i,loadImage[i]); 
		}
		
		jsonLoader.once("complete", _assetLoaded);
		assetLoader.once("complete", _assetLoaded);
		assetLoader.load(untyped _onAssetLoadProgress);
		jsonLoader.load();
	};
	
	private function _onAssetLoadProgress (loader:Loader, resource:Resource):Void {		
		AssetLoaded(loader, resource);
	}
	
	private function _assetLoaded (loader:Loader):Void {
		++loaderReady;
		if(loaderReady == 2){
			AllAssetsLoaded(loader);
			StateLoaded = true;
			Start();
			StateManager.loadingState = false;
		}
	}
	
	public function Preload():Void { };
	
	public function AssetLoaded(loader:Loader, resource:Resource):Void { };

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