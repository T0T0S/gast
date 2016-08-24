package utils;



import haxe.Timer;
import js.Browser;
import js.Error;
import objects.modules.LOSModule.LOSPoint;
import pixi.core.display.Container;
import pixi.core.graphics.Graphics;
import pixi.core.math.Point;
import Main;
import managers.CharacterManager;
import managers.DrawManager;
import managers.MapManager;
import managers.PoolManager;
import objects.attacks.Attack;
import objects.attacks.NormalAttack;
import objects.attacks.TripleAttack;
import objects.Camera;
import objects.Tile;
import pixi.core.math.Point in PixPoint;
import pixi.core.math.shapes.Rectangle;
import pixi.core.Pixi.ScaleModes;
import pixi.core.sprites.Sprite;
import pixi.core.text.Text;
import pixi.core.textures.Texture;
import pixi.filters.color.ColorMatrixFilter;
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
	
	
	public static function getAbsoluteDistanceBetweenTiles(tile1:TilePoint, tile2:TilePoint):Float{
		var tile1Ab = convertToAbsolutePosition(tile1);
		var tile2Ab = convertToAbsolutePosition(tile2);
		return getDistance(tile1Ab.x, tile1Ab.y, tile2Ab.x, tile2Ab.y);
	}
	
	/**
	 * Calcule l'angle en radian entre les objets S et T en absolute
	 * @return angle in radian between S and T 
	 */
	public static function angleBetween (s:Point, t:Point):Float {
		return - Math.atan2(t.y - s.y, t.x - s.x);
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
	
	public static function getDirectionToPoint(source:TilePoint, target:TilePoint):Int{
		return convertAngleToDirection(angleBetweenTiles(source, target));
	}
	
	/**
	 * Calcule l'angle en radian entre les objets from et to en tilePos
	 * @return angle in radian between from and to 
	 */
	public static function angleBetweenTiles(from:TilePoint,to:TilePoint):Float{
		return angleBetween(convertToAbsolutePosition(from), convertToAbsolutePosition(to));
	}
	
	/**
	 * convertie une position de tile de grid => en pixel
	 * @return absolute position in PIXELS of tilePosition
	 */
	public static function convertToAbsolutePosition (tilePosition:TilePoint):Point {
		return new Point((tilePosition.x -  tilePosition.y) * Main.tileSize.x * 0.5, (tilePosition.x +  tilePosition.y) * Main.tileSize.y * 0.5);
	}
	
	
	/**
	 * convertie une position de pixel => en tile
	 */
	public static function convertToGridPosition(absoluteX:Float, absoluteY:Float):TilePoint {
		return new TilePoint(	Math.floor((absoluteY + absoluteX / 2) / Main.tileSize.y),
								Math.floor((absoluteY - absoluteX / 2) / Main.tileSize.y));
	}
	
	
	public static function getTilesAround(tilePos:TilePoint, minRange:Int = 0, maxRange:Int = 1, mapConstricted:Bool = true, removeWalls:Bool = false):Array<TilePoint>
	{	
		if (minRange == 0 && maxRange == 0)
			return [tilePos];
		var returnArray:Array<TilePoint> = [];
		
		var refMap = MapManager.getInstance().activeMap;
		
		for (i in -maxRange...maxRange+1) {
			for (j in -maxRange...maxRange+1) {
				if (mapConstricted)
				{
					if(tilePos.x + i >= 0 && tilePos.x + i < refMap.size.x && tilePos.y + j >= 0 && tilePos.y + j < refMap.size.y)
						if (!(Math.abs(i) + Math.abs(j) > maxRange) && !(Math.abs(i) + Math.abs(j) < minRange))
							returnArray.push(new TilePoint(tilePos.x + i, tilePos.y + j));
				}
				else
				{
					if (!(Math.abs(i) + Math.abs(j) > maxRange) && !(Math.abs(i) + Math.abs(j) < minRange))
						returnArray.push(new TilePoint(tilePos.x + i, tilePos.y + j));
				}
			}
		}
		
		if (removeWalls)
		{
			var i:Int = 0;
			while (i < returnArray.length)
			{
				if (!refMap.getWalkableAt(returnArray[i]))
				{
					returnArray.splice(i,1);
					i--;
				}
				i++;
			}
		}
		
		return returnArray;
	}
	
	public static function colliSquarePoint(obj:Sprite, point:Point, ?cameraAffected:Bool):Bool {
		var offset:Point = cameraAffected ? Camera.getInstance().offset : new Point();
		var target:Point = untyped obj.getGlobalPosition(null);
		var size:Dynamic = { width:obj.width, height:obj.height };
		if(obj.parent != null)
			size = untyped obj.getBounds(null);
		
		if (obj.anchor == null)
			obj.anchor = new PixPoint(0, 0);
			
		if (target.x - (size.width * obj.anchor.x)> point.x + offset.x)
			return false;
		if (target.y - (size.height * obj.anchor.y) > point.y + offset.y)
			return false;
		if (target.x + size.width - (size.width * obj.anchor.x) < point.x + offset.x)
			return false;
		if (target.y + size.height - (size.height * obj.anchor.y) < point.y + offset.y)
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
	
	public static function targetInRange(target:TilePoint, tilesInRange:Array<LOSPoint>):Bool {
		for (i in tilesInRange.iterator())
		{
			if (i.equals(target))
				return i.isVisible;
		}
		return false;
	}
	
	
	
	//public static function processLOSRange(from:TilePoint, range:Array<TilePoint>):Array<TilePoint>
	//{
		//var goodTiles:Array<TilePoint> = [];
		//for (tile in range)
		//{
			//if (hasLineOfSight(from, tile))
				//goodTiles.push(tile);
		//}
		//return goodTiles;
	//}
	

	
		
	public static function getTileLine(p0:TilePoint, p1:TilePoint):Array<TilePoint>
	{
		var points:Array<TilePoint> = [];
		var N:Int = diagonal_distance(p0, p1);
		for (i in 0...N+1) {
			var t = N == 0? 0.0 : i / N;
			points.push(round_point(lerp_point(p0, p1, t)));
		}
		return points;
	}
	
	public static function getNumberOfTileInZone(minRange:Int, maxRange:Int)
	{
		return maxRange * maxRange + (maxRange+1) * (maxRange+1) - (minRange * minRange + (minRange+1) * (minRange+1));
	}
	
	public static function lerp(start:Float, end:Float, t:Float):Float {
		t = t > 1 ? 1 : t;
		t = t < 0 ? 0 : t;
		return start + t * (end-start);
	}
	
	static function lerp_point(p0:TilePoint, p1:TilePoint, t:Float):Point {
		return new Point(lerp(p0.x, p1.x, t),
						 lerp(p0.y, p1.y, t));
	}
	
	static function round_point(p:Point):TilePoint {
		return new TilePoint(Math.round(p.x), Math.round(p.y));
	}
	
	static function diagonal_distance(p0:TilePoint, p1:TilePoint):Int {
		var dx:Int = p1.x - p0.x, dy:Int = p1.y - p0.y;
		return cast Math.max(Math.abs(dx), Math.abs(dy));
	}
	
	public static function placeTilePointer (positions:Array<TilePoint>, ?color:Int, ?absolute:Bool = false):Void {
		for (i in positions.iterator()) {
			var newPointer:Tile = PoolManager.pullObject(PoolType.pointer);
			var specialColor = color != null ? color: 0xFFFFFF;
			if (!absolute)
				newPointer.setTilePosition(i.x, i.y);
			else
				newPointer.setAbsolutePosition(i.x, i.y);
				
			//newPointer.tint = 0x00FF00;
			newPointer.tint = specialColor;
			newPointer.visible = true;
			newPointer.anchor.set(0.5, 0.5);
			DrawManager.addToDisplay(newPointer, MapManager.getInstance().activeMap.mapContainer, 0.2);
		}
	}
	
	public static function getClosestPosFromDirection(target:TilePoint, direction:Int):TilePoint
	{
		switch direction {
			case 0: target.y++;
			case 1: target.x--;
			case 2: target.y--;
			case 3: target.x++;
		}
		
		return target;
	}
	
	public static function removeAllPointers ():Void {
		PoolManager.applyFunctionToPool(PoolType.pointer, function(element) { element.visible = false; } );
	}
	
	public static function getBasicMask():Graphics
	{
		var returnMask:Graphics = new Graphics();
		returnMask.beginFill(0xFFFFFF, 1);
		returnMask.drawRect(0, 0, 20, 20);
		returnMask.endFill();
		return returnMask;
	}
	
	public static function getRoundMask():Graphics
	{
		var returnMask:Graphics = new Graphics();
		returnMask.beginFill(0xFFFFFF, 1);
		returnMask.drawCircle(0, 0, 10);
		returnMask.endFill();
		return returnMask;
	}
	public static function generateButtonTextures(texture:Texture):Array<Texture>
	{
		var returnArray:Array<Texture> = [];
		var tempSprite:Sprite = new Sprite(texture);
		if (tempSprite.texture.valid == false)
		{
			throw new Error("Texture '"+texture.baseTexture.source.name+"' could not be generated.");
			return [];
		}
		var filter:ColorMatrixFilter = new ColorMatrixFilter();
		returnArray.push(tempSprite.generateTexture(Main.getInstance().renderer));
		
		tempSprite.filters = [filter];
		filter.brightness(1.3, false);
		returnArray.push(tempSprite.generateTexture(Main.getInstance().renderer));
		filter.brightness(0.7, false);
		returnArray.push(tempSprite.generateTexture(Main.getInstance().renderer));
		
		return returnArray;	
	}
	
	public static function displayTextOverTime(textObject:Text, delay:Int = 0, speed:Int = 50):Void
	{
		var timer =  new Timer(speed);
		var progression:Int = 0;
		var textToDisplay:String = textObject.text;
		textObject.text = "";
		Timer.delay(function(){
			timer.run = function(){
				if (progression > textToDisplay.length)
				{
					timer.stop();
					timer = null;
					return;
				}
				textObject.text = textToDisplay.substr(0, progression);
				++progression;
			};
		}, delay);
		
	}
	
	public static function get9slicedTexture(newTexture:Texture, width:Int, height:Int, scaleMode:Int = 2):Texture
	{
		var arraySprites:Array<Sprite> = [];
		var textureToSlice:Texture = untyped newTexture.clone();
		
		textureToSlice.baseTexture.scaleMode = scaleMode;
		
		var thirdW =  Math.floor(textureToSlice.width / 3);
		var thirdH =  Math.floor(textureToSlice.height / 3);
		
		var centerWidth:Float = width - (thirdW * 2);
		var centerHeight:Float = height - (thirdH * 2);
		for (i in 0...9)
		{
			arraySprites.push(new Sprite(new Texture(textureToSlice.baseTexture, new Rectangle(((i % 3) * thirdW) + textureToSlice.frame.x, Math.floor(i / 3) * thirdH + textureToSlice.frame.y,thirdW, thirdH))));
		}
		
		arraySprites[1].width = centerWidth;
		arraySprites[4].width = centerWidth;
		arraySprites[7].width = centerWidth;
		
		arraySprites[3].height = centerHeight;
		arraySprites[4].height = centerHeight;
		arraySprites[5].height = centerHeight;
		
		var returnContainer:Container = new Container();
		
		var j:Int = 0;
		for (sprite in arraySprites)
		{
			returnContainer.addChild(sprite);
			if (j % 3 != 0)
			{
				sprite.x = arraySprites[j -1].width + arraySprites[j -1].x;
			}
			if (Math.floor(j / 3) != 0)
			{
				sprite.y = arraySprites[j - 3].height + arraySprites[j - 3].y;
			}
				
			j++;
		}
		return returnContainer.generateTexture(Main.getInstance().renderer);	
	}
	
	public static function getTileFromEvent(e:EventTarget):TilePoint
	{
		return  convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y + Main.tileSize.y);
	}
}

