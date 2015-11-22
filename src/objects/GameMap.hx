package objects;
import js.Browser;
import js.Error;
import managers.DrawManager;
import managers.InitManager;
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
	
	public var mapContainer:ParticleContainer = new ParticleContainer();
	
	public var associatedTiles:Array<String>;
	
	public function new(datas:Dynamic, mapName:String) {
		name = mapName;
		json = InitManager.data[untyped name];
		OffsetY = InitManager.data.config.tileSize[1] * 0.5;
		
		mapContainer.y = OffsetY;
		mapContainer.x = OffsetX;
		
		
		associatedTiles = InitManager.data.config.mapsData[untyped name].tiles;
		if (associatedTiles == null)
			throw new Error("[ERROR] No tileData defined in config for: "+name);
		
		associatedTiles.unshift(null);

		
		if (json == null)
			Browser.window.console.warn("%c[WARNING] no data json found for map '" + mapName+"' ", "color:red;");
		setMapData(datas.graphics, datas.collisions);
	}
	
	public function setMapData(newGraphicalData:Array<Array<Int>>, newCollisionData:Array<Array<Int>>):Void{
		graphicalData = newGraphicalData;
		collisionData = newCollisionData;
	}
	
	public function addTileToMap(tile:Sprite):Void{
		DrawManager.addToDisplay(tile,mapContainer);
	}
	
	public function displayMap():Void{
		if (mapContainer.parent == null)
			DrawManager.addToDisplay(mapContainer, Main.getInstance().tileCont);
		
		mapContainer.visible = true;
	}
	
	public function getTileAt(tilePosition:Array<Int>):String{
		return associatedTiles[graphicalData[tilePosition[0]][tilePosition[1]]];
	}
	
	public function getColliAt(tilePosition:Array<Int>):Bool{
		return collisionData[tilePosition[0]][tilePosition[1]] != 0;
	}
	
	public function hideMap():Void {
		mapContainer.visible = false;
	}
	
}