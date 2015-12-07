package objects;

import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */

/*
 * DEPRECIATED !!!
 * 
 * */
class HudElement extends Sprite{

	public function new(texture:Texture) {
		super(texture);
		
		on("mousedown", p_onDown);
		on("mouseup", p_onUp);
	}
	
	private function mouseIsAbove(e):Bool{
		return Misc.colliSquarePoint(this, [e.layerX, e.layerY]);
	}
	
	private function p_onDown(e:EventTarget):Void { /*e.stopPropagation();*/ }
	private function p_onUp(e:EventTarget):Void { /*e.stopPropagation();*/ }
	
}