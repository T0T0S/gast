package objects;

import haxe.Constraints.Function;
import pixi.core.display.Container;
import pixi.core.math.shapes.Rectangle;
import pixi.core.Pixi.ScaleModes;
import pixi.core.sprites.Sprite;
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
class ButtonSliced extends Sprite{

	private var arrayCallbacks:Dynamic = { };
	
	public var text:Text = new Text("", { "fill":"white", "font":"60px gastFont" } );
	private var isDown:Bool = false;
	private var isAbove:Bool = false;
	
	private var locked:Bool = false;
	
	public var specialWidth(default, set):Float = 0;
	public var specialHeight(default, set):Float = 0;
	
	public var originalWidth:Float = 0;
	public var originalHeight:Float = 0;
	
	private var arrayContainer:Array<Container> = [];
	private var minimumWidth:Float;
	private var minimumHeight:Float;
	/**
	 * basic button constructor
	 * 
	 * @param	name The name of the button (ex: 'pouet' will seek "pouet.png" for textures.)
	 * @param	customButtonTexture Are there custom "idle/hover/down" sprites made for the button (ex: "pouet_idle.png"...) (if == false, brightness is used instead)
	 */
	public function new(name:String, customButtonTexture:Bool = false) {
		super(null);

		var arrayTextures:Array<Texture>;
		if (!customButtonTexture)
		{
			arrayTextures = Misc.generateButtonTextures(Texture.fromImage(name+".png"));
		}
		else
		{
			arrayTextures = [];
			var textureW:Int = cast Texture.fromImage(name+"_idle.png").width;
			var textureH:Int = cast Texture.fromImage(name+"_idle.png").height;
			arrayTextures.push(Misc.get9slicedTexture(Texture.fromImage(name+"_idle.png"), textureW, textureH));
			arrayTextures.push(Misc.get9slicedTexture(Texture.fromImage(name+"_hover.png"), textureW, textureH));
			arrayTextures.push(Misc.get9slicedTexture(Texture.fromImage(name+"_down.png"), textureW, textureH));
		}
		
		for (texture in arrayTextures)
		{
			arrayContainer.push(sliceTexture(texture));
			arrayContainer[arrayContainer.length -1].visible = false;
			arrayContainer[arrayContainer.length -1].interactive = true;
			addChild(arrayContainer[arrayContainer.length -1]);
		}
		getChildAt(0).visible = true;
		originalWidth = arrayTextures[0].width;
		originalHeight = arrayTextures[0].height;
		
		//minimumWidth = originalWidth / 3;
		//minimumHeight = originalHeight / 3;
		
		minimumWidth = originalWidth / 3;
		minimumHeight = originalHeight / 3;
		
		hitArea = new Rectangle(0,0,untyped getChildAt(0).width, untyped getChildAt(0).height);
		interactive = true;
		buttonMode = true;
		defaultCursor = "pointer";
		
		anchor.set(0.5,0.5);
		
		arrayCallbacks.down 	= function():Void { };
		arrayCallbacks.up 		= function():Void { };
		arrayCallbacks.hover 	= function():Void { };
		arrayCallbacks.out 		= function():Void { };
		
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
		
		untyped anchor.set = customAnchorSet;
	}
	
	private function customAnchorSet(x:Float, y:Float)
	{
		for (cont in arrayContainer)
		{
			cont.x = - x * cont.width;
			cont.y = - y * cont.height;
		}
	}
	
	public function setText(newText:String):Void {
		text.text = newText;
		text.visible = true;
		if (text.parent == null && newText.length != 0) {
			text.anchor.set(0.5, 0.5);
			text.scale.set(1 / scale.x, 1 / scale.y);
			addChild(text);
		}
		else if(newText.length == 0){
			text.visible = false;
		}
	};
	
	public function set_specialWidth(value:Float){internalResize(value, null); specialWidth = value; return specialWidth;}
	public function set_specialHeight(value:Float) { internalResize(null, value); specialHeight = value; return specialHeight; }
	
	public function resize(?newWidth:Float, ?newHeight:Float)
	{
		if (newWidth != null)
			specialWidth = newWidth;
		if (newHeight != null)
			specialHeight = newHeight;
	}
	
