package objects.attacks;
import managers.CharacterManager;
import objects.character.Character.Stats;

/**
 * ...
 * @author ToTos
 */
class NormalAttack extends Attack{

	public function new(jsonData:Dynamic) {
		super(jsonData);
		
	}
	
	override public function attackEffect(stats:Stats):Void {
		super.attackEffect(stats);
		if (CharacterManager.getInstance().findCharacterAtTilePos(targetPosition)) {
			CharacterManager.getInstance().findCharacterAtTilePos(targetPosition).damage(damage * (stats.strength / 100 * 10));
		}
	}
	
}