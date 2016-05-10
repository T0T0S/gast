package objects;
import haxe.Json;
import js.Browser;
import js.Error;
import js.JQuery;
import managers.DrawManager;
import managers.FightManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import pixi.core.display.Container;
import pixi.core.particles.ParticleContainer;
import pixi.core.sprites.Sprite;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class GameMap{
	
	private static var suitableLayerTypes:Array<String> = ["setupAllied", "setupEnemy", "collisions", "graphical", "LOS"];
	
	public var size:TilePoint = new TilePoint();
	
	public var graphicalData:Array<Array<Int>>;
	public var collisionData:Array<Array<Int>>;
	public var LOSData:Array<Array<Int>>;
	public var alliedSetupData:Array<TilePoint>;
	public var enemySetupData:Array<TilePoint>;
	
	private var tileData:Array<Array<Tile>> = [];
	private var finder:Dynamic = untyped  __new__("EasyStar.js");

	public var name:String = "";
	
	public var OffsetX:Float = 0;
	public var OffsetY:Float = 0;
	
	public var mapContainer:Container = new Container();
	
	public var scrollable:Bool = false;
	
	public var tiles:Array<String> = [""];
	public var tilesHeight:Array<Int> = [0];
	
	
	public var charactersOnMap:Array<String> = [];
	
	/*
	 * finish this.
	 * */
	
	public var enemyGroups:Array<EnemyGroup> = [];
	
	
	public function new(mapName:String = null) {
		if (mapName == null)
			return;
		name = mapName;
		
		var datas = formatMap(mapName);
		var mapJson = InitManager.data[untyped name];
		size.x = mapJson.width;
		size.y = mapJson.height;
		//OffsetY = Main.tileSize.y;
		
		/*
		 * CHANGE TO FRAMES !
		 * */
		
		
		generateTileData(mapJson);
		
		graphicalData = datas.graphical;
		collisionData = datas.collisions;
		LOSData = datas.LOS;
		alliedSetupData = convertMapDataToPoints(datas.setupAllied);
		enemySetupData = convertMapDataToPoints(datas.setupEnemy);

		generatePathfinding();
	}
	
	public function addTileToMap(tile:Tile, layer:Int):Void {
		if (tileData[tile.tilePos.x] == null)
			tileData[tile.tilePos.x] = [];
			
		tileData[tile.tilePos.x][tile.tilePos.y] = tile;
		DrawManager.addToDisplay(tile,mapContainer,layer);
	}
	
	public function displayMap():Void{
		if (mapContainer.parent == null)
			DrawManager.addToDisplay(mapContainer, Main.getInstance().tileCont);
		
		mapContainer.visible = true;
		//MapManager.displayDebugColliMap(finder.getGrid());
		
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

	public function getTileAt(tilePosition:TilePoint):Tile {
		if (tileData[tilePosition.x] == null)
			return null;
		return tileData[tilePosition.x][tilePosition.y];
	}
	
	
	
	public function generatePathfinding():Void{
		finder.setGrid(collisionData);
		finder.setAcceptableTiles([0]);
		//finder.enableDiagonals();
		finder.enableSync();
	}
	
	public function setColliAt(pos:TilePoint, collision:Bool):Void {
		if (collision)
			collisionData[pos.y][pos.x] = 1;
		else
			collisionData[pos.y][pos.x] = 0;
	}
	
	public function setLOSAt(pos:TilePoint, blocked:Bool):Void{
		if (blocked)
			LOSData[pos.y][pos.x] = 1;
		else
			LOSData[pos.y][pos.x] = 0;
	}
	
	public function getWalkableAt(target:TilePoint):Bool {
		if (collisionData[target.y] == null)
			return false;
		return collisionData[target.y][target.x] == 0;
	}
	
	public function getLOSAt(target:TilePoint):Bool {
		if (LOSData[target.y] == null)
			return true;
		return LOSData[target.y][target.x] == 0;
	}
	
	public function getFinderGrid():Array<Array<Int>>{
		return finder.getGrid();
	}
	
	public function findPath(source:TilePoint, target:TilePoint, rangeToSearch:Array<TilePoint>):Array<TilePoint> {
		var path:Array<TilePoint> = [];
		
		
		//FOR LATER
		//if (FightManager.status == StatusModes.normal)
			//finder.enableDiagonals();
		//else
			//finder.disableDiagonals();
	
		finder.setGrid(getNewGridPathFinding(rangeToSearch));
		
		if (source.x > size.x-1 || 
			target.x > size.x-1 || 
			source.y > size.y-1 || 
			target.y > size.y-1 ||
			source.x < 0 || source.y < 0 || target.x < 0 || target.y < 0)
			return [];
		
		finder.findPath(source.x, source.y, target.x, target.y, function( newpath ) {
			if (newpath != null) 
				untyped path = newpath;
		});
		finder.calculate();
		
		untyped return path;
	}
	
	private function getNewGridPathFinding(range:Array<TilePoint>):Array<Array<Int>>
	{
		var returnArray:Array<Array<Int>> = [collisionData[0]];
		
		var i:Int = 0;
		while ( i < size.y)
		{
			if(i != 0)
				returnArray[i] = [];
			++i;
		}
		
		for (rangePoint in range.iterator())
		{
			if(collisionData[rangePoint.y] != null)
				returnArray[rangePoint.y][rangePoint.x] = collisionData[rangePoint.y][rangePoint.x];
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
	
	private function convertMapDataToPoints(mapData:Array<Array<Int>>):Array<TilePoint>
	{
		var tempArray:Array<TilePoint> = [];
		for (y in 0...mapData.length)
		{
			for (x in 0...mapData[y].length)
			{
				if (mapData[y][x] != 0)
					tempArray.push(new TilePoint(x,y));
			}
		}
		
		return tempArray;
	}
	
	public function addEnemyGroup(enemiesID:Array<String>)
	{
		if (enemyGroups.length > enemySetupData.length)
			Browser.window.console.warn("enemy group is too large for fight setup, it will not be active !");
		else
			enemyGroups.push(new EnemyGroup(enemiesID));
	}
	
	public function getEnemyGroupOf(enemyID:String):EnemyGroup
	{
		for (group in enemyGroups)
		{
			if (group.enemiesID.indexOf(enemyID) != -1)
				return group;
		}
		trace("group not found.");
		return null;
	}
	
	public function removeEnemyGroup(enemyID:String)
	{
		for (group in enemyGroups)
		{
			if (group.enemiesID.indexOf(enemyID) != -1)
			{
				enemyGroups.remove(group);
				break;
			}
		}
	}
}