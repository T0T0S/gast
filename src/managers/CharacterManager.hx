package managers;
import objects.character.Character;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class CharacterManager{
	private static var instance: CharacterManager;

	public var managedCharacters:Map<String,Character> = new Map.Map();
	public var positions:Array<Array<String>> = [];

	public function new() {
		
	}
	
	public function findCharacterAtTilePos(position:TilePoint):Character {
		if (positions[position.x] == null)
			return null;
		if (positions[position.x][position.y] != null)
			return managedCharacters.get(positions[position.x][position.y]);
		else
			return null;
	}
	
	public function updateCharacterCoordinatesFromTo(element:Character, nx:Int, ny:Int):Void{
		if (positions[element.tilePos.x] == null)
			positions[element.tilePos.x] = [];
		positions[element.tilePos.x][element.tilePos.y] = null;
		MapManager.getInstance().activeMap.setColliAt(element.tilePos, false);
		MapManager.getInstance().activeMap.setLOSAt(element.tilePos, false);
		
		if (positions[nx] == null)
			positions[nx] = [];
		positions[nx][ny] = element.ID;
		MapManager.getInstance().activeMap.setColliAt(new TilePoint(nx, ny), true);
		MapManager.getInstance().activeMap.setLOSAt(new TilePoint(nx, ny), true);
		
		ServerManager.getInstance().onCharacterMove(element.ID, nx, ny);
	}
	
	public function addCharacter(element:Character):Void{
		managedCharacters.set(element.ID, element);
	}
	
	public function removeCharacter(element:Character):Void{
		managedCharacters.remove(element.ID);
		positions[element.tilePos.x][element.tilePos.y] = null;
		
		MapManager.getInstance().activeMap.setLOSAt(element.tilePos, false);
		MapManager.getInstance().activeMap.setColliAt(element.tilePos, false);
	}
	
	public function findCharacterById(charaId:String):Character{
		return managedCharacters.get(charaId);
	}
	
	public function Update():Void{
		for (i in managedCharacters.iterator()) {
			if (i == null)
				continue;
			i._selfUpdate();
		}
	}
	
	public function switchState():Void{
		for (i in managedCharacters.iterator())
			managedCharacters.remove(i.ID);
		positions = [[]];
	}
	
	public static function getInstance (): CharacterManager {
		if (instance == null) instance = new CharacterManager();
		return instance;
	}
}