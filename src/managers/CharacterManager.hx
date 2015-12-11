package managers;
import objects.character.Character;

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
	
	public function findCharacterAtTilePos(position:Array<Int>):Dynamic {
		if (positions[position[0]] == null)
			return null;
		if (positions[position[0]][position[1]] != null)
			return managedCharacters.get(positions[position[0]][position[1]]);
		else
			return null;
	}
	
	public function updateCharacterCoordinatesFromTo(element:Character, newPosition:Array<Int>):Void{
		var oldGrid:Array<Array<Int>> = MapManager.finder.getGrid();
		
		if (positions[element.tilePos[0]] == null)
			positions[element.tilePos[0]] = [];
		positions[element.tilePos[0]][element.tilePos[1]] = null;
		MapManager.finder.setColliTile(element.tilePos[0],element.tilePos[1],true);
		
		if (positions[newPosition[0]] == null)
			positions[newPosition[0]] = [];
		positions[newPosition[0]][newPosition[1]] = element.charaName;
		MapManager.finder.setColliTile(newPosition[0],newPosition[1],false);
	}
	
	public function addCharacter(element:Character):Void{
		managedCharacters.set(element.charaName, element);
	}
	
	public function removeCharacter(element:Character):Void{
		managedCharacters.remove(element.charaName);
		positions[element.tilePos[0]][element.tilePos[1]] = null;
		MapManager.finder.setColliTile(element.tilePos[0],element.tilePos[1],true);
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
			managedCharacters.remove(i.charaName);
		positions = [[]];
	}
	
	public static function getInstance (): CharacterManager {
		if (instance == null) instance = new CharacterManager();
		return instance;
	}
}