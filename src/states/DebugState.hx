package states;
import js.Browser;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import objects.State;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class DebugState extends State {
	
	private var hoverSprite:Sprite;
	
	public function new() {
		super("Debug");
	}
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		MapManager.getInstance().generateMapDisplay("testMapZig");
		hoverSprite = new Sprite(Texture.fromImage("tilehover.png"));
		hoverSprite.x = -1000;
		hoverSprite.y = -1000;
		hoverSprite.anchor.set(0.5, 1);
		DrawManager.addToDisplay(hoverSprite, Main.getInstance().tileCont,10);

		Browser.window.addEventListener("gameHover", moveHover);
	}
	
	public override function Update() {
	}
	
	
	private function moveHover(e):Void {
		hoverSprite.x = Misc.convertToAbsolutePosition(e.tilePos)[0];
		hoverSprite.y = Misc.convertToAbsolutePosition(e.tilePos)[1] + InitManager.data.config.tileSize[1] *0.5;
	}
}