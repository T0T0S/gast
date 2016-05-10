package managers;

	
/**
 * ...
 * @author ToTos
 */
class ServerManager {
	
	private static var instance: ServerManager;

	private function new() {
	
	}
	
	//server will send new position to be converted in tilepoint
	public function onCharacterMove(characterId:String, ?nx:Int, ?ny:Int):Void{
		for (i in CharacterManager.getInstance().managedCharacters.iterator())
		{
			if(i == null)
				continue;
			i.onCharacterMove(characterId);
		}
	}
	
	
	public static function getInstance (): ServerManager {
		if (instance == null) instance = new ServerManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}
}