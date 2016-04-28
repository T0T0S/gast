package managers;

	
/**
 * ...
 * @author ToTos
 */
class ServerManager {
	
	private static var instance: ServerManager;

	private function new() {
	
	}
	
	public function onCharacterMove(characterId:String, ?nx:Int, ?ny:Int):Void{
		for (i in CharacterManager.getInstance().managedCharacters.iterator())
		{
			i.onCharacterMove(characterId, nx, ny);
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