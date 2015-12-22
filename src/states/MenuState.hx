package states;

import managers.DrawManager;
import managers.StateManager;
import objects.Button;
import objects.State;


/**
 * ...
 * @author ToTos
 */
class MenuState extends State{
	
	private var playButton:Button;

	public function new() {
		super("Menu");
	}
	
	public override function Preload():Void {
	}
	
	public override function Start():Void {
		playButton = new Button("baseButton");
		playButton.onUp(clickHandler);
		playButton.x = Main.getInstance().renderer.width * 0.5;
		playButton.y = Main.getInstance().renderer.height * 0.6;
		playButton.scale.set(0.5, 0.5);
		
		playButton.setText("PLAY");
		DrawManager.addToDisplay(playButton, Main.getInstance().hudCont);
		
	}
	
	private function clickHandler(e):Void {
		playButton.Destroy();
		StateManager.getInstance().switchToState("Debug");
	}
	
	public override function Update():Void {
	}
	
	override public function switchState():Void {
	}
}