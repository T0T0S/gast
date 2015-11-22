package states;

import haxe.Json;
import js.Browser;
import managers.DrawManager;
import managers.MapManager;
import managers.StateManager;
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
	
	private var fond:Sprite;
	private var sprite:Sprite;

	public function new() {
		super("Menu");
	}
	
	public override function Preload():Void {
	}
	
	public override function Start():Void {
		sprite = new Sprite(Texture.fromImage("tile2.png"));
		sprite.interactive = true;
		sprite.on("mouseup", clickHandler);
		DrawManager.addToDisplay(sprite, Main.getInstance().gameCont);
		
	}
	
	private function clickHandler(e):Void {
		StateManager.getInstance().switchToState("Debug");
	}
	
	public override function Update():Void {
	}
	
	override public function switchState():Void {
	}
}