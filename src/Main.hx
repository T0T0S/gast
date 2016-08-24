package ;

import js.Browser;
import js.html.Event;
import js.html.EventListener;
import js.html.EventTarget;
import js.html.Font;
import js.html.KeyboardEvent;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.InitManager;
import managers.InputManager;
import managers.MapManager;
import managers.MouseManager;
import managers.PoolManager;
import managers.ServerManager;
import managers.StateManager;
import managers.TimeManager;
import managers.UpdateManager;
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
	private var updateManager:UpdateManager;
	private var inputManager:InputManager;
	
	
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
	public static var gameSize:Point = new Point();
	public static var gameCenter:Point = new Point();
	
	private var mouseCallPerFrame:Int = 1;
	private var mouseCalled:Int = 0;
	
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
		
		gameSize.x = renderer.width;
		gameSize.y = renderer.height;
		gameCenter.x = gameSize.x * 0.5;
		gameCenter.y = gameSize.y * 0.5;
		
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
			StateManager.indexContainerToPreserve.push(fullStage.getChildIndex(debugCont));
		}
		
		
		StateManager.indexContainerToPreserve.push(fullStage.getChildIndex(effectCont));
		
		debugCont.name = "debugCont";
		
		renderer.render(fullStage);
		renderer.view.className = "gastCanvas";
		var tempMoveFunction:Dynamic = function(event):Void {
			if (mouseCalled >= mouseCallPerFrame)
				return;
			++mouseCalled;

			renderer.plugins.interaction.onMouseMove(event);
		}
		
		renderer.plugins.interaction.onMouseMove = untyped tempMoveFunction.bind(renderer.plugins.interaction);
		
		renderer.plugins.interaction.setTargetElement(renderer.view);
		
		Browser.document.body.appendChild(renderer.view);
		//Browser.window.addEventListener("keydown", keyDownListener);
		//Browser.window.addEventListener("keyup", keyUpListener);
		bindInputs();		
		
		var font = new Font();
		font.onload = function() { Browser.window.requestAnimationFrame(cast InitManager.getInstance); };
		font.fontFamily = "gastFont";
		font.src = "assets/fonts/TRACER__.ttf";
		//font.src = "assets/fonts/Days.otf";
	}
	

	public static function getInstance (): Main {
		if (instance == null) instance = new Main();
		return instance;
	}
	
	public function Start() {
		inputManager = InputManager.getInstance();
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
		updateManager = UpdateManager.getInstance();

		Browser.window.addEventListener("resize", resize);
		Browser.window.requestAnimationFrame(cast Update);
	}
	
	public function resize (pEvent:Event): Void {
		//renderer.resize(DeviceCapabilities.width, DeviceCapabilities.height);
		screenRatio.x = renderer.width / 1920;
		screenRatio.y = renderer.height / 1080;
		gameSize.x = renderer.width;
		gameSize.y = renderer.height;
		
		gameCenter.x = gameSize.x * 0.5;
		gameCenter.y = gameSize.y * 0.5;
	}
	
	public function Update() {
		mouseCalled = 0;
		Browser.window.requestAnimationFrame(cast Update);
		if (GAMESTOPPED && DEBUGMODE)
			return;

		
		if(timeManager !=null)
			timeManager.Update();
			
		characterManager.Update();
		stateManager.Update();
		updateManager.Update();
		camera.Update();
	}
	
	public function Render():Void {
		drawManager.isometricSort(MapManager.getInstance().activeMap.mapContainer);
		renderer.render(fullStage);
	}
	
	private function bindInputs()
	{
		InputManager.getInstance().AddOnKeyUp("stopGame", ToggleStopGame, Keycode.A, false, false, true);
		InputManager.getInstance().AddOnKeyUp("toggleAlphaCharacters", ToggleAlphaCharacter, Keycode.One, true);
	}
	
	private function ToggleStopGame(e)
	{
		GAMESTOPPED = !GAMESTOPPED;
	}
	
	private function ToggleAlphaCharacter(e)
	{
		Options.getInstance().setOption("alphaCharacter", !Options.getInstance().getOption("alphaCharacter"));
		for (character in CharacterManager.getInstance().managedCharacters.iterator())
		{
			untyped character.alpha = 1 - 0.2 * Options.getInstance().getOption("alphaCharacter");
		}
	}
	
	public function destroy (): Void {
		instance = null;
	}

}




/*
 * 	server nodejs  !!!
 * 
 *  ON LOGIN => gather player info and getInstance() => persist.
 * launch only once loged
 * 
 * 
 *   IA ENEMY ZOMBIE
 * 		1 - rush player
 * 	 	2 - attack cac
 * 		3 - attack ranged
 * 	
 * normal mode => menu contextuel (right clic)
 * 
 * 
 * run anim.
 * 
 * 	=> Popup de victoire ou défaite <<<<===== to do secondary

 * ##################
 * 	 tache en cours
 * ##################
 *  => make landing page for login.
 * 	
 * 
 * ##############################################
 *  mark functions that need to be server side !
 * ##############################################
 * 
 *	#############
 * 	   SUPPORT
 *	#############
 * 	
 * 	Need Utilitaire d'import de perso.
 * ADD DISPLACEMENT MAP :>
 * 
 * Add sounds,  basic beeps for text. shooting sounds and movement.
 * FAIRE UNE PASSE SUR LES GRAPHISMES pour au moins vendre un peu le projet.
 * 
 **/


