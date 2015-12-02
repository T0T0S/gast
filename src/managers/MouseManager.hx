package managers;
import js.Browser;
import js.html.CustomEvent;
import js.html.Event;
import js.html.svg.Color;
import objects.Camera;
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
	private static var redPoint:Graphics;//optionnel
	public static var gamehover:CustomEvent = new CustomEvent("gameHover");
	public static var gameMouseUp:CustomEvent = new CustomEvent("gameMouseUp");
	public static var gameMouseDown:CustomEvent = new CustomEvent("gameMouseDown");
	
	public var calledPerFrame:Int = 0;
	private var refreshPerFrame:Int = 1;
	
	var arrayPoints:Array<Array<Float>> = [];
	
	public function new() {
		Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousedown",mouseDown);
		Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mouseup",mouseUp);
		Browser.window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousemove",mouseMoveHandler);
	}
	
	public function mouseMoveHandler (e){
		if (calledPerFrame > refreshPerFrame)
			return;
		
		++calledPerFrame;
		
		var clicPoint:Array<Float> = [e.layerX + Main.camera.offset[0], e.layerY + Main.camera.offset[1]];
		Reflect.setField(gamehover,"layerX",e.layerX);
		Reflect.setField(gamehover,"layerY",e.layerY);
		Reflect.setField(gamehover,"tilePos",convertClicToTilePosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(gamehover,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(gamehover);
	}

	public function mouseUp (e:Event):Void {
		var event = gameMouseUp;
		var clicPoint:Array<Float> = [untyped e.layerX + Main.camera.offset[0], untyped e.layerY + Main.camera.offset[1]];

		Reflect.setField(event,"layerX",untyped e.layerX);
		Reflect.setField(event,"layerY",untyped e.layerY);
		Reflect.setField(event,"tilePos",convertClicToTilePosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(event,"gamePos",clicPoint);
		Reflect.setField(event,"drag",Camera.getInstance().hasMovedEnough);

		//createLilCubes([convertClicToTilePosition(clicPoint[0], clicPoint[1])]);
		
		//var contChildren:Array<Sprite>;
		//var conts:Array<Container> = cast Main.getInstance().fullStage.children;
		//var needOffsetCamera:Int = conts.length;
		//
		//var i:Int = conts.length - 1;
		//var j:Int = 0;
		//while (i >= 0)
		//{
			//contChildren = untyped conts[i].children;
			//j = contChildren.length - 1;
			//while (j >= 0)
			//{
				//if (contChildren[j] != null)
					//if(contChildren[j].anchor != null)
						//if (Misc.colliSquarePoint(cast contChildren[j], clicPoint, --needOffsetCamera < 2 )) 
						//{
							//Reflect.setField(event, "element", contChildren[j]);
							//Browser.window.dispatchEvent(event);
							//e.stopPropagation();
							//return;
						//}
				//--j;
			//}
			//i--;
		//}
		//
		//Reflect.setField(event,"element", null);

		Browser.window.dispatchEvent(event);

		//trace(""+arrayPoints);
	}
	
	public function mouseDown (e:Event):Void {
		var event = gameMouseDown;
		var clicPoint:Array<Float> = [untyped e.layerX + Main.camera.offset[0], untyped e.layerY + Main.camera.offset[1]];
		Reflect.setField(event,"layerX",untyped e.layerX);
		Reflect.setField(event,"layerY",untyped e.layerY);
		Reflect.setField(event,"tilePos",convertClicToTilePosition(clicPoint[0],clicPoint[1]));
		Reflect.setField(event,"gamePos",clicPoint);
		
		Browser.window.dispatchEvent(event);
	}
	
	// fonction de detection de tile clické, c'est sure a 99% qu'il y a plus simple mais ça passe et ça consomme pas trop vu que ya que des calculs simples.
	public static function convertClicToTilePosition(absoluteX:Float,absoluteY:Float):Array<Float> {
		var tileSize = InitManager.data.config.tileSize;
		var halfMousePosX:Float = Math.floor((absoluteX) / (tileSize[0]/2))/2;
		var halfMousePosY:Float = Math.floor((absoluteY) / (tileSize[1] / 2)) / 2;
		
		if (halfMousePosX % 1 != 0)
			halfMousePosX += 0.5;
		if (halfMousePosY % 1 != 0)
			halfMousePosY += 0.5;

		var dx = (absoluteX - halfMousePosX * tileSize[0]) / tileSize[0]*2;
		var dy = (absoluteY - halfMousePosY * tileSize[1]) / tileSize[1] *2;
		var SelectedPos:Array<Float> = (Math.abs(dx)+ Math.abs(dy) <= 1) ? [halfMousePosX, halfMousePosY] : [halfMousePosX + ((dx / Math.abs(dx)) * 0.5), halfMousePosY + ((dy / Math.abs(dy))*0.5)]; 
		SelectedPos[0] = Math.floor(SelectedPos[0]);
		SelectedPos[1] *= 2;
		
//		trace(SelectedPos);
		return SelectedPos;
	}
	
	
	// A REFAIRE !
	public static function getSquareTileAbove(posClicked:Array<Int>,size:Array<Int>):Array<Array<Int>> {
		var ArrayOfPos:Array<Array<Int>> = [];
		var height:Int = (size[0]-1) * 2;		
		var tileSize:Array<Int> = [64,32];
		var GridAround:Array<Array<Int>> = [];
		var iter:IntIterator = new IntIterator(Math.floor(-height * 0.5),Math.floor(1 + height * 0.5));
		for (i in iter) {
			var iter2:IntIterator = new IntIterator(- height,height * 2);
			for (j in iter2) {
				GridAround.push([posClicked[0] + i, posClicked[1] - j]);
			}
		}
		//createLilCubes(cast GridAround,0x0000FF);
		
		var centerPosition:Array<Float> = cast posClicked;	
		ArrayOfPos.push(cast [centerPosition[0], centerPosition[1]]);
		
		if (size[0] % 2 == 0){
			centerPosition[0] += centerPosition[1] % 2 == 1 ? 0.5 : -0.5;
		}
		centerPosition[1] += size[1];
		var dx:Float;
		var dy:Float;
		var centerAbsolutePos:Array<Float> = Misc.convertToAbsolutePosition(cast centerPosition);
		for (i in GridAround.iterator()) {
			var absolutePosPoint = Misc.convertToAbsolutePosition(i);
			dx = (centerAbsolutePos[0] - absolutePosPoint[0]) / tileSize[0];
			dy = (centerAbsolutePos[1] - absolutePosPoint[1]) / tileSize[1];
			if (Math.abs(dx) + Math.abs(dy) <= 0.5 * (size[0] -1) && ArrayOfPos.indexOf(i) == -1)
				ArrayOfPos.push(i);
		}
		//createLilCubes(cast ArrayOfPos,0xFFFF00);
		return ArrayOfPos;
	}
	
	public static function createLilCubes (position:Array<Array<Float>>, ?color:Int):Void {
	
		var iter:IntIterator = new IntIterator(0,position.length);
		var tileSize = InitManager.data.config.tileSize;
		for (i in iter) {
			var displayX:Float = position[i][0] * tileSize[0] -1;
			var displayY:Float = position[i][1] * tileSize[1] / 2 -1;
			if (Math.abs(position[i][1] % 2) == 1)
				displayX += tileSize[0] * 0.5;
			displayY += tileSize[1] * 0.5;
			var redPoint = new Graphics();
			var specialColor = color != null ? color: 0x00FF00;
			redPoint.lineStyle(1, specialColor);
			redPoint.beginFill(0xFF0000);
			redPoint.drawRect(-1, - 1, 3, 3);
			redPoint.endFill();
			redPoint.y = displayY - 1;
			redPoint.x = displayX - 1;
			//Main.getInstance().tileCont.addChild(redPoint);
			//Main.getInstance().tileCont.setChildIndex(redPoint,Main.getInstance().tileCont.children.length-1);
			DrawManager.addToDisplay(redPoint,Main.getInstance().tileCont,100);
		}
	}
	
	public static function displayMap (nodes:Array<Array<Int>>):Void {
		for(x in Reflect.fields(nodes)){
	untyped for(y in Reflect.fields(nodes[x])){
	untyped		if (nodes[x][y] < 2)
				{
		 	untyped	MouseManager.createLilCubes([[cast x,cast y]], 0x0000FF);
				}
				else{
		 	untyped	MouseManager.createLilCubes([[cast x,cast y]], 0xFF0000);
				}
			}
		}
	}
	
	
	public static function getInstance (): MouseManager {
		if (instance == null) instance = new MouseManager();
		return instance;
	}
	
}