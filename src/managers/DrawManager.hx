package managers;
import objects.character.Character;
import objects.Options;
import pixi.core.display.Container;
import pixi.core.display.DisplayObject;

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
		if (Options.getInstance().getOption("alphaCharacter")) {
			cast(cont.children).sort(characterSortFunction);
		}	
		else{
			cast(cont.children).sort(normalSortFunction);
		}
	}
	
	private function normalSortFunction(a:DisplayObject,b:DisplayObject):Int{
		untyped if (b.z == a.z)
		untyped 	return a.depth - b.depth;
				else
		untyped 	return a.z - b.z;
	}
	
	private function characterSortFunction(a:DisplayObject, b:DisplayObject):Int {
		untyped if (a.charaName || b.charaName) {
				return !!a.charaName - !!b.charaName;
		}
		else{
			
		}
		untyped if (b.z == a.z)
		untyped 	return a.depth - b.depth;
				else
		untyped 	return a.z - b.z;
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