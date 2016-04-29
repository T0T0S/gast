package objects.modules;
import js.Browser;
import js.html.KeyboardEvent;
import managers.CharacterManager;
import managers.MapManager;
import states.DiamondTestState;
import utils.Misc;
import utils.TilePoint;

using LOSModule.ArrayExtender;

/**
 * ...
 * @author ToTos
 */
class LOSModule{
	
	private var shadowLineTemp:ShadowLine = new ShadowLine();
	private var centerPos:TilePoint = new TilePoint();
	private var isFresh:Bool = false;
	
	private var maxRange:Int = 1;
	private var minRange:Int = 0;
	
	private var activeLOSRange:Array<LOSPoint> = [];
	
	
	public function new() {	}
	
	// unfresh if player move in range !
	
	public function getLOS():Array<LOSPoint>
	{
		if (!isFresh)
			processLOSRange();
		return activeLOSRange;
	}
	
	public function getDisplayLOS():Array<TilePoint>
	{
		var tempArray:Array<LOSPoint> = getLOS();
		var tileIndex:Int = 0;
		
		while(tileIndex < tempArray.length)
		{
			if(!tempArray[tileIndex].isVisible)
			{
				tempArray.splice(tileIndex, 1);
				tileIndex--;
			}
			tileIndex++;
		}
		
		return cast tempArray;
	}
	
	public function HasLOS(target:TilePoint):Bool
	{
		return getLOS().hasTile(target);
	}

	public function moveToPoint(pos:TilePoint)
	{
		centerPos = pos;
		isFresh = false;
	}
	
	public function setRange(?newRangeMin:Int, ?newRangeMax:Int)
	{
		minRange = newRangeMin != null ? newRangeMin : minRange;
		maxRange = newRangeMax != null ? newRangeMax : maxRange;
		isFresh = false;
	}
	
	public function forceRefresh()
	{
		isFresh = false;
	}
	
	private function processLOSRange():Void
	{
		if (!isFresh)
			HardRefreshActiveLosRange();
		
		SoftRefreshActiveLosRange();
		for (octant in 0...8) 
		{
			refreshOctant(octant);
		}
		
		for (tile in activeLOSRange.iterator())
		{
			if(tile.getDistance(centerPos) < minRange) tile.isVisible =  false;
			if(tile.isWall) tile.isVisible =  false;
			if(tile.isTarget) tile.isVisible =  true;
		}
		
		if (minRange == 0)
			if(activeLOSRange.find(centerPos) != null)
				activeLOSRange.find(centerPos).isVisible = true;
	}
	
	function HardRefreshActiveLosRange()
	{
		activeLOSRange = cast Misc.getTilesAround(centerPos, 0, maxRange);
		var mapLOSRef:Array<Array<Int>> = MapManager.getInstance().activeMap.LOSData;
		
		for (tile in activeLOSRange.iterator())
		{
			tile.isWall = true;
			if (mapLOSRef[tile.y] != null)
			{
				tile.isWall = mapLOSRef[tile.y][tile.x] != 0;
				tile.isTarget = tile.isWall && CharacterManager.getInstance().findCharacterAtTilePos(tile) != null;
			}
		}
		isFresh = true;
	}
	
	function SoftRefreshActiveLosRange()
	{
		for (tile in activeLOSRange.iterator())
		{
			tile.isVisible = false;
		}
	}
	
	function refreshOctant(octant:Int) {
		shadowLineTemp.reset();
		
		var fullShadow = false;
		var tempTile:LOSPoint ;
		for (row in 1...3000) 
		{
			// Stop once we go out of bounds.
			var pos = centerPos.addUnAlter(transformOctant(row, 0, octant));
			if (!activeLOSRange.hasTile(pos)) break;

			for (col in 0...row+1) 
			{
				var pos = centerPos.addUnAlter(transformOctant(row, col, octant));
				tempTile = activeLOSRange.find(pos);
				// If we've traversed out of bounds, bail on this row.
				if (tempTile == null) break;
				
				if (fullShadow) 
				{
					tempTile.isVisible = false;
				} 
				else 
				{
					var projection:Shadow = projectTile(col, row);
					
					var visible = !shadowLineTemp.isInShadow(projection);
					
					if(!tempTile.isVisible)
						tempTile.isVisible = visible;
					
					if (tempTile.isWall) {
					
						//if (centerPos.equals(new TilePoint(28, 16)))
							//trace("add shadow" + projection);
						shadowLineTemp.add(projection, tempTile.isVisible );
						fullShadow = shadowLineTemp.isFullShadow;
					}
				}
			}
		}
	}
	
