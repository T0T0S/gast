package objects;

import haxe.Constraints.Function;
import pixi.extras.MovieClip;
import pixi.core.textures.Texture;
/**
 * ...
 * @author ToTos
 */
class OSmovieclip extends MovieClip{
	
	private var callback:Dynamic = function(){};
	public function new(textures:Array<Texture>,newCallback = null) {
		super(textures);
		if(newCallback != null)
			callback = newCallback;
		onComplete = complete;
		loop = false;
		gotoAndPlay(0);
	}
	
	private function complete():Void {
		callback();
		if (parent != null)
			parent.removeChild(this);
	}
}