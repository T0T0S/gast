package managers;

import js.Browser;
import js.Error;
import managers.FightManager.StatusModes;
import objects.character.Character;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class CharacterManager{
	private static var instance: CharacterManager;

	public var managedCharacters:Map<String,Character> = new Map.Map();
	public var positions:Map<String, Array<String>> = new Map.Map();

	public function new() 
	{
		untyped Browser.window.characterManager = this;
	}
	
	private function retreiveAllCharactersAtPos(position:TilePoint):Array<Character>
	{
		var tempArray:Array<Character> = [];
		var tempIdArray:Array<String>  = positions.get(position.toString());
		for (id in tempIdArray.iterator())
		{
			tempArray.push(managedCharacters.get(id));
		}
		return tempArray;
	}
	
	public function findCharactersAtTilePos(position:TilePoint):Array<Character> {
		if (positions.get(position.toString()) == null)
			return [];
		else
			return retreiveAllCharactersAtPos(position);
	}
	
	public function updateCharacterCoordinatesFromTo(element:Character, oldPosition:TilePoint):Void{
		var oldPosIDs:Array<String> = positions.get(oldPosition.toString());
		if (oldPosIDs != null)
		{
			oldPosIDs.splice(oldPosIDs.indexOf(element.ID), 1);
		
			if (oldPosIDs.length == 0)
			{
				positions.remove(oldPosition.toString());
				MapManager.getInstance().activeMap.setColliAt(oldPosition, false);
				MapManager.getInstance().activeMap.setLOSAt(oldPosition, false);
			}
			
			positions.set(oldPosition.toString(), oldPosIDs);
		}
		
		var newPos:Array<String> = positions.get(element.tilePos.toString());
		
		if (newPos != null)
		{
			if(newPos.indexOf(element.ID) != -1)
				return;
		}
		else
			newPos = [];
		newPos.push(element.ID);
			
			
		if (newPos.length == 1)
		{
			MapManager.getInstance().activeMap.setColliAt(element.tilePos, FightManager.status != StatusModes.normal);
			MapManager.getInstance().activeMap.setLOSAt(element.tilePos, FightManager.status != StatusModes.normal);
		}
		
		positions.set(element.tilePos.toString(),newPos);
		
		ServerManager.getInstance().onCharacterMove(element.ID);
	}
	
	public function setTileData(tilePos:TilePoint, hasSight:Bool, canWalk:Bool)
	{
		MapManager.getInstance().activeMap.setColliAt(tilePos, !canWalk);
		MapManager.getInstance().activeMap.setLOSAt(tilePos, !hasSight);
	}
	
	public function addCharacter(element:Character):Void {
		if (managedCharacters.get(element.ID) != null)
			throw new Error("Character Id is already in use: "+ element.ID);
		managedCharacters.set(element.ID, element);
	}
	
	public function removeCharacter(element:Character):Void {
		var playerArrayPos = element.tilePos.toString();
		if (!managedCharacters.exists(element.ID))	
			return;
			
		managedCharacters.remove(element.ID);
		
		if(positions.get(playerArrayPos) == null)
			return;
		positions.get(playerArrayPos).splice(positions.get(playerArrayPos).indexOf(element.ID), 1);
		
		if (positions.get(playerArrayPos).length == 0)
		{
			positions.remove(playerArrayPos);
			MapManager.getInstance().activeMap.setColliAt(element.tilePos, false);
			MapManager.getInstance().activeMap.setLOSAt(element.tilePos, false);
		}
	}
	
	public function findCharacterById(charaId:String):Character{
		return managedCharacters.get(charaId);
	}
	
	public function Update():Void{
		//for (i in managedCharacters.iterator()) {
			//if (i == null)
				//continue;
			//i._selfUpdate();
		//}
	}
	
	public function switchState():Void{
		managedCharacters = new Map.Map();
		positions = new Map.Map();
	}
	
	public static function getInstance (): CharacterManager {
		if (instance == null) instance = new CharacterManager();
		return instance;
	}
}