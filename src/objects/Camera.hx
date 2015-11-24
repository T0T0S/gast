package objects;
import js.Browser;
import managers.InitManager;
import managers.MapManager;
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
	public var size:Array<Float> = [0, 0];
	
	public var minimumMovement:Float = 10;
	public var dragSensitivity:Float = 2;
	
	private var mouseDownPosition:Array<Float> = [];
	private var oldCameraPosition:Array<Float> = [];
	private var clicked:Bool = false;
	public var hasMovedEnough:Bool = false;
	private var configTileSize:Array<Int>;
	
	public var mapSize:Rectangle;
	
	
	/*
	 * initialisation des events receivers et variables de la cam
	 */
	public function new() {
		configTileSize = InitManager.data.config.tileSize;
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
		mouseDownPosition = [e.layerX, e.layerY];
		oldCameraPosition = offset;
	}
	
/*
 * 1 - ne fait rien si on n'a pas clické ou si on clic en dehors du canvas du jeu
 * 2 - check si on a bougé la souris un minimum avant de bouger la caméra
 * 3 - change l'offset de la caméra pour "suivre la souris" et clamp les valeurs pour qu'elle reste sur le terrain
 * */
	private function mouseMoveListener (e):Void {
		if(!MapManager.getInstance().activeMap.scrollable)
			return;
		if (!clicked)
			return;
		if (hasMovedEnough == false && Math.abs(mouseDownPosition[0] - e.layerX) < minimumMovement && Math.abs(mouseDownPosition[1] - e.layerY) < minimumMovement)
			return;
		else if(!hasMovedEnough){
			mouseDownPosition[0] = e.layerX;
			mouseDownPosition[1] = e.layerY;
		}
		hasMovedEnough = true;
		
		offset = [oldCameraPosition[0] - (e.layerX - mouseDownPosition[0]) * dragSensitivity, oldCameraPosition[1] - (e.layerY - mouseDownPosition[1])*dragSensitivity];
		
		offset[0] = Misc.clamp(offset[0],0,Math.max(mapSize.width - size[0],0));
		offset[1] = Misc.clamp(offset[1],0,Math.max(mapSize.height - size[1],0));
		
		translateOffsetToConts();
	}

	private function mouseUpListener (e):Void {
		clicked = false;
		hasMovedEnough = false;
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
		mapSize.width = newMap.graphicalData.length * InitManager.data.config.tileSize[0];
		mapSize.height = newMap.graphicalData[0].length * InitManager.data.config.tileSize[1] * 0.5;
	}
	
	public function switchState ():Void {
		setCameraPosition([0,0]);
	}
		
	public static function getInstance (): Camera {
		if (instance == null) instance = new Camera();
		return instance;
	}
	
}