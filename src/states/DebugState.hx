package states;
import js.Browser;
import managers.DrawManager;
import managers.InitManager;
import managers.MapManager;
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
		hero.setTilePosition([10, 10]);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, Main.getInstance().gameCont);
		
		
		MapManager.getInstance().activeMap.InitPathfinding();
	}
	
	public override function Update() {
	}
	
	
	private function mouseClick(e):Void {
		if(! e.drag){
			hero.setDirection(Misc.convertAngleToDirection(Misc.angleBetweenTiles(hero.tilePos, e.tilePos)));
			//Debug.log(Misc.angleBetweenTiles(hero.tilePos, e.tilePos));
		}
	}
	
	private function mouseHover(e):Void {
		hoverSprite.x = Misc.convertToAbsolutePosition(e.tilePos)[0];
		hoverSprite.y = Misc.convertToAbsolutePosition(e.tilePos)[1];
		Debug.log("" + e.tilePos);
	}
}