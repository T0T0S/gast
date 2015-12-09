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

/**
 * ...
 * @author ToTos
 */
class MouseManager{
	private static var instance: MouseManager;
	private static var tileSize;
	public static var gamehover:CustomEvent = new CustomEvent("gameHover");
	public static var gameMouseUp:CustomEvent = new CustomEvent("gameMouseUp");
	public static var gameMouseDown:CustomEvent = new CustomEvent("gameMouseDown");
	
	public var calledPerFrame:Int = 0;
	private var refreshPerFrame:Int = 1;
	
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
	
	public function mouseMoveHandler (e:EventTarget){
		if (calledPerFrame > refreshPerFrame || StateManager.loadingState || lockedMouseEvents)
			return;
		
		++calledPerFrame;
		
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset[0], e.data.global.y + Main.camera.offset[1]];
		var tilePos:Array<Int> = Misc.convertToGridPosition(clicPoint[0],clicPoint[1]);
		Reflect.setField(gamehover,"layerX",e.data.global.x);
		Reflect.setField(gamehover,"layerY",e.data.global.y);
		Reflect.setField(gamehover,"tilePos",tilePos);
		Reflect.setField(gamehover,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(gamehover);
	}

	public function mouseUp (e:EventTarget):Void {
		//getRangeTileAround(Misc.convertToGridPosition(e.data.global.x, e.data.global.y, true),0,5);
		if(StateManager.loadingState || lockedMouseEvents)
			return;
		var event = gameMouseUp;
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset[0], e.data.global.y + Main.camera.offset[1]];
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
		var clicPoint:Array<Float> = [e.data.global.x + Main.camera.offset[0], e.data.global.y + Main.camera.offset[1]];
		//var clicPoint:Array<Float> = [untyped e.layerX + Main.camera.offset[0], untyped e.layerY + Main.camera.offset[1]];
		Reflect.setField(event,"layerX", e.data.global.x);
		Reflect.setField(event,"layerY", e.data.global.y);
		Reflect.setField(event,"tilePos",Misc.convertToGridPosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(event,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(event);
	}
	
	// A REFAIRE !
	public static function getSquareTileAround(posClicked:Array<Int>, size:Int = 1):Array<Array<Int>> {
		if (size == 0)
			return [posClicked];
		
		var ArrayOfPos:Array<Array<Int>> = [];
		var tileSize:Array<Int> = cast Main.tileSize;
		var GridAround:Array<Array<Int>> = [];
		var iter:IntIterator = new IntIterator(Math.floor(-size),Math.floor(1 + size));
		for (i in iter) {
			var iter2:IntIterator = new IntIterator(- size *2,size * 4);
			for (j in iter2) {
				GridAround.push([posClicked[0] + i, posClicked[1] - j]);
			}
		}
		//createLilCubes(cast GridAround,0x0000FF);
		
		var centerPosition:Array<Float> = cast posClicked;	
		ArrayOfPos.push(cast [centerPosition[0], centerPosition[1]]);
		
		//if (size % 2 == 0){
			//centerPosition[0] += centerPosition[1] % 2 == 1 ? 0.5 : -0.5;
		//}
		
		var dx:Float;
		var dy:Float;
		var centerAbsolutePos:Array<Float> = Misc.convertToAbsolutePosition(cast centerPosition);
		for (i in GridAround.iterator()) {
			var absolutePosPoint = Misc.convertToAbsolutePosition(i);
			dx = (centerAbsolutePos[0] - absolutePosPoint[0]) / tileSize[0];
			dy = (centerAbsolutePos[1] - absolutePosPoint[1]) / tileSize[1];
			if (Math.abs(dx) + Math.abs(dy) <= (size) && ArrayOfPos.indexOf(i) == -1)
				ArrayOfPos.push(i);
		}
		//createLilCubes(cast ArrayOfPos,0xFFFF00);
		return ArrayOfPos;
	}
	
	public static function createLilCubes (position:Array<Array<Float>>, ?color:Int):Dynamic {
	
		var iter:IntIterator = new IntIterator(0,position.length);
		var tileSize = Main.tileSize;
		var redPoint;
		for (i in iter) {
			var displayX:Float = position[i][0] * tileSize[0] -1;
			var displayY:Float = position[i][1] * tileSize[1] / 2 -1;
			if (Math.abs(position[i][1] % 2) == 1)
				displayX += tileSize[0] * 0.5;
			displayY += tileSize[1] * 0.5;
			redPoint = new Graphics();
			var specialColor = color != null ? color: 0x00FF00;
			redPoint.lineStyle(1, specialColor);
			redPoint.beginFill(0xFF0000);
			redPoint.drawRect(-1, - 1, 3, 3);
			redPoint.endFill();
			redPoint.y = displayY - 1;
			redPoint.x = displayX - 1;
			//Main.getInstance().tileCont.addChild(redPoint);
			//Main.getInstance().tileCont.setChildIndex(redPoint,Main.getInstance().tileCont.children.length-1);
			DrawManager.addToDisplay(redPoint, Main.getInstance().tileCont, 100);
		}
		return redPoint;
	}

	public static function getInstance (): MouseManager {
		if (instance == null) instance = new MouseManager();
		return instance;
	}
	
}