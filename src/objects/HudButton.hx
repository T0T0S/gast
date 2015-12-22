package objects;
import objects.Button;
import objects.character.Player;

/**
 * ...
 * @author ToTos
 */
class HudButton extends Button{
	public var actionName:String;
	public function new(textureName:String, actionName:String) {
		super(textureName);
		anchor.set(0.5, 0.5);
		this.actionName = actionName;
		this.name = actionName;
		onUp(function() { 
				Player.getInstance().changeSelectedAction(actionName); 
			} 
		);
	}
	
	
	
	
}