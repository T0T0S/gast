package objects;

import haxe.Constraints.Function;
import js.Browser;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import pixi.filters.dropshadow.DropShadowFilter;
import pixi.interaction.EventTarget;
import utils.Misc;
/**
 * ...
 * @author ToTos
 */
class Button extends MovieClip {

	private var arrayCallbacks:Dynamic = { };
	
	private var text:Text = new Text("",{"fill":"white", "font":"60px gastFont"});
	
	public function new(name:String) {
		var arrayTextures:Array<Texture> = [];
		arrayTextures.push(Texture.fromImage(name+"_idle.png"));
		arrayTextures.push(Texture.fromImage(name+"_hover.png"));
		arrayTextures.push(Texture.fromImage(name+"_down.png"));

		super(arrayTextures);
		
		interactive = true;
		anchor.set(0.5,0.5);
		
		arrayCallbacks.down 	= function():Void { };
		arrayCallbacks.up 		= function():Void { };
		arrayCallbacks.hover 	= function():Void { };
		arrayCallbacks.out 		= function():Void { };
		
		on("mousedown", p_onDown);
		Browser.window.addEventListener("gameHover",p_onHover);
		on("mouseup", p_onUp);
		on("mouseout", p_onOut);
		
		var shadow = new DropShadowFilter();
		shadow.color 	= 0x0000;
		shadow.distance = 5;
		shadow.alpha 	= 0.55;
		shadow.angle 	= 45;
		shadow.blur 	= 5;
	
		filters = [shadow];
	}
	
	
	public function setText(newText:String):Void {
		text.text = newText;
		text.visible = true;
		if (text.parent == null && newText != "") {
			text.anchor.set(0.5, 0.5);
			text.scale.set(1 / scale.x, 1 / scale.y);
			addChild(text);
		}
		else if(newText == ""){
			text.visible = false;
		}
	};
	
	public function setSpecialTexture(actionName:String){
		if (actionName == "hover")
			gotoAndStop(1);
		else if (actionName == "down")
			gotoAndStop(2);
		else 
			gotoAndStop(0);
			
	}
	
	private function p_onDown	(e:EventTarget):Void { setSpecialTexture("down"); arrayCallbacks.down(e); e.stopPropagation(); }
	private function p_onUp		(e:EventTarget):Void { setSpecialTexture("hover"); arrayCallbacks.up(e); e.stopPropagation(); }
	private function p_onOut	(e:EventTarget):Void { setSpecialTexture("out"); arrayCallbacks.out(e); e.stopPropagation(); }
	private function p_onHover	(e):Void { 
		if (Misc.colliSquarePoint(this, [e.layerX, e.layerY])) {
			setSpecialTexture("hover"); 
			arrayCallbacks.hover(e); 
		}
		else if(currentFrame != 0){
			gotoAndStop(0);
		}
	}

	public function onDown	(newFunction:Function):Void { arrayCallbacks.down 	= newFunction; }
	public function onUp	(newFunction:Function):Void { arrayCallbacks.up 	= newFunction; }
	public function onOut	(newFunction:Function):Void { arrayCallbacks.out 	= newFunction; }
	public function onHover	(newFunction:Function):Void { arrayCallbacks.hover 	= newFunction; }
	
}