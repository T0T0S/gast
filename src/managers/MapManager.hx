package managers;
import js.Browser;
import js.Error;
import objects.GameMap;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class MapManager{
	private static var instance: MapManager;
	
	public var activeMap:GameMap;
	
	private var mapSpriteSheet:Sprite;
	
	public var maps:Map<String,GameMap> = new Map.Map();
		
	public function new() {
		activeMap = new GameMap();
		maps.set("testMapZig", new GameMap(formatMap("testMapZig"), "testMapZig"));
	}
	
	
	public function generateMapDisplay(mapName:String, select:Bool = false):Void {
		var newMap = maps.get(mapName);
		
		
		var i:Int = 0;
		var j:Int = 0;
		var tileSprite:Sprite;
		for (arrayY in newMap.graphicalData.iterator()) {
			j = 0;
			for(tileIndex in arrayY.iterator()){
				if (tileIndex != 0) // ignore empty tiles
				{
					if (newMap.json.tiles[tileIndex] == null)
						throw new Error("[ERROR] tile index "+tileIndex+" not found in "+newMap.name+".json");
					
					var pos:Array<Int> = Misc.convertToAbsolutePosition([i, j]);
					tileSprite = new Sprite(Texture.fromImage(""+newMap.json.tiles[tileIndex]));
					tileSprite.x = pos[0];
					tileSprite.y = pos[1];
					tileSprite.anchor.set(0.5, 1);
					Reflect.setField(tileSprite,"tilePositionX",pos[0]);
					Reflect.setField(tileSprite, "tilePositionY", pos[1]);
					newMap.addTileToMap(tileSprite, newMap.json.tilesPriority[tileIndex]);
				}
				++j;
			}
			++i;
		}
		newMap.displayMap();
		if (select)
			setActiveMap(newMap);
	}
	
	public function formatMap(mapName:String):Array<Array<Int>> {
		if (InitManager.data[untyped mapName] == null) {
			Browser.window.console.warn("%c[WARNING] unknown map '" + mapName+"'", "color:red;");
			return [[]];
		}
		var mapData = InitManager.data[untyped mapName];
		
		return convertMapDataToXY(mapData);
	}
	
	private function convertMapDataToXY(newMap:Dynamic):Dynamic {
		var mapLayer:Array<Array<Int>>;
		var returnObject:Dynamic = { };
		var i:Int = 0;
		var j:Int = 0;	
		while(i < newMap.layers.length){
			mapLayer = [];
			j = 0;
			
			var map = newMap.layers[i].data;
			while (j < newMap.layers[i].data.length) {
				if (mapLayer[cast j % newMap.width] == null)
					mapLayer[cast j % newMap.width] = [];
				mapLayer[cast j % newMap.width][Math.floor(j / newMap.width)] = newMap.layers[i].data[j];
				j++;
			}
			
			returnObject[newMap.layers[i].name] = mapLayer.copy();
			i++;
		}
		//trace(returnObject);
		return returnObject;
	}
	
	public function setActiveMap(newMap:GameMap):Void{
		activeMap = newMap;
		Main.camera.updateMapSize(activeMap);
	};
	
	
	public function switchState():Void {
		activeMap.hideMap(true);
	}
	
	public static function getInstance (): MapManager {
		if (instance == null) instance = new MapManager();
		return instance;
	}
	
}