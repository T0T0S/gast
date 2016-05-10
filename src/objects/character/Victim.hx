package objects.character;

/**
 * ...
 * @author ToTos
 */
class Victim extends BaseEnemy{

	public function new(newName:String, ?pseudo:String) {
		super(newName, pseudo);
		stats.health = 1000;
	}
}