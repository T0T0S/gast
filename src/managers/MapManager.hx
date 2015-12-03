package managers;
import js.Browser;
import js.Error;
import objects.GameMap;
import objects.Tile;
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
	
	public static var finder:Dynamic = untyped  __new__("EasyStar.js");

	public function new() {
		activeMap = new GameMap();
		maps.set("testMapZig", new GameMap(formatMap("testMapZig"), "testMapZig"));
	}
	
	
	public function generateMapDisplay(mapName:String, select:Bool = false):Void {
		var newMap = maps.get(mapName);
		
		
		var i:Int = 0;
		var j:Int = 0;
		var tileSprite:Tile;
		for (arrayX in newMap.graphicalData.iterator()) {
			j = 0;
			for(tileIndex in arrayX.iterator()){
				if (tileIndex != 0) // ignore empty tiles
				{
					if (newMap.json.tiles[tileIndex] == null)
						throw new Error("[ERROR] tile index "+tileIndex+" not found in "+newMap.name+".json");
					
					tileSprite = new Tile(Texture.fromImage(""+newMap.json.tiles[tileIndex]));
					tileSprite.setTilePosition([j, i]);
					tileSprite.x += activeMap.OffsetX;
					tileSprite.y += 16;
					tileSprite.setZ(newMap.json.tilesHeight[tileIndex]);
					newMap.addTileToMap(tileSprite, newMap.json.tilesHeight[tileIndex]);
					if (newMap.tileMap[j] == null)
						newMap.tileMap[j] = [];
					newMap.tileMap[j][i] = tileSprite;
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
				if (mapLayer[Math.floor(j / newMap.width)] == null)
					mapLayer[Math.floor(j / newMap.width)] = [];
				mapLayer[Math.floor(j / newMap.width)][cast j % newMap.width] = newMap.layers[i].data[j];
				j++;
			}
			
			returnObject[newMap.layers[i].name] = mapLayer.copy();
			i++;
		}
		//trace(returnObject);
		return returnObject;
	}
	
	public static function displayDebugColliMap (nodes:Array<Array<Int>>):Void {
		for(y in Reflect.fields(nodes)){
			for(x in Reflect.fields(untyped nodes[x])){
				if (untyped nodes[y][x] < 2)
					MouseManager.createLilCubes([[cast x,cast y]], 0x0000FF);
				else
					MouseManager.createLilCubes([[cast x,cast y]], 0xFF0000);
			}
		}
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