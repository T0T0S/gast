package objects.character;
import js.Browser;
import js.html.RGBColor;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
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
import states.DebugState;
import utils.Debug;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class Player extends Character{
	private static var instance:Player;

	private var targetTile:Tile;
	

	private var APFlash:OSmovieclip;
	private var pathPositions:Array<Dynamic> = [];
	
	private var mouseHovering:Bool = false;
	public var allowInput:Bool = true;
	
	private function new() {
		super("hero");
		
		HudManager.getInstance().HPmeter.text = ""+stats.health;
		HudManager.getInstance().APmeter.text = ""+stats.AP;
		
		targetTile = new Tile(Texture.fromImage("selectedTile.png"));
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
		if(!allowInput)
			return;
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement = true) {
				showRange(1, cast getMaxMovement(), 0x00FF00, 0.5);
			}
	}
	
	private function mouseOutSelf(e:EventTarget):Void{
		if(!allowInput)
			return;
			
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement = true){
				hidePoolTiles();
			}
	}
	
	private function mapClick(e:EventTarget):Void {
		if(!allowInput)
			return;
		var newtilePos = Misc.getTileFromEvent(e);

		if (selectedAction == "move" && !isMoving) {
			if (!Camera.getInstance().isDragged && !newtilePos.equals(tilePos)) {
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
		if(!allowInput)
			return;
		var tileHovered:TilePoint = Misc.getTileFromEvent(e);
		hidePoolTiles();
		hideHoverTile();
		
		if (selectedAction == "move" && !isMoving && !tileHovered.equals(tilePos)) {
			if(FightManager.status == StatusModes.fight)
				showPathMovement(findPathTo(tileHovered));
		}
		else if (attacks.exists(selectedAction) && FightManager.status == StatusModes.fight) {
			showAttackRange(selectedAction);
			if(Misc.targetInRange(tileHovered, losModule.getLOS()))
				showHoverTile(tileHovered, 0xFF0000);
		}
		
		if (tileHovered.equals(tilePos))
		{
			mouseHovering = true;
			mouseOverSelf(e);
		}
		else if (mouseHovering)
		{
			mouseHovering = false;
			mouseOutSelf(e);
		}
		
		Debug.log(""+tileHovered.toArray());
	}
	
	private function showAttackRange(attackName:String):Void{
		showRange(attacks.get(attackName).minRange, attacks.get(attackName).maxRange, 0xFF4747, 0.3);
	}
	
	override public function newTick(tickNumber:Int):Void {
		super.newTick(tickNumber * 10);
		HudManager.getInstance().APmeter.text = ""+stats.AP;
		
		//// DEBUG
		//if(!DebugState.superEnemy.isDead){
			//DebugState.superEnemy.findPathTo(tilePos,true);
		//}
		
		if (APFlash.parent == null) {
			DrawManager.addToDisplay(APFlash, HudManager.getInstance().APmeter);
			APFlash.scale.set(2 *(1 / APFlash.parent.parent.scale.x), 2 *(1 / APFlash.parent.parent.scale.y));
		}
		APFlash.gotoAndPlay(0);
		
		if (mouseHovering)
			mouseOverSelf(null);
		
			
		lockHudButtons();
	}
	
	override public function damage(amount:Int):Void {
		super.damage(amount);
		HudManager.getInstance().HPmeter.text = ""+stats.health;
	}
	
	
	private function lockHudButtons():Void{
		for (attackName in HudManager.getInstance().attackButtons.keys())
		{
			if(stats.AP < attacks.get(attackName).apCost)
				HudManager.getInstance().attackButtons.get(attackName).lock();
			else
				HudManager.getInstance().attackButtons.get(attackName).unlock();
		}
	}
	
	public function showPathMovement(path:Array<Dynamic>):Void{
		path.shift();
		if (path.length == 0 || path.length > getMaxMovement())
			return;
		
		for (i in pathPositions.iterator())
		{
			hideOnePoolTile(i);
		}
		pathPositions = [];
		
		for (i in path.iterator())
		{
			var newTile:Tile = PoolManager.pullObject("tile"); 
			newTile.visible = true;
			newTile.tint = 0x00FF00;
			newTile.alpha = 0.5;
			newTile.setTilePosition(i.x, i.y);
			pathPositions.push(newTile);
			if (newTile.parent == null)
				if (parent != null)
					DrawManager.addToDisplay(newTile, parent,untyped 0.5);
		}
	}
	
	@:deprecated("redo tile showing !!! important")
	public function showRange(min:Int, max:Int, ?color:Int, ?alpha:Float, ?customRange:Array<TilePoint>):Void {
		/*
		 * attention pour le pathfinding bug <= il calcule pas si on peux arriver aux positions.
		 * need to use dijkstra algo
		 * */
		if (!allowInput)
			return;
			
		hidePoolTiles();
		if (FightManager.status == StatusModes.normal)
			return;
		
		
		
		var arrayIter:Array<TilePoint> = selectedAction != "move" ? cast losModule.getLOS() : Misc.getTilesAround(tilePos, min, max);
		for (i in arrayIter.iterator())
		{
			if(!MapManager.getInstance().activeMap.getWalkableAt(i) && CharacterManager.getInstance().findCharacterAtTilePos(i) == null)
				continue;
			var newTile:Tile = PoolManager.pullObject("tile"); 
			newTile.visible = true;
			newTile.setTilePosition(i.x, i.y);
			if (newTile.parent == null)
				if (parent != null)
					DrawManager.addToDisplay(newTile, parent, untyped 0.5);
			if (color != null)
				newTile.tint = color;
			
			if (alpha != null)
				newTile.alpha = alpha;
		}
	}
	
	public function hidePoolTiles():Void {
		PoolManager.applyFunctionToPool("tile", poolHide);
	}
	
	/**
	 *  DON'T USE
	 */
	private function poolHide(i:Dynamic):Void{
		i.visible = false;
		i.tint = 0xFFFFFF;
		i.alpha = 1;
	}
	
	
	public function hideOnePoolTile(element:Dynamic):Void {
		PoolManager.applyFunctionToElement("tile", poolHide, element);
	}
	
	
	
	public function showHoverTile(tilePos:TilePoint, newTint:Int = null):Void {
		if (targetTile.parent == null){
			DrawManager.addToDisplay(targetTile, MapManager.getInstance().activeMap.mapContainer, untyped 0.7);
		}
		targetTile.setTilePosition(tilePos.x, tilePos.y);
		targetTile.visible = true;
		//targetTile.tint = newTint != null ? newTint : 0xFFFFFF;	
	}
	
	public function loseCombat():Void { trace("fight lost!"); }
	public function winCombat():Void { trace("fight won!"); }
	
	public function hideHoverTile(remove:Bool = false):Void {
		targetTile.visible = false;
		if (remove)
			DrawManager.removeFromDisplay(targetTile);
	}
	
	override public function useAp(amount:Int):Void {
		super.useAp(amount);
		lockHudButtons();
		HudManager.getInstance().APmeter.text = ""+stats.AP;
	}
	
	override public function changeSelectedAction(newActionName:String):Void {
		selectedAction = selectedAction == newActionName ? "move" : newActionName; 
		
		hideEveryTile();
		
		if (selectedAction != "move") {
			losModule.setRange(attacks.get(selectedAction).minRange, attacks.get(selectedAction).maxRange);
			showAttackRange(selectedAction);
		}
	}
	
	public function hideEveryTile():Void{
		hideHoverTile();
		hidePoolTiles();
	}
	
	override public function setTilePosition(nx:Int, ny:Int):Void {
		super.setTilePosition(nx, ny);
		losModule.moveToPoint(tilePos);
		
		if (selectedAction != "move"){
			showAttackRange(selectedAction);
		}
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