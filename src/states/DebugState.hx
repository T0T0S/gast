package states;
import js.Browser;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import objects.Camera;
import objects.character.Character;
import objects.State;
import objects.Tile;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Debug;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class DebugState extends State {
	
	private var hoverSprite:Tile;
	private var hero:Character;
	
	public function new() {
		super("Debug");
	}
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		MouseManager.lockedMouseEvents = true;
		MapManager.getInstance().generateMapDisplay("testMapZig", true);
		MapManager.getInstance().activeMap.scrollable = true;
		
		hoverSprite = new Tile(Texture.fromImage("tilehover.png"));
		hoverSprite.setTilePosition([0,0]);
		DrawManager.addToDisplay(hoverSprite, MapManager.getInstance().activeMap.mapContainer,1);
		
		Browser.window.addEventListener("gameHover", mouseHover);
		Browser.window.addEventListener("gameMouseUp", mouseClick);
		
		hero = new Character("hero");
		hero.setTilePosition([13, 30]);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, MapManager.getInstance().activeMap.mapContainer,1);
		
		Camera.getInstance().setFollowTarget(hero);	
	}
	
	public override function Update() {
		MouseManager.lockedMouseEvents = false;
	}
	
	
	private function mouseClick(e):Void {
		if(! e.drag){
			hero.findPathTo(e.tilePos);
			//.followPath(MapManager.getInstance().activeMap.findPath(hero.getPathFindingPoint(), e.tilePos));
		}
	}
	
	private function mouseHover(e):Void {
		hoverSprite.setTilePosition(e.tilePos);
		hoverSprite.setAbsolutePosition(hoverSprite.x, hoverSprite.y - 1);
		if (MapManager.getInstance().activeMap.getWalkableAt(e.tilePos))
			hoverSprite.tint = 0x00FF00;
		else
			hoverSprite.tint = 0xFF0000;
			
		Debug.log("" + e.tilePos);
	}
}