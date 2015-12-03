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

	public var Zindex:Int = 0;
	public var tileHeight:Int = 0;
	public var tilePos:Array<Int>;

	public function new(texture:Texture) {
		super(texture);
	}
	
	public function setTilePosition(position:Array<Int>):Void {
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
	
}