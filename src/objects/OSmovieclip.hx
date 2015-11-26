package objects;

import haxe.Constraints.Function;
import pixi.extras.MovieClip;
import pixi.core.textures.Texture;
/**
 * ...
 * @author ToTos
 */
class OSmovieclip extends MovieClip{
	
	private var callback;
	public function new(textures:Array<Texture>,newCallback) {
		super(textures);
		callback = newCallback;
		onComplete = complete;
	}
	
	private function complete():Void{
		callback();
		destroy();
	}
}