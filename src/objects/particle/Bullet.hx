package objects.particle;

import pixi.core.textures.Texture;
import pixi.extras.MovieClip;

/**
 * ...
 * @author ToTos
 */
class Bullet extends MovieClip{

	public function new(textures:Array<Texture>) {
		super(textures);
		loop = false;
		anchor.set(0.5,0);
		onComplete = function() { gotoAndStop(0); visible = false; scale.set(1, 1); }
	}
	
}