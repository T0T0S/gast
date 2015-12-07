package managers;
import js.Browser;
import js.html.CustomEvent;
import objects.character.Character;

	
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
	private var tickInterval:Int = 60;
	private var numberOfTicks:Int = 0;
	
	private var managedElements:Array<Character> = [];
	
	private var timeNow:Float;
	
	private function new() {
		timeNow = Date.now().getTime();
	}
	
	public function Update():Void{
		elapsedTime += Date.now().getTime() - timeNow;
		deltaTime = (Date.now().getTime() - timeNow) / 1000;
		timeNow = Date.now().getTime();
		
		++frameElapsed;
		
		if (frameElapsed % tickInterval == 0){
			++numberOfTicks;
			newTick();
		}

		if (HudManager.mode == "fight") 
		{
			Main.getInstance().hudCont.getChildByName("tickTimer").rotation = (2 * Math.PI) * ((frameElapsed % tickInterval) / tickInterval);
		}
		
		FPS = 3600 * deltaTime > 60 ? 60 : Math.floor(3600 * deltaTime);
	};
	
	public function newTick():Void { 
		for (element in managedElements.iterator() )
		{
			element.newTick(numberOfTicks);
		}
	}
	
	public function switchState():Void {
		managedElements = [];
	}
	
	
	
	public static function getInstance (): TimeManager {
		if (instance == null) instance = new TimeManager();
		return instance;
	}

}