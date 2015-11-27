package objects;
import js.Browser;
import js.Error;
import managers.DrawManager;
import managers.InitManager;
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
	}
	
	public function hideMap(remove:Bool = false):Void {
		mapContainer.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(mapContainer);
	}

	public function getTileAt(tilePosistion:Array<Int>):String{
		return json.tiles[graphicalData[tilePosistion[0]][tilePosistion[1]]];
	}
	
	public function getColliAt(tilePosistion:Array<Int>):Bool{
		return collisionData[tilePosistion[0]][tilePosistion[1]] != 0;
	}
	
	
	public function InitPathfinding():Void {
		trace("init path");	
		
		var pathfinding:Dynamic = {};
		var grid:Dynamic = { };
		var finder:Dynamic = { };
		var path:Dynamic = { };
		untyped grid = __new__(Browser.window.PF.Grid, collisionData.length * 2, collisionData[0].length);
		
		var x:Int = 0;
		var y:Int = 0;
		for (i in collisionData.iterator()) {
			y = 0;		
			for (j in i.iterator()) {
				grid.setWalkableAt(x*2, y, j == 1);
				grid.setWalkableAt((x*2)+1, y, j == 1);
				y ++;
			}
			x ++;
		}
		
		var source = [3, 4];
		var target = [8, 15];
		
		untyped finder = __new__(Browser.window.PF.AStarFinder, {
			allowDiagonal: true,
			dontCrossCorners: true
			//heuristic: PF.Heuristic.chebyshev
			//heuristic: PF.Heuristic.euclidean
			//heuristic: PF.Heuristic.octile
		});
		
		path = finder.findPath(source[0] * 2 + source[1]%2 ,source[1] , target[0]* 2 + target[1]%2 , target[1] , grid);
		
		
		if (path.length == 0)
		{
			trace("no path found");
		}
		for (pointName in Reflect.fields(path))
		{
			path[untyped pointName][0]  /= 2;
			path[untyped pointName][0] -= (path[untyped pointName][1] % 2) * 0.5;
			path[untyped pointName][0] = Math.floor(path[untyped pointName][0]);
			trace(path[untyped pointName]);
		}
		
		MouseManager.createLilCubes(cast path);
		
		
		//var easystar:Dynamic = {};
		//untyped easystar = __new__(Browser.window.EasyStar.js);
//
		//var grid:Array<Array<Int>> = collisionData;
		//
		//easystar.setGrid(grid);
		//easystar.setAcceptableTiles([1]);
		//
		//easystar.findPath(3, 4, 8, 8, function( path:Array<Dynamic> ) {
			//if (path == null) {
				//trace("Path was not found.");
			//} else {
				//trace(path);
				//for (i in path.iterator()) {
					//if (i.y % 2 == 1){
						//--i.x;
					//}
					//MouseManager.createLilCubes([[i.x,i.y]]);
				//}
			//}
		//});
		//easystar.setIterationsPerCalculation(1000);
		////easystar.enableDiagonals();
		//easystar.calculate();
		
		
	}
	
	
}