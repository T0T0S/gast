package objects;

import objects.character.Player;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */

class HudElement extends Sprite{
	
	private var stopping:Bool = false;
	
	public function new(texture:Texture) {
		super(texture);
		interactive = true;
		on("mousemove", p_onMove);
	}
		
	private function mouseIsAbove(point:Array<Int>):Bool{
		return Misc.colliSquarePoint(this, cast point);
	}
		
	private function p_onMove(e:EventTarget):Void { 
		stopping = mouseIsAbove(cast [e.data.global.x, e.data.global.y]);
		if (stopping) { 
			e.stopPropagation(); 
		}
	}
	
}