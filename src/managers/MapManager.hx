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

	public function new() {
		activeMap = new GameMap();
		maps.set("testMapZig", new GameMap("testMapZig"));
		maps.set("TestingMap", new GameMap("TestingMap"));
	}
	
	
	public function generateMapDisplay(mapName:String, select:Bool = false):Void {
		var newMap = maps.get(mapName);
		
		var i:Int = 0;
		var j:Int = 0;
		for (arrayY in newMap.graphicalData.iterator()) {
			j = 0;
			for(tileIndex in arrayY.iterator()){
				if (tileIndex != 0) // ignore empty tiles
				{
					if ( untyped tileIndex.length != null) //if Is Array
					{
						var realTileIndex:Int = 0;
						while ( untyped realTileIndex < tileIndex.length)
						{
							if ( untyped tileIndex[realTileIndex] == null)
								throw new Error("[ERROR] tile index " + untyped tileIndex[realTileIndex] + " not found in " + newMap.name+" tileSet");

							untyped generateTile(j, i, newMap, tileIndex[realTileIndex], realTileIndex);
							++realTileIndex;
						}
					}
					else
					{
						if (newMap.tiles[tileIndex] == null)
							throw new Error("[ERROR] tile index " + tileIndex + " not found in " + newMap.name+" tileSet");
							
						generateTile(j, i, newMap, tileIndex, 0);
					}
				}
				++j;
			}
			++i;
		}
		newMap.displayMap();
		if (select)
			setActiveMap(newMap);
	}
	
	private function generateTile(x:Int, y:Int, newMapRef:GameMap, tileIndex:Int, ?specialHeight:Int = 0){
		var tileSprite = new Tile(Texture.fromImage(""+newMapRef.tiles[tileIndex]));
		tileSprite.setTilePosition([x, y]);
		tileSprite.x += newMapRef.OffsetX;
		tileSprite.y += newMapRef.OffsetY;
		tileSprite.setZ(newMapRef.tilesHeight[tileIndex] + specialHeight * 0.001);
		newMapRef.addTileToMap(tileSprite, newMapRef.tilesHeight[tileIndex]);
	}
	
	
	
	public static function displayDebugColliMap (nodes:Array<Array<Int>>):Void {
		for(y in Reflect.fields(nodes)){
			for(x in Reflect.fields(untyped nodes[x])){
				if (untyped nodes[y][x] < 2)
					Misc.placeTilePointer([[cast x,cast y]], 0x0000FF);
				else
					Misc.placeTilePointer([[cast x,cast y]], 0xFF0000);
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