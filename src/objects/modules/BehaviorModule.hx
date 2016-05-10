package objects.modules;
import js.Browser;
import js.Error;

/**
 * ...
 * @author ToTos
 */
class BehaviorModule{
	/*
	 * ######################
	 * WORK IN PROGRESS 
	 * NO YET USED !
	 * ######################
	 * */
	private var behaviors:Map<String, Void->Void> = new Map.Map();
	
	private var activeBehavior:String = "stop";
	
	public function new()
	{
		behaviors.set("stop", function() { } );
	}
	
	
	public function update()
	{
		behaviors.get(activeBehavior)();
	}
	
	public function switchTo(behaviorName:String)
	{
		if(behaviors.exists(behaviorName))
			activeBehavior = behaviorName;
		else
			throw new Error("behavior \""+behaviorName+"\" was not found.");
	}
	
	public function addBehavior(behaviorName:String, actionToDo:Void->Void)
	{
		if (behaviorName == "stop")
			throw new Error("can't add default behavior 'stop'");
		behaviors.set(behaviorName, actionToDo);
	}
	
	public function removeBehavior(behaviorName:String)
	{
		if (behaviorName == "stop")
			throw new Error("can't remove default behavior 'stop'");
		behaviors.remove(behaviorName);
		if (behaviorName == activeBehavior)
		{
			Browser.window.console.warn("Attention ! removing activeBehavior "+behaviorName+" auto switching to stop behavior.");
			activeBehavior = "stop";
		}
	}
	
}