	private function internalResize(?newWidth:Float, ?newHeight:Float):Void
	{
		if (newWidth != null)
		{
			var centerWidth:Float = newWidth - (minimumWidth * 2);
			centerWidth = centerWidth < 1 ? 1 : centerWidth;
			for (cont in arrayContainer)
			{
				untyped cont.getChildAt(1).width = centerWidth;
				untyped cont.getChildAt(4).width = centerWidth;
				untyped cont.getChildAt(7).width = centerWidth;
				//cont.getChildAt(1).visible = Math.abs(centerWidth) > 0.1;
				//cont.getChildAt(4).visible = Math.abs(centerWidth) > 0.1;
				//cont.getChildAt(7).visible = Math.abs(centerWidth) > 0.1;
				
				
				for (i in 0...cont.children.length)
				{
					if (i % 3 != 0)
						cont.getChildAt(i).x = untyped cont.getChildAt(i - 1).width + cont.getChildAt(i -1).x;
				}
			}
		}
		
		if (newHeight != null)
		{
			var centerHeight:Float = newHeight - (minimumHeight * 2);
			centerHeight = centerHeight < 1 ? 1 : centerHeight;
			for (cont in arrayContainer)
			{
				untyped cont.getChildAt(3).height = centerHeight;
				untyped cont.getChildAt(4).height = centerHeight;
				untyped cont.getChildAt(5).height = centerHeight;
				
				//cont.getChildAt(3).visible = Math.abs(centerHeight) > 0.1;
				//cont.getChildAt(4).visible = Math.abs(centerHeight) > 0.1;
				//cont.getChildAt(5).visible = Math.abs(centerHeight) > 0.1;
				
				for (i in 0...cont.children.length)
				{
					if (Math.floor(i / 3) != 0)
						cont.getChildAt(i).y = untyped cont.getChildAt(i - 3).height + cont.getChildAt(i - 3).y;
				}
			}
		}
		anchor.set(anchor.x, anchor.y);
		hitArea.x = untyped getChildAt(0).x;
		hitArea.y = untyped getChildAt(0).y;
		hitArea.width = untyped getChildAt(0).width;
		hitArea.height = untyped getChildAt(0).height;
	}
	
	public function setSpecialTexture(actionName:String){
		for (cont in arrayContainer)
		{
			cont.visible = false;
		}
		
		if (actionName == "hover")
			arrayContainer[1].visible = true;
		else if (actionName == "down")
			arrayContainer[2].visible = true;
		else 
			arrayContainer[0].visible = true;
	}
	
	private function p_onDown	(e:EventTarget):Void { if (locked) return; isDown = true; setSpecialTexture("down"); arrayCallbacks.down(e); if(e != null)e.stopPropagation(); }
	private function p_onUp		(e:EventTarget):Void { if (locked) return; if (!isDown) return; isDown = false;  setSpecialTexture("hover"); arrayCallbacks.up(e); if(e != null) e.stopPropagation(); }
	private function p_onOut	(e:EventTarget):Void { if (locked) return; isDown = false; setSpecialTexture("idle"); arrayCallbacks.out(e); if(e != null) e.stopPropagation(); }
	private function p_onHover	(e:EventTarget):Void {
		if (locked) return;
		if(isDown)
			setSpecialTexture("down"); 
		else
			setSpecialTexture("hover"); 
		arrayCallbacks.hover(e); 
	}
	
	private function mouseIsAbove(e:EventTarget):Bool {
		return Misc.colliSquarePoint(this, untyped e.data.global);
	}
	
	public function Destroy():Void{
		destroy();
	}

	public function onDown	(newFunction:Function):Void { arrayCallbacks.down 	= newFunction; }
	public function onUp	(newFunction:Function):Void { arrayCallbacks.up 	= newFunction; }
	public function onHover	(newFunction:Function):Void { arrayCallbacks.hover 	= newFunction; }
	public function onOut	(newFunction:Function):Void { arrayCallbacks.out 	= newFunction; }
	
	public function lock():Void { isDown = false ; locked = true; tint = 0x666666; buttonMode = false; }
			
	public function unlock():Void { locked = false;  tint = 0xFFFFFF;  buttonMode = true; }

	public function sliceTexture(newTexture:Texture, scaleMode:Int = 2):Container
	{
		var arraySprites:Array<Sprite> = [];
		var textureToSlice:Texture = untyped newTexture.clone();
		
		textureToSlice.baseTexture.scaleMode = scaleMode;
		
		var thirdW = Math.floor(textureToSlice.width / 3);
		var thirdH = Math.floor(textureToSlice.height / 3);
		
		var centerWidth:Float = textureToSlice.width - (thirdW * 2);
		var centerHeight:Float = textureToSlice.height - (thirdH * 2);
		for (i in 0...9)
		{
			arraySprites.push(new Sprite(new Texture(textureToSlice.baseTexture, new Rectangle(((i % 3) * thirdW) + textureToSlice.frame.x, Math.floor(i / 3) * thirdH + textureToSlice.frame.y,thirdW, thirdH))));
		}
		
		arraySprites[1].width = centerWidth;
		arraySprites[4].width = centerWidth;
		arraySprites[7].width = centerWidth;
		
		arraySprites[3].height = centerHeight;
		arraySprites[4].height = centerHeight;
		arraySprites[5].height = centerHeight;
		
		var returnContainer:Container = new Container();
		
		var j:Int = 0;
		for (sprite in arraySprites)
		{
			returnContainer.addChild(sprite);
			if (j % 3 != 0)
			{
				sprite.x = arraySprites[j -1].width + arraySprites[j -1].x;
			}
			if (Math.floor(j / 3) != 0)
			{
				sprite.y = arraySprites[j - 3].height + arraySprites[j - 3].y;
			}
				
			j++;
		}
		return returnContainer;
	}
}