package states;

import haxe.Json;
import js.Browser;
import managers.DrawManager;
import managers.MapManager;
import managers.StateManager;
import objects.Button;
import objects.State;
import pixi.core.sprites.Sprite;
import pixi.core.math.shapes.Rectangle;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import utils.DeviceCapabilities;


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
		StateManager.getInstance().switchToState("Debug");
	}
	
	public override function Update():Void {
	}
	
	override public function switchState():Void {
	}
}