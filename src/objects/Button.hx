package objects;

import haxe.Constraints.Function;
import js.Browser;
import js.html.Event;
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
	
	private var text:Text = new Text("", { "fill":"white", "font":"60px gastFont" } );
	private var isDown:Bool = false;
	private var isAbove:Bool = false;
	
	public function new(name:String) {
		var arrayTextures:Array<Texture> = [];
		arrayTextures.push(Texture.fromImage(name+"_idle.png"));
		arrayTextures.push(Texture.fromImage(name+"_hover.png"));
		arrayTextures.push(Texture.fromImage(name+"_down.png"));
		super(arrayTextures);
		
		interactive = true;
		buttonMode = true;
		defaultCursor = "pointer";
		
		anchor.set(0.5,0.5);
		
		arrayCallbacks.down 	= function():Void { };
		arrayCallbacks.up 		= function():Void { };
		arrayCallbacks.hover 	= function():Void { };
		arrayCallbacks.out 		= function():Void { };
		
		//Browser.window.addEventListener("gameMouseDown", p_onDown);
		//Browser.window.addEventListener("gameHover",p_onHover);
		//Browser.window.addEventListener("gameMouseUp", p_onUp);
		
		on("mousedown", p_onDown);
		on("mouseup", p_onUp);
		on("mouseover", p_onHover);
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
	
	private function p_onDown	(e:EventTarget):Void { isDown = true; setSpecialTexture("down"); arrayCallbacks.down(e); e.stopPropagation(); }
	private function p_onUp		(e:EventTarget):Void { if (!isDown) return; isDown = false;  setSpecialTexture("hover"); arrayCallbacks.up(e); e.stopPropagation(); }
	private function p_onOut	(e:EventTarget):Void { isDown = false; setSpecialTexture("idle"); arrayCallbacks.out(e); e.stopPropagation(); }
	private function p_onHover	(e:EventTarget):Void {
		if(isDown)
			setSpecialTexture("down"); 
		else
			setSpecialTexture("hover"); 
		arrayCallbacks.hover(e); 
	}
	
	private function mouseIsAbove(e:EventTarget):Bool {
		return Misc.colliSquarePoint(this, [e.data.global.x, e.data.global.y]);
	}
	
	public function Destroy():Void{
		destroy();
	}

	public function onDown	(newFunction:Function):Void { arrayCallbacks.down 	= newFunction; }
	public function onUp	(newFunction:Function):Void { arrayCallbacks.up 	= newFunction; }
	public function onHover	(newFunction:Function):Void { arrayCallbacks.hover 	= newFunction; }
	public function onOut	(newFunction:Function):Void { arrayCallbacks.out 	= newFunction; }
	
}