package managers;
import js.Browser;
import js.html.KeyboardEvent;


class InputHandler
{
	private var altKey:Bool;
	private var shiftKey:Bool;
	private var ctrlKey:Bool;
	private var key:Int;
	private var callback:KeyboardEvent->Void;
	public var identifier:String;
	
	public function new(newIdentifier:String, newCallback:KeyboardEvent->Void, keyCode:Int, ?ctrl:Bool, ?shift:Bool, ?alt:Bool)
	{
		identifier = newIdentifier;
		callback = newCallback;
		key = keyCode;
		ctrlKey = ! !ctrl;
		shiftKey = ! !shift;
		altKey = ! !alt;
	}
	
	public function testCall(e:KeyboardEvent)
	{
		if (key 		== e.keyCode && 
			ctrlKey 	== e.ctrlKey &&
			altKey 		== e.altKey &&
			shiftKey	== e.shiftKey)
		{
			callback(e);
		}
	}
}

/**
 * ...
 * @author ToTos
 */
class InputManager {
	private static var instance: InputManager;
	
	private var keyDownArray:Array<Bool> = [];
	private var onDownFunctions:Array<InputHandler> = [];
	private var onUpFunctions:Array<InputHandler> = [];
	
	private function new() 
	{
		Browser.window.addEventListener("keydown", OnDownListener);	
		Browser.window.addEventListener("keyup", OnUpListener);	
		Browser.window.addEventListener('contextmenu', rightClickListener, false);
	}
	
	private function OnDownListener(e:KeyboardEvent)
	{
		if (!keyDownArray[e.keyCode])
		{
			keyDownArray[e.keyCode] = true;
			
			for (handler in onDownFunctions.iterator())
			{
				handler.testCall(e);
			}
		}
	}
	
	private function OnUpListener(e:KeyboardEvent)
	{
		if (keyDownArray[e.keyCode])
		{
			keyDownArray[e.keyCode] = false;
			for (handler in onUpFunctions.iterator())
			{
				handler.testCall(e);
			}
		}
	}
	
	/**
	 * Adds a method to be called on keyboardDown
	 * @param	newIdentifier "name" of the InputHandler, used to remove it if needed
	 */
	public function AddOnKeyDown(newIdentifier:String, callback:KeyboardEvent->Void, keyCode:Int, ?shift:Bool, ?ctrl:Bool, ?alt:Bool)
	{
		onDownFunctions.push(new InputHandler(newIdentifier, callback, keyCode, ctrl, shift, alt));
	}
	
	/**
	 * Adds a method to be called on keyboardUp
	 * @param	newIdentifier "name" of the InputHandler, used to remove it if needed
	 */
	public function AddOnKeyUp(newIdentifier:String, callback:KeyboardEvent->Void, keyCode:Int, ?shift:Bool, ?ctrl:Bool, ?alt:Bool)
	{
		onUpFunctions.push(new InputHandler(newIdentifier, callback, keyCode, ctrl, shift, alt));
	}
	
	public function removeListener(identifier:String):Void
	{
		for (handler in onDownFunctions.iterator())
		{
			if (handler.identifier == identifier)
			{
				onDownFunctions.remove(handler);
				return;
			}
		}
		
		for (handler in onUpFunctions.iterator())
		{
			if (handler.identifier == identifier)
			{
				onUpFunctions.remove(handler);
				return;
			}
		}
	}
	
	public static function getInstance (): InputManager {
		if (instance == null) instance = new InputManager();
		return instance;
	}
	
	private function rightClickListener(e:KeyboardEvent)
	{
		if (e.which != Keycode.Right_clic)
			return true;
			
		e.preventDefault();
		
		/*
		 * MENU CONTEXTUEL !
		 * */

		return false;
	}
	
}

class Keycode {
		public static var Right_clic= 3; public static var Backspace = 8; public static var Tab = 9; public static var Enter = 13; public static var Shift = 16; 
		public static var Ctrl = 17; public static var Alt = 18; public static var Caps_lock = 20; public static var Esc = 27; public static var Space = 32; 
		public static var Page_up = 33; public static var Page_down = 34; public static var End = 35; public static var Home = 36; public static var Left = 37; 
		public static var Up = 38; public static var Right = 39; public static var Down = 40; public static var Insert = 45; public static var Delete = 46; 
		public static var Command = 91; public static var Numpad_star = 106; public static var Numpad_plus = 107; public static var Numpad_minus = 109; 
		public static var Numpad_dot = 110; public static var Numpad_slash = 111; public static var A = 65; public static var B = 66; public static var C = 67; 
		public static var D = 68; public static var E = 69; public static var F = 70; public static var G = 71; public static var H = 72; public static var I = 73; 
		public static var J = 74; public static var K = 75; public static var L = 76; public static var M = 77; public static var N = 78; public static var O = 79; 
		public static var P = 80; public static var Q = 81; public static var R = 82; public static var S = 83; public static var T = 84; public static var U = 85; 
		public static var V = 86; public static var W = 87; public static var X = 88; public static var Y = 89; public static var Z = 90; public static var Zero = 48; 
		public static var One = 49; public static var Two = 50; public static var Three = 51; public static var Four = 52; public static var Five = 53; 
		public static var Six = 54; public static var Seven = 55; public static var Eight = 56; public static var Nine = 57;
	}

//typedef Keycode = { 
	//Right_clic: Int, Backspace : Int, Tab : Int, Enter : Int, Shift : Int, Ctrl : Int, Alt : Int, Caps_lock : Int, Esc : Int, Space : Int, Page_up : Int, Page_down : Int, End : Int,
	//Home : Int, Left : Int, Up : Int, Right : Int, Down : Int, Insert : Int, Delete : Int, Command : Int, Numpad_star : Int, Numpad_plus : Int, Numpad_minus : Int,
	//Numpad_dot : Int, Numpad_slash : Int, A : Int, B : Int, C : Int, D : Int, E : Int, F : Int, G : Int, H : Int, I : Int, J : Int, K : Int, L : Int, M : Int, N : Int,
	//O : Int, P : Int, Q : Int, R : Int, S : Int, T : Int, U : Int, V : Int, W : Int, X : Int, Y : Int, Z : Int, Zero : Int, One : Int, Two : Int, Three : Int, 
	//Four : Int, Five : Int, Six : Int, Seven : Int, Eight : Int, Nine : Int
//}