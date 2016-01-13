package objects.character;

/**
 * ...
 * @author ToTos
 */
class Victim extends BaseEnemy{

	public function new(newName:String) {
		super(newName);
		stats.health = 1000;
	}
}