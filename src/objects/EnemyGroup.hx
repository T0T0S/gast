package objects;
import objects.character.BaseEnemy;

/**
 * ...
 * @author ToTos
 */
class EnemyGroup{

	/*
	 * don't know if we need refs or ids...
	 * change later if needed.
	 * */
	public var enemiesID:Array<String> = [];
	public var isInFight:Bool = false;
	
	
	public function new(newIds:Array<String>) 
	{
		enemiesID = newIds;
	}
	
}