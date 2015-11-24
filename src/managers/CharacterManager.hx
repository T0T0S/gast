package managers;
import objects.Character;

/**
 * ...
 * @author ToTos
 */
class CharacterManager{
	private static var instance: CharacterManager;

	public var managedCharacters:Map<String,Character> = new Map.Map();
	public var managedCharactersPosition:Array<Array<String>> = [];

	public function new() {
		
	}
	
	public function findCharacterAtTilePos(position:Array<Int>):Dynamic {
		if (managedCharactersPosition[position[0]] == null)
			return null;
		if (managedCharactersPosition[position[0]][position[1]] != null)
			return managedCharacters.get(managedCharactersPosition[position[0]][position[1]]);
		else
			return null;
	}
	
	public function updateCharacterCoordinatesFromTo(element:Character, newPosition:Array<Int>):Void{
		if (managedCharactersPosition[element.tilePos[0]] == null)
			managedCharactersPosition[element.tilePos[0]] = [];
		managedCharactersPosition[element.tilePos[0]][element.tilePos[1]] = null;
		if (managedCharactersPosition[newPosition[0]] == null)
			managedCharactersPosition[newPosition[0]] = [];
		managedCharactersPosition[newPosition[0]][newPosition[1]] = element.charaName;
	}
	
	public function addCharacter(element:Character):Void{
		managedCharacters.set(element.charaName, element);
	}
	
	public function removeCharacter(element:Character):Void{
		managedCharacters.remove(element.charaName);
		managedCharactersPosition[element.tilePos[0]][element.tilePos[1]] = null;
	}
	
	public function update():Void{
		for (i in managedCharacters.iterator()){
			i._update();
		}
	}
	
	public function switchState():Void{
		for (i in managedCharacters.iterator())
			managedCharacters.remove(i.charaName);
		managedCharactersPosition = [[]];
	}
	
	public static function getInstance (): CharacterManager {
		if (instance == null) instance = new CharacterManager();
		return instance;
	}
}