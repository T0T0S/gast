package objects.character;
import js.Browser;
import js.Lib;
import managers.UpdateManager;
import objects.modules.BehaviorModule;
import objects.modules.LOSModule;
import pixi.core.math.Point;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.InitManager;
import managers.MapManager;
import managers.PoolManager;
import managers.TimeManager;
import objects.Animation;
import objects.attacks.Attack;
import objects.attacks.NormalAttack;
import objects.attacks.TripleAttack;
import objects.particle.DmgText;
import objects.Tile;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Id;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */

typedef Stats = {
	var health 			: Float;
	var strength 		: Int;
	var endurance 		: Int;
	var moveSpeed 		: Float;
	var moveCost 		: Float;
	
	var APregeneration 	: Int;
	var precision 		: Int;
	var luck 			: Int;
	var AP 				: Float;
	var MaxAP 			: Float;
}


class Character extends MovieClip{

	public var ID:String;
	public var selectedAction:String = "move";

	public var tilePos:TilePoint = new TilePoint();
	public var directionFacing:Int = 0;
	
	public var stats:Stats = {
		health 			: 100,
		strength 		: 10,
		endurance 		: 10,
		APregeneration	: 10,
		moveSpeed		: 1,
		moveCost		: 1,
		precision 		: 10,
		luck 			: 10,
		AP 				: 100,
		MaxAP			: 100
	};
	
	private var activePath:Array<TilePoint> = [];
	private var pathIndex:Int = 1;
	private var activePathPoint:Dynamic;
	private var isMoving:Bool = false;
	
	public var refreshSpeed:Float = 1;
	
	public var charaName:String;
	public var attacks:Map<String,Attack> = new Map.Map();
	private var activeAttack:Attack;
	private var losModule:LOSModule = new LOSModule();
	
	//Work In Progress
	//private var behaviorModule:BehaviorModule = new BehaviorModule();
	
	public var animations:Map<String,Animation> = new Map.Map();
	public var activeAnimation:Animation;
	
	public var config:Dynamic;
	
	public var z:Float = 0;
	public var depth:Float = 0;
	
	private var lastTickRegistered:Int = 0;
	
	private var updateBlocked:Bool = false;
	public var waitForNextTick:Bool = false;
	
	public var isDead:Bool = false;
	
	public var positionTile:Tile;
	
	

	
	/*#################
	*		NEW	 
	* ################# */
	public function new(newName:String) {
	
		charaName = newName;
		config = InitManager.data[untyped newName];
		super(generateTextures(charaName));
		
		generateStats();
		generateAnimations();
		generateAttacks();
		loop = true;
		
		ID = Id.newId();
		anchor.set(0.5, 1);
		UpdateManager.getInstance().manage(this);
		CharacterManager.getInstance().addCharacter(this);
	}
	
	
	private function generateStats():Void {
		/* test from server */	
		stats.health 		= config.stats.health;
		stats.strength 		= config.stats.strength;
		stats.endurance 	= config.stats.endurance;
		stats.APregeneration= config.stats.APregeneration;
		stats.moveSpeed		= config.stats.moveSpeed;
		stats.precision		= config.stats.precision;
		stats.luck 			= config.stats.luck;
		stats.MaxAP 		= config.stats.MaxAP;
		stats.AP 			= stats.MaxAP;
		stats.moveCost 		= config.stats.moveCost;
		
	}
	
	private function generateTextures(newName:String):Array<Texture>{
		var returnArray:Array<Texture> = [];
		var textureData:Array<String> = config.texturesUrls;

		if (textureData == null)
			Browser.window.console.warn("NO TEXTUREDATA FOUND FOR: "+newName);
		
		for (i in textureData.iterator()) {
			returnArray.push(Texture.fromImage(i));
		}
		
		return returnArray;
	}
	
	private function generateAttacks():Void{
		for (i in Reflect.fields(config.attacks)) {
			attacks.set(i, getAttackFromName(i, Reflect.field(config.attacks, i)));
		}	
	}
	
	private function getAttackFromName(name:String, data:Dynamic):Attack{
		switch name{
			case "normal": return new NormalAttack(data);
			case "triple": return new TripleAttack(data);
		}
		Browser.window.console.warn("ATTACK NOT FOUND !");
		return new Attack(data);
	}
	
	private function generateAnimations():Void {
		for (i in Reflect.fields(config.animations)) {
			addAnimation(i, Reflect.field(config.animations,i));
		}	
		setAnimation("idle");
	}
	
	public function addAnimation(newName:String, data:Dynamic, ?endCallback){
		animations.set(newName, new Animation(newName,data, endCallback));
	}
		
	public function damage(amount:Int):Void {
		var dmgText:DmgText = PoolManager.pullObject("dmgText");
		if (amount > 0)
			dmgText.text = "-"+(amount);
		else
			dmgText.text = "+"+(amount);
		dmgText.alpha = 1;
		dmgText.visible = true;
		dmgText.x = x + (Math.random() * width * 0.5) - width*0.25;
		dmgText.y = y - height * 0.5;
		dmgText.anchor.set(0.5, 0.5);
		DrawManager.addToDisplay(dmgText,Main.getInstance().gameCont);
		dmgText.animate(0.5);
		
		setAnimation("damage");
		
		
		stats.health -= amount;
		if(stats.health <= 0){
			stats.health = 0;
			kill();
		}
	};
	
