package objects.particle;

import pixi.core.text.Text;
import pixi.core.text.Text.TextStyle;
import tweenx909.EaseX;
import tweenx909.TweenX;

/**
 * ...
 * @author ToTos
 */
class DmgText extends Text{
	private var tempCallBack:DmgText->Void;
	
	public function new() {
		super("", { "fill":"#ff6c00", "font":"30px gastFont", "stroke": "#790000", "strokeThickness":10 } );
	}
	
	/**
	 * @param	time le temps en secondes
	 */
	public function animate(newTime:Float, ?callBack:DmgText->Void):Void{
		TweenX.serial([
			TweenX.to( this, {y: y -50}).time(newTime).ease( EaseX.quadIn ).skip(),
			TweenX.to( this, { alpha: 0 } ).time(newTime).ease( EaseX.expoIn ).onFinish(function():Void { visible = false; } ),
			TweenX.func(LaunchCallBack)
		] );
		
		
	}
	
	private function LaunchCallBack()
	{
		tempCallBack(this);
	}
	
}