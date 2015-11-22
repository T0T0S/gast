package objects;

import js.Error;
import managers.DrawManager;
import managers.InitManager;
import pixi.core.textures.Texture;
import pixi.extras.MovieClip;
import utils.Id;

/**
 * ...
 * @author ToTos
 */

class Tile extends pixi.extras.MovieClip{
	
	public var tilePosition = { x:0, y:0 };
	public var tileSize:Array<Int> = [];
	public var tileTaken:Array<Array<Int>> = [];
	public var placed:Bool = false;
	public var tileName:String;
	public var Zindex:Int = 0;
	public var layer:Int = 0;
	
	
	public var ID:String = Id.newId();
	
	private var tileInfo:Dynamic;
	private var tileSizeConfig:Array<Int>;

	public function new(pname:String, tilePosition:Array<Int>) {
		tileSizeConfig = InitManager.data.config.tileSize;
		tileInfo = InitManager.data.config.tileTypes[untyped pname];
		if (tileInfo == null)
			throw new Error("Le name '"+pname+"' n'a pas été trouvé dans la config lors de la création de la tile N°"+ID);
		tileSize = tileInfo.size;
		tileName = pname;
		if (tileInfo.frames != null) {
			var frames:Array<Texture> = []; 
			var iter:IntIterator = new IntIterator(0, tileInfo.frames.length);
			for (i in iter) {
				frames.push(Texture.fromFrame(tileInfo.frames[i]));
			}
			
			super(frames);
			
			loop = tileInfo.loop != null ? tileInfo.loop : false;
			animationSpeed = (tileInfo.fps / 60);
			play();
		}
		else
			super([Texture.fromImage("assets/" + cast(tileInfo.image, String))]);
		
		settilePosition(tilePosition[0],tilePosition[1]);
		anchor.set(0.5,1);
	}
	
	/**
	 * modifie la position d'une tile,
	 * ### /!\ prend en compte le décalage due a l'iso /!\ ###
	 * @param	?newX {Int} la position en X tiles voulu (null si vous ne voulez pas modifier le x)
	 * @param	?newY {Int} la position en Y tiles voulu (null si vous ne voulez pas modifier le y)
	 */ 
	public function settilePosition(?newX:Int, ?newY:Int):Void {
		if (newX != null) {
			tilePosition.x = newX;
			x = newX * tileSizeConfig[0] + Main.camera.offset[0];
		}
		if (newY != null) {
			tilePosition.y = newY;
			y = newY * tileSizeConfig[1] * 0.5  + Main.camera.offset[1];
			if (Math.abs(tilePosition.y % 2) == 1)
				x = tilePosition.x * tileSizeConfig[0] + tileSizeConfig[0] * 0.5  + Main.camera.offset[0];
		}
	}
	

	public function getAbsolutePosition ():Array<Float> {
		var arrayToReturn:Array<Float> = [];
		arrayToReturn[0] = tilePosition.x * tileSizeConfig[0];
		arrayToReturn[1] = tilePosition.y * tileSizeConfig[1]/2;
		if(Math.abs(tilePosition.y % 2) == 1)
			arrayToReturn[0] += tileSizeConfig[0] * 0.5;
		return arrayToReturn;
	}
	/**
	 * décale le rendu de la tile en fonction de la position de la caméra passé en paramètre.
	 * @param	camPosition {Array}
	 */
	public function followCamera(camPosition:Array<Float>):Void {
		x = getAbsolutePosition()[0] + camPosition[0];
		y = getAbsolutePosition()[1] + camPosition[1];
	}
	
	public function update ():Void {
	}
	
	public function placeEffect():Void{
		
	}
	
	
	public function Destroy():Void {
		DrawManager.removeFromDisplay(this);
	}
	
}
