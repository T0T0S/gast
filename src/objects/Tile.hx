package objects;

import pixi.core.math.Point;
import managers.CharacterManager;
import managers.InitManager;
import managers.MapManager;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class Tile extends Sprite{

	public var z:Float = 0;
	public var depth:Float;
	public var tilePos:TilePoint = new TilePoint();
	
	public function new(texture:Texture) {
		super(texture);
		anchor.set(0.5, 1);
	}
	
	public function setTilePosition(nx:Int, ny:Int):Void {
		tilePos.x = nx;
		tilePos.y = ny;
		x = (nx - ny) * Main.tileSize.x * 0.5;
		y = (nx + ny) * Main.tileSize.y * 0.5;
		setZ(z);
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
	
}