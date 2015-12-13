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
	
	public var attackButtons:Map<String,HudButton> = new Map.Map();
	public var buttonPosition:Array<HudButton> = [];
	public var HPmeter:Text;
	public var APmeter:Text;
	

	private function new() {
		
	}
	
	public function generateFightHud():Void {
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
		
		
		
		var attackButton:HudButton = addActionButton("button_attack", "normal", 1);
		
		var tripleAttackButton:HudButton  =  addActionButton("button_triple_attack", "triple", 2);
		
		
		
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
	
	public function addActionButton(textureName:String, attackName:String, position:Int):HudButton{
		position = position == 0 ? 10 : position;
		var newButton = new HudButton(textureName, attackName);
		newButton.anchor.set(0.5, 0.5);
		newButton.x = -695 + 125 * (position -1);
		newButton.y = -73;
		attackButtons.set(newButton.actionName, newButton);
		buttonPosition[position] = newButton;
		return newButton;
	}
	
	public function switchState():Void{
	}
	
	public static function getInstance (): HudManager {
		if (instance == null) instance = new HudManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}