package objects;
import js.Browser;
import managers.HudManager;
import pixi.core.math.Point;
import managers.InitManager;
import managers.MapManager;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */


/*
 * penser a faire le clipping
 * */
class Camera{
	private static var instance: Camera;
	
	public var offset:Point = new Point();
	private var size:Point = new Point();
	
	private var minimumMovement:Float = 10;
	private var dragSensitivity:Float = 2;
	
	private var mouseDownPosition:Point = new Point();
	private var oldCameraPosition:Point = new Point();
	private var clicked:Bool = false;
	private var mouseUpDelay:Int = 0;
	public var isDragged:Bool = false;
	
	public var targetToFollow:DisplayObject;
	private var clampedCam:Bool = false;
	
	public var mapSize:Rectangle;
	
	
	/*
	 * initialisation des events receivers et variables de la cam
	 */
	public function new() {
		minimumMovement = Reflect.field(InitManager.data.config.camera, "minimumMovement");
		dragSensitivity = Reflect.field(InitManager.data.config.camera, "sensitivity");
		Browser.window.addEventListener("gameMouseDown", mouseDownListener);
		Browser.window.addEventListener("gameHover", mouseMoveListener);
		Browser.window.addEventListener("gameMouseUp", mouseUpListener);
		Browser.window.addEventListener("resize", getContainerBounds);		
		getContainerBounds();
		
		mapSize = Main.getInstance().fullStage.getBounds();
	}

	private function mouseDownListener(e):Void {
		clicked = true;
		mouseDownPosition.x = e.layerX;
		mouseDownPosition.y = e.layerY;
		oldCameraPosition = offset.clone();
	}
	
/*
 * 1 - ne fait rien si on n'a pas clické ou si on clic en dehors du canvas du jeu
 * 2 - check si on a bougé la souris un minimum avant de bouger la caméra
 * 3 - change l'offset de la caméra pour "suivre la souris" et clamp les valeurs pour qu'elle reste sur le terrain
 * */
	private function mouseMoveListener (e):Void {
		if (MapManager.getInstance().activeMap == null)
			return;
		if(!MapManager.getInstance().activeMap.scrollable || targetToFollow != null)
			return;
		if (!clicked)
			return;
		if (isDragged == false && Math.abs(mouseDownPosition.x - e.layerX) < minimumMovement && Math.abs(mouseDownPosition.y - e.layerY) < minimumMovement)
			return;
		else if(!isDragged){
			mouseDownPosition.x = e.layerX;
			mouseDownPosition.y = e.layerY;
		}
		isDragged = true;
		
		offset.x = oldCameraPosition.x - (e.layerX - mouseDownPosition.x) * dragSensitivity;
		offset.y = oldCameraPosition.y - (e.layerY - mouseDownPosition.y) * dragSensitivity;

		if (clampedCam)
		{
			constrainCam();
		}
		
		translateOffsetToConts();
	}

	private function mouseUpListener (e):Void {
		clicked = false;
		mouseUpDelay = 1;
	}
	
	public function translateOffsetToConts():Void {
		Main.getInstance().tileCont.x = -offset.x;
		Main.getInstance().tileCont.y = -offset.y;
		Main.getInstance().gameCont.x = -offset.x;
		Main.getInstance().gameCont.y = -offset.y;
	}
	
	public function getContainerBounds (?e):Void {
		size.x = Main.getInstance().renderer.width;
		size.y = Main.getInstance().renderer.height;
	}
	
	public function updateMapSize(newMap:GameMap):Void{
		mapSize.width = newMap.size.x * Main.tileSize.x;
		mapSize.height = newMap.size.y * Main.tileSize.y * 0.5 + Main.getInstance().hudCont.height;
	}
	
	public function Update():Void
	{
		if (!clicked)
		{
			--mouseUpDelay;
			isDragged = mouseUpDelay <= 0 ? false : isDragged;
		}
		
		if (targetToFollow != null)
		{
			offset.x = targetToFollow.x - size.x * 0.5;
			offset.y = targetToFollow.y - size.y * 0.5;
		}
		
		if (clampedCam)
				constrainCam();
				
		translateOffsetToConts();
	}
	
	private function constrainCam():Void{
		offset.x = Misc.clamp(offset.x, - mapSize.width * 0.5, mapSize.width * 0.5 - size.x);
		offset.y = Misc.clamp(offset.y, - mapSize.height * 0.5 + size.y * 0.5,mapSize.height * 0.5 - Main.tileSize.y * 1.5 + Main.getInstance().hudCont.height);
	}
	
	public function clampCam():Void { clampedCam = true; }
	public function unClampCam():Void { clampedCam = false; }
	
	public function setFollowTarget(target:DisplayObject, absolutePos:Bool = false)
	{
		targetToFollow = target;
		clampedCam = !absolutePos;
	}
	
	public static function focusOnPosition(position:TilePoint)
	{
		instance.targetToFollow = null;
		var tempPoint = Misc.convertToAbsolutePosition(position);
		instance.offset.x = tempPoint.x - instance.size.x * 0.5;
		instance.offset.y = tempPoint.y - instance.size.y * 0.5;
		instance.translateOffsetToConts();
	}
	
	public function switchState ():Void 
	{
		focusOnPosition(new TilePoint(0,0));
		targetToFollow = null;
	}
		
	public static function getInstance (): Camera {
		if (instance == null) instance = new Camera();
		return instance;
	}
	
}