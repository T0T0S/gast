package utils;

/**
 * ...
 * @author ToTos
 */
class TilePoint
{
	public var x:Int = 0;
	public var y:Int = 0;
	public function new(?nx:Int = 0, ?ny:Int = 0) { x = nx; y = ny; };
	
	// => var tilepoint1  += tilepoint2
	public function add (point:TilePoint):TilePoint {
		x += point.x;
		y += point.y;
		return this;
	}
	
	// => var a  = tilepoint1 + tilepoint2
	public function addUnAlter (point:TilePoint):TilePoint {
		return new TilePoint(x + point.x,y + point.y);
	}
	
	public function equals(pos2:TilePoint):Bool{
		return x == pos2.x && y == pos2.y;
	}
	
	public function getDistance(tile2:TilePoint)
	{
		return Math.abs(x - tile2.x) + Math.abs(y - tile2.y);
	}
	
	public function toArray():Array<Int>
	{
		return [x,y];
	}
}

