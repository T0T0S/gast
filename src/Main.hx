package ;

import js.Browser;
import js.html.Event;
import js.html.Font;
import js.html.KeyboardEvent;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import managers.PoolManager;
import managers.ServerManager;
import managers.StateManager;
import managers.TimeManager;
import objects.Camera;
import objects.Options;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import pixi.core.renderers.Detector;
import pixi.core.renderers.webgl.WebGLRenderer;
import utils.TilePoint;

//import managers.ZoomManager;

/**
 * ...
 * @author ToTos
 */

class Main 
{
	private static var instance: Main;
	
	private var Init:InitManager;
	private var drawManager:DrawManager;	
	private var mouseManager:MouseManager;	
	private var stateManager:StateManager;
	private var mapManager:MapManager;
	private var timeManager:TimeManager;
	private var characterManager:CharacterManager;
	private var poolManager:PoolManager;
	private var fightManager:FightManager;
	private var serverManager:ServerManager;
	
	
	public static var camera:Camera;
	
	public var renderer:WebGLRenderer;

	public var fullStage:Container = new Container();
	public var tileCont:Container = new Container();
	public var gameCont:Container = new Container();
	public var hudCont:Container = new Container();
	public var effectCont:Container = new Container();
	public var debugCont:Container = new Container();
	
	public var renderMask:Graphics = new Graphics();
	
	public static var tileSize:TilePoint = new TilePoint();
	public static var screenRatio:Point = new Point(); // ratio of the scale from 1920x1080 screen
	
	private var mouseCallPerFrame:Int = 1;
	private var mouseCalled:Int = 0;
	
	public static var keysDown:Array<Int> = [];
	
	public static var DEBUGMODE:Bool = true;
	public static var GAMESTOPPED:Bool = false;
	
	static function main ():Void {
		Main.getInstance();
	}
	
	private function new () {
		Options.getInstance();
		
		renderer = Detector.autoDetectRenderer(1600, 900, {});
		renderer.backgroundColor = 0x171824;
		renderMask.beginFill();
		renderMask.drawRect(0, 0, renderer.width, renderer.height);
		renderMask.endFill();
		
		screenRatio.x = renderer.width / 1920;
		screenRatio.y = renderer.height / 1080;
		
		fullStage.addChild(renderMask);
		
		tileCont.interactive = true;
		gameCont.interactive = true;
		hudCont.interactive = true;
		
		fullStage.mask = renderMask;
		Reflect.setField(tileCont, "isoSort", true);
		Reflect.setField(gameCont, "isoSort", true);
		Reflect.setField(hudCont, "isoSort", true);
		
		fullStage.addChildAt(tileCont, 0);
		fullStage.addChildAt(gameCont,1);
		fullStage.addChildAt(hudCont,2);
		fullStage.addChildAt(effectCont, 3);
		
		if (DEBUGMODE) {
			fullStage.addChildAt(debugCont, 4);
		}
		
		debugCont.name = "debugCont";
		
		renderer.render(fullStage);
		renderer.view.className = "gastCanvas";
		var oldMoveFunction = renderer.plugins.interaction.onMouseMove;
		
		var tempMoveFunction:Dynamic = function(event):Void {
			if (mouseCalled >= mouseCallPerFrame)
				return;
			++mouseCalled;

			renderer.plugins.interaction.onMouseMove(event);
		}
		
		renderer.plugins.interaction.onMouseMove = untyped tempMoveFunction.bind(renderer.plugins.interaction);
		
		renderer.plugins.interaction.setTargetElement(renderer.view);
		
		Browser.document.body.appendChild(renderer.view);
		Browser.window.addEventListener("keydown", keyDownListener);
		Browser.window.addEventListener("keyup", keyUpListener);
		
		
		var font = new Font();
		font.onload = function() { Browser.window.requestAnimationFrame(cast InitManager.getInstance); };
		font.fontFamily = "gastFont";
		font.src = "assets/fonts/Days.otf";
	}
	

