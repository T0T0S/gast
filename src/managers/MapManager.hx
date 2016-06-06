package managers;
import js.Browser;
import js.Error;
import objects.character.BaseEnemy;
import objects.character.Character;
import objects.GameMap;
import objects.modules.LOSModule.LOSPoint;
import objects.Tile;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import tweenx909.advanced.GroupX;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class MapManager{
	private static var instance: MapManager;
	
	public var activeMap:GameMap;
	
	private var mapSpriteSheet:Sprite;
	
	public var maps:Map<String,GameMap> = new Map.Map();

	private function new() {
		activeMap = new GameMap(); //Phantom Map (prevents bugs)
	}
	
	public function Init()
	{
		loadNewMap("map_diamondIso");
	}
	
	private function loadNewMap(mapName:String)
	{
		maps.set(mapName, new GameMap(mapName));
	}
	
	public function generateMapDisplay(mapName:String, select:Bool = false):Void {
		var newMap = maps.get(mapName);
		
		var i:Int = 0;
		var j:Int = 0;
		for (arrayY in newMap.graphicalData.iterator()) {
			j = 0;
			for(tileIndex in arrayY.iterator()){
				if (tileIndex != 0) // ignore empty tiles
				{
					if ( untyped tileIndex.length != null) //if Is Array
					{
						var realTileIndex:Int = 0;
						while ( untyped realTileIndex < tileIndex.length)
						{
							if ( untyped tileIndex[realTileIndex] == null)
								throw new Error("[ERROR] tile index " + untyped tileIndex[realTileIndex] + " not found in " + newMap.name+" tileSet");

							untyped generateTile(j, i, newMap, tileIndex[realTileIndex], realTileIndex);
							++realTileIndex;
						}
					}
					else
					{
						if (newMap.tiles[tileIndex] == null)
							throw new Error("[ERROR] tile index " + tileIndex + " not found in " + newMap.name+" tileSet");
							
						generateTile(j, i, newMap, tileIndex, 0);
					}
				}
				++j;
			}
			++i;
		}
		newMap.displayMap();
		if (select)
			setActiveMap(newMap);
	}
	
	private function generateTile(x:Int, y:Int, newMapRef:GameMap, tileIndex:Int, ?specialHeight:Int = 0){
		var tileSprite = new Tile(Texture.fromImage("" + newMapRef.tiles[tileIndex]));
		tileSprite.setTilePosition(x, y);
		tileSprite.x += newMapRef.OffsetX;
		tileSprite.y += newMapRef.OffsetY;
		tileSprite.setZ(newMapRef.tileHeights[tileIndex] + specialHeight * 0.001);
		newMapRef.addTileToMap(tileSprite, newMapRef.tileHeights[tileIndex]);
	}
	
	
	
	public static function displayDebugColliMap (nodes:Array<Array<Int>>):Void {
		for (row in 0...nodes.length) {
			for (col in 0...nodes[row].length) {
				if (nodes[row][col] < 2)
					Misc.placeTilePointer([new TilePoint(col,row)]);
				else
					Misc.placeTilePointer([new TilePoint(col,row)], 0xFF0000);
			}
		}
	}
	
	public function setActiveMap(newMap:GameMap):Void{
		activeMap = newMap;
		Main.camera.updateMapSize(activeMap);
	}
	
	public function getRandomPointOnMap(?condition:LOSPoint->Bool):TilePoint
	{
		var tempPoint:LOSPoint = new LOSPoint( Math.floor(Math.random() * (activeMap.size.x -1)), Math.floor(Math.random() * (activeMap.size.y -1)));
		tempPoint.isWall = activeMap.getLOSAt(tempPoint);
		if(condition != null)
			if (!condition(tempPoint))
				return getRandomPointOnMap(condition);
			
		return tempPoint;

	}
	

	public function placeEnemyGroupRamdom(range:Int, ?enemiesID:Array<String>):Void
	{
		if(enemiesID == null)
			placeEnemyGroupRamdomInternal(activeMap.addEnemyGroup().enemiesID.copy(), range);
		else
			placeEnemyGroupRamdomInternal(enemiesID, range);
	}
	
	private function placeEnemyGroupRamdomInternal(enemiesID:Array<String>, range:Int, ?__INTERNAL_LOOPS__:Int = 0):Void
	{
		__INTERNAL_LOOPS__++;
		if (__INTERNAL_LOOPS__ > 5)
		{
			Browser.window.console.warn("ENEMY SPAWN FAILED ! Too many tries!");
			return null;
		}
	
		var rangeSpawn:Array<TilePoint> = Misc.getTilesAround(getRandomPointOnMap(), 0, range, true, true);

		if (rangeSpawn.length < enemiesID.length) // reset if not enough space
			return placeEnemyGroupRamdomInternal(enemiesID, range, __INTERNAL_LOOPS__);

		var tempPos:TilePoint;
		
		while (enemiesID.length > 0)
		{
			tempPos = rangeSpawn.splice(Math.floor(Math.random() * rangeSpawn.length), 1)[0];
			CharacterManager.getInstance().findCharacterById(enemiesID[0]).setTilePosition(tempPos.x, tempPos.y);
			DrawManager.addToDisplay(CharacterManager.getInstance().findCharacterById(enemiesID[0]), activeMap.mapContainer);
			enemiesID.shift();
			//rangeSpawn.splice(rangeSpawn.indexOf(tempPos), 1);
		}
	}
	
	@:deprecated("NOT YET IMPLEMENTED !")
	public function spawnEnemyGroupPrecise(position:TilePoint, range:Array<TilePoint>)
	{
	}
	
	public function rePopCharactersOnMap()
	{
		for (group in activeMap.mapCharacterData.enemyGroups)
		{
			if (!group.isInFight)
			{
				for (enemyId in group.enemiesID)
				{
					var tempCharacter:Character = CharacterManager.getInstance().findCharacterById(enemyId);
					//if enemy is still in the character manager teleport it there.
					if (tempCharacter != null)
					{
						trace("Enemy "+tempCharacter.inGameName+" found in CharacterManager, moving to previous position.");
						tempCharacter.teleportTo(TilePoint.fromString(group.enemiesData.get(enemyId).position));
						tempCharacter.visible = true;
						untyped tempCharacter.parentGroup = group;
						DrawManager.addToDisplay(tempCharacter, activeMap.mapContainer);
					}
					else //create a new Enemy and teleport it to the position.
					{
						tempCharacter = Type.createInstance(Type.resolveClass(group.enemiesData.get(enemyId).className), []);
						tempCharacter.changeId(enemyId);
						untyped tempCharacter.parentGroup = group;
						tempCharacter.visible = true;
						DrawManager.addToDisplay(tempCharacter, activeMap.mapContainer);
					
						tempCharacter.teleportTo(TilePoint.fromString(group.enemiesData.get(enemyId).position));
					}
				}
			}
		}
	}
	
	public function switchState():Void {
		activeMap.hideMap(true);
	}
	
	public static function getInstance (): MapManager {
		if (instance == null) instance = new MapManager();
		return instance;
	}
	
}