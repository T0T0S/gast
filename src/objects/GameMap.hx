package objects;
import haxe.Json;
import js.Browser;
import js.Error;
import js.JQuery;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import pixi.core.display.Container;
import pixi.core.particles.ParticleContainer;
import pixi.core.sprites.Sprite;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class GameMap{
	
	private static var suitableLayerTypes:Array<String> = ["collisions", "graphical", "LOS"];
	
	public var graphicalData:Array<Array<Int>>;
	public var collisionData:Array<Array<Int>>;
	public var LOSData:Array<Array<Int>>;

	private var tileData:Array<Array<Tile>> = [];
	
	public var name:String = "";
	
	public var OffsetX:Float = 0;
	public var OffsetY:Float = 0;
	
	public var mapContainer:Container = new Container();
	
	public var scrollable:Bool = false;
	
	public var tiles:Array<String> = [""];
	public var tilesHeight:Array<Int> = [0];
	private var finder:Dynamic = untyped  __new__("EasyStar.js");

	
	public function new(mapName:String = null) {
		if (mapName == null)
			return;
		name = mapName;
		
		var datas = formatMap(mapName);
		var mapJson = InitManager.data[untyped name];
		
		OffsetY = Main.tileSize[1] * 0.5;
		
		/*
		 * CHANGE TO FRAMES !
		 * */
		
		
		generateTileData(mapJson);
		
		graphicalData = datas.graphical;
		collisionData = datas.collisions;
				
		LOSData = datas.LOS;

		generatePathfinding();
	}
	
	public function addTileToMap(tile:Tile, layer:Int):Void {
		if (tileData[tile.tilePos[0]] == null)
			tileData[tile.tilePos[0]] = [];
			
		tileData[tile.tilePos[0]][tile.tilePos[1]] = tile;
		DrawManager.addToDisplay(tile,mapContainer,layer);
	}
	
	public function displayMap():Void{
		if (mapContainer.parent == null)
			DrawManager.addToDisplay(mapContainer, Main.getInstance().tileCont);
		
		mapContainer.visible = true;
		MapManager.displayDebugColliMap(finder.getGrid());
		
		//var y:Int = 0;
		//var x:Int = 0;
		//while (y < LOSData.length) {
			//x = 0;
			//while (x < LOSData[y].length) {
				//if(LOSData[y][x] != 0)
					//Misc.placeTilePointer([[x,y]]);
				//++x;
			//}
			//++y;
		//}
	}
	
	public function hideMap(remove:Bool = false):Void {
		mapContainer.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(mapContainer);
	}

	public function getTileAt(tilePosition:Array<Int>):Tile {
		if (tileData[tilePosition[0]] == null)
			return null;
		return tileData[tilePosition[0]][tilePosition[1]];
	}
	
	
	
	public function generatePathfinding():Void{
		finder.setGrid(collisionData);
		finder.setAcceptableTiles([0]);
		finder.enableDiagonals();
		finder.enableSync();
	}
	
	public function setColliAt(pos:Array<Int>, collision:Bool):Void {
		if (collision)
			collisionData[pos[1]][pos[0]] = 1;
		else
			collisionData[pos[1]][pos[0]] = 0;
	}
	
	public function setLOSAt(pos:Array<Int>, blocked:Bool):Void{
		if (blocked)
			LOSData[pos[1]][pos[0]] = 1;
		else
			LOSData[pos[1]][pos[0]] = 0;
	}
	
	public function getWalkableAt(target:Array<Int>):Bool {
		if (collisionData[target[1]] == null)
			return false;
		return collisionData[target[1]][target[0]] == 0;
	}
	
	public function getLOSAt(target:Array<Int>):Bool {
		if (LOSData[target[1]] == null)
			return true;
		return LOSData[target[1]][target[0]] == 0;
	}
	
	public function getFinderGrid():Array<Array<Int>>{
		return finder.getGrid();
	}
	
	public function findPath(source:Array<Int>, target:Array<Int>, range:Array<Array<Int>>):Array<Dynamic> {
		var path:Array<Dynamic> = [];
		finder.setGrid(getNewGridPathFinding(range));
		
		if (source[0] > collisionData[0].length-1 || 
			target[0] > collisionData[0].length-1 || 
			source[1] > collisionData.length-1 || 
			target[1] > collisionData.length-1 ||
			source[0] < 0 || source[1] < 0 || target[0] < 0 || target[1] < 0)
			return [];
		
		finder.findPath(source[0], source[1], target[0], target[1], function( newpath ) {
			if (newpath != null) 
				untyped path = newpath;
		});
		finder.calculate();
		
		
		untyped return path;
	}
	
	private function getNewGridPathFinding(range:Array<Array<Int>>):Array<Array<Int>>
	{
		var returnArray:Array<Array<Int>> = [collisionData[0]];
		
		var i:Int = 0;
		while ( i < collisionData.length)
		{
			if(i != 0)
				returnArray[i] = [];
			++i;
		}
		
		for (rangePoint in range.iterator())
		{
			if(collisionData[rangePoint[1]] != null)
				returnArray[rangePoint[1]][rangePoint[0]] = collisionData[rangePoint[1]][rangePoint[0]];
		}
		return returnArray;
	}
	
	private function formatMap(mapName:String):Dynamic {
		if (InitManager.data[untyped mapName] == null) {
			Browser.window.console.warn("%c[WARNING] unknown map '" + mapName+"'", "color:red;");
			return [[]];
		}
		
		return convertMapDataToYX(InitManager.data[untyped mapName]);
	}
	
	private function convertMapDataToYX(newMap:Dynamic):Dynamic {
		var mapLayer:Array<Array<Int>>;
		var returnObject:Dynamic = { };
		var i:Int = 0;
		var j:Int = 0;	
		while(i < newMap.layers.length){
			mapLayer = [];
			j = 0;
			var layerName:Dynamic = newMap.layers[i].name;
			
			if (newMap.layers[i].properties != null){
				if (newMap.layers[i].properties.type != null) {
					if(suitableLayerTypes.indexOf(newMap.layers[i].properties.type) == -1)
						Browser.window.console.warn("Warning property 'type' for layer '"+layerName+"' of map '"+ name +"' is unknown,\nSuitable types are: "+suitableLayerTypes);
					layerName = newMap.layers[i].properties.type;
				}
				else
					Browser.window.console.warn("Warning no property 'type' found for layer '"+layerName+"' of map '"+ name +"'.\nSuitable types are: "+suitableLayerTypes);
			}
			else
				Browser.window.console.warn("Warning no property 'type' found for layer '"+layerName+"' of map '"+ name +"'.\nSuitable types are: "+suitableLayerTypes);
			
			if (newMap.layers == null)
				break;
			var map = newMap.layers[i].data;
			while (j < newMap.layers[i].data.length) {
				if (mapLayer[Math.floor(j / newMap.width)] == null)
					mapLayer[Math.floor(j / newMap.width)] = [];
				mapLayer[Math.floor(j / newMap.width)][cast j % newMap.width] = newMap.layers[i].data[j];
				j++;
			}
			
			if (returnObject[layerName] != null) // merge Layers
			{
				var x1:Int = 0;
				var y1:Int = 0;
				while (y1 < mapLayer.length) {
					x1 = 0;
					while (x1 < mapLayer[y1].length)
					{
						if (mapLayer[y1][x1] != 0) {
							if(layerName == "graphical"){
								if(returnObject[layerName][y1][x1].length == null)
									returnObject[layerName][y1][x1] = [returnObject[layerName][y1][x1], mapLayer[y1][x1]];
								else
									returnObject[layerName][y1][x1] = returnObject[layerName][y1][x1].push(mapLayer[y1][x1]);
							}
							else
								returnObject[layerName][y1][x1] = mapLayer[y1][x1];
						}
						++x1;
					}
					++y1;
				}
			}
			else
				returnObject[layerName] = mapLayer.copy();
				
			i++;
		}
		return returnObject;
	}
	
	private function generateTileData(mapData:Dynamic):Void
	{
		var tilesets:Array<Dynamic> = mapData.tilesets;
		
		for (tileSet in tilesets.iterator())
		{
			var imageName:Array<String> = cast(tileSet.image, String).split("/");
			tiles[tileSet.firstgid] = imageName[cast imageName.length - 1];
			tilesHeight[tileSet.firstgid] = cast tileSet.imageheight / 32 - 1 > 0 ? 1 : 0;
			if (tileSet.firstgid - 1 > tilesets.length)
			{
				Browser.window.console.warn("%c[WARNING] Detected multiple images in tileset of '" + name +"' map!", "color:red;");
			}
		}
		
	}
}