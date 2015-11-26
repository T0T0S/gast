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
		cast(cont.children).sort(function (a:DisplayObject,b:DisplayObject):Int {
			if (a.y > b.y)
				return 1;
			else if (a.y < b.y || untyped a.Zindex == null)
				return -1;
				
			return untyped a.Zindex - b.Zindex;
		});
	}
	
	public static function removeFromDisplay (element:DisplayObject):Void {
		if(element.parent != null)
			element.parent.removeChild(element);	
	}
	
	public static function switchState ():Void {
	}
	
	public static function getInstance (): DrawManager {
		if (instance == null) instance = new DrawManager();
		return instance;
	}
}	