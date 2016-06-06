package managers;
import js.Browser;
import js.html.CustomEvent;
import js.html.Event;
import js.html.svg.Color;
import objects.Camera;
import objects.Tile;
import pixi.core.display.DisplayObject;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.Misc;
import pixi.core.display.Container;
import pixi.interaction.EventTarget;
import pixi.interaction.InteractionData;
import pixi.core.graphics.Graphics;
import utils.TilePoint;

/**
 * ############################################
 * 
 * 					DEPRECATED !
 * 
 * ############################################
 * 
 * Still used by camera to get global mouse events (needs refactoring)
 * 
 * @author ToTos
 */
class MouseManager{
	private static var instance: MouseManager;
	private static var tileSize;
	public static var gamehover:CustomEvent = new CustomEvent("gameHover");
	public static var gameMouseUp:CustomEvent = new CustomEvent("gameMouseUp");
	public static var gameMouseDown:CustomEvent = new CustomEvent("gameMouseDown");
	
	private static var redPoint:Graphics;//optionnel
	
	
	public static var lockedMouseEvents:Bool = false;
	
	var arrayPoints:Array<Array<Float>> = [];
	
	public function new() {
		//Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousedown",mouseDown);
		//Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mouseup",mouseUp);
		//Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousemove",mouseMoveHandler);
		Main.getInstance().tileCont.on("mousedown", mouseDown);
		Main.getInstance().tileCont.on("mouseup", mouseUp);
		Main.getInstance().tileCont.on("mousemove", mouseMoveHandler);
	}
	
	public function mouseMoveHandler (e:EventTarget) {
		if (StateManager.loadingState || lockedMouseEvents)
			return;
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset.x, e.data.global.y + Main.camera.offset.y];
		var tilePos:TilePoint = Misc.convertToGridPosition(clicPoint[0],clicPoint[1]);
		Reflect.setField(gamehover,"layerX",e.data.global.x);
		Reflect.setField(gamehover,"layerY",e.data.global.y);
		Reflect.setField(gamehover,"tilePos",tilePos);
		Reflect.setField(gamehover,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(gamehover);
	}

	public function mouseUp (e:EventTarget):Void {
		//getTilesAround(Misc.convertToGridPosition(e.data.global.x, e.data.global.y, true),0,5);
		if(StateManager.loadingState || lockedMouseEvents)
			return;
		var event = gameMouseUp;
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset.x, e.data.global.y + Main.camera.offset.y];
		Reflect.setField(event,"layerX", e.data.global.x);
		Reflect.setField(event,"layerY", e.data.global.y);
		Reflect.setField(event,"tilePos",Misc.convertToGridPosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(event,"gamePos",clicPoint);
		Reflect.setField(event,"drag",Camera.getInstance().isDragged);
		//createLilCubes([convertClicToTilePosition(clicPoint[0], clicPoint[1])]);
		
		Browser.window.dispatchEvent(event);

		//trace(""+arrayPoints);
	}
	
	public function mouseDown (e:EventTarget):Void {
		if(StateManager.loadingState || lockedMouseEvents)
			return;
		var event = gameMouseDown;
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset.x, e.data.global.y + Main.camera.offset.y];
		//var clicPoint:Array<Float> = [untyped e.layerX + Main.camera.offset.x, untyped e.layerY + Main.camera.offset.y];
		Reflect.setField(event,"layerX", e.data.global.x);
		Reflect.setField(event,"layerY", e.data.global.y);
		Reflect.setField(event,"tilePos",Misc.convertToGridPosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(event,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(event);
	}
	
	public static function getInstance (): MouseManager {
		if (instance == null) instance = new MouseManager();
		return instance;
	}
	
}