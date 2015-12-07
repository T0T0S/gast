package managers;
import objects.Button;
import objects.character.Player;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
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
		var rightHud:Sprite 	= new Sprite(Texture.fromImage("hud_bottom_right.png"));
		rightHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		rightHud.anchor.set(1, 1);
		rightHud.x = Main.getInstance().renderer.width;
		rightHud.y = Main.getInstance().renderer.height;
		rightHud.name = "right_bottom";
		
		var attackHud:Sprite 	= new Sprite(Texture.fromImage("hud_bottom_center.png"));
		attackHud.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		attackHud.anchor.set(1, 1);
		attackHud.x = rightHud.x - (rightHud.width + 20);
		attackHud.y = Main.getInstance().renderer.height;
		
		var moveButton:Button  = new Button("button_move");
		moveButton.anchor.set(0.5, 0.5);
		moveButton.x = -695;
		moveButton.y = -73;
		moveButton.onUp(function() { Player.selectedAction = Player.selectedAction == null ? "move" : null; } );
		
		var attackButton:Button  = new Button("button_attack");
		attackButton.anchor.set(0.5, 0.5);
		attackButton.x = -570;
		attackButton.y = -73;
		attackButton.onUp(function() { Player.selectedAction = Player.selectedAction == null ? "attack" : null; } );
		
		var tickTimer:Sprite = new Sprite(Texture.fromImage("timerFill.png"));
		tickTimer.anchor.set(0.5,0.5);
		tickTimer.x = - (tickTimer.width * 0.5 + 50);
		tickTimer.y = - (tickTimer.height * 0.5 + 48);
		tickTimer.name = "tickTimer";
	
		var APText:Text = new Text("", { "fill" :"white", "font":"35px gastFont", "stroke": "black", "strokeThickness":5 } );
		APText.anchor.set(0.5,0.5);
		APText.name = "HP";
		APText.x = - 342 ;
		APText.y = - 65 ;
		
		var HPText:Text = new Text("", { "fill" :"white", "font":"35px gastFont", "stroke": "black", "strokeThickness":5 } );
		HPText.anchor.set(0.5,0.5);
		HPText.name = "AP";
		HPText.x = - 342;
		HPText.y = - 175;
		
		DrawManager.addToDisplay(attackHud, Main.getInstance().hudCont);
		DrawManager.addToDisplay(moveButton, attackHud);
		DrawManager.addToDisplay(attackButton, attackHud);

		DrawManager.addToDisplay(rightHud, Main.getInstance().hudCont);
		DrawManager.addToDisplay(tickTimer, rightHud);
		DrawManager.addToDisplay(APText, rightHud);
		DrawManager.addToDisplay(HPText, rightHud);

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