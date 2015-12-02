package states;
import js.Browser;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import objects.Camera;
import objects.character.Character;
import objects.State;
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
	
	private var hoverSprite:Sprite;
	private var hero:Character;
	
	public function new() {
		super("Debug");
	}
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		MapManager.getInstance().generateMapDisplay("testMapZig", true);
		MapManager.getInstance().activeMap.scrollable = true;
		
		hoverSprite = new Sprite(Texture.fromImage("tilehover.png"));
		hoverSprite.x = -1000;
		hoverSprite.y = -1000;
		hoverSprite.anchor.set(0.5, 1);
		DrawManager.addToDisplay(hoverSprite, MapManager.getInstance().activeMap.mapContainer,1);
		
		Browser.window.addEventListener("gameHover", mouseHover);
		Browser.window.addEventListener("gameMouseUp", mouseClick);
		
		hero = new Character("hero");
		hero.setTilePosition([13, 30]);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, Main.getInstance().tileCont);
		
		Camera.getInstance().setFollowTarget(hero);	
	}
	
	public override function Update() {
	}
	
	
	private function mouseClick(e):Void {
		if(! e.drag){
			hero.setDirection(Misc.getDirectionToPoint(hero.tilePos, e.tilePos));
			hero.followPath(MapManager.getInstance().activeMap.findPath([hero.tilePos[0],hero.tilePos[1]],e.tilePos));
			MouseManager.getSquareTileAround(e.tilePos, 2);
			//Debug.log(Misc.angleBetweenTiles(hero.tilePos, e.tilePos));
		}
	}
	
	private function mouseHover(e):Void {
		hoverSprite.x = Misc.convertToAbsolutePosition(e.tilePos)[0];
		hoverSprite.y = Misc.convertToAbsolutePosition(e.tilePos)[1];
		if (MapManager.getInstance().activeMap.getWalkableAt(e.tilePos))
			hoverSprite.tint = 0x00FF00;
		else
			hoverSprite.tint = 0xFF0000;
			
		Debug.log("" + e.tilePos);
	}
}