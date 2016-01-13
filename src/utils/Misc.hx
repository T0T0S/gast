package utils;
import js.Browser;
import managers.CharacterManager;
import managers.DrawManager;
import managers.MapManager;
import managers.PoolManager;
import objects.attacks.Attack;
import objects.attacks.NormalAttack;
import objects.attacks.TripleAttack;
import objects.Camera;
import objects.Tile;
import pixi.core.math.Point;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;

/**
 * ...
 * @author ToTos
 */
class Misc {

	private static var squareColliMax:Tile;
	private static var squareColliMin:Tile;

	/**
	 * Fonction de calcul de distance entre 2 objects
	 * @return distance between obj1 / obj2
	 */ 
	public static function getDistance (x1:Float, y1:Float, x2:Float, y2:Float):Float {
		var dx:Float = x1 - x2;
		var dy:Float = y1 - y2;
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	
	public static function getDistanceBetweenTiles(tile1:Array<Int>, tile2:Array<Int>):Float{
		var tile1Ab = convertToAbsolutePosition(tile1);
		var tile2Ab = convertToAbsolutePosition(tile2);
		return getDistance(tile1Ab[0], tile1Ab[1], tile2Ab[0], tile2Ab[1]);
	}
	
	/**
	 * Calcule l'angle en radian entre les objets S et T en absolute
	 * @return angle in radian between S and T 
	 */
	public static function angleBetween (s:Array<Float>, t:Array<Float>):Float {
		return - Math.atan2(t[1] - s[1], t[0] - s[0]);
	}
	
	/**
	 * renvoie la direction 
	 * @param	angle en radian
	 * @return	la direction (0 => b-l / 1 => u-l / 2 => u-r / 3 => b-r)
	 */
	public static function convertAngleToDirection(angle:Float):Int {
		if(Math.abs(angle) / Math.PI  > 0.5)
			if (angle > 0)
				return 1;
			else
				return 0;
		else
			if (angle > 0)
				return 2;
			else
				return 3;
	}
	
	public static function getDirectionToPoint(source:Array<Int>, target:Array<Int>):Int{
		return convertAngleToDirection(angleBetweenTiles(source, target));
	}
	
	/**
	 * Calcule l'angle en radian entre les objets from et to en tilePos
	 * @return angle in radian between from and to 
	 */
	public static function angleBetweenTiles(from:Array<Int>,to:Array<Int>):Float{
		return angleBetween(convertToAbsolutePosition(from), convertToAbsolutePosition(to));
	}
	
	/**
	 * convertie une position de tile de grid => en pixel
	 * @return absolute position in PIXELS of tilePosition
	 */
	public static function convertToAbsolutePosition (tilePosition:Array<Int>):Array<Float> {
		var returnPosition:Array<Float> = [];
		returnPosition[0] = tilePosition[0] * Main.tileSize[0];
		if (Math.abs(tilePosition[1] % 2) == 1)
			returnPosition[0] += Main.tileSize[0] * 0.5;		
		returnPosition[1] = tilePosition[1] * Main.tileSize[1] * 0.5;
		return cast returnPosition;
	}
	
	
	/**
	 * convertie une position de pixel => en tile
	 */
	public static function convertToGridPosition(absoluteX:Float, absoluteY:Float, ?withCamera:Bool):Array<Int> {
		if (withCamera)
		{
			absoluteX += Camera.getInstance().offset[0];
			absoluteY += Camera.getInstance().offset[1];
		}
		
		var tileSize = Main.tileSize;
		var halfMousePosX:Float = Math.floor((absoluteX) / (tileSize[0]/2))/2;
		var halfMousePosY:Float = Math.floor((absoluteY) / (tileSize[1] / 2)) / 2;
		
		if (halfMousePosX % 1 != 0)
			halfMousePosX += 0.5;
		if (halfMousePosY % 1 != 0)
			halfMousePosY += 0.5;

		var dx = (absoluteX - halfMousePosX * tileSize[0]) / tileSize[0]*2;
		var dy = (absoluteY - halfMousePosY * tileSize[1]) / tileSize[1] *2;
		var SelectedPos:Array<Int> = (Math.abs(dx)+ Math.abs(dy) <= 1) ? cast [halfMousePosX, halfMousePosY] : cast [halfMousePosX + ((dx / Math.abs(dx)) * 0.5), halfMousePosY + ((dy / Math.abs(dy))*0.5)]; 
		SelectedPos[0] = Math.floor(SelectedPos[0]);
		SelectedPos[1] *= 2;
		
//		trace(SelectedPos);
		return SelectedPos;
	}
	
	
	public static function getRangeTileAround(tilePos:Array<Int>, minRange:Int = 0, maxRange:Int = 10):Array<Array<Int>>
	{	
		if (minRange == 0 && maxRange == 0)
			return [tilePos];
			
		var ArrayOfPos:Array<Array<Int>> = [];
		
		var GridAround:Array<Array<Int>> = [];
		var iter:IntIterator = new IntIterator(Math.floor(-maxRange * 0.5),Math.floor(2 + maxRange * 0.5));
		for (i in iter) {
			var iter2:IntIterator = new IntIterator(- maxRange,1 +maxRange);
			for (j in iter2) {
				GridAround.push([tilePos[0] + i, tilePos[1] - j]);
			}
		}
		
		//Misc.placeTilePointer(cast GridAround,0x0000FF);
		
		var centerAbsolutePos:Array<Float> = Misc.convertToAbsolutePosition(cast tilePos);
		
		if (squareColliMax == null)
		{
			squareColliMax = new Tile(Texture.fromImage(""));
			squareColliMax.anchor.set(0.5, 0.5);
		}
		
		if (squareColliMin == null)
		{
			squareColliMin = new Tile(Texture.fromImage(""));
			squareColliMin.anchor.set(0.5, 0.5);
		}
		squareColliMin.width = (minRange -1) * Main.tileSize[0] + 4;
		squareColliMin.height = (minRange  -1) * Main.tileSize[1] + 4;
		squareColliMin.x = centerAbsolutePos[0] - 2;
		squareColliMin.y = centerAbsolutePos[1] - 2;
			
		squareColliMax.width = maxRange * Main.tileSize[0] + 4;
		squareColliMax.height = maxRange * Main.tileSize[1] + 4;
		squareColliMax.x = centerAbsolutePos[0] - 2;
		squareColliMax.y = centerAbsolutePos[1] - 2;
		
		for (i in GridAround.iterator()) {
			var absolutePosPoint = Misc.convertToAbsolutePosition(i);
			if (Misc.colliSquarePoint(squareColliMax, absolutePosPoint))
				if (!Misc.colliSquarePoint(squareColliMin, absolutePosPoint) || minRange == 0)
					ArrayOfPos.push(i);
		}
		//Misc.placeTilePointer(cast ArrayOfPos,0xFFFF00);
		//Misc.placeTilePointer(cast [tilePos],0xFF0000);
		
		return ArrayOfPos;
	}
	
	public static function colliSquarePoint(obj:Sprite, point:Array<Float>, ?cameraAffected:Bool):Bool {
		var offset:Array<Float> = cameraAffected ? Camera.getInstance().offset : [0,0];
		var target:Point = untyped obj.getGlobalPosition(null);
		var size:Dynamic = { width:obj.width, height:obj.height };
		if(obj.parent != null)
			size = untyped obj.getBounds(null);
		
		if (obj.anchor == null)
			obj.anchor = new Point(0, 0);
			
		if (target.x - (size.width * obj.anchor.x)> point[0] + offset[0])
			return false;
		if (target.y - (size.height * obj.anchor.y) > point[1] + offset[1])
			return false;
		if (target.x + size.width - (size.width * obj.anchor.x) < point[0] + offset[0])
			return false;
		if (target.y + size.height - (size.height * obj.anchor.y) < point[1] + offset[1])
			return false;
		
		return true;
	} 
	
	public static function colliSquareSquare(obj1:Sprite,obj2:Sprite):Bool{
		if (obj1.x - obj1.width * obj1.anchor.x > obj2.x + obj2.width - obj2.width * obj2.anchor.x)
			return false;
		if (obj1.y - obj1.height * obj1.anchor.y > obj2.y + obj2.height - obj2.height * obj2.anchor.y)
			return false;
		if (obj1.x + obj1.width - (obj1.width * obj1.anchor.x) < obj2.x - obj2.width * obj2.anchor.x)
			return false;
		if (obj1.y + obj1.height - (obj1.height * obj1.anchor.y) < obj2.y - obj2.height * obj2.anchor.y)
			return false;
		
		return true;
	} 
	
	public static function sign(number:Dynamic):Int { return (number > 0) ? 1 : ((number < 0) ? -1 : 0); }
	
	/**
	 * Clamps the value of Number between min and max,
	 * notes that it doesn't change the value straight away
	 * USE :
	 * number = Misc.Clamp(number, 0 , 5);
	 * @return the clamped value;
	 */
	public static function clamp(number:Float, min:Float, max:Float):Float {
		if (number < min)
			return min;
		if (number > max)
			return max;
		return number;
	}	
	
	public static function targetInRange(target:Array<Int>, tilesInRange:Array<Array<Int>>):Bool {
		for (i in tilesInRange.iterator())
		{
			if (i[0] == target[0] && i[1] == target[1]){
				return true;
			}
		}
		return false;
	}
	
	public static function hasLineOfSight(from:Array<Int>, to:Array<Int>, tilesInRange:Array<Array<Int>>, ?precalculatedObstacleList:Array<Array<Array<Array<Float>>>>):Bool
	{
		var absoluteFrom:Array<Float> = convertToAbsolutePosition(from);
		var absoluteTo:Array<Float> = convertToAbsolutePosition(to);
		
		// OPTIMISATION !!!
		
		var obstacleList:Array<Array<Array<Array<Float>>>>;
		
		if (precalculatedObstacleList == null)
			obstacleList = generateObstacleMap(tilesInRange)
		else
			obstacleList = precalculatedObstacleList;
		
		for (tileCollision in obstacleList.iterator())
			for (segment in tileCollision.iterator())
			{
				if (isSameTile(convertToGridPosition(segment[0][0],segment[0][1]), to)){
					if (CharacterManager.getInstance().findCharacterAtTilePos(to) != null)
						continue;
				}
				else if (doLinesIntersect(absoluteFrom, absoluteTo, segment[0], segment[1]))
					return false;
			}
					
		return true;		
	}
	
	public static function processLOSRange(from:Array<Int>, range:Array<Array<Int>>):Array<Array<Int>>
	{
		var obstacleList:Array<Array<Array<Array<Float>>>> = generateObstacleMap(range);
		
		var i:Int = 0;
		while (i < range.length)
		{
			if (!hasLineOfSight(from, range[i], range, obstacleList))
			{
				range.splice(i, 1);
				--i;
			}
			++i;
		}
		
		return range;
	}
	
	public static function isSameTile(pos1:Array<Int>, pos2:Array<Int>):Bool{
		return pos1[0] == pos2[0] && pos1[1] == pos2[1];
	}
	
	
	private static function generateObstacleMap(range:Array<Array<Int>>):Array<Array<Array<Array<Float>>>>{
		var obstacleList:Array<Array<Array<Array<Float>>>> = [];
		for (tilePos in range.iterator())
			if(MapManager.getInstance().activeMap.getTileAt(tilePos) != null)
				if (!MapManager.getInstance().activeMap.getLOSAt(tilePos))
					obstacleList.push(generateTileCollisions(MapManager.getInstance().activeMap.getTileAt(tilePos)));
				
		return obstacleList;
	}
	
	private static function generateTileCollisions(tile:Tile):Array<Array<Array<Float>>>
	{
		var errorMargin:Int = 1;
		var returnArray:Array<Array<Array<Float>>> = [];
		returnArray.push(	[[tile.x, tile.y - errorMargin],
							[tile.x - Main.tileSize[0] * 0.5 + errorMargin, tile.y - Main.tileSize[1] * 0.5]]); //bottom left
							
		returnArray.push(	[[tile.x - Main.tileSize[0] * 0.5 + errorMargin, tile.y - Main.tileSize[1] * 0.5],
							[tile.x, tile.y - Main.tileSize[1] + errorMargin]]); //top left
							
		returnArray.push(	[[tile.x, tile.y - Main.tileSize[1] + errorMargin], 
							[tile.x + Main.tileSize[0] * 0.5 - errorMargin, tile.y - Main.tileSize[1] * 0.5]]);//top right
		
		returnArray.push(	[[tile.x + Main.tileSize[0] * 0.5 - errorMargin, tile.y - Main.tileSize[1] * 0.5],
							[tile.x, tile.y - errorMargin]]); //bottom right
							
		return returnArray;
	}
	
	private static function doLinesIntersect(a1:Array<Float>, a2:Array<Float>, b1:Array<Float>, b2:Array<Float>):Bool {
		// Fastest method, based on Franklin Antonio's "Faster Line Segment Intersection" topic "in Graphics Gems III" book (http://www.graphicsgems.org/)
		var ax = a2[0]-a1[0],
			ay = a2[1]-a1[1],
			bx = b1[0]-b2[0],
			by = b1[1]-b2[1],
			cx = a1[0]-b1[0],
			cy = a1[1]-b1[1],
			alphaNumerator = by*cx - bx*cy,
			commonDenominator = ay * bx - ax * by;
			
		if (commonDenominator > 0){
			if (alphaNumerator < 0 || alphaNumerator > commonDenominator)
				return false;
		} else if (commonDenominator < 0){
			if (alphaNumerator > 0 || alphaNumerator < commonDenominator)
				return false;
		}
		var betaNumerator = ax*cy - ay*cx;
		if (commonDenominator > 0){
			if (betaNumerator < 0 || betaNumerator > commonDenominator)
				return false;
		}else if (commonDenominator < 0){
			if (betaNumerator > 0 || betaNumerator < commonDenominator)
				return false;
		}
		if (commonDenominator == 0){
			var y3LessY1 = b1[1]-a1[1];
			var collinearityTestForP3 = a1[0]*(a2[1]-b1[1]) + a2[0]*(y3LessY1) + b1[0]*(a1[1]-a2[1]);   // see http://mathworld.wolfram.com/Collinear.html
			if (collinearityTestForP3 == 0){
				if (a1[0] >= b1[0] && a1[0] <= b2[0] || a1[0] <= b1[0] && a1[0] >= b2[0] ||
					a2[0] >= b1[0] && a2[0] <= b2[0] || a2[0] <= b1[0] && a2[0] >= b2[0] ||
					b1[0] >= a1[0] && b1[0] <= a2[0] || b1[0] <= a1[0] && b1[0] >= a2[0]){
					if (a1[1] >= b1[1] && a1[1] <= b2[1] || a1[1] <= b1[1] && a1[1] >= b2[1] ||
						a2[1] >= b1[1] && a2[1] <= b2[1] || a2[1] <= b1[1] && a2[1] >= b2[1] ||
						b1[1] >= a1[1] && b1[1] <= a2[1] || b1[1] <= a1[1] && b1[1] >= a2[1]){
						return true;
					}
				}
			}
			return false;
		}
		return true;
	}
	
	public static function placeTilePointer (positions:Array<Array<Int>>, ?color:Int, ?absolute:Bool = false):Void {
		for (i in positions.iterator()) {
			if (!absolute)
			{
				var displayX:Float = i[0] * Main.tileSize[0];
				var displayY:Float = i[1] * Main.tileSize[1] / 2;
				
				if (Math.abs(i[1] % 2) == 1)
					displayX += Main.tileSize[0] * 0.5;
				
				displayY += Main.tileSize[1] * 0.5;
			}
			var newPointer:Tile = PoolManager.pullObject("pointer");
			var specialColor = color != null ? color: 0xFFFFFF;
			if (!absolute)
				newPointer.setTilePosition(i);
			else
				newPointer.setAbsolutePosition(i[0], i[1]);
				
			newPointer.tint = specialColor;
			newPointer.visible = true;
			newPointer.anchor.set(0.5, 0.5);
			DrawManager.addToDisplay(newPointer, Main.getInstance().tileCont, 100);
		}
		
	}
	
	public static function getClosestPosFromDirection(target:Array<Int>, direction:Int):Array<Int>
	{
		var returnPos:Array<Int> = [target[0],target[1]];
		
		if (direction == 0)
		{
			if (target[1] % 2 == 0){
				--returnPos[0];
				++returnPos[1]; 
			}
			else
				++returnPos[1];
		}
		else if (direction == 1)
		{
			if (target[1] % 2 == 0){
				--returnPos[0];
				--returnPos[1]; 
			}
			else
				--returnPos[1];
		}
		else if (direction == 2)
		{
			if (target[1] % 2 == 0)
				--returnPos[1];
			else{
				++returnPos[0];
				--returnPos[1];
			}
		}
		else
		{
			if (target[1] % 2 == 0)
				++returnPos[1];
			else{
				++returnPos[0];
				++returnPos[1];
			}
		}
		
		return returnPos;
	}
	
	public static function removeAllPointers ():Void {
		PoolManager.applyFunctionToPool("pointer", function(element) { element.visible = false; } );
	}
	
	
	public static function getTileFromEvent(e:EventTarget):Array<Int>
	{
		return  convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y);
	}
}