	function transformOctant(row:Int, col:Int , octant:Int ):TilePoint {
		
		switch octant {
			case 0: return new TilePoint( col, -row);
			case 1: return new TilePoint( row, -col);
			case 2: return new TilePoint( row,  col);
			case 3: return new TilePoint( col,  row);
			case 4: return new TilePoint(-col,  row);
			case 5: return new TilePoint(-row,  col);
			case 6: return new TilePoint(-row, -col);
			case 7: return new TilePoint( -col, -row);
			default: return null;
		}
	}
	
	function projectTile(col:Int, row:Int ):Shadow 
	{
		var topLeft = col / (row + 2);
		var bottomRight = (col + 1) / (row + 1);
		return new Shadow(topLeft, bottomRight);
	}
}
	
private class ShadowLine 
{
	private var _shadows:Array<Shadow> = [];
	
	private var precision:Float = 0.24;
	
	public function new ()
	{
		//Browser.window.onkeydown = function (e:KeyboardEvent):Void 
		//{
			////if (e.which == 107)
				////precision += 0.01;
			////if (e.which == 109)
				////precision -= 0.01;
			////
			////if (e.which == 32)
				////trace(_shadows);
			//////DiamondTestState.getLos();
			////trace(precision);
		//};
	}
	public function reset() { _shadows = []; }
	
	public function isInShadow(projection:Shadow):Bool {
			
		for (shadow in _shadows) {
			if (shadow.contains(projection,precision)) return true;
		}

		return false;
	}
	
	public var isFullShadow(get, null):Bool;
	
	function get_isFullShadow():Bool
	{
		return 	_shadows.length == 1 &&
				_shadows[0].start == 0 &&
				_shadows[0].end == 1;
	}
	
	public function add(shadow:Shadow, visible:Bool):Void {
		var index = 0;
		
		for (shad in _shadows.iterator())
		{
			if (shad.contains(shadow, precision ,false))
				return;
		}

		while (index < _shadows.length)
		{
			if (_shadows[index].start >= shadow.start) 
				break;
			++index;
		}
		var overlappingPrevious = null;
		
		if (index > 0 && _shadows[index - 1].end > shadow.start) 
			overlappingPrevious = _shadows[index - 1];
		

		var overlappingNext = null;
		if (index < _shadows.length && _shadows[index].start < shadow.end) 
			overlappingNext = _shadows[index];

		if (overlappingNext != null) 
		{
			if (overlappingPrevious != null) 
			{
				overlappingPrevious.end = overlappingNext.end;
				//_shadows.splice(index, 1);
				_shadows.remove(overlappingNext);
			}
			else 
			{
				overlappingNext.start = shadow.start;
			}
		} 
		else 
		{
			if (overlappingPrevious != null) 
			{
				overlappingPrevious.end = shadow.end;
			} 
			else 
			{
				
				_shadows.insert(index, shadow);
			}
		}
	}
}
private class Shadow 
{
	public var start:Float;
	public var end:Float;
	
	public function new (s, e) { start = s; end = e; }
	
	// separate visibility && angle of fire !
	public function contains(other:Shadow, precision:Float, strict:Bool = true):Bool 
	{
		//strict	
		if (strict)
			return (start  <  other.end && end > other.start) && (start + end - other.start) / (other.start + other.end) >= precision;
		
		//permissive
		return start <= other.start && end >= other.end;
	}
}

class LOSPoint extends TilePoint
{
	public var isVisible:Bool = false;
	public var isWall:Bool = false;
	public var isTarget:Bool = false;
		
	public function new(?nx:Int = 0, ?ny:Int = 0)
	{
		super(nx, ny);
	}
}


/*
private class ArrayLos
{
	private var _array:Array<Array<LOSPoint>>;
	
	private var _normalArray:Array<LOSPoint> = [];
	
	private var isFresh:Bool = false;
	
	
	
	public function iterator()
	{
		return getArray().iterator();
	}
	
	public function hasTile(tile:TilePoint)
	{
		return _array[tile.x][tile.y] != null;
	}
	
	public function getArray():Array<LOSPoint>
	{
		if (isFresh)
			return _normalArray;
		_normalArray = [];
		for (x in _array.iterator())
		{
			for (tile in x.iterator())
			{
				_normalArray.push(tile);
			}
		}
		isFresh = true;
		return _normalArray;
	}
	
	public function new()
	{
		_array  = [[]];
		isFresh = false;
	}
	
	public function find(point:TilePoint)
	{
		return _array[point.x][point.y];
	}
}


*/

class ArrayExtender
{
	static public function hasTile(i:Array<LOSPoint>, tile:TilePoint):Bool {
		for (j in i.iterator())
		{
			if (j.equals(tile))
				return true;
		}
		return false;
	}
	
	static public function find(i:Array<LOSPoint>, tile:TilePoint):LOSPoint
	{
		for (j in i.iterator())
		{
			if (j.equals(tile))
				return j;
		}
		return null;
	}
}