package managers;
import haxe.Timer;
import js.html.CustomEvent;
import managers.PoolManager.PoolType;
import objects.character.Character;
import objects.character.Player;
import objects.Tile;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;
import utils.Misc;
import utils.TilePoint;

enum StatusModes {
	normal;
	setup;
	fight;
}
	
/**
 * ...
 * @author ToTos
 */
class FightManager {
	public static var status:StatusModes = StatusModes.normal;
	
	private static var instance: FightManager;
	
	private var alliedCharactersID:Array<String> = [];
	private var enemyCharactersID:Array<String> = [];
	
	private var alliedReady:Int = 0;
	private var enemyReady:Int = 0;
	
	
	
	private var setupAlliedTiles:Array<Tile> = [];
	private var setupEnemyTiles:Array<Tile> = [];
	
	private function new() { }
	
	public function startFight(alliesIDS:Array<String>, enemiesID:Array<String>)
	{
		alliedReady = 0;
		enemyReady = 0;
		startSetupPhase(alliesIDS, enemiesID);
		
		
		// wait for ready;
	}
	
	/*
	 * afficher la grid => prendre des tiles de la pool et les sauvegarder
	 * les rendres clicable.
	 * */
	
	private function placeCharactersOnSetupGrid()
	{
		var rangeAvailable = MapManager.getInstance().activeMap.alliedSetupData.copy();

		var newPos:TilePoint;
		for (characterID in alliedCharactersID.iterator())
		{
			newPos = rangeAvailable.splice(Math.floor(Math.random() * rangeAvailable.length), 1)[0];
			CharacterManager.getInstance().findCharacterById(characterID).teleportTo(newPos);
		}
		
		rangeAvailable = MapManager.getInstance().activeMap.enemySetupData.copy();
		for (characterID in enemyCharactersID.iterator())
		{
			newPos = rangeAvailable.splice(Math.floor(Math.random() * rangeAvailable.length), 1)[0];
			CharacterManager.getInstance().findCharacterById(characterID).teleportTo(newPos);
		}
	}
	
	private function showSetupTiles()
	{
		var enemyPoints:Array<TilePoint> = MapManager.getInstance().activeMap.enemySetupData;
		var alliedPoints:Array<TilePoint> = MapManager.getInstance().activeMap.alliedSetupData;
		
		var tempTile:Tile;
		for (point in enemyPoints)
		{
			tempTile = PoolManager.pullObject(PoolType.tileWhite);
			setupEnemyTiles.push(tempTile);
			tempTile.setTilePosition(point.x, point.y);
			tempTile.tint = 0xFF3333;
			tempTile.alpha = 0.7;
			tempTile.visible = true;
			DrawManager.addToDisplay(tempTile, MapManager.getInstance().activeMap.mapContainer);
			tempTile.setZ(0.5);
		}
		
		
		for (point in alliedPoints)
		{
			tempTile = PoolManager.pullObject(PoolType.tileWhite);
			setupAlliedTiles.push(tempTile);
			tempTile.setTilePosition(point.x, point.y);
			tempTile.tint = 0x3333FF;
			tempTile.alpha = 1;
			tempTile.setZ(0.5);
			tempTile.visible = true;
			DrawManager.addToDisplay(tempTile, MapManager.getInstance().activeMap.mapContainer);
		}
		
	}
	
	private function hideSetupTiles()
	{
		for (tile in setupAlliedTiles)
		{
			tile.visible = false;
			DrawManager.removeFromDisplay(tile);
		}
		
		for (tile in setupEnemyTiles)
		{
			tile.visible = false;
			DrawManager.removeFromDisplay(tile);
		}
	}
	
	private function removeNeutralCharactersFromMap()
	{
		for (character in CharacterManager.getInstance().managedCharacters.iterator())
		{
			if (alliedCharactersID.indexOf(character.ID) == -1 && enemyCharactersID.indexOf(character.ID) == -1)
				character.Destroy();
		}
	}
	
	
	private function startSetupPhase(alliesIDS:Array<String>, enemiesID:Array<String>):Void{
		status = StatusModes.setup;
		showSetupTiles();
		
		addAlliedCharacterToSetup(Player.getInstance().ID);
		
		for (i in enemiesID.iterator())
		{
			addEnemyCharacterToSetup(i);
		}
		
		removeNeutralCharactersFromMap();
		placeCharactersOnSetupGrid();
		
		Main.getInstance().tileCont.on("mouseup", movePlayerToSetupTile);
		
		//wait for server timeout
		trace("FIGHT WILL START IN 5 SECONDS");
		Timer.delay(startFightPhase, 5000);
	}
	
