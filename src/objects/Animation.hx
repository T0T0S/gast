package objects;

/**
 * ...
 * @author ToTos
 */
class Animation{
	
	public var data:Array<Array<Int>>;
	public var name:String;
	public var loop:Bool;
	public var callback:Dynamic;
	public var fps:Int;
	
	private var direction:Int = 0;
	
	public function new(newName:String, newData:Dynamic, ?endCallback) {
		name = newName;
		loop = newData.loop;
		data = newData.frameData;
		fps = newData.fps;
		callback = endCallback;
	}
	
	public function getFrames(newDirection:Int):Array<Int> {
		direction = newDirection;
		return data[direction];
	}
	
	public function getLastIndex():Int{
		return data[direction][data[direction].length -1];
	}
	
	public function endAction():Void{
		callback();
	}
}