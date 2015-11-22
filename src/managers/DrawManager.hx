package managers;
import js.Lib;
import objects.Tile;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import js.Browser;
import pixi.core.math.Point;

/**
 * ...
 * @author ToTos
 */
class DrawManager
{
	private static var instance: DrawManager;
	
	public function new() 
	{
	}
	
	public static function Update ():Void {
		
	}
	
	
	
	public static function addToDisplay(element:DisplayObject, newParent:Container, layer:Int = 0):Void {
		Reflect.setField(element,"Zindex",layer);
		if (element.parent == null) {
			newParent.addChild(element);
		}
	}
	
	public function isometricSort(cont:Container, ?layerIndex:Int):Void {
		var array:Array<Tile> = cast cont.children;
		array.sort(function (a:Tile,b:Tile):Int {
			if (a.y > b.y)
				return 1;
			else if (a.y < b.y)
				return -1;
			return a.Zindex - b.Zindex;
		});
		var j:Int = 0;
		var iter:IntIterator = new IntIterator(0,layerIndex);
		for (i in array.iterator()) {
			cont.setChildIndex(i, j);
			j++;
		}
	}
	
	public static function removeFromDisplay (element:Sprite):Void {
		Main.getInstance().tileCont.removeChild(element);		
		Main.getInstance().gameCont.removeChild(element);
		Main.getInstance().hudCont.removeChild(element);
		Main.getInstance().effectCont.removeChild(element);
	}
	
	public static function switchState ():Void {
	}
	
	public static function getInstance (): DrawManager {
		if (instance == null) instance = new DrawManager();
		return instance;
	}
}	