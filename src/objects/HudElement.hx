package objects;

import objects.character.Player;
import pixi.core.math.Point;
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
		
	private function mouseIsAbove(point:Point):Bool {
		return Misc.colliSquarePoint(this, point);
	}
		
	private function p_onMove(e:EventTarget):Void { 
		stopping = mouseIsAbove(e.data.global);

		if (stopping) { 
			e.stopPropagation(); 
		}
	}
	
}