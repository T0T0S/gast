package objects.character;
import managers.CharacterManager;
import managers.FightManager;
import managers.MapManager;
import objects.character.Character;
import objects.EnemyGroup;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class BaseEnemy extends Npc{
	
	public var agressionRange:Int = 0;
	public var parentGroup:EnemyGroup;
	
	public function new(newName:String, ?newpseudo:String) {
		super(newName, newpseudo);
		setZ(1);
		entityType = EntityType.enemy;
		agressionRange = config.agressionRange == null ? 0: config.agressionRange;
	}
	
	public function findParentEnemyGroup()
	{
		for (group in MapManager.getInstance().activeMap.mapCharacterData.enemyGroups.iterator())
		{
			if (group.enemiesID.indexOf(ID) != -1)
				return group;
		}
		
		return null;
	}
	
	/*
	 * rendre les tiles setup clickable (indirect)
	 * hide au start
	 * remove pathfinding
	 * */
	override public function onCharacterMove(characterId:String):Void {
		super.onCharacterMove(characterId);
		
		checkForAgro(characterId);
	}
	
	private function checkForAgro(characterId:String)
	{
		if (FightManager.status != StatusModes.normal)
			return;
		
		if (parentGroup == null)
			parentGroup = findParentEnemyGroup();
		
		var character:Character = CharacterManager.getInstance().findCharacterById(characterId);
		if (character.entityType != EntityType.player || parentGroup == null)
			return;
		
		
		if (character.tilePos.getDistance(tilePos) <= agressionRange)
		{
			if (agressionRange == 0)
			{
				if (character.pathRemaining.length != 0)
					return;
			}
			agroPlayer(characterId);
		}
	}
	
	private function agroPlayer(playerId:String)
	{
		trace("ennemy team => " + parentGroup.enemiesData);
		
		parentGroup.isInFight = true;
		FightManager.getInstance().startFight([playerId], parentGroup.enemiesID);
		
		for (i in 0...parentGroup.enemiesID.length)
		{
			FightManager.getInstance().setEnemyReady(true);
		}
	}
	
	override public function onCombatWon():Void {
		super.onCombatWon();
		regenerate();
	}
	
	public function regenerate()
	{
		stats.health = stats.maxHealth;
		isDead = false;
	}
	
	override public function setTilePosition(nx:Int, ny:Int):Void {
		super.setTilePosition(nx, ny);
		if (FightManager.status == StatusModes.normal)
			parentGroup.enemiesData.get(ID).position = tilePos.toString();
	}
}