	/*#################
			UPDATE
	  #################*/
	public function _start()
	{
	
	}
	  
	public function _update():Void {
		manageAnim();
		
		if (isDead || updateBlocked)
			return;
			
		if (FightManager.status != StatusModes.setup){
			managePathFinding();
		}
		if (FightManager.status == StatusModes.fight)
			fight_update();
		else if(FightManager.status == StatusModes.setup)
			setup_update();
		else
			normal_update();
	}
	
	private function manageAnim():Void {
		if (activeAnimation == null) {
			return;
		}
		
		if (activeAttack != null) {
			if (!activeAttack.finished)
			{
				activeAttack.updateAttack(this);
			}
			else {
			
			//post Attack callback
				activeAttack = null;
				if (activePathPoint == null)
				{
					setAnimation("idle");
				}
				else{
					setDirection(Misc.getDirectionToPoint(tilePos, activePathPoint));
					setAnimation("run");
				}
			}
		}
		
		gotoAndStop(activeAnimation.getNextFrameIndex());
		if (activeAnimation.finished) 
			setAnimation("idle");
	}
	
	private var tempTimeMovement:Float = 0;
	private function managePathFinding():Void {
		if (activePath.length != 0 && stats.AP > 0) {
			if (activePathPoint == null)
				getNextPathPoint();
			
			tempTimeMovement += TimeManager.deltaTime * stats.moveSpeed;
			
			setAbsolutePosition(
				Misc.lerp((tilePos.x - tilePos.y) * Main.tileSize.x * 0.5, (activePathPoint.x - activePathPoint.y) * Main.tileSize.x * 0.5, tempTimeMovement),
				Misc.lerp((tilePos.x + tilePos.y) * Main.tileSize.y * 0.5, (activePathPoint.x + activePathPoint.y) * Main.tileSize.y * 0.5, tempTimeMovement)
			);
				
			if (tempTimeMovement >= 1)
			{
				//new Path point
				setTilePosition(activePathPoint.x, activePathPoint.y);
				pathIndex++;
				
				tempTimeMovement = 0;
				if(FightManager.status == StatusModes.fight)
					useAp(cast stats.moveCost);
				
				if(pathIndex <= activePath.length -1){					
					if (!MapManager.getInstance().activeMap.getWalkableAt(activePath[pathIndex]))
						stopPath();
					else
						getNextPathPoint();
				}
				else
					stopPath();
			}
		}
	}
	
