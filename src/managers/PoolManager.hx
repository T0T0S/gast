package managers;
import js.Browser;
import objects.particle.Bullet;
import objects.particle.DmgText;
import objects.Tile;
import pixi.core.display.DisplayObject;
import pixi.core.textures.Texture;

	
enum PoolType
{
	tile;
	tileWhite;
	dmgText;
	pointer;
	bulletNormal;
}
	
/**
 * ...
 * @author ToTos
 */
class PoolManager {
	
	private static var instance: PoolManager;
	
	private static var Pools:Map<PoolType,Array<DisplayObject>> = new Map.Map();
	private static var itemUsed:Map<PoolType,Array<Bool>> = new Map.Map();
	
	private function new() {
		for (type in PoolType.createAll())
		{
			Pools.set(type, []);
			itemUsed.set(type, []);
		}
	}
	
	public static function generatePool():Void {
		for (pool in Pools.keys())
		{
			for (i in 0...100)
			{
				Pools.get(pool).push(findClass(pool));
				itemUsed.get(pool).push(false);
			}
		}
	}
	
	public static function pullObject(poolName:PoolType):Dynamic{
		if (!Pools.exists(poolName))
		{
			Browser.window.console.warn("Unknown pool: "+poolName.getName());
			return [];
		}
		var item:Int = getUnusedPoolIndex(poolName);
		Pools.get(poolName)[item].alpha = 1;
		if(Pools.get(poolName)[item].scale != null)
			Pools.get(poolName)[item].scale.set(1, 1);
		itemUsed.get(poolName)[item] = true;
		
		return Pools.get(poolName)[item];
	}
	/*
	 * FINISH RETURN BULLETS 
	 * 
	 * */
	public static function returnObject(item:Dynamic, poolType:PoolType):Void{
		if (!Pools.exists(poolName))
		{
			Browser.window.console.warn("Unknown pool: " + poolName.getName());
			return;
		}
		
		var item:Int = Pools.get(poolType).indexOf(item);
		
		if (item == -1)
		{
			Browser.window.console.warn("Item not found in pool: " + poolName.getName());
			return;
		}
		
		itemUsed.get(poolName)[item] = false;
	}
	
	private static function getUnusedPoolIndex(poolName:PoolType):Int{
		for (i in Pools.get(poolName).iterator() ){
			if (!i.visible)
				if(!itemUsed.get(poolName)[Pools.get(poolName).indexOf(i)])
					return Pools.get(poolName).indexOf(i);
		}
		increasePoolSize(poolName, 1);
		return Pools.get(poolName).length -1;
	}
	
	private static function increasePoolSize(poolName:PoolType, number:Int):Void {
		trace("Increased pool '"+poolName.getName()+"' size.");
		for (i in 0...number) {
			Pools.get(poolName).push(findClass(poolName));
			if (Pools.get(poolName)[Pools.get(poolName).length -1] == null)
				return;
		}
	}
	
	private static function findClass(name:PoolType):Dynamic{
		switch name {
			case PoolType.tile: return new Tile(Texture.fromImage("tile.png"));
			case PoolType.tileWhite: return new Tile(Texture.fromImage("tileWhite.png"));
			case PoolType.dmgText: return new DmgText();
			case PoolType.pointer: return new Tile(Texture.fromImage("debugPointer.png"));
			case PoolType.bulletNormal: return new Bullet([Texture.fromImage("bullet1.png"),Texture.fromImage("bullet2.png"),Texture.fromImage("bullet3.png"),Texture.fromImage("bullet4.png"),Texture.fromImage("bullet5.png")]);
		}
		trace("class not found in PoolManager: " +name.getName());

		return {};
	}
	
	@:deprecated("usage of applyFunctionToPool must be extremly contained.")
	public static function applyFunctionToPool(poolName:PoolType, callback:Dynamic, filter:Dynamic = null ):Void {
		if (filter == null)
			for (i in Pools.get(poolName).iterator())
				callback(i);
		else
			for (i in Pools.get(poolName).iterator())
				if (filter())
					callback(i);
	}
	
	public static function applyFunctionToElement(poolName:PoolType, callback:Dynamic, element:Dynamic ):Void{
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