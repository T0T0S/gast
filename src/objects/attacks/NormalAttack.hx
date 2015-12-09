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
		trace("attack !");
		if (CharacterManager.getInstance().findCharacterAtTilePos(targetPosition)) {
			CharacterManager.getInstance().findCharacterAtTilePos(targetPosition).damage(stats.strength);
		}
	}
	
}