package objects;
import js.Browser;
import js.html.CanvasElement;
import js.html.ClientRect;
import js.html.InputElement;
import js.html.Node;

/**
 * ...
 * @author ToTos
 */
class TextInput{
	public var value(get, null):String;
	public var domInput:InputElement;
	
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	public var width(default, set):Float = 100;
	public var height(default, set):Float = 30;
	public var bgAlpha(default, set):Float = 1;
	public var color(default, set):String = "#31d031";
	
	private var canvasRef:CanvasElement;
	
	public function new() {
		domInput = Browser.document.createInputElement();
		canvasRef = Main.getInstance().renderer.view;
		domInput.type = "text";
		domInput.style.border = "none";
		domInput.style.position = "absolute";
		domInput.style.padding = "0";
		domInput.style.width = width+"px";
		domInput.style.height = height+"px";
		domInput.style.backgroundColor = "rgba(255,255,255," + bgAlpha + ")";
		domInput.style.color = "#31d031";
		domInput.style.fontFamily = "gastFont";
		domInput.style.fontSize = (height * 0.75)+"px";
		domInput.style.outline = "none";
		
		x = 0;
		y = 0;
	}
	
	private function set_x(value:Float) { x = canvasRef.offsetLeft + value; domInput.style.left = x + "px"; return x; }
	private function set_y(value:Float) { y =  canvasRef.offsetTop + value; domInput.style.top = y + "px"; return y; }
	private function set_width(value:Float) { width = value; domInput.style.width = width + "px"; return width; }	
	private function set_height(value:Float) { height = value;domInput.style.fontSize = (height * 0.75)+"px"; domInput.style.height = height + "px"; return height; }
	private function set_bgAlpha(value:Float) { bgAlpha = value; domInput.style.backgroundColor = "rgba(255,255,255,"+bgAlpha+")"; return bgAlpha; }
	private function set_color(value:String) { color = value; domInput.style.color = value; return color; }
	private function get_value() { return domInput.value; }	
	
	public function append()
	{
		Main.getInstance().renderer.view.parentNode.appendChild(domInput);
	}
	
	public function remove()
	{
		Main.getInstance().renderer.view.parentNode.removeChild(domInput);
	}
	
}