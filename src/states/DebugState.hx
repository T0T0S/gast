package states;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.MapManager;
import objects.Camera;
import objects.character.Character;
import objects.character.Player;
import objects.character.Victim;
import objects.State;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class DebugState extends State {
	
	public function new() {
		super("Debug");
	}
		
	public static var superEnemy:Character;
		
	public override function Preload():Void {
		
	
	}
	public override function Start() {
		HudManager.getInstance().generateFightHud();
		
		var camShader:Sprite = new Sprite(Texture.fromImage("camShader.png"));
		camShader.scale.set(Main.screenRatio.x, Main.screenRatio.y);
		DrawManager.addToDisplay(camShader, Main.getInstance().effectCont);
		
		MapManager.getInstance().generateMapDisplay("TestingMap", true);

		
		//hoverSprite = new Tile(Texture.fromImage("tilehover.png"));
		//hoverSprite.setTilePosition([0,0]);
		//DrawManager.addToDisplay(hoverSprite, MapManager.getInstance().activeMap.mapContainer,1);
		
		var hero:Player = Player.getInstance();
		hero.setTilePosition(8, 50);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, MapManager.getInstance().activeMap.mapContainer,1);
		
		Camera.getInstance().setFollowTarget(hero);	
		
		var targetsID:Array<String> = [];
		
		var victim:Victim = new Victim("victim");
		victim.setTilePosition(10, 64);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		targetsID.push(victim.ID);
		
		victim = new Victim("victim");
		victim.setTilePosition(5, 25);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		targetsID.push(victim.ID);
		
		victim = new Victim("victim");
		victim.setTilePosition(9, 29);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		targetsID.push(victim.ID);
		
		victim = new Victim("victim");
		victim.setTilePosition(13, 34);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		targetsID.push(victim.ID);
		
		victim = new Victim("victim");
		victim.setTilePosition(17, 40);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		superEnemy = victim;
		targetsID.push(victim.ID);
		
		//FightManager.getInstance().startFight(targetsID);
	
	}
	
	public override function Update() {
		
	}
}