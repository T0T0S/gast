package states;
import js.Browser;
import managers.DrawManager;
import managers.HudManager;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import managers.PoolManager;
import objects.Camera;
import objects.character.Character;
import objects.character.Player;
import objects.character.Pnj;
import objects.character.Victim;
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
	
	public function new() {
		super("Debug");
	}
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		Main.FIGHTMODE = true;
		HudManager.getInstance().generateFightHud();
		
		var camShader:Sprite = new Sprite(Texture.fromImage("camShader.png"));
		camShader.scale.set(Main.screenRatio[0], Main.screenRatio[1]);
		DrawManager.addToDisplay(camShader, Main.getInstance().effectCont);
		
		MapManager.getInstance().generateMapDisplay("testMapZig", true);

		
		//hoverSprite = new Tile(Texture.fromImage("tilehover.png"));
		//hoverSprite.setTilePosition([0,0]);
		//DrawManager.addToDisplay(hoverSprite, MapManager.getInstance().activeMap.mapContainer,1);
		
		var hero:Player = Player.getInstance();
		hero.setTilePosition([13, 30]);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, MapManager.getInstance().activeMap.mapContainer,1);
		
		Camera.getInstance().setFollowTarget(hero);	
		
		var victim:Victim = new Victim("victim");
		victim.setTilePosition([10, 24]);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer,1);
		

	}
	
	public override function Update() {
		
	}
}