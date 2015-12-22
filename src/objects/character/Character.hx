package objects.character;
import js.Browser;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.InitManager;
import managers.MapManager;
import managers.PoolManager;
import managers.TimeManager;
import objects.Animation;
import objects.attacks.Attack;
import objects.particle.DmgText;
import objects.Tile;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Id;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */

typedef Stats = {
	var health 			: Float;
	var strength 		: Int;
	var endurance 		: Int;
	var moveSpeed 		: Float;
	var regeneration 	: Int;
	var precision 		: Int;
	var luck 			: Int;
	var AP 				: Int;
	var MaxAP 			: Int;
}


class Character extends MovieClip{

	public var ID:String;

	public var tilePos:Array<Int> = [0,0];
	public var directionFacing:Int = 0;
	
	public var stats:Stats = {
		health 		: 100,
		strength 	: 10,
		endurance 	: 10,
		regeneration: 10,
		moveSpeed	: 2.5,
		precision 	: 10,
		luck 		: 10,
		AP 			: 10,
		MaxAP		: 10
	};
	
	private var activePath:Array<Dynamic> = [];
	private var pathIndex:Int = 1;
	private var activePathPoint:Dynamic;
	private var isMoving:Bool = false;
	
	public var refreshSpeed:Float = 1;
	
	public var charaName:String;
	public var attacks:Map<String,Attack> = new Map.Map();
	private var activeAttack:Attack;
	private var activeAttackRange:Array<Array<Int>> = [];
	
	
	public var animations:Map<String,Animation> = new Map.Map();
	public var animationFrame:Float = 0;
	public var activeAnimation:Animation;
	public var activeAnimationName:String;
	
	public var config:Dynamic;
	
	public var z:Float = 0;
	public var depth:Float = 0;
	
	private var lastTickRegistered:Int = 0;
	
	private var updateBlocked:Bool = false;
	public var waitForNextTick:Bool = false;
	
	public var isDead:Bool = false;
	
	private var positionTile:Tile;

	
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
		CharacterManager.getInstance().addCharacter(this);
	}
	
	
	private function generateStats():Void {
		/* test from server */	
		stats.health 		= config.stats.health;
		stats.strength 		= config.stats.strength;
		stats.endurance 	= config.stats.endurance;
		stats.regeneration 	= config.stats.regeneration;
		stats.moveSpeed		= config.stats.moveSpeed;
		stats.precision		= config.stats.precision;
		stats.luck 			= config.stats.luck;
		stats.MaxAP 		= config.stats.MaxAP;
		stats.AP 			= stats.MaxAP;
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
			attacks.set(i, Misc.getAttackFromName(i, Reflect.field(config.attacks, i)));
		}	
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
	public function _selfUpdate():Void {
		manageAnim();
		
		if (!updateBlocked) {
			if (FightManager.status != StatusModes.setup)
				managePathFinding();
			if (FightManager.status == StatusModes.fight)
				fightUpdate();
			else
				normalUpdate();
		}
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
					setDirection(Misc.getDirectionToPoint(tilePos, [activePathPoint.x,activePathPoint.y]));
					setAnimation("run");
				}
			}
		}
		
		if(activeAnimation.data[0].length > 1){
			if (animationFrame >= activeAnimation.getFrames(directionFacing).length - 1) {
				if (!activeAnimation.loop) {
					stop();
					setAnimation("idle");
					activeAnimation.endAction();
				}
				else {
					gotoAndStop(activeAnimation.getFrames(directionFacing)[0]);
				}
				animationFrame = 0;
			}
			else {
				animationFrame += 1 * (activeAnimation.fps / 60);
				gotoAndStop(activeAnimation.getFrames(directionFacing)[Math.floor(animationFrame)]);
			}
		}
	}
	
	private function managePathFinding():Void {
		if (activePath.length != 0 && stats.AP > 0) {
			if (activePathPoint == null)
				getNextPathPoint();
			if (tilePos[0] != activePath[activePath.length - 1].x || tilePos[1] != activePath[activePath.length - 1].y){
				var arrayPos = [activePathPoint.x, activePathPoint.y];
				
				//trace(Misc.getDistance(x,y,Misc.convertToAbsolutePosition(arrayPos)[0],Misc.convertToAbsolutePosition(arrayPos)[1]));
				setAbsolutePosition(x + Math.cos(Misc.angleBetweenTiles(tilePos, arrayPos)) * stats.moveSpeed * TimeManager.deltaTime, y - Math.sin(Misc.angleBetweenTiles(tilePos, arrayPos)) * stats.moveSpeed * TimeManager.deltaTime);
				if(Misc.getDistance(x,y,Misc.convertToAbsolutePosition(arrayPos)[0],Misc.convertToAbsolutePosition(arrayPos)[1] + Main.tileSize[1] * 0.5) < stats.moveSpeed * TimeManager.deltaTime)
				{
					// new Point
					setTilePosition(arrayPos);
					pathIndex++;
					
					useAp(1); // - 1 AP
					
					if(pathIndex <= activePath.length -1)
						getNextPathPoint();
					else
					{
						//finish Path
						setAnimation("idle");
						activePath = [];
						activePathPoint = null;
						isMoving = false;
					}
				}
			}
		}
	}
	
	private function getNextPathPoint():Void{
		activePathPoint = activePath[pathIndex];
		setDirection(Misc.getDirectionToPoint(tilePos, [activePathPoint.x,activePathPoint.y]));
	}
	
	public function generatePosTile(allied:Bool):Void {
		positionTile = allied ? new Tile(Texture.fromImage("alliedTile.png")) :new Tile(Texture.fromImage("enemyTile.png"));
		DrawManager.addToDisplay(positionTile, MapManager.getInstance().activeMap.mapContainer, 0.45);
		positionTile.visible = true;
		showPosTile(tilePos);
	}
	
	private function showPosTile(newPos:Array<Int>):Void {
		if (FightManager.status == StatusModes.normal || positionTile == null)
			return;
			
		positionTile.setTilePosition(newPos);
	}
	
	public function normalUpdate():Void{
	
	}
	
	public function fightUpdate():Void{
	
	}
	
	
	
	public function setAnimation(animName:String):Void {
		if (!animations.exists(animName)){
			Browser.window.console.warn("anim not found: "+animName);
			return;
		}
		activeAnimation = animations.get(animName);
		activeAnimationName = activeAnimation.name;	
		
		if (activeAnimation.getFrames(directionFacing).length == 1)
			gotoAndStop(activeAnimation.getFrames(directionFacing)[0]);
		else
			gotoAndPlay(activeAnimation.getFrames(directionFacing)[0]);
		animationSpeed = activeAnimation.fps / 60;
	}
	
	public function setDirection(newDir:Int):Void{
		directionFacing = newDir % 4;
		setAnimation(activeAnimationName);
	}
	
	
	
	public function kill():Void {
		trace("TARGET '" + charaName+"' is dead !");
		
		setAnimation("death");
		/* callback of death animation */  
		updateBlocked = true;
		isDead = true;
		
		FightManager.getInstance().testFightOver();
		Destroy();
		
		
		// penser a anim de mort
		// penser aux callback sur les anims
	}
	
	
	
	/**
	 * modifie la position du character,
	 * ### /!\ prend en compte le décalage due a l'iso /!\ ###
	 */ 
	public function setTilePosition(position:Array<Int>):Void {
		CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this, position);
	
		tilePos[0] = position[0];
		x = position[0] * Main.tileSize[0] + MapManager.getInstance().activeMap.OffsetX;
		
		tilePos[1] =  position[1];
		y = position[1] * Main.tileSize[1] * 0.5 + MapManager.getInstance().activeMap.OffsetY;
		if (Math.abs(tilePos[1] % 2) == 1)
			x += Main.tileSize[0] * 0.5;
			
		setZ(z);
		showPosTile(position);
	}
	

	public function getAbsolutePosition ():Array<Float> {
		var arrayToReturn:Array<Float> = [];
		arrayToReturn[0] = tilePos[0] * Main.tileSize[0];
		arrayToReturn[1] = tilePos[1] * Main.tileSize[1]*0.5;
		if(Math.abs(tilePos[1] % 2) == 1)
			arrayToReturn[0] += Main.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	
	public function setAbsolutePosition (newX:Float, newY:Float):Void {
		x = newX;
		y = newY;
		setZ(z);
	}
	
	public function setZ(newZ:Float):Void{
		z = newZ;
		depth = y + z;
	}
	
	public function findPathTo(target:Array<Int>, follow:Bool = false):Array<Dynamic>
	{
		MapManager.finder.setColliTile(tilePos[0], tilePos[1], true);
		var returnPath = MapManager.getInstance().activeMap.findPath(getPathFindingPoint(), target);
		MapManager.finder.setColliTile(tilePos[0], tilePos[1], false);
		if (follow)
			followPath(returnPath);
		return returnPath;
	}
	
	public function followPath(path:Array<Dynamic>):Void{
		if (path.length == 0 || path.length-1 > stats.AP)
			return;
		activePath = path;
		isMoving = true;
		
		pathIndex = activePathPoint != null ? 0 : 1;
		setAnimation("run");
	}
	
	public function launchAttack(attackName:String, targetPosition:Array<Int>):Void {
		if (attacks.get(attackName) == null){
			Browser.window.console.warn("attack not found: " + attackName);
			return;
		}
		if (!Misc.targetInRange(tilePos, targetPosition, activeAttackRange)){
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
	
	public function getPathFindingPoint():Array<Int> {
		if(activePathPoint != null)
			return [activePathPoint.x, activePathPoint.y];
		return tilePos;
	}
	
	public function newTick(tickNumber:Int):Void { 
		if (stats.AP < stats.MaxAP)
			stats.AP += tickNumber - lastTickRegistered;
			
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

	/**
	 * destroy to call for removing a character
	 */
	public function Destroy():Void {
		CharacterManager.getInstance().removeCharacter(this);
		DrawManager.removeFromDisplay(this);
		if (Camera.targetToFollow == this)
			Camera.targetToFollow = null;
			
		destroy();
	}

		
}