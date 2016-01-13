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

	public function new(newName:String) {
		super(newName);
	}
	
	private function processAI():Void{
		
	}
	
}