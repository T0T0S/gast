package objects;
import js.Browser;
import js.Error;
import managers.DrawManager;
import managers.InitManager;
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
	
	
}