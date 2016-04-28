package states;

import js.Browser;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.MapManager;
import managers.PoolManager;
import managers.TimeManager;
import objects.Camera;
import objects.character.Player;
import objects.character.Victim;
import objects.modules.LOSModule;
import objects.State;
import objects.Tile;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.Debug;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class DiamondTestState extends State{

	public function new() {
		super("Diam");
		
	}
	
	
	override public function Start():Void {
		HudManager.getInstance().generateFightHud();
	
		MapManager.getInstance().generateMapDisplay("DiamondMap", true);
		MapManager.getInstance().activeMap.scrollable = true;
		Main.camera.setCameraPosition(new Point(-MapManager.getInstance().activeMap.mapContainer.width * 0.25,0));
		
		var losModule:LOSModule =  new LOSModule();
		losModule.setRange(0, 10);
		
		/*
		 * integrer le joueur
		 * */
		var hero:Player = Player.getInstance();
		hero.setTilePosition(8, 8);
		hero.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(hero, MapManager.getInstance().activeMap.mapContainer,1);
		
		Camera.getInstance().setFollowTarget(hero);	
		
		var targetsID:Array<String> = [];
		
		var victim:Victim = new Victim("victim");
		victim.setTilePosition(13, 15);
		victim.scale.set(0.4, 0.4);
		DrawManager.addToDisplay(victim, MapManager.getInstance().activeMap.mapContainer, 1);
		targetsID.push(victim.ID);
		
		FightManager.getInstance().startSetup(targetsID);
	}
}

/*
 * TODO:
 * character
 * pathfinding
 * los
 * 
 * 
 * */