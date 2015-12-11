package objects.character;
import js.Browser;
import js.html.RGBColor;
import managers.CharacterManager;
import managers.DrawManager;
import managers.HudManager;
import managers.MapManager;
import managers.PoolManager;
import objects.character.Character;
import objects.particle.OSmovieclip;
import objects.Tile;
import pixi.core.display.Container;
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
	private static var instance:Player;

	private var tilePool:Array<Tile> = [];
	private var targetTile:Tile;
	
	public static var selectedAction:String = "move";

	private var APFlash:OSmovieclip;
	private var pathPositions:Array<Int> = [];
	
	private var mouseHovering:Bool = false;
	
	private function new() {
		super("hero");
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("HP").text = stats.health;
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
		
		tilePool = cast PoolManager.pullObject("tile", stats.MaxAP * 2);
		for (i in tilePool.iterator())
		{
			i.tint = 0x00FF00;
		}
		
		targetTile = new Tile(Texture.fromImage("tile.png"));
		targetTile.visible = false;
		
		Main.getInstance().tileCont.on("mousemove", mapHover);
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
	
	private function mouseOverSelf(e:EventTarget):Void {
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement = true){
				showRange(0, stats.AP, 0x00FF00, 0.7);
			}
	}
	
	private function mouseOutSelf(e:EventTarget):Void{
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement = true){
				hidePoolTiles();
			}
	}
	
	private function mapClick(e:EventTarget):Void {
		var newtilePos = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y);

		if (selectedAction == "move") {
			if (!Camera.getInstance().isDragged) {
				findPathTo(newtilePos,true);
			}
		}
		else if (attacks.exists(selectedAction)) {
			launchAttack(selectedAction, newtilePos);
		}
		hideHoverTile();
		hidePoolTiles();
		changeSelectedAction("move");
	}
	
	private function mapHover(e:EventTarget):Void {
		var newtilePos = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y);
		hidePoolTiles();
		hideHoverTile();

		if(selectedAction == "move"){
			showPathMovement(findPathTo(newtilePos));
		}
		else if (attacks.exists(selectedAction)) {
			showRange(attacks.get(selectedAction).minRange, attacks.get(selectedAction).maxRange, 0xFF4747, 0.3);
			if(Misc.targetInRange(tilePos, newtilePos, activeAttackRange))
				showHoverTile(newtilePos, 0xFF0000);
		}
		
		if (newtilePos[0] == tilePos[0] && newtilePos[1] == tilePos[1])
		{
			mouseHovering = true;
			mouseOverSelf(e);
		}
		else if (mouseHovering)
		{
			mouseHovering = false;
			mouseOutSelf(e);
		}

		Debug.log("" + newtilePos);
	}
	
	override public function newTick(tickNumber:Int):Void {
		super.newTick(tickNumber);
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
		
		if (APFlash.parent == null) {
			DrawManager.addToDisplay(APFlash, untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP"));
			APFlash.scale.set(2 *(1 / APFlash.parent.parent.scale.x), 2 *(1 / APFlash.parent.parent.scale.y));
		}
		APFlash.gotoAndPlay(0);
		
		lockHudButtons();
		for (attackName in attacks.keys())
		{
			if(stats.AP < attacks.get(attackName).apCost)
				untyped Main.getInstance().hudCont.getChildByName("center").getChildByName(attackName).lock();
			else
				untyped Main.getInstance().hudCont.getChildByName("center").getChildByName(attackName).unlock();
		}
	}
	
	override public function damage(amount:Int):Void {
		super.damage(amount);
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("HP").text = stats.health;
	}
	
	
	private function lockHudButtons():Void{
		for (attackName in attacks.keys())
		{
			if(stats.AP < attacks.get(attackName).apCost)
				untyped Main.getInstance().hudCont.getChildByName("center").getChildByName(attackName).lock();
			else
				untyped Main.getInstance().hudCont.getChildByName("center").getChildByName(attackName).unlock();
		}
	}
	
	public function showPathMovement(path:Array<Dynamic>):Void{
		path.shift();
		if (path.length == 0 || path.length > stats.AP)
			return;
		
		for (i in pathPositions.iterator())
		{
			hideOnePoolTile(i);
		}
		pathPositions = [];
		
		for (i in path.iterator())
		{
			var tileIndex = getUnusedTileIndex(); 
			pathPositions.push(tileIndex);
			tilePool[tileIndex].visible = true;
			tilePool[tileIndex].tint = 0x00FF00;
			tilePool[tileIndex].setTilePosition([i.x, i.y]);
			if (tilePool[tileIndex].parent == null)
				if (parent != null)
					DrawManager.addToDisplay(tilePool[tileIndex], parent,untyped 0.5);
		}
	}
	
	public function showRange(min:Int, max:Int, ?color:Int, ?alpha:Float):Void {
		/*
		 * attention pour le pathfinding bug <= il calcule pas si on peux arriver aux positions.
		 * need to repredict after every end of path and stock the value.
		 * */
	
		for (i in activeAttackRange.iterator())
		{
			if(!MapManager.getInstance().activeMap.getWalkableAt(i) && CharacterManager.getInstance().findCharacterAtTilePos(i) == null)
				continue;
			var tileIndex = getUnusedTileIndex(); 
			tilePool[tileIndex].visible = true;
			tilePool[tileIndex].setTilePosition([i[0], i[1]]);
			if (tilePool[tileIndex].parent == null)
				if (parent != null)
					DrawManager.addToDisplay(tilePool[tileIndex], parent, untyped 0.5);
			if (color != null)
				tilePool[tileIndex].tint = color;
			
			if (alpha != null)
				tilePool[tileIndex].alpha = alpha;
		}
	}
	
	public function hidePoolTiles(?customCont:Container):Void {
		for (i in tilePool.iterator() ){
			i.visible = false;
			i.tint = 0xFFFFFF;
			i.alpha = 1;
		}
	}
	
	public function hideOnePoolTile(index:Int):Void {
		tilePool[index].visible = false;
		tilePool[index].tint = 0xFFFFFF;
		tilePool[index].alpha = 1;
	}
	
	public function getUnusedTileIndex():Int{
		for (i in tilePool.iterator() ){
			if (!i.visible)
				return tilePool.indexOf(i);
		}
		tilePool.push(PoolManager.pullObject("tile", 1)[0]);
		return tilePool.length -1;
	}
	
	public function showHoverTile(tilePos:Array<Int>, newTint:Int = null):Void {
		if (targetTile.parent == null){
			DrawManager.addToDisplay(targetTile, MapManager.getInstance().activeMap.mapContainer, untyped 0.5);
		}
		targetTile.setTilePosition(tilePos);
		targetTile.visible = true;
		targetTile.tint = newTint != null ? newTint : 0xFFFFFF;	
	}
	
	public function hideHoverTile(remove:Bool = false):Void {
		targetTile.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(targetTile);
	}
	
	override public function useAp(amount:Int):Void {
		super.useAp(amount);
		lockHudButtons();
		untyped Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = stats.AP;
	}
	
	public function changeSelectedAction(newActionName:String):Void{
		selectedAction = selectedAction == newActionName ? "move" : newActionName; 
	}
	
	public function generateAttackRange(attackName:String):Void {
		if(attacks.exists(attackName))
			activeAttackRange = Misc.getRangeTileAround(tilePos, attacks.get(attackName).minRange, attacks.get(attackName).maxRange);
		else
			Browser.window.console.warn("Attack not found while generating attackRange of:" + attackName);
		showRange(attacks.get(attackName).minRange, attacks.get(attackName).maxRange, 0xFF4747, 0.3);
	}
	
	public function hideEveryTile():Void{
		hideHoverTile();
		hidePoolTiles();
	}
	
	override public function Destroy():Void {
		super.Destroy();
		Main.getInstance().tileCont.off("mousemove", mapHover);
		Main.getInstance().tileCont.off("mouseup", mapClick);
	}
	
	public static function getInstance():Player{
		if (instance == null) instance = new Player();
		return instance;
	}
}