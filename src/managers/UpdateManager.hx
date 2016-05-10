package managers;

/**
 * ...
 * @author ToTos
 */
class UpdateManager{
	private static var instance: UpdateManager;

	private var elementsToManage:Array<Dynamic> = [];
	
	private var elementsStarted:Int = 0;
	
	private function new() {
	
	}
	
	
	
	public function _update()
	{
		testStart();
		for (element in elementsToManage.iterator())
		{
			if (element == null)
			{
				return remove(element);
			}
			if (element._update != null)
			{
				if (element.isActive)
					element._update();
			}
			else
			{
				trace("element doesn't have an update method, removing");
				remove(element);
			}
		}
	}
	
	private function testStart()
	{
		if (elementsStarted != elementsToManage.length)
		{
			if (elementsToManage[elementsStarted] == null)
			{
				return remove(elementsToManage[elementsStarted]);
			}
			if (elementsToManage[elementsStarted]._start == null)
			{
				remove(elementsToManage[elementsStarted]);
				trace("element doesn't have a start method, removing");
				return;
			}
			
			elementsToManage[elementsStarted]._start();
			testStart();
		}
	}
	
	public function manage (element:Dynamic):Void 
	{
		elementsToManage.push(element);
		elementsStarted++;
	}
	
	public function remove (element:Dynamic):Void 
	{
		elementsToManage.splice(elementsToManage.indexOf(element), 1);
		elementsStarted--;
	}
	
	public static function getInstance (): UpdateManager {
		if (instance == null) instance = new UpdateManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}
	
	
}