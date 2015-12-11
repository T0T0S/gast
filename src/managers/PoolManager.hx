package managers;
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
	}
	
	public static function generatePool():Void{
		for(i in 0...30){
			Pools.get("tile").push(new Tile(Texture.fromImage("tile.png")));
			Pools.get("dmgText").push(new DmgText());
		}
	}
	
	public static function pullObject(poolName:String, number:Int):Array<Dynamic>{
		if(!Pools.exists(poolName))
			return [];
		
		if (number > Pools.get(poolName).length)
		{
			var iter:IntIterator = new IntIterator(0,cast Math.abs(Pools.get(poolName).length - number));
			for (i in iter) {
				Pools.get(poolName).push(findClass(poolName));
				if (Pools.get(poolName)[Pools.get(poolName).length -1] == null)
					return [];
			}
		}
		var returnArray:Array<Dynamic> = [];
		for(i in 0...number){
			returnArray.push(Pools.get(poolName).pop());
			returnArray[i].visible = true;
		}
		return returnArray;
	}
	
	public static function returnObject(poolName:String, object:Dynamic):Void{
		if(!Pools.exists(poolName))
			return;
		
		object.visible = false;
		Pools.get(poolName).push(object);
	}
	
	private static function findClass(name:String):Dynamic{
		switch name {
			case "tile": return new Tile(Texture.fromImage("tile.png"));
			case "dmgText": return new DmgText();
		}
			trace("class not found in PoolManager: " +name);

		return null;
	}
	
	public static function getInstance (): PoolManager {
		if (instance == null) instance = new PoolManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}