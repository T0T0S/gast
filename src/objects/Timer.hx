package objects;
import haxe.Constraints.Function;
import js.Browser;
import managers.DrawManager;
import managers.UpdateManager;
import pixi.core.sprites.Sprite;
import pixi.primitives.Graphics;
import pixi.core.textures.Texture;

/**
 * ...
 * @author ToTos
 */
class Timer {

	public var progression:Float;
	public var progressionDisplay:Float;
	public var totalLength:Int;
	public var finishedCallBack:Dynamic;
	
	public var gaugeDisplayed:Bool = false;

	public var finished:Bool = false;

	public var gaugeBG:Sprite;
	private var gaugeFill:Sprite;
	private var gaugeMask:Graphics;
	private var basePos:Array<Int> = [0,0];
	
	/**
	 * @param length 	- 	La durée totale du timer (en secondes).
	 * @param timeLeft 	- 	Le temps restant dans le timer (en secondes).
	 * @param callback 	- 	Un callback a executer.
	 */
	public function new(length:Int,timeLeft:Float,?callback:Function) {
		progression = length - timeLeft;
		progressionDisplay = progression;
		totalLength = length;
		finishedCallBack = callback != null ? callback : function(){};
		UpdateManager.addToUpdate(untyped this);
	}
	
	public function update(timeSpent:Int):Void {
		progression += timeSpent;
		progressionDisplay = progression;
		if (progression >= totalLength) {
			if (finishedCallBack != null)
				finishedCallBack();
			destroy();
		}
	}
	public function frameUpdate(Dtime:Float,tickValue:Int):Void {
		if (gaugeDisplayed == false)
			return;
			
		progressionDisplay += Dtime * tickValue;
		gaugeMask.clear();
		gaugeMask.beginFill(0x8bc5ff, 0);
		gaugeMask.drawRect(0,0, gaugeFillSize(), gaugeBG.height + 10);
		gaugeMask.endFill();
	}
	
	public function showGauge(position:Array<Int>, layer:Int):Void {
		basePos = position;
		gaugeDisplayed = true;
		gaugeBG = new Sprite(Texture.fromImage("assets/interface/bandeau.png"));
		gaugeBG.width = 150;
		gaugeBG.height = 35;
		gaugeBG.x = position[0];
		gaugeBG.y = position[1];
		
		gaugeMask = new Graphics();
		gaugeMask.beginFill(0x8bc5ff,0);
		gaugeMask.drawRect(0,0, gaugeFillSize(), gaugeBG.height);
		gaugeMask.endFill();
		
		gaugeFill = new Sprite(Texture.fromImage("assets/misc/timerBar.png"));
		gaugeFill.scale.x = 1 / gaugeBG.scale.x;
		gaugeFill.scale.y = 1 / gaugeBG.scale.y;
		gaugeFill.x = 5;
		gaugeFill.y = 5;
		gaugeFill.mask = gaugeMask;
		
		gaugeBG.addChild(gaugeMask);
		gaugeBG.addChild(gaugeFill);
	}
	
	private function gaugeFillSize():Float {
		return (progressionDisplay / totalLength) * gaugeBG.width / gaugeBG.scale.x;
	}
	
	public function destroy():Void {
		UpdateManager.removeFromUpdate(untyped this);
		DrawManager.removeFromDisplay(gaugeBG);
		DrawManager.removeFromDisplay(gaugeFill);
	}
	
}