	private function movePlayerToSetupTile(e:EventTarget)
	{
		var tileClicked:TilePoint = Misc.getTileFromEvent(e);
		
		for (tile in setupAlliedTiles)
		{
			if (tile.tilePos.equals(tileClicked))
			{
				Player.getInstance().teleportTo(tile.tilePos);
				return;
			}
		}
	}
	
	public function addAlliedCharacterToSetup(alliedID:String):Void{
		// contact server
		CharacterManager.getInstance().findCharacterById(alliedID).generatePosTile(true);
		alliedCharactersID.push(alliedID);
	}
	
	public function addEnemyCharacterToSetup(enemyID:String):Void{
		// contact server
		CharacterManager.getInstance().findCharacterById(enemyID).generatePosTile(false);
		enemyCharactersID.push(enemyID);
	}
	
	public function setEnemyReady(readyState:Bool)
	{
		enemyReady += readyState ? 1 : -1;
	}
	
	public function setAlliedReady(readyState:Bool)
	{
		alliedReady += readyState ? 1 : -1;
	}
	
	private function checkAllCharactersReady()
	{
		if (enemyReady == enemyCharactersID.length && alliedReady == alliedCharactersID.length)
			startFightPhase();
	}
	
	private function startFightPhase():Void {
		if (status == StatusModes.fight)
			return;
			
		Main.getInstance().tileCont.off("mouseup", movePlayerToSetupTile);
		
		hideSetupTiles();	
		trace("FIGHT STARTED");
		status = StatusModes.fight;
	}
	
	@:deprecated("needs to be server side")
	public function testFightOver():Void{
		var numberAlliedDead:Int = 0;
		var numberEnemyDead:Int = 0;
		
		for (i in alliedCharactersID.iterator())
		{
			if (CharacterManager.getInstance().findCharacterById(i) != null)
			{
				if (CharacterManager.getInstance().findCharacterById(i).isDead)
					++numberAlliedDead;
			}
			else
			{
				++numberAlliedDead;
			}
		}
		
		for (i in enemyCharactersID.iterator())
		{
			if (CharacterManager.getInstance().findCharacterById(i) != null)
			{
				if (CharacterManager.getInstance().findCharacterById(i).isDead)
					++numberEnemyDead;
			}
			else
			{
				++numberEnemyDead;
			}
		}
		
		if (numberAlliedDead == alliedCharactersID.length)
			fightEnd(false);
		else if(numberEnemyDead == enemyCharactersID.length)
			fightEnd(true);
	}
	
	
	private function fightEnd(alliedWon:Bool):Void
	{
		status = StatusModes.normal;
		if (alliedWon)
		{
			MapManager.getInstance().activeMap.removeEnemyGroup(enemyCharactersID[0]);
			trace("Allied won, applying callback.");
			for (id in alliedCharactersID)
			{
				CharacterManager.getInstance().findCharacterById(id).onCombatWon();
			}
			for (id in enemyCharactersID)
			{
				CharacterManager.getInstance().findCharacterById(id).onCombatLost();
			}
		}
		else
		{
			trace("Allied Lost, applying callback.");
			
			MapManager.getInstance().activeMap.getEnemyGroupOf(enemyCharactersID[0]).isInFight = false;
			
			for (id in alliedCharactersID)
			{
				CharacterManager.getInstance().findCharacterById(id).onCombatLost();
			}
			for (id in enemyCharactersID)
			{
				CharacterManager.getInstance().findCharacterById(id).onCombatWon();
			}
			
		}
		
		// if player lost change map to respawn point.
		
		/*
		 * repop enemies still alive.
		 * */
		
	}
	
	public function isEnemy(elementId:String):Bool{ return alliedCharactersID.indexOf(elementId) == -1; }
	public function isAllied(elementId:String):Bool{ return alliedCharactersID.indexOf(elementId) != -1; }
	
	
	public static function getInstance (): FightManager {
		if (instance == null) instance = new FightManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}	
}