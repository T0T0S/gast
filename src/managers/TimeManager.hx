package managers;
import js.Browser;
import js.html.CustomEvent;
import objects.character.Character;
import pixi.core.display.Container;
import managers.FightManager;
import utils.Misc;

	
/**
 * ...
 * @author ToTos
 */
class TimeManager {
	
	private static var instance: TimeManager;

	public static var elapsedTime:Float = 0;
	public static var deltaTime:Float = 0;
	public var frameElapsed:Int = 0;
	
	public static var FPS:Float = 0;
	
	private var tickInterval:Int = 90;
	private var numberOfTicks:Int = 0;
	
	private var timeNow:Float;
	
	private function new() {
		timeNow = Date.now().getTime();
	}
	
	public function Update():Void{
		elapsedTime += Date.now().getTime() - timeNow;
		deltaTime = (Date.now().getTime() - timeNow) / 1000;
		timeNow = Date.now().getTime();
		if(FightManager.status == StatusModes.fight)
			combatTick();
			
		FPS = 3600 * deltaTime > 60 ? 60 : Math.floor(3600 * deltaTime);
	};
	
	@:deprecated("ServSide")
	private function combatTick():Void{
		++frameElapsed;
		if (frameElapsed % tickInterval == 0){
			++numberOfTicks;
			newTick();
		}

		if (FightManager.status == StatusModes.fight) 
		{
			cast(HudManager.getInstance().APTicker, Container).rotation = (2 * Math.PI) * ((frameElapsed % tickInterval) / tickInterval);
		}
	}
	
	private function newTick():Void { 
		for (element in CharacterManager.getInstance().managedCharacters.iterator() )
		{
			element.newTick(numberOfTicks);
		}
	}
	
	public function switchState():Void {
	}
	
	
	
	public static function getInstance (): TimeManager {
		if (instance == null) instance = new TimeManager();
		return instance;
	}

}