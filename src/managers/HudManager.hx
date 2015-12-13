package managers;
import objects.Button;
import objects.character.Player;
import objects.HudButton;
import objects.HudElement;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;

	
/**
 * ...
 * @author ToTos
 */
class HudManager {
	
	private static var instance: HudManager;
	
	public static var mode:String = "none";
	
	public var attackButtons:Map<String,HudButton> = new Map.Map();
	public var HPmeter:Text;
	public var APmeter:Text;
	

	private function new() {
		
	}
	
	public function generateFightHud():Void {
		mode = "fight";
		var rightHud:Sprite 	= new HudElement(Texture.fromImage("hud_bottom_right.png"));
		rightHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		rightHud.anchor.set(1, 1);
		rightHud.x = Main.getInstance().renderer.width;
		rightHud.y = Main.getInstance().renderer.height;
		rightHud.name = "right_bottom";
		
		var attackHud:Sprite 	= new HudElement(Texture.fromImage("hud_bottom_center.png"));
		attackHud.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		attackHud.anchor.set(1, 1);
		attackHud.x = rightHud.x - (rightHud.width + 20);
		attackHud.y = Main.getInstance().renderer.height;
		attackHud.name = "center";
		
		//var moveButton:Button  = new Button("button_move");
		//moveButton.x = -695;
		//moveButton.y = -73;
		
		var attackButton:HudButton  = new HudButton("button_attack", "normal");
		attackButton.x = -695;
		attackButton.y = -73;
		attackButtons.set(attackButton.actionName, attackButton);
		
		var tripleAttackButton:HudButton  = new HudButton("button_triple_attack", "triple");
		tripleAttackButton.anchor.set(0.5, 0.5);
		tripleAttackButton.x = -570;
		tripleAttackButton.y = -73;
		attackButtons.set(tripleAttackButton.actionName, tripleAttackButton);
		
		var tickTimer:Sprite = new Sprite(Texture.fromImage("timerFill.png"));
		tickTimer.anchor.set(0.5,0.5);
		tickTimer.x = - (tickTimer.width * 0.5 + 50);
		tickTimer.y = - (tickTimer.height * 0.5 + 48);
		tickTimer.name = "tickTimer";
	
		var HPText:Text = new Text("", { "fill" :"white", "font":"35px gastFont", "stroke": "black", "strokeThickness":5 } );
		HPText.anchor.set(0.5,0.5);
		HPText.name = "HP";
		HPText.x = - 342 ;
		HPText.y = - 65 ;
		HPmeter = HPText;
		
		var APText:Text = new Text("", { "fill" :"white", "font":"35px gastFont", "stroke": "black", "strokeThickness":5 } );
		APText.anchor.set(0.5,0.5);
		APText.name = "AP";
		APText.x = - 342;
		APText.y = - 175;
		APmeter = APText;
		
		DrawManager.addToDisplay(attackHud, Main.getInstance().hudCont);
		DrawManager.addToDisplay(attackButton, attackHud);
		DrawManager.addToDisplay(tripleAttackButton, attackHud);

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