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
	
	public function new(datas:Dynamic = null, mapName:String = null) {
		if (datas == null)
			return;
		name = mapName;
		json = InitManager.data.config.mapsData[untyped name];
		
		OffsetY = InitManager.data.config.tileSize[1] * 0.5;
		
		mapContainer.y = OffsetY;
		mapContainer.x = OffsetX;
		
		if (json == null)
			Browser.window.console.warn("%c[WARNING] no data json found for map '" + mapName+"' ", "color:red;");
		json.tiles.unshift(null);
		json.tilesPriority.unshift(null);
		
		setMapData(datas.graphics, datas.collisions);
		generatePathfinding();
	}
	
	public function setMapData(newGraphicalData:Array<Array<Int>>, newCollisionData:Array<Array<Int>>):Void{
		graphicalData = newGraphicalData;
		collisionData = newCollisionData;
	}
	
	public function addTileToMap(tile:Sprite,layer:Int):Void{
		DrawManager.addToDisplay(tile,mapContainer,layer);
	}
	
	public function displayMap():Void{
		if (mapContainer.parent == null)
			DrawManager.addToDisplay(mapContainer, Main.getInstance().tileCont);
		
		mapContainer.visible = true;
		MouseManager.displayMap(MapManager.finder.getGrid());
	}
	
	public function hideMap(remove:Bool = false):Void {
		mapContainer.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(mapContainer);
	}

	public function getTileAt(tilePosition:Array<Int>):String{
		return json.tiles[graphicalData[tilePosition[0]][tilePosition[1]]];
	}
	
	public function getColliAt(tilePosition:Array<Int>):Bool{
		return collisionData[tilePosition[0]][tilePosition[1]] != 0;
	}
	
	public function generatePathfinding():Void{
		var finder:Dynamic = MapManager.finder;
		//gridOriginal = untyped __new__(Browser.window.PF.Grid, collisionData.length * 2, collisionData[0].length);
		//var x:Int = 0;
		//var y:Int = 0;
		//while(y < gridOriginal.height){
			//x = 0;		
			//while (x < gridOriginal.width)
			//{
				//gridOriginal.setWalkableAt(x, y, collisionData[untyped x*0.5][y] == 1);
				//gridOriginal.setWalkableAt(x+1,y,false);
				//untyped gridOriginal.nodes[y][x].x *= 0.5;
				//untyped gridOriginal.nodes[y][x + 1].x *= 0.50;
				//
				//x+=2;
			//}
			//y++;
		//}
		finder.setGrid(collisionData);
		finder.setAcceptableTiles([1]);
		finder.enableDiagonals();
		finder.enableSync();
		
		untyped Browser.window.finder = finder;
		
		trace(finder);
	}
	
	public function findPath(source:Array<Int>, target:Array<Int>):Array<Array<Int>> {
		var finder:Dynamic = MapManager.finder;
		var path:Array<Dynamic> = [];
		trace(target);
		
		/*
		 * MAP IS NOT GOOD ! 
		 * pathfinding does weird shit
		 * 
		 * */
		
		finder.findPath(source[0], source[1], target[0], target[1], function( newpath ) {
			if (newpath == null) {
				trace("XXX  NO PATH FOUND !. XXX");
			} else {
				trace("Path found. ");
				trace(newpath);
				untyped path = newpath;
				for(point in path.iterator()){
					MouseManager.createLilCubes([[point.x,point.y]]);
				}
			}
		});
		finder.calculate();

		
		untyped return path;
	}
	
	
}