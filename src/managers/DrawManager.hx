package managers;
import js.Lib;
import objects.Tile;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import js.Browser;
import pixi.core.math.Point;
import utils.Misc;

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
	
	
	
	public static function addToDisplay(element:DisplayObject, newParent:Container, layer:Float = 0):Void {
		if (untyped element.setZ != null && layer != 0)
			untyped element.setZ(layer);
		if (element.parent == null) {
			newParent.addChild(element);
		}
	}
	
	public function isometricSort(cont:Container, ?layerIndex:Int):Void {
		cast(cont.children).sort(function (a:DisplayObject,b:DisplayObject):Int {
			untyped if (b.z == a.z)
			untyped 	return a.depth - b.depth;
					else
			untyped 	return a.z - b.z;
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