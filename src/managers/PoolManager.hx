package managers;
import js.Browser;
import objects.particle.Bullet;
import objects.particle.DmgText;
import objects.Tile;
import pixi.core.display.DisplayObject;
import pixi.core.textures.Texture;

	
/**
 * ...
 * @author ToTos
 */
class PoolManager {
	
	private static var instance: PoolManager;
	
	private static var Pools:Map<String,Array<DisplayObject>> = new Map.Map();
	
	private function new() {
		Pools.set("tile", []);
		Pools.set("dmgText", []);
		Pools.set("pointer", []);
		Pools.set("bulletNormal", []);
	}
	
	public static function generatePool():Void {
		for (pool in Pools.keys())
		{
			for (i in 0...10)
			{
				Pools.get(pool).push(findClass(pool));
			}
		}
	}
	
	public static function pullObject(poolName:String):Dynamic{
		if (!Pools.exists(poolName))
		{
			Browser.window.console.warn("Unknown pool: "+poolName);
			return [];
		}
		
		Pools.get(poolName)[getUnusedPoolIndex(poolName)].alpha = 1;
		Pools.get(poolName)[getUnusedPoolIndex(poolName)].scale.set(1,1);
		return Pools.get(poolName)[getUnusedPoolIndex(poolName)];
	}
	
	private static function getUnusedPoolIndex(poolName:String):Int{
		for (i in Pools.get(poolName).iterator() ){
			if (!i.visible && i.visible != null)
				return Pools.get(poolName).indexOf(i);
		}
		increasePoolSize(poolName, 1);
		return Pools.get(poolName).length -1;
	}
	
	private static function increasePoolSize(poolName:String, number:Int):Void {
		for (i in 0...number) {
			Pools.get(poolName).push(findClass(poolName));
			if (Pools.get(poolName)[Pools.get(poolName).length -1] == null)
				return;
		}
	}
	
	private static function findClass(name:String):Dynamic{
		switch name {
			case "tile": return new Tile(Texture.fromImage("tile.png"));
			case "dmgText": return new DmgText();
			case "pointer": return new Tile(Texture.fromImage("debugPointer.png"));
			case "bulletNormal": return new Bullet([Texture.fromImage("bullet1.png"),Texture.fromImage("bullet2.png"),Texture.fromImage("bullet3.png"),Texture.fromImage("bullet4.png"),Texture.fromImage("bullet5.png")]);
		}
		trace("class not found in PoolManager: " +name);

		return {};
	}
	
	public static function applyFunctionToPool(poolName:String, callback:Dynamic, filter:Dynamic = null ):Void {
		if (filter == null)
			for (i in Pools.get(poolName).iterator())
				callback(i);
		else
			for (i in Pools.get(poolName).iterator())
				if (filter())
					callback(i);
	}
	
	public static function applyFunctionToElement(poolName:String, callback:Dynamic, element:Dynamic ):Void{
		if(Pools.get(poolName).indexOf(element) != -1)
			callback(Pools.get(poolName)[Pools.get(poolName).indexOf(element)]);
		else 
			Browser.window.console.warn("Element not found: "+element.name);
	}
	
	public static function getInstance (): PoolManager {
		if (instance == null) instance = new PoolManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}