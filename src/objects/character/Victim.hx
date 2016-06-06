package objects.character;

/**
 * ...
 * @author ToTos
 */
class Victim extends BaseEnemy{
	private static var numberOfVictim:Int = 0;
	public function new(?pseudoDebug:String) {
		if (pseudoDebug == null)
			pseudoDebug = "Victim Basic "+(++numberOfVictim);
		super("victim", pseudoDebug);
		stats.health = 1000;
		scale.set(0.4, 0.4);
	}
}