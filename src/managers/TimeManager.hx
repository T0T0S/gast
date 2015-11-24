package managers;

	
/**
 * ...
 * @author ToTos
 */
class TimeManager {
	
	private static var instance: TimeManager;

	public static var elapsedTime:Float = 0;
	public static var deltaTime:Float = 0;
	
	public static var FPS:Float = 0;
	
	private var timeNow:Float;
	
	private function new() {
		timeNow = Date.now().getTime();
	}
	
	var timeSinceLastFPS:Float = 0;
	public function Update():Void{
		elapsedTime += Date.now().getTime() - timeNow;
		deltaTime = (Date.now().getTime() - timeNow) / 1000;
		timeNow = Date.now().getTime();
		
		timeSinceLastFPS += deltaTime;
		
		if(timeSinceLastFPS > 0.1){
			timeSinceLastFPS = 0;
			FPS = 3600 * deltaTime > 60 ? 60 : Math.floor(3600 * deltaTime);
		}
	};
	
	public static function getInstance (): TimeManager {
		if (instance == null) instance = new TimeManager();
		return instance;
	}

}