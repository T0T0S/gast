package objects.character;
import managers.DrawManager;
import managers.HudManager;
import managers.MapManager;
import objects.character.Character;
import objects.OSmovieclip;
import objects.Tile;
import pixi.core.sprites.Sprite;
import pixi.core.textures.Texture;
import pixi.interaction.EventTarget;
import utils.Debug;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class Player extends Character{
	
	private var movementTile:Array<Tile> = [];
	private var targetTile:Tile;
	
	public static var selectedAction:String = null;

	private var APFlash:OSmovieclip;
	
	public function new(newName:String) {
		super(newName);
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("HP").text = stats.health;
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
		
		for (i in 0...cast(stats.MaxAP+1))
		{
			movementTile.push(new Tile(Texture.fromImage("tile.png")));
			movementTile[i].visible = false;
			movementTile[i].tint = 0x00FF00;
		}
		
		targetTile = new Tile(Texture.fromImage("tile.png"));
		targetTile.visible = false;
		
		Main.getInstance().tileCont.on("mousemove", mouseHover);
		Main.getInstance().tileCont.on("mouseup", mapClick);
		
		APFlash = new OSmovieclip([
			Texture.fromFrame("y_explo_0"),
			Texture.fromFrame("y_explo_1"),
			Texture.fromFrame("y_explo_2"),
			Texture.fromFrame("y_explo_3"),
			Texture.fromFrame("y_explo_4"),
			Texture.fromFrame("y_explo_5"),
			Texture.fromFrame("y_explo_6")
		]);
		APFlash.anchor.set(0.5, 0.5);
		APFlash.animationSpeed = 0.5;
	}
	
	private function mapClick(e:EventTarget):Void {
		var tilePos = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y, true);
		if(selectedAction == "move")
			if (!Camera.getInstance().isDragged) {
				findPathTo(tilePos,true);
			}
		else if(selectedAction == "attack"){
			launchAttack(tilePos);
			
			/*
			 * gerer les portées!
			 * afficher les porter de deplacement et d'attack
			 * */
		}
		hideHoverTile();
		hidePathMovement();
		selectedAction = null;
	}
	
	private function mouseHover(e:EventTarget):Void {
		var tilePos = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y, true);
		if(selectedAction == "move")
			showPathMovement(findPathTo(tilePos));
		else if (selectedAction == "attack") {
			showHoverTile(tilePos, 0xFF0000);
		}
		Debug.log("" + tilePos);
	}
	
	override public function newTick(tickNumber:Int):Void {
		super.newTick(tickNumber);
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
		
		if (APFlash.parent == null) {
			DrawManager.addToDisplay(APFlash, untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP"));
			APFlash.scale.set(2 *(1 / APFlash.parent.parent.scale.x), 2 *(1 / APFlash.parent.parent.scale.y));
		}
		APFlash.gotoAndPlay(0);
	}
	
	override public function damage(amount:Float):Void {
		super.damage(amount);
		untyped Main.getInstance().hudCont.getChildByName("HP").text = stats.health;
	}
	
	public function showPathMovement(path:Array<Dynamic>):Void{
		hidePathMovement();
		path.shift();
		if (path.length == 0 || path.length > stats.AP)
			return;
		
		var j:Int = 0;
		for (i in path.iterator())
		{
			movementTile[j].visible = true;
			movementTile[j].setTilePosition([i.x, i.y]);
			if (movementTile[j].parent == null)
				if (parent != null)
					DrawManager.addToDisplay(movementTile[j], parent,untyped 0.5);
			j++;
		}
	}
	
	public function hidePathMovement():Void{
		for (i in movementTile.iterator() ){
			i.visible = false;
		}
	}
	
	public function showHoverTile(tilePos:Array<Int>, newTint:Int = null):Void {
		if (targetTile.parent == null){
			DrawManager.addToDisplay(targetTile, MapManager.getInstance().activeMap.mapContainer, untyped 0.5);
		}
		targetTile.setTilePosition(tilePos);
		targetTile.visible = true;
		targetTile.tint = newTint != null ? newTint : null;	
	}
	
	public function hideHoverTile(remove:Bool = false):Void {
		targetTile.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(targetTile);
	}
	
	override public function useAp(amount:Int):Void {
		super.useAp(amount);
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
	}
	
}