package objects;
import js.Browser;
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
	
	public var offset:Array<Float> = [0, 0];
	private var size:Array<Float> = [0, 0];
	
	private var minimumMovement:Float = 10;
	private var dragSensitivity:Float = 2;
	
	private var mouseDownPosition:Array<Float> = [];
	private var oldCameraPosition:Array<Float> = [];
	private var clicked:Bool = false;
	public var isDragged:Bool = false;
	
	public static var targetToFollow:DisplayObject;
	private var clampedCam:Bool = true;
	
	public var mapSize:Rectangle;
	
	
	/*
	 * initialisation des events receivers et variables de la cam
	 */
	public function new() {
		minimumMovement = Reflect.field(InitManager.data.config.camera, "minimumMovement");
		dragSensitivity = Reflect.field(InitManager.data.config.camera, "sensitivity");
		//Browser.window.addEventListener("gameMouseDown", mouseDownListener);
		//Browser.window.addEventListener("gameHover", mouseMoveListener);
		//Browser.window.addEventListener("gameMouseUp", mouseUpListener);
		Browser.window.addEventListener("resize", getContainerBounds);		
		getContainerBounds();
		
		mapSize = Main.getInstance().fullStage.getBounds();
	}

	private function mouseDownListener(e):Void {
		clicked = true;
		mouseDownPosition = [e.layerX, e.layerY];
		oldCameraPosition = offset;
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
		if (isDragged == false && Math.abs(mouseDownPosition[0] - e.layerX) < minimumMovement && Math.abs(mouseDownPosition[1] - e.layerY) < minimumMovement)
			return;
		else if(!isDragged){
			mouseDownPosition[0] = e.layerX;
			mouseDownPosition[1] = e.layerY;
		}
		isDragged = true;
		
		offset = [oldCameraPosition[0] - (e.layerX - mouseDownPosition[0]) * dragSensitivity, oldCameraPosition[1] - (e.layerY - mouseDownPosition[1])*dragSensitivity];
		
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
	
	public function setCameraPosition (newPosition:Array<Float>):Void {
		offset = newPosition;
		translateOffsetToConts();
	}
	
	public function translateOffsetToConts():Void {
		Main.getInstance().tileCont.x = -offset[0];
		Main.getInstance().tileCont.y = -offset[1];
		Main.getInstance().gameCont.x = -offset[0];
		Main.getInstance().gameCont.y = -offset[1];
	}
	
	public function getContainerBounds (?e):Void {
		size = [Main.getInstance().renderer.width, Main.getInstance().renderer.height];
	}
	
	public function updateMapSize(newMap:GameMap):Void{
		mapSize.width = newMap.graphicalData[0].length * Main.tileSize[0];
		mapSize.height = newMap.graphicalData.length * Main.tileSize[1] * 0.5 + Main.getInstance().hudCont.height;
	}
	
	public function Update():Void
	{
		if (targetToFollow != null)
		{
			offset[0] = targetToFollow.x - size[0] * 0.5;
			offset[1] = targetToFollow.y - size[1] * 0.5;
			if (clampedCam)
				constrainCam();
			translateOffsetToConts();
		}
	}
	
	private function constrainCam():Void{
		offset[0] = Misc.clamp(offset[0],0,Math.max(mapSize.width - size[0] - Main.tileSize[0],0));
		offset[1] = Misc.clamp(offset[1],0,Math.max(mapSize.height - size[1] - Main.tileSize[1] * 1.5,0));
	}
	
	public function clampCam():Void { clampedCam = true; }
	public function unClampCam():Void { clampedCam = false; }
	
	public function setFollowTarget(target:DisplayObject, absolutePos:Bool = false)
	{
		targetToFollow = target;
		clampedCam = !absolutePos;
	}
	
	public function switchState ():Void {
		setCameraPosition([0, 0]);
		targetToFollow = null;
	}
		
	public static function getInstance (): Camera {
		if (instance == null) instance = new Camera();
		return instance;
	}
	
}