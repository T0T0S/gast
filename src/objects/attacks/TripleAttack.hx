package objects.attacks;
import managers.CharacterManager;
import objects.character.Character.Stats;

/**
 * ...
 * @author ToTos
 */
class TripleAttack extends Attack{

	public function new(jsonData:Dynamic) {
		super(jsonData);
		
	}
	
	override public function attackEffect(stats:Stats):Void {
		if (CharacterManager.getInstance().findCharactersAtTilePos(targetPosition).length != 0) {
			
			for (character in CharacterManager.getInstance().findCharactersAtTilePos(targetPosition).iterator())
			{
				character.damage(cast damage * (stats.strength / 100 * 10));
			}
		}
	}
	
}