package objects;
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

/**
 * ...
 * @author ToTos
 */
class GameMap{
	
	public var graphicalData:Array<Array<Int>>;
	public var collisionData:Array<Array<Int>>;
	
	public var name:String;
	public var json:Dynamic;
	
	public var OffsetX:Float = 0;
	public var OffsetY:Float = 0;
	
	public var mapContainer:Container = new Container();
	
	public var scrollable:Bool = false;
	
	public var tileMap:Array < Array<Tile> > = [];
	
	public function new(datas:Dynamic = null, mapName:String = null) {
		if (datas == null)
			return;
		name = mapName;
		json = InitManager.data.config.mapJson[untyped name];
		
		OffsetY = InitManager.data.config.tileSize[1] * 0.5;
		
		if (json == null)
			Browser.window.console.warn("%c[WARNING] no data json found for map '" + mapName+"' ", "color:red;");
		json.tiles.unshift(null);
		json.tilesHeight.unshift(null);
		
		setMapData(datas.graphics, datas.collisions);
		generatePathfinding();
	}
	
	public function setMapData(newGraphicalData:Array<Array<Int>>, newCollisionData:Array<Array<Int>>):Void{
		graphicalData = newGraphicalData;
		collisionData = newCollisionData;
	}
	
	public function addTileToMap(tile:Sprite, layer:Int):Void {
		DrawManager.addToDisplay(tile,mapContainer,layer);
	}
	
	public function displayMap():Void{
		if (mapContainer.parent == null)
			DrawManager.addToDisplay(mapContainer, Main.getInstance().tileCont);
		
		mapContainer.visible = true;
		MapManager.displayDebugColliMap(MapManager.finder.getGrid());
	}
	
	public function hideMap(remove:Bool = false):Void {
		mapContainer.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(mapContainer);
	}

	public function getTileAt(tilePosition:Array<Int>):String {
		return json.tiles[graphicalData[tilePosition[1]][tilePosition[0]]];
	}
	
	public function getColliAt(tilePosition:Array<Int>):Bool{
		trace(mapContainer.y);	
		return collisionData[tilePosition[1]][tilePosition[0]] != 0;
	}
	
	public function generatePathfinding():Void{
		var finder:Dynamic = MapManager.finder;

		finder.setGrid(collisionData);
		finder.setAcceptableTiles(InitManager.data.config.tileCollisions.walkable);
		finder.enableDiagonals();
		finder.enableSync();
		
		untyped Browser.window.finder = finder;
	}
	
	public function getWalkableAt(target:Array<Int>):Bool {
		return MapManager.finder.isTileWalkable(MapManager.finder.getGrid() , [InitManager.data.config.tileCollisions.walkable], target[0], target[1]);
	}
	
	public function findPath(source:Array<Int>, target:Array<Int>):Array<Array<Int>> {
		var finder:Dynamic = MapManager.finder;
		var path:Array<Dynamic> = [];
		/*
		 * pathfinding does weird shit
		 * */
		
		finder.findPath(source[0], source[1], target[0], target[1], function( newpath ) {
			if (newpath == null) {
				trace("XXX  NO PATH FOUND ! XXX");
			} else {
				untyped path = newpath;
				//Main.getInstance().hudCont.removeChildren();
				//for(point in path.iterator()){
					//MouseManager.createLilCubes([[point.x,point.y]]);
				//}
			}
		});
		finder.calculate();

		
		untyped return path;
	}
	
	
}