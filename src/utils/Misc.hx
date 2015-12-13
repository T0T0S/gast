package utils;
import js.Browser;
import managers.InitManager;
import managers.MapManager;
import managers.MouseManager;
import managers.PoolManager;
import objects.attacks.Attack;
import objects.attacks.NormalAttack;
import objects.attacks.TripleAttack;
import objects.Camera;
import objects.GameMap;
import objects.Tile;
import pixi.core.display.DisplayObject;
import pixi.core.math.shapes.Rectangle;
import pixi.core.sprites.Sprite;
import pixi.core.math.Point;

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
		
		//MouseManager.createLilCubes(cast GridAround,0x0000FF);
		
		var centerAbsolutePos:Array<Float> = Misc.convertToAbsolutePosition(cast tilePos);
		
		if (squareColliMax == null)
		{
			squareColliMax = PoolManager.pullObject("tile",1)[0];
			squareColliMax.anchor.set(0.5, 0.5);
		}
		
		if (squareColliMin == null)
		{
			squareColliMin = PoolManager.pullObject("tile",1)[0];
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
		//MouseManager.createLilCubes(cast ArrayOfPos,0xFFFF00);
		//MouseManager.createLilCubes(cast [tilePos],0xFF0000);
		
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
	
	public static function sign(number):Int { return number > 0 ? 1 : -1; }
	
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
	
	
	public static function getAttackFromName(name:String, data:Dynamic):Attack{
		switch name{
			case "normal": return new NormalAttack(data);
			case "triple": return new TripleAttack(data);
		}
		Browser.window.console.warn("ATTACK NOT FOUND !");
		return new Attack(data);
	}
	
	
	public static function targetInRange(source:Array<Int>, target:Array<Int>, tilesInRange:Array<Array<Int>>):Bool {
		for (i in tilesInRange.iterator())
		{
			if (i[0] == target[0] && i[1] == target[1]){
				return true;
			}
		}
		
		return false;
		
	}
	
	static inline function fastAbs(v:Dynamic) : Int {
		return (v ^ (v >> 31)) - (v >> 31);
	}	
 
	static inline function fastFloor(v:Float) : Int {
		return Std.int(v);
	}
		
	
	// algo de bresenham;
	public static function checkLine(x0:Int, y0:Int, x1:Int, y1:Int):Array<Array<Int>> {
		var rayCanPass  = function(x, y) { return MapManager.getInstance().activeMap.getWalkableAt([x, y]); };
		var swapXY = fastAbs( y1 - y0 ) > fastAbs( x1 - x0 );
		var tmp : Int;
		if ( swapXY ) {
			// swap x and y
			tmp = x0; x0 = y0; y0 = tmp; // swap x0 and y0
			tmp = x1; x1 = y1; y1 = tmp; // swap x1 and y1
		}
		 
		if ( x0 > x1 ) {
			// make sure x0 < x1
			tmp = x0; x0 = x1; x1 = tmp; // swap x0 and x1
			tmp = y0; y0 = y1; y1 = tmp; // swap y0 and y1
		}
		 
		var deltax = x1 - x0;
		var deltay = fastFloor( fastAbs( y1 - y0 ) );
		var error = fastFloor( deltax / 2 );
		var y = y0;
		var ystep = if ( y0 < y1 ) 1 else -1;
		var pts:Array<Array<Int>> = [];
		if( swapXY )
			// Y / X
			for ( x in x0 ... x1+1 ) {
				pts.push([y,x]);
				if( !rayCanPass(y,x) )
					return pts;
					 
				error -= deltay;
				if ( error < 0 ) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		else
			// X / Y
			for ( x in x0 ... x1+1 ) {
				pts.push([x,y]);
				if( !rayCanPass(x,y) )
					return pts;
					 
				error -= deltay;
				if ( error < 0 ) {
					y = y + ystep;
					error = error + deltax;
				}
			}
		return pts;
	}
	
	public static function convertOrthoToIso(orthoPos:Array<Array<Int>>):Array<Array<Int>>{
		var i:Int = 0;
		while (i < orthoPos.length) {
			if (i == 0){ // skip first
				++i;
				continue;
			}
			
			if (orthoPos[i - 1][1] % 2 == 0)
			{
				if (orthoPos[i - 1][0] - orthoPos[i][0] < 0)
				{
					if (orthoPos[i - 1][1] - orthoPos[i][1] < 0)
					{
						//wrong diago down right move
						if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0] + 1, orthoPos[i - 1][1]]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0] + 1, orthoPos[i - 1][1]]);
							++i;
						}
						else if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0], orthoPos[i - 1][1] +1]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0], orthoPos[i - 1][1] +1]);
							++i;
						}
						else
						{
							trace("BREAK");
							orthoPos.splice(i, orthoPos.length - i - 1);
							i = 300000;
						}
					
					}
					else if(orthoPos[i - 1][1] - orthoPos[i][1] > 0)
					{
						//wrong diago up right move
						if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0] + 1, orthoPos[i - 1][1]]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0] + 1, orthoPos[i - 1][1]]);
							++i;
						}
						else if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0], orthoPos[i - 1][1]  - 1]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0], orthoPos[i - 1][1] - 1]);
							++i;
						}
						else
						{
							trace("BREAK");
							orthoPos.splice(i, orthoPos.length - i - 1);
							i = 300000;
						}
					}
				}
			}
			else
			{
				if (orthoPos[i - 1][0] - orthoPos[i][0] > 0)
				{
					if (orthoPos[i - 1][1] - orthoPos[i][1] < 0)
					{
						//wrong diago down left move
						if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0] - 1, orthoPos[i - 1][1]]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0] - 1, orthoPos[i - 1][1]]);
							++i;
						}
						else if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0], orthoPos[i - 1][1] +1]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0], orthoPos[i - 1][1] +1]);
							++i;
						}
						else
						{
							trace("BREAK");
							orthoPos.splice(i, orthoPos.length - i - 1);
							i = 300000;
						}
					
					}
					else if(orthoPos[i - 1][1] - orthoPos[i][1] > 0)
					{
						//wrong diago up left move
						if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0] - 1, orthoPos[i - 1][1]]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0] - 1, orthoPos[i - 1][1]]);
							++i;
						}
						else if (MapManager.getInstance().activeMap.getWalkableAt([orthoPos[i - 1][0], orthoPos[i - 1][1]  - 1]))
						{
							trace("addPoint");
							orthoPos.insert(i, [orthoPos[i - 1][0], orthoPos[i - 1][1] - 1]);
							++i;
						}
						else
						{
							trace("BREAK");
							orthoPos.splice(i, orthoPos.length - i - 1);
							i = 300000;
						}
					}
				}
			}
			++i;
		}
			
			
		
		//PHASE DECOUPE
		i = 0;
		while (i < orthoPos.length) {
			if (i < 2){// skip 2 first
				++i;
				continue;
			}
			
			if (orthoPos[i][0] == orthoPos[i - 1][0] && orthoPos[i][0] == orthoPos[i - 2][0])
			{
				trace("cutPoint");
				orthoPos.splice(i - 1, 1);
			}
			++i;
		}
		
		return orthoPos;
	}
	
	public static function traceRay(from:Array<Int>, to:Array<Int>):Void{
		//MouseManager.createLilCubes(cast checkLine(from[0],from[1], to[0], to[1]));
		MouseManager.createLilCubes(cast convertOrthoToIso(checkLine(from[0],from[1], to[0], to[1])));
	}
	
}