	private function getNextPathPoint():Void{
		activePathPoint = activePath[pathIndex];
		CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this, activePathPoint.x, activePathPoint.y);
		setDirection(Misc.getDirectionToPoint(tilePos, activePathPoint));
	}
	
	private function stopPath():Void{
		setAnimation("idle");
		activePath = [];
		activePathPoint = null;
		isMoving = false;
	}
	
	public function generatePosTile(allied:Bool):Void {
		positionTile = allied ? new Tile(Texture.fromImage("alliedTile.png")) :new Tile(Texture.fromImage("enemyTile.png"));
		DrawManager.addToDisplay(positionTile, MapManager.getInstance().activeMap.mapContainer, 0.45);
		positionTile.visible = true;
		untyped positionTile.charaName = charaName;
		showPosTile(tilePos.x, tilePos.y);
	}
	
	private function showPosTile(nx:Int, ny:Int):Void {
		if (FightManager.status == StatusModes.normal || positionTile == null)
			return;
			
		positionTile.setTilePosition(nx, ny);
	}
	
	public function normal_update():Void
	{
		stats.AP = stats.MaxAP;
	}
	
	public function setup_update():Void{
	
	}
	
	public function fight_update():Void{
	
	}
	
	public function setupUpdate():Void
	{
		stats.AP = stats.MaxAP;
	}
	
	public function onCharacterMove(characterId:String, ?nx:Int, ?ny:Int ):Void
	{
		if(selectedAction != "move")
			losModule.forceRefresh();
	}
	
	public function setAnimation(animName:String, resetFrames:Bool = true):Void {
		var lastAnimPreciseFrame:Float = 0;
		if (!resetFrames)
			lastAnimPreciseFrame = activeAnimation.preciseAnimFrame;
			
		if(activeAnimation != null)
			activeAnimation.resetAnim(directionFacing);
			
		if (!animations.exists(animName)){
			Browser.window.console.warn("anim not found: "+animName);
			return;
		}
		activeAnimation = animations.get(animName);
		activeAnimation.resetAnim(directionFacing);
		animationSpeed = activeAnimation.fps / 60;
		if (!resetFrames)
			activeAnimation.setPreciseAnimFrame(lastAnimPreciseFrame);
		
		gotoAndStop(activeAnimation.getNextFrameIndex());
	}
	
	
	public function setDirection(newDir:Int):Void {
		directionFacing = newDir % 4;
		setAnimation(activeAnimation.name, false);
	}
	
	
	
	public function kill():Void {
		trace("TARGET '" + charaName+"' is dead !");
		
		setAnimation("death");
		/* callback of death animation */  
		updateBlocked = true;
		
		
		/* end */
		DrawManager.removeFromDisplay(positionTile);
		isDead = true;
		Destroy();
		FightManager.getInstance().testFightOver();
		
		
		// penser a anim de mort
		// penser aux callback sur les anims
	}
	
	
	
	
	public function setTilePosition(nx:Int, ny:Int):Void {
		CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this, nx, ny);
		tilePos.x = nx;
		tilePos.y = ny;
		x = (nx -  ny) * Main.tileSize.x * 0.5;
		y = (nx +  ny) * Main.tileSize.y * 0.5;
		setZ(z);
		showPosTile(nx, ny);
	}
	
	public function setAbsolutePosition (newX:Float, newY:Float):Void {
		x = newX;
		y = newY;
		setZ(z);
	}
	
	public function setZ(newZ:Float):Void{
		z = newZ;
		depth = x * 0.1 + y + z * 0.01;
	}


	public function getAbsolutePosition ():Point {
		return new Point((tilePos.x -  tilePos.y) * Main.tileSize.x * 0.5, (tilePos.x +  tilePos.y) * Main.tileSize.y * 0.5);
	}
	
	public function findPathTo(target:TilePoint, follow:Bool = false, unlimited:Bool = false):Array<TilePoint>
	{
		if (target.equals(tilePos))
			return [];
		if (target.getDistance(tilePos) > getMaxMovement() && !unlimited)//target is too far anyway.
			return [];
		
		if (target.equals(Player.getInstance().tilePos))
		{
			target = Misc.getClosestPosFromDirection(target,Misc.getDirectionToPoint(target, tilePos));
		}
		
		MapManager.getInstance().activeMap.setColliAt(tilePos, false);
		var returnPath;
		if(unlimited)
			returnPath = MapManager.getInstance().activeMap.findPath(getPathFindingPoint(), target, Misc.getTilesAround(tilePos, 0, 
			cast Math.max(	MapManager.getInstance().activeMap.collisionData.length, 
							MapManager.getInstance().activeMap.collisionData[0].length)));
		else
			returnPath = MapManager.getInstance().activeMap.findPath(getPathFindingPoint(), target, Misc.getTilesAround(tilePos,0, cast getMaxMovement()));
		MapManager.getInstance().activeMap.setColliAt(tilePos, true);
		
		if (follow)
			followPath(returnPath, unlimited);
			
		return returnPath;
	}
	
	public function followPath(path:Array<TilePoint>, unlimited:Bool = false):Void{
		if (path.length == 0 || (path.length-1 > getMaxMovement() && !unlimited))
			return;
		activePath = path;
		isMoving = true;
		pathIndex = activePathPoint != null ? 0 : 1;
		setAnimation("run");
	}
	
	public function launchAttack(attackName:String, targetPosition:TilePoint):Void {
		if (attacks.get(attackName) == null){
			Browser.window.console.warn("attack not found: " + attackName);
			return;
		}
		if (!Misc.targetInRange(targetPosition, losModule.getLOS())){
			Browser.window.console.warn("target not in range");
			return;
		}
		if (attacks.get(attackName).apCost > stats.AP)
		{
			Browser.window.console.warn("not enough AP");
			return;
		}
		activeAttack = attacks.get(attackName);
		useAp(activeAttack.apCost);
		setAnimation(activeAttack.animationName);
		updateBlocked = activeAttack.waitForFinish;
		activeAttack.activateAttack(targetPosition);
		setDirection(Misc.getDirectionToPoint(tilePos, targetPosition));
	};
	
	public function getPathFindingPoint():TilePoint {
		if(activePathPoint != null)
			return activePathPoint;
		return tilePos;
	}
	
	public function newTick(tickNumber:Int):Void { 
		stats.AP = cast Math.min(stats.MaxAP,stats.AP + (tickNumber - lastTickRegistered) * stats.APregeneration);
			
		lastTickRegistered = tickNumber;
		
		if (waitForNextTick)
		{
			waitForNextTick = false;
			updateBlocked = false;
		}
	}
	
	public function useAp(amount:Int):Void
	{
		stats.AP -= amount;
	}
	
	public function getMaxMovement():Float
	{
		return Math.floor(stats.AP / stats.moveCost);
	}
	
	public function changeSelectedAction(newActionName:String):Void {
		if (FightManager.status != StatusModes.fight)
		{
			selectedAction = "move";
			return;
		}
		selectedAction = selectedAction == newActionName ? "move" : newActionName; 
		
		if (selectedAction != "move") {
			losModule.forceRefresh();
		}
	}

	/**
	 * destroy to call for removing a character
	 */
	public function Destroy():Void {
		CharacterManager.getInstance().removeCharacter(this);
		DrawManager.removeFromDisplay(this);
		UpdateManager.getInstance().remove(this);
		if (Camera.targetToFollow == this)
			Camera.targetToFollow = null;
			
		destroy();
	}

		
}