package objects.attacks;
import managers.PoolManager;
import objects.character.Character;
import pixi.core.text.Text;
import objects.particle.DmgText;

/**
 * ...
 * @author ToTos
 */
class Attack{

	public var waitForFinish:Bool = true;
	public var animationName:String = "no animation defined";
	
	public var framesData:Array<Array<Int>> = [];
	public var activeFrameData:Int = 0;
	public var frameElaped:Int = 0;
	
	public var targetPosition:Array<Int> = [];
	public var finished:Bool = false;
	
	public var minRange:Int = 0;
	public var maxRange:Int = 0;
	
	public var damage:Int = 0;
	public var apCost:Int = 0;
	
	public function new(jsonData:Dynamic) {
		framesData = jsonData.framesData;
		animationName = jsonData.animationName;
		waitForFinish = jsonData.waitForFinish;
		minRange = jsonData.minRange;
		maxRange = jsonData.maxRange;
		damage = jsonData.damage;
		apCost = jsonData.apCost;
		
	}
	
	public function updateAttack(launcher:Character):Void {
		if(frameElaped == framesData[activeFrameData][0])
			attackEffect(launcher.stats);
		
		if (frameElaped == framesData[activeFrameData][0] + framesData[activeFrameData][1]){
			if (activeFrameData == framesData.length -1)
				endAction(launcher);
			else {
				frameElaped = 0;
				++activeFrameData;
			}
		}
		
		++frameElaped;
	}
	
	public function activateAttack(position:Array<Int>):Void{
		targetPosition = position;
		activeFrameData = 0;
		frameElaped = 0;
		finished = false;
	}
	
	public function attackEffect(stats:Stats):Void {
	}
	
	
	
	public function endAction(launcher:Character):Void{
		launcher.waitForNextTick = waitForFinish;
		finished = true;
	}
	
}