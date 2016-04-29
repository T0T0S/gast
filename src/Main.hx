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
		
		Browser.window.addEventListener('contextmenu', rightClickListener, false);
		
		
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
		updateManager = UpdateManager.getInstance();


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
		updateManager._update();
	}
	
	public function Render():Void {
		drawManager.isometricSort(MapManager.getInstance().activeMap.mapContainer);
		renderer.render(fullStage);
	}
	
	
	
	private function keyDownListener (e:KeyboardEvent):Void
	{
		if (e.keyCode == Keycodes.A && e.altKey) {
			GAMESTOPPED = !GAMESTOPPED;
		}
		if (keysDown.indexOf(e.keyCode) != -1)
			return;
		keysDown.push(e.keyCode);
		
		if (e.keyCode == Keycodes.One && e.shiftKey){
			Options.getInstance().setOption("alphaCharacter", !Options.getInstance().getOption("alphaCharacter"));
			for (character in CharacterManager.getInstance().managedCharacters.iterator())
			{
				untyped character.alpha = 1 - 0.2 * Options.getInstance().getOption("alphaCharacter");
			}
			
			return;
		}

		if (FightManager.status == StatusModes.fight)
		{
			if (e.keyCode >= Keycodes.Zero && e.keyCode <= Keycodes.Nine)
			{
				var attackIndex = e.keyCode - 48;
				attackIndex = attackIndex == 0 ? 10 : attackIndex;
				
				if (HudManager.getInstance().buttonSlot[attackIndex] != null)
					HudManager.getInstance().buttonSlot[attackIndex].Action();
			}
		}
	}
	
	private function keyUpListener (e:KeyboardEvent):Void
	{
		keysDown.splice(keysDown.indexOf(e.keyCode) , 1);
	}
	
	private function rightClickListener(e:KeyboardEvent)
	{
		if (e.which != Keycodes.Right_clic)
			return true;
			
		e.preventDefault();
		
		/*
		 * MENU CONTEXTUEL !
		 * */

		return false;
	}
	
	public function destroy (): Void {
		instance = null;
	}

	public static var Keycodes:Keycode = {
		Right_clic: 3, Backspace : 8, Tab : 9, Enter : 13, Shift : 16, Ctrl : 17, Alt : 18, Caps_lock : 20, Esc : 27, Space : 32, Page_up : 33, Page_down : 34, End : 35, Home : 36, Left : 37, 
		Up : 38, Right : 39, Down : 40, Insert : 45, Delete : 46, Command : 91, Numpad_star : 106, Numpad_plus : 107, Numpad_minus : 109, Numpad_dot : 110, Numpad_slash : 111,
		A : 65, B : 66, C : 67, D : 68, E : 69, F : 70, G : 71, H : 72, I : 73, J : 74, K : 75, L : 76, M : 77, N : 78, O : 79, P : 80, Q : 81, R : 82, S : 83, T : 84, U : 85,
		V : 86, W : 87, X : 88, Y : 89, Z : 90, Zero : 48, One : 49, Two : 50, Three : 51, Four : 52, Five : 53, Six : 54, Seven : 55, Eight : 56, Nine : 57
	}


	
}

typedef Keycode = { 
	Right_clic: Int, Backspace : Int, Tab : Int, Enter : Int, Shift : Int, Ctrl : Int, Alt : Int, Caps_lock : Int, Esc : Int, Space : Int, Page_up : Int, Page_down : Int, End : Int,
	Home : Int, Left : Int, Up : Int, Right : Int, Down : Int, Insert : Int, Delete : Int, Command : Int, Numpad_star : Int, Numpad_plus : Int, Numpad_minus : Int,
	Numpad_dot : Int, Numpad_slash : Int, A : Int, B : Int, C : Int, D : Int, E : Int, F : Int, G : Int, H : Int, I : Int, J : Int, K : Int, L : Int, M : Int, N : Int,
	O : Int, P : Int, Q : Int, R : Int, S : Int, T : Int, U : Int, V : Int, W : Int, X : Int, Y : Int, Z : Int, Zero : Int, One : Int, Two : Int, Three : Int, 
	Four : Int, Five : Int, Six : Int, Seven : Int, Eight : Int, Nine : Int
}




/*
 *	 TODO: 
 * 	event player move
 * 
 * 
 * 	server nodejs  !!!
 * 
 * 
 *   IA ENEMY ZOMBIE
 * 		1 - rush player
 * 	 	2 - attack cac
 * 		3 - attack ranged
 * 	
 * 	mode normal vs mode fight
 * 
 * normal mode => menu contextuel (right clic)
 * 
 * intégrer custom loader cool (folio)
 * 
 * run anim.
 * 
 * ###############
 * 		PRIO
 * ###############
 * flow de jeu: 
 *	3 groupes de monstres sur la map
 *	clic sur un groupe => launch fight
 * 		=> remove group from map enemy groups
 * 		=> Map generator -> géré les cases de spawn dans tiled.
 *  	=> phase de setup (mob en random sur les cases accessibles)
 * 		=> after 1 min or after all ready
 * 
 * start fight
 * 
 * upon finish 
 * popup victory / loss
 * 		return mode normal 
 * 			=> spawn still alive groups
 * 
 * map global timer 
 * 		=> respawn different group after X seconds 
 * 
 **/










