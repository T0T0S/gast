package states;

import haxe.Timer;
import managers.MapManager;
import managers.PoolManager;
import managers.StateManager;
import objects.State;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.loaders.Loader;
import tweenx909.EaseX;
import tweenx909.TweenX;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class LoadingState extends State{

	private var infoScreen:Sprite;
	private var screenRatio:Array<Float>;
	private var centerSprite:Sprite;
	private var loadProgression:Float = 0;
	private var hasFinishedLoading:Bool = false;
	private var loadingText:Text;
	private var loadingBall:Sprite;
	private var displayedLoading:Float  = 0;
	private var lineSides:Sprite;
	
	public function new() {
		super("Loading");
	}
	
	override public function AssetLoad(loader:Loader):Void {
		loadProgression = loader.progress;
	}
		
	override public function AllAssetsLoaded(loader:Loader):Void {
		loadProgression = loader.progress;
		hasFinishedLoading = true;
		
		PoolManager.generatePool();
		MapManager.getInstance().Init();
		//Timer.delay(function() { hasFinishedLoading = true; }, 3000); // delay finish by x seconds
	}
	
	private function addToLoader()
	{
		loadJson.set("Attack", 		"assets/spriteSheets/AttacksButtons.json");
		loadJson.set("hud_bottom", 	"assets/spriteSheets/hud_bottom.json");
		loadJson.set("tileSh2", 	"assets/spriteSheets/loadSpriteSheet.json");
		loadJson.set("buttons", 	"assets/spriteSheets/buttonSpriteSheet.json");
		loadJson.set("hero", 		"assets/spriteSheets/heroSpriteSheet.json");
		loadJson.set("hero2", 		"assets/spriteSheets/heroSpriteSheet2.json");
		loadJson.set("explosion", 	"assets/spriteSheets/testExplosion.json");
		loadJson.set("victim", 		"assets/spriteSheets/victim.json");
		loadJson.set("bullet", 		"assets/spriteSheets/bullet.json");
		loadJson.set("camShader",	"assets/effects/camShade.json");
	}
	
	
	override public function Preload():Void {
		addToLoader();
		
		infoScreen = new Sprite(Texture.fromImage("loadingScreenOpen.png"));
		infoScreen.anchor.set(0.5, 0.5);
		infoScreen.x = Main.gameCenter.x;
		infoScreen.y = Main.gameSize.y * 0.2;
		Main.getInstance().effectCont.addChild(infoScreen);
		screenRatio = [1 / infoScreen.scale.x, 1 / infoScreen.scale.y];

		var maskSprite:Sprite = new Sprite(Misc.getBasicMask().generateTexture(Main.getInstance().renderer)); 
		maskSprite.anchor.set(0.5, 0);
		maskSprite.y = - infoScreen.height * 0.5 * screenRatio[1];
		
		infoScreen.mask = maskSprite;
		maskSprite.scale.set(screenRatio[0], screenRatio[1]);
		
		infoScreen.addChild(maskSprite);
		
		
		maskSprite.width = 1;
		maskSprite.height = 10;
		TweenX.serial([
			TweenX.to(maskSprite, { width: infoScreen.width * screenRatio[0] }, 0.3).ease(EaseX.cubicOut),
			TweenX.wait(0.1),
			TweenX.to(maskSprite, { height:infoScreen.height * screenRatio[1] }, 0.3).ease(EaseX.cubicOut).onFinish(openCenter)
		]);
		
	}
	
	
	private function openCenter()
	{
		//write loading
		loadingText = new Text("Loading", { fill: "#31d031", font:'bold 76px gastFont' });
		loadingText.anchor.set(0.5, 0.5);
		loadingText.scale.set(screenRatio[0]- 0.1, screenRatio[1]);
		infoScreen.addChild(loadingText);
		
		Misc.displayTextOverTime(loadingText, 0, 50);
		
		centerSprite = new Sprite(Texture.fromImage("centerLoad.png"));
		centerSprite.x = Main.gameCenter.x;
		centerSprite.y = Main.gameCenter.y;
		centerSprite.anchor.set(0.5, 0.5);
		Main.getInstance().effectCont.addChild(centerSprite);

		var maskSprite:Sprite = new Sprite(Misc.getBasicMask().generateTexture(Main.getInstance().renderer)); 
		maskSprite.anchor.set(0.5, 0.5);
		centerSprite.addChild(maskSprite);

		centerSprite.mask = maskSprite;
		maskSprite.height = 1;
		maskSprite.width = centerSprite.width;
		
		TweenX.serial([
			TweenX.to(maskSprite, { height:centerSprite.height }, 0.3).ease(EaseX.cubicOut).onFinish(openLines)
		]);
	}
	
	function openLines()
	{
		centerSprite.mask = null;
		centerSprite.removeChildren();
		
		loadingBall = new Sprite(Texture.fromImage("loadingBall.png"));
		loadingBall.anchor.set(0.5,0.5);
		Main.getInstance().effectCont.addChildAt(loadingBall, 0);
		loadingBall.position = centerSprite.position;
		setScaleToLoadingBall(displayedLoading);
		
		var centerBallTimer:Timer = new Timer(16);
		centerBallTimer.run = function()
		{
			if (loadingBall != null)
			{
				displayedLoading = Misc.lerp(displayedLoading, loadProgression / 100, 0.04);
				setScaleToLoadingBall(displayedLoading);
			}
			else if(hasFinishedLoading)
			{
				centerBallTimer.stop();
				centerBallTimer = null;
			}
		};
		
		
		lineSides = new Sprite(Texture.fromImage("lineSides.png"));
		lineSides.anchor.set(0.5, 0.5);
		lineSides.x = Main.gameCenter.x;
		lineSides.y = Main.gameCenter.y;
		Main.getInstance().effectCont.addChild(lineSides);
		
		var maskSprite:Sprite = new Sprite(Misc.getBasicMask().generateTexture(Main.getInstance().renderer)); 
		maskSprite.anchor.set(0.5, 0.5);
		lineSides.addChild(maskSprite);
		
		lineSides.mask = maskSprite;
		
		maskSprite.alpha = 0;
		maskSprite.width = 1;
		maskSprite.height = lineSides.height;
		
		
		var lightMask:Sprite = new Sprite(Texture.fromImage("lineMask.png"));
		lightMask.anchor.set(0.5, 0.5);
		lineSides.addChild(lightMask);
		
		var toLeftLight:Sprite = new Sprite(Texture.fromImage("lightBlast.png")); // - x
		toLeftLight.anchor.set(0, 0.5);
		toLeftLight.x = Main.gameCenter.x;
		toLeftLight.mask = lightMask;

		lineSides.addChild(toLeftLight);
		
		var toRightLight:Sprite = new Sprite(Texture.fromImage("lightBlast.png")); // + x
		toRightLight.anchor.set(0, 0.5);
		toRightLight.x = -Main.gameCenter.x;
		toRightLight.rotation = Math.PI;
		toRightLight.mask = lightMask;

		
		lineSides.addChild(toRightLight);
		
		TweenX.serial([
			TweenX.wait(0.3),
			TweenX.func(function() { maskSprite.alpha = 1; } ),
			TweenX.to(maskSprite, { width:lineSides.width }, 0.5).ease(EaseX.cubicInOut).onFinish(function(){
				tweenFromSideToSide(toLeftLight, -1);
				tweenFromSideToSide(toRightLight, 1);
			})
		]);
	}
	
	function tweenFromSideToSide(element:Sprite, direction:Int):Void
	{
		var originalPos:Point = element.position.clone();
		TweenX.serial([
			TweenX.to(element, { x : 0.5 + direction * Main.gameCenter.x + (element.width + 25) * direction } ).time(1).ease(EaseX.sineOutIn).onFinish(
				function()
				{
					if (hasFinishedLoading)
					{
						prepareOpeningDoors();
					}
					else
					{
						element.position = originalPos;
						tweenFromSideToSide(element, direction);
					}
				}
			)
		]);
	}
	
	private var launchedOpeningPhase:Bool = false;
	function prepareOpeningDoors():Void
	{
		if (launchedOpeningPhase)
			return;
		launchedOpeningPhase = true;
		
		
		var timer =  new Timer(50);
		var loadString:String = "Done";
		var progression:Int = loadingText.text.length - 1;
		var temp:Bool = false;
		timer.run = function() {
			if (!temp)
			{
				if (progression == 0)
				{
					temp = true;
					return;
				}
				loadingText.text = loadingText.text.substr(0, progression);
				progression = loadingText.text.length - 1;
			}
			else
			{
				if (progression > loadString.length)
				{
					timer.stop();
					timer = null;
					Timer.delay(function()
					{
						TweenX.serial([
							TweenX.to(infoScreen.mask, { height: 10 }, 0.3).ease(EaseX.cubicOut),
							TweenX.wait(0.1),
							TweenX.to(infoScreen.mask, { width: 1 }, 0.3).ease(EaseX.cubicOut).onFinish(function() { infoScreen.parent.removeChild(infoScreen); infoScreen.destroy(true); openDoors(); } )
						]);
					}, 200);
					return;
				}
				loadingText.text = loadString.substr(0, progression);
				++progression;
			}
		};
	}
	
	function openDoors():Void
	{
		var leftDoor:Graphics = Misc.getBasicMask();
		leftDoor.height = Main.gameSize.y;
		leftDoor.width = Main.gameCenter.x;
		leftDoor.tint = Main.getInstance().renderer.backgroundColor;
		
		var rightDoor:Graphics = Misc.getBasicMask();
		rightDoor.height = Main.gameSize.y;
		rightDoor.width = Main.gameCenter.x;
		rightDoor.tint = Main.getInstance().renderer.backgroundColor;
		rightDoor.x = Main.gameCenter.x;
		
		Main.getInstance().hudCont.addChild(leftDoor);
		Main.getInstance().hudCont.addChild(rightDoor);
		
		Main.getInstance().renderer.backgroundColor = 0x0d0d0d;
		
		TweenX.serial([
			TweenX.to(centerSprite, { rotation: -Math.PI * 2 }, 1).ease(EaseX.quadInOut).skip(),
			TweenX.wait(0.1),
			TweenX.to(lineSides, { rotation: Math.PI * 0.5 }, 0.9).ease(EaseX.quadInOut),
			TweenX.wait(0.1),
			TweenX.to(centerSprite, { x: Main.getInstance().renderer.width + 300 }, 1).ease(EaseX.quadIn).skip(),
			TweenX.to(lineSides, { x: Main.getInstance().renderer.width + 300 }, 1).ease(EaseX.quadIn).skip(),
			TweenX.to(rightDoor, { x: Main.getInstance().renderer.width + 300}, 1).ease(EaseX.quadIn).skip(),
			TweenX.to(leftDoor, { x: -Main.gameCenter.x - 300 }, 1).ease(EaseX.quadIn).onFinish(generateLandingPage)
		]);
	}
	
	
	function generateLandingPage()
	{
		loadingBall = null;
		StateManager.alphaTransition("Menu", 0.2, 0.5);
	}
	
	private function setScaleToLoadingBall(amount:Float)
	{
		loadingBall.scale.set(amount, amount);
	}	
}