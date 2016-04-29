package objects;
import js.Browser;
import managers.HudManager;
import pixi.core.math.Point;
import managers.InitManager;
import managers.MapManager;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import utils.Misc;

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
	public var isDragged:Bool = false;
	
	public static var targetToFollow:DisplayObject;
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
		isDragged = false;
	}
	
	public function setCameraPosition (newPosition:Point):Void {
		offset = newPosition;
		translateOffsetToConts();
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
		mapSize.width = newMap.graphicalData[0].length * Main.tileSize.x;
		mapSize.height = newMap.graphicalData.length * Main.tileSize.y * 0.5 + Main.getInstance().hudCont.height;
	}
	
	public function Update():Void
	{
		if (targetToFollow != null)
		{
			offset.x = targetToFollow.x - size.x * 0.5;
			offset.y = targetToFollow.y - size.y * 0.5;

			if (clampedCam)
				constrainCam();
			translateOffsetToConts();
		}
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
	
	public function switchState ():Void {
		setCameraPosition(new Point(0,0));
		targetToFollow = null;
	}
		
	public static function getInstance (): Camera {
		if (instance == null) instance = new Camera();
		return instance;
	}
	
}