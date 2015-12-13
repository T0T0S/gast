package managers;
import js.Browser;
import js.html.CustomEvent;
import objects.character.Character;
import pixi.core.display.Container;

	
/**
 * ...
 * @author ToTos
 */
class TimeManager {
	
	private static var instance: TimeManager;

	public static var elapsedTime:Float = 0;
	public static var deltaTime:Float = 0;
	
	public static var FPS:Float = 0;
	
	private var frameElapsed:Int = 0;
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
		
		if(Main.FIGHTMODE)
			combatTick();
			
		FPS = 3600 * deltaTime > 60 ? 60 : Math.floor(3600 * deltaTime);
	};
	
	private function combatTick():Void{
		++frameElapsed;
		if (frameElapsed % tickInterval == 0){
			++numberOfTicks;
			newTick();
		}

		if (HudManager.mode == "fight") 
		{
			cast(Main.getInstance().hudCont.getChildByName("right_bottom"), Container).getChildByName("tickTimer").rotation = (2 * Math.PI) * ((frameElapsed % tickInterval) / tickInterval);
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