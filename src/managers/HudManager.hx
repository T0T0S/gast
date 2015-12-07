package managers;
import objects.HudElement;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;

	
/**
 * ...
 * @author ToTos
 */
class HudManager {
	
	private static var instance: HudManager;
	
	public static var mode:String = "none";
	

	private function new() {
		
	}
	
	public static function generateFightHud():Void {
		mode = "fight";
		var rightHud 	= new Sprite(Texture.fromImage("hud_bottom_right.png"));
		rightHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		rightHud.anchor.set(1, 1);
		rightHud.x = Main.getInstance().renderer.width;
		rightHud.y = Main.getInstance().renderer.height;
		
		var attackHud 	= new Sprite(Texture.fromImage("hud_bottom_center.png"));
		attackHud.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		attackHud.anchor.set(1, 1);
		attackHud.x = rightHud.x - (rightHud.width + 20);
		attackHud.y = Main.getInstance().renderer.height;
		
		var tickTimer = new Sprite(Texture.fromImage("timerFill.png"));
		tickTimer.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		tickTimer.anchor.set(0.5,0.5);
		tickTimer.x = rightHud.x - (tickTimer.width * 0.5 + 49 * Main.screenRatio[0]);
		tickTimer.y = Main.getInstance().renderer.height - (tickTimer.height * 0.5 + 48 *  Main.screenRatio[1]);
		tickTimer.name = "tickTimer";

		DrawManager.addToDisplay(attackHud, Main.getInstance().hudCont);
		DrawManager.addToDisplay(rightHud, Main.getInstance().hudCont);
		DrawManager.addToDisplay(tickTimer, Main.getInstance().hudCont);

	}
	
	public function switchState():Void{
		mode = "none";
	}
	
	public static function getInstance (): HudManager {
		if (instance == null) instance = new HudManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}