	public static function getInstance (): Main {
		if (instance == null) instance = new Main();
		return instance;
	}
	
	/*
	 * called after json config recup in InitManager.hx
	 * access it with InitManager.data.config
	 * */
	
	public function Start() {
		poolManager = PoolManager.getInstance();
		drawManager = DrawManager.getInstance();
		timeManager = TimeManager.getInstance();
		mouseManager = MouseManager.getInstance();
		camera = Camera.getInstance();
		mapManager = MapManager.getInstance();
		characterManager = CharacterManager.getInstance();
		fightManager = FightManager.getInstance();
		stateManager = StateManager.getInstance();
		serverManager = ServerManager.getInstance();
		
		Browser.window.addEventListener("resize", resize);
		Browser.window.requestAnimationFrame(cast Update);
	}
	
	public function resize (pEvent:Event): Void {
		//renderer.resize(DeviceCapabilities.width, DeviceCapabilities.height);
		screenRatio.x = renderer.width / 1920;
		screenRatio.y = renderer.height / 1080;
	}
	
	public function Update() {
		mouseCalled = 0;
		Browser.window.requestAnimationFrame(cast Update);
		if (GAMESTOPPED && DEBUGMODE)
			return;

		
		if(timeManager !=null)
			timeManager.Update();
			
		characterManager.Update();
		camera.Update();
		stateManager.Update();
	}
	
	public function Render():Void {
		drawManager.isometricSort(MapManager.getInstance().activeMap.mapContainer);
		renderer.render(fullStage);
	}
	
	
	
	public function keyDownListener (e:KeyboardEvent):Void
	{
		if (String.fromCharCode(e.keyCode) == "A" && e.altKey) {
			GAMESTOPPED = !GAMESTOPPED;
		}
		if (keysDown.indexOf(e.keyCode) != -1)
			return;
		keysDown.push(e.keyCode);
		
		if (e.keyCode == 49 && e.shiftKey){
			Options.getInstance().setOption("alphaCharacter", !Options.getInstance().getOption("alphaCharacter"));
			for (character in CharacterManager.getInstance().managedCharacters.iterator())
			{
				untyped character.alpha = 1 - 0.2 * Options.getInstance().getOption("alphaCharacter");
			}
			
			return;
		}

		if (FightManager.status == StatusModes.fight)
		{
			if (e.keyCode >= 48 && e.keyCode < 58)
			{
				var attackIndex = e.keyCode - 48;
				attackIndex = attackIndex == 0 ? 10 : attackIndex;
				
				if (HudManager.getInstance().buttonPosition[attackIndex] != null){
					HudManager.getInstance().buttonPosition[attackIndex].emit("mousedown");
					HudManager.getInstance().buttonPosition[attackIndex].emit("mouseup");
					HudManager.getInstance().buttonPosition[attackIndex].emit("mouseout");
				}
			}
		}
	}
	
	public function keyUpListener (e:KeyboardEvent):Void
	{
		keysDown.splice(keysDown.indexOf(e.keyCode) , 1);
	}
	
	

	
	public function destroy (): Void {
		instance = null;
	}
	
}

/*
 *	 TODO: 
 * 	event player move
 * 
 * 	Input manager
 * 	Button.hx => peux être bind a une touche (window.onkeydown listener)
 * 	tenter de faire comme Unity 
 * 	if(Button.isClicked())
	{
		do you shit !
	}
	
 * 	server nodejs  !!!
 * 
 * 	passer en iso diamond !
 * 	integrer le joueur <=== 
 * 
 *   IA ENEMY ZOMBIE
 * 		1 - rush player
 * 	 	2 - attack cac
 * 		3 - attack ranged
 * 	
 * 	new map survival
 * 	mode survival
 * 
 * 	mode normal vs mode fight
 * 	
 * add 2D vector support
 * 
 * sortir des fonctions de miscs
 * 
 * 
 **/










