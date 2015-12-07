package states;
import js.Browser;
import managers.DrawManager;
import managers.HudManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import objects.Camera;
import objects.character.Character;
import objects.character.Player;
import objects.State;
import objects.Tile;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import pixi.interaction.EventTarget;
import utils.Debug;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class DebugState extends State {
	
	private var hoverSprite:Tile;
	private var hero:Player;
	
	public function new() {
		super("Debug");
	}
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		Main.FIGHTMODE = true;
		HudManager.generateFightHud();
	
		MapManager.getInstance().generateMapDisplay("testMapZig", true);
		
		//hoverSprite = new Tile(Texture.fromImage("tilehover.png"));
		//hoverSprite.setTilePosition([0,0]);
		//DrawManager.addToDisplay(hoverSprite, MapManager.getInstance().activeMap.mapContainer,1);
		
		hero = new Player("hero");
		hero.setTilePosition([13, 30]);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, MapManager.getInstance().activeMap.mapContainer,1);
		
		Camera.getInstance().setFollowTarget(hero);	
		var camShader:Sprite = new Sprite(Texture.fromImage("camShader.png"));
		camShader.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		
		DrawManager.addToDisplay(camShader, Main.getInstance().effectCont);
	}
	
	public override function Update() {
		
	}
}