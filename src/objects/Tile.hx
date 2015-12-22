package objects;

import managers.CharacterManager;
import managers.InitManager;
import managers.MapManager;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;

/**
 * ...
 * @author ToTos
 */
class Tile extends Sprite{

	public var z:Float = 0;
	public var depth:Float;
	public var tilePos:Array<Int> = [0,0];
	
	public function new(texture:Texture) {
		super(texture);
		anchor.set(0.5, 1);
	}
	
	public function setTilePosition(position:Array<Int>):Void {
		tilePos[0] = position[0];
		x = position[0] * Main.tileSize[0] + MapManager.getInstance().activeMap.OffsetX;
		
		tilePos[1] =  position[1];
		y = position[1] * Main.tileSize[1] * 0.5 + MapManager.getInstance().activeMap.OffsetY;
		if (Math.abs(tilePos[1] % 2) == 1)
			x += Main.tileSize[0] * 0.5;
		
		setZ(z);
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

	public function getAbsolutePosition ():Array<Float> {
		var arrayToReturn:Array<Float> = [];
		arrayToReturn[0] = tilePos[0] * Main.tileSize[0];
		arrayToReturn[1] = tilePos[1] * Main.tileSize[1]*0.5;
		if(Math.abs(tilePos[1] % 2) == 1)
			arrayToReturn[0] += Main.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	
}