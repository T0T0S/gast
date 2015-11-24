package objects;
import haxe.Constraints.Function;
import haxe.Json;
import js.Browser;
import managers.CharacterManager;
import managers.InitManager;
import managers.MapManager;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Id;

/**
 * ...
 * @author ToTos
 */

typedef Stats = {
	var health : Float;
	var strength : Float;
	var endurance : Float;
	var speed : Float;
	var precision : Float;
	var luck : Float;
}


class Character extends MovieClip{

	public var ID:Id;

	public var tilePos:Array<Int> = [0,0];
	public var directionFacing:Int = 0;
	
	public var stats:Stats = {
		health 		: 1000,
		strength 	: 100,
		endurance 	: 100,
		speed 		: 100,
		precision 	: 100,
		luck 		: 100
	};
	
	public var refreshSpeed:Float = 1000;
	
	public var charaName:String;
	public var attacks:Map<String,Function>;
	
	public var animations:Map<String,Array<Array<Int>>> = new Map.Map();
	public var activeAnimation:Array<Int>;
	public var activeAnimationName:String;
	
	public var config:Dynamic;

	public function new(newName:String) {
		charaName = newName;
		super(generateTextures(charaName));
		loop = true;
		
		anchor.set(0.5, 1);
		
		CharacterManager.getInstance().addCharacter(this);
	}
	
	private function generateTextures(newName:String):Array<Texture>{
		var returnArray:Array<Texture> = [];
		var animData:Map<String,Array<Array<Int>>> = cast InitManager.data[untyped newName+"_animations"];
		untyped Browser.window.ass = animData;
		if (animData == null)
			Browser.window.console.warn("NO ANIMDATA FOUND FOR: "+newName);
		
		var j:Int = 0;
		var k:Int = 0;
		for (i in Reflect.fields(animData)) {
			j = 0;
			while (j < Reflect.field(animData,i).length) {
				k = 0;
				while(k < Reflect.field(animData,i)[j].length){
					returnArray.push(Texture.fromImage(newName+"_"+i+"_"+j+".png"));
					++k;
				}
				++j;
			}
		}
		generateAnimations(animData);
		
		return returnArray;
	}
	
	private function generateAnimations(animationData:Map<String,Array<Array<Int>>>):Void {
		for (i in Reflect.fields(animationData)) {
			animations.set(i, Reflect.field(animationData,i));
		}	
		setAnimation("idle");
	}
		
	public function damage(amount:Float):Void{
		stats.health -= amount;
		if(stats.health <= 0){
			stats.health = 0;
			kill();
		}
	};
	
	public function _update():Void{
		manageAnim();
		update();
	}
	
	private function manageAnim():Void {
		if (activeAnimation == null)
			return;
		
		if(currentFrame == activeAnimation[activeAnimation.length - 1]){
			gotoAndPlay(activeAnimation[0]);
		}
	}
	
	public function setAnimation(animName:String):Void {
		if (!animations.exists(animName)){
			Browser.window.console.warn("anim not found: "+animName);
			return;
		}
		
		activeAnimationName = animName;			
		activeAnimation = animations.get(animName)[directionFacing];
		gotoAndPlay(activeAnimation[0]);
	}
	
	public function changeDirection(newDir:Int):Void{
		directionFacing = newDir % 4;
		setAnimation(activeAnimationName);
	}
	
	
	var ass:Int = 0;
	public function update():Void {
		if(ass % 10 == 0)
			changeDirection(ass);
		ass++;
	}
	
	public function kill():Void{
		trace("TARGET '" + charaName+"' is dead !");
		CharacterManager.getInstance().removeCharacter(this);
	}
	
	
	
	/**
	 * modifie la position du character,
	 * ### /!\ prend en compte le décalage due a l'iso /!\ ###
	 */ 
	public function setTilePosition(position:Array<Int>):Void {
		CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this, position);
	
		tilePos[0] = position[0];
		x = position[0] * InitManager.data.config.tileSize[0] + MapManager.getInstance().activeMap.OffsetX;
		
		tilePos[1] =  position[1];
		y = position[1] * InitManager.data.config.tileSize[1] * 0.5 + MapManager.getInstance().activeMap.OffsetY;
		if (Math.abs(tilePos[1] % 2) == 1)
			x += InitManager.data.config.tileSize[0] * 0.5;
	}
	

	public function getAbsolutePosition ():Array<Float> {
		var arrayToReturn:Array<Float> = [];
		arrayToReturn[0] = tilePos[0] * InitManager.data.config.tileSize[0];
		arrayToReturn[1] = tilePos[1] * InitManager.data.config.tileSize[1]*0.5;
		if(Math.abs(tilePos[1] % 2) == 1)
			arrayToReturn[0] += InitManager.data.config.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	
	public function launchAttack(targetPosition:Array<Int>):Void{
		trace("attacked tile: "+targetPosition);
		if (CharacterManager.getInstance().findCharacterAtTilePos(targetPosition)){
			trace("found character");
			CharacterManager.getInstance().findCharacterAtTilePos(targetPosition).damage(stats.strength);
		}
	};

		
}