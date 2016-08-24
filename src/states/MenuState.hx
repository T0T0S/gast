package states;

import haxe.Timer;
import managers.DrawManager;
import managers.InputManager;
import managers.StateManager;
import objects.Button;
import objects.ButtonSliced;
import objects.State;
import objects.TextInput;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.filters.dropshadow.DropShadowFilter;
import pixi.filters.pixelate.PixelateFilter;
import tweenx909.EaseX;
import tweenx909.TweenX;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class MenuState extends State{
	
	private var playButton:Button;
	private var centerBar:Sprite;
	
	private var loginText:TextInput;
	private var mdpText:TextInput;
	
	
	public function new() {
		super("Menu");
	}
	
	public override function Preload():Void {
	}
	
	public override function Start():Void {
		
		
		
		var slicedButton = new ButtonSliced("hollowBoxFull");
		Main.getInstance().hudCont.addChild(slicedButton);
		slicedButton.anchor.set(0.5,0.5);
		slicedButton.x = Main.gameCenter.x;
		slicedButton.y = Main.gameSize.y * 0.6;
		slicedButton.resize(10,10);
		slicedButton.buttonMode = false;
		slicedButton.interactive = false;
		
		//playButton = new Button("baseButton", true);
		//playButton.onUp(clickHandler);
		//playButton.x = Main.gameSize.x - playButton.width * 0.25;
		//playButton.y = Main.gameSize.y - playButton.height * 0.25;
		//playButton.scale.set(0.5, 0.5);
		//playButton.setText("PLAY");
		//DrawManager.addToDisplay(playButton, Main.getInstance().hudCont);
		
		
		centerBar = new Sprite(Texture.fromImage("glowBar.png"));
		centerBar.width = 1;
		centerBar.anchor.set(0.5, 0.5);
		slicedButton.getGlobalPosition(centerBar.position);
		Main.getInstance().hudCont.addChild(centerBar);
		
		var loginButton:ButtonSliced = new ButtonSliced("hollowBoxMid");
		Main.getInstance().hudCont.addChild(loginButton);
		loginButton.anchor.set(0.5,0.5);
		loginButton.x = Main.gameCenter.x;
		loginButton.y = Main.gameSize.y * 0.8;
		loginButton.alpha = 0;
		loginButton.resize(10, 10);
		loginButton.text.style.fill = "#31d031";
		loginButton.text.style.font = "48px gastFont";
		loginButton.onUp(TryLogin);
		
		var MainTitle:Text = new Text("GAST", {"fill": "#31d031", "font":"200px gastfont"});
		Main.getInstance().hudCont.addChild(MainTitle);
		MainTitle.x = Main.gameCenter.x - MainTitle.width * 0.5;
		MainTitle.y = Main.gameCenter.y * 0.15;
		Misc.displayTextOverTime(MainTitle, 1, 150);
		
		TweenX.serial([
			TweenX.wait(0.5),
			TweenX.to(slicedButton, { specialWidth: 400 }, 0.5).ease(EaseX.cubicOut).skip(),
			TweenX.wait(0.2),
			TweenX.to(slicedButton, { specialHeight: 200 }, 0.5).ease(EaseX.cubicOut).skip(),
			TweenX.wait(0.7),
			TweenX.to(centerBar, { width: 350 }, 0.5).ease(EaseX.cubicOut),
			TweenX.func(createTextInputs),
			TweenX.wait(0.3),
			TweenX.to(loginButton, { alpha: 1 }, 0.3).ease(EaseX.cubicOut).skip(),
			TweenX.to(loginButton, { specialWidth: 250, specialHeight: 150 }, 0.3).ease(EaseX.cubicOut),
			TweenX.func(function() { loginButton.setText("Login"); Misc.displayTextOverTime(loginButton.text, 0, 50);} )
		]);
		
		//Main.getInstance().hudCont.on("mousemove", function(e)
		//{
			//slicedButton.resize(e.data.global.x - slicedButton.x,e.data.global.y - slicedButton.y);
		//});
		
	}
	
	private function createTextInputs()
	{
		loginText = new TextInput();
		loginText.append();
		loginText.width = 300;
		loginText.height = 50;
		loginText.x = centerBar.x - centerBar.width * 0.5 + 30;
		loginText.y = centerBar.y - loginText.height - 10;
		loginText.bgAlpha = 0.01;
		loginText.domInput.placeholder = "";
		
		var textToDisplay = "Username";
		var timer =  new Timer(50);
		var progression:Int = 0;
		
		timer.run = function(){
			if (progression > textToDisplay.length)
			{
				timer.stop();
				timer = null;
				return;
			}
			loginText.domInput.placeholder = textToDisplay.substr(0, progression);
			++progression;
		};
		
		mdpText = new TextInput();
		mdpText.append();
		mdpText.width = 300;
		mdpText.height = 50;
		mdpText.x = centerBar.x - centerBar.width * 0.5 + 30;
		mdpText.y = centerBar.y + 10;
		mdpText.bgAlpha = 0.01;
		mdpText.domInput.placeholder = "";
		mdpText.domInput.type = "password";
		
		var textToDisplay2 = "Password";
		var timer2 =  new Timer(50);
		var progression2:Int = 0;
		Timer.delay(
			timer2.run = function(){
				if (progression2 > textToDisplay2.length && timer2 != null)
				{
					timer2.stop();
					timer2 = null;
					return;
				}
				mdpText.domInput.placeholder = textToDisplay2.substr(0, progression2);
				++progression2;
			}
		, 500);
	}
	
	private function TryLogin()
	{
		trace("login: " + loginText.value +" \nmdp: " + mdpText.value);
		
	}
	
	private function clickHandler(e):Void {
		StateManager.alphaTransition("Diam");
	}
	
	public override function Update():Void {
	}
	
	override public function switchState():Void {
	}
}