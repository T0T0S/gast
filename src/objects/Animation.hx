package objects;

/**
 * ...
 * @author ToTos
 */
class Animation{
	
	private var data:Array<Array<Int>>;
	public var name:String;
	private var loop:Bool;
	private var callback:Dynamic = function(){};
	public var fps:Int;
	
	private var direction:Int = 0;
	
	private var activeFrame:Float = 0;
	public var finished:Bool = false;
	public var preciseAnimFrame:Float = 0;
	
	public function new(newName:String, newData:Dynamic, ?endCallback) {
		name = newName;
		loop = newData.loop;
		data = newData.frameData;
		fps = newData.fps;
	}
	
	public function getFrames(newDirection:Int):Array<Int> {
		direction = newDirection;
		return data[direction];
	}
	
	public function getNextFrameIndex():Int
	{
		if (activeFrame > data[direction][1] || data[direction][1] == null){
			if (loop)
				activeFrame = data[direction][0];
			else
				endAction();
		}
		else
			activeFrame += 1 * (fps / 60);
		
		preciseAnimFrame = activeFrame - data[direction][0];
		return Math.floor(activeFrame);
	}
	
	public function resetAnim(newDir:Int):Void { activeFrame = getFrames(newDir)[0]; finished = false; }
	
	public function setPreciseAnimFrame(newPreciseFrame:Float)
	{
		preciseAnimFrame = newPreciseFrame;
		activeFrame = data[direction][0] + preciseAnimFrame;
	}
	
	public function getLastIndex():Int {
		if(data[direction][1] != null)
			return data[direction][1];
		return data[direction][0];
	}
	
	public function endAction():Void {
		finished = true;
		callback();
	}
}