package objects;
import js.Browser;
import managers.CharacterManager;
import managers.FightManager;
import managers.MapManager;
import objects.character.BaseEnemy;
import objects.character.Character;
import objects.character.Victim;
import objects.EnemyGroup.EnemyData;
import utils.TilePoint;
import haxe.Timer;


typedef EnemyData =
{
	var position:String;
	var className:String;
}

/**
 * ...
 * @author ToTos
 */
class EnemyGroup{
	
	public var enemiesID:Array<String> = [];
	public var enemiesData:Map<String, EnemyData> = new Map.Map();
	public var mapRef:GameMap;
	public var isInFight:Bool = false;
	
	@:deprecated("ServSide")
	public function new(newMapRef:GameMap) 
	{
		mapRef = newMapRef;
		generateNewGroup();
	}
	
	@:deprecated("revoir la composition des groups")
	private function generateNewGroup()
	{
		for (enemyClass in mapRef.mapCharacterData.enemyTypesAllowed)
		{
			if (Type.resolveClass("objects.character." + enemyClass) == null)
			{
				Browser.window.console.warn("Unknown enemyType '"+enemyClass+"' for enemy group.");
				continue;
			}
			var rand:Int = Math.floor(1 + Math.random() * mapRef.mapCharacterData.maxEnemiesInGroup);
			for (i in 0...rand)
			{
				var tempEnemy = Type.createInstance(Type.resolveClass("objects.character." + enemyClass), [enemyClass]);
				tempEnemy.parentGroup = this;
				enemiesID.push(tempEnemy.ID);
			}
		}

		var tempData:EnemyData;
		for (enemyId in enemiesID.iterator())
		{
			enemiesData.set(enemyId, getDataFromEnemy(CharacterManager.getInstance().findCharacterById(enemyId)));
		}
		

	}
	
	private function getDataFromEnemy(character:Character):EnemyData
	{
		return 
		{
			position: character.tilePos.toString(),
			className: Type.getClassName(Type.getClass(character))
		};
	}
	
	@:deprecated("ServSide")
	public function kill()
	{
		//Add to timeManagerRespawn
		//Timer.delay(respawnGroup, 60000);
		for (id in enemiesID)
		{
			if(CharacterManager.getInstance().findCharacterById(id) != null)
				CharacterManager.getInstance().findCharacterById(id).Destroy();
		}
		
		enemiesID = [];
		enemiesData = new Map.Map();
		trace("group respawn in 5 sec");
		Timer.delay(respawnGroup, 5000);
	}
	
	public function respawnGroup()
	{
		isInFight = false;
		generateNewGroup();
		trace("group has respawned");
		if(FightManager.status == StatusModes.normal)
			MapManager.getInstance().placeEnemyGroupRamdom(3, enemiesID);
	}
	
}