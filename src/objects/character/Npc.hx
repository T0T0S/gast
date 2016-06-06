package objects.character;
import objects.character.Character;

/**
 * ...
 * @author ToTos
 */
class Npc extends Character{

	/* AI */
	private var targetCharacter:Character;
	/* End AI */

	public function new(newName:String, ?newInGameName:String) {
		super(newName, newInGameName);
		entityType = EntityType.npc;
	}
	
	override public function fight_update():Void {
		super.fight_update();
		
		processAI();
	}
	
	private function processAI():Void
	{
		
	}
	
	override public function onCombatLost():Void {
		super.onCombatLost();
		Destroy(); // test enemy destroy only at the end on fight if npc.
	}
	
}