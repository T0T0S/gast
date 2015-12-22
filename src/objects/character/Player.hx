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
import utils.Debug;
import utils.Misc;

/**
 * ...
 * @author ToTos
 */
class Player extends Character{
	private static var instance:Player;

	private var targetTile:Tile;
	
	public static var selectedAction:String = "move";

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
			if (Options.data.player_showHoverMovement = true){
				showRange(0, stats.AP, 0x00FF00, 0.7, Misc.getRangeTileAround(tilePos, 1, stats.AP));
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
		var newtilePos = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y);

		if (selectedAction == "move" && !isMoving) {
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
		if(!allowInput)
			return;
		var tileHovered = Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x, e.data.getLocalPosition(e.target).y);
		hidePoolTiles();
		hideHoverTile();
		
		if (selectedAction == "move" && !isMoving) {
			if(FightManager.status == StatusModes.fight)
				showPathMovement(findPathTo(tileHovered));
		}
		else if (attacks.exists(selectedAction) && FightManager.status == StatusModes.fight) {
			showAttackRange(selectedAction);
			if(Misc.targetInRange(tilePos, tileHovered, activeAttackRange))
				showHoverTile(tileHovered, 0xFF0000);
		}
		
		if (tileHovered[0] == tilePos[0] && tileHovered[1] == tilePos[1])
		{
			mouseHovering = true;
			mouseOverSelf(e);
		}
		else if (mouseHovering)
		{
			mouseHovering = false;
			mouseOutSelf(e);
		}

	}
	
	private function showAttackRange(attackName:String):Void{
		showRange(attacks.get(attackName).minRange, attacks.get(attackName).maxRange, 0xFF4747, 0.3);
	}
	
	override public function newTick(tickNumber:Int):Void {
		super.newTick(tickNumber);
		HudManager.getInstance().APmeter.text = ""+stats.AP;
		
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
		if (path.length == 0 || path.length > stats.AP)
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
			newTile.setTilePosition([i.x, i.y]);
			pathPositions.push(newTile);
			if (newTile.parent == null)
				if (parent != null)
					DrawManager.addToDisplay(newTile, parent,untyped 0.5);
		}
	}
	
	public function showRange(min:Int, max:Int, ?color:Int, ?alpha:Float, ?customRange:Array<Array<Int>>):Void {
		/*
		 * attention pour le pathfinding bug <= il calcule pas si on peux arriver aux positions.
		 * need to repredict after every end of path and stock the value.
		 * */
		if (!allowInput)
			return;
			
		hidePoolTiles();
		if (FightManager.status == StatusModes.normal)
			return;
		
		var arrayIter:Array<Array<Int>> = customRange == null ? activeAttackRange : customRange;
		for (i in arrayIter.iterator())
		{
			if(!MapManager.getInstance().activeMap.getWalkableAt(i) && CharacterManager.getInstance().findCharacterAtTilePos(i) == null)
				continue;
			var newTile:Tile = PoolManager.pullObject("tile"); 
			newTile.visible = true;
			newTile.setTilePosition([i[0], i[1]]);
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
	
	
	
	public function showHoverTile(tilePos:Array<Int>, newTint:Int = null):Void {
		if (targetTile.parent == null){
			DrawManager.addToDisplay(targetTile, MapManager.getInstance().activeMap.mapContainer, untyped 0.7);
		}
		targetTile.setTilePosition(tilePos);
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
	
	public function changeSelectedAction(newActionName:String):Void{
		selectedAction = selectedAction == newActionName ? "move" : newActionName; 
		
		hideEveryTile();
		
		if (selectedAction != "move"){
			generateAttackRange(selectedAction);
			showAttackRange(selectedAction);
		}
	}
	
	private function generateAttackRange(attackName:String):Void {
		if (attacks.exists(attackName))
		{
			activeAttackRange = Misc.getRangeTileAround(tilePos, attacks.get(attackName).minRange, attacks.get(attackName).maxRange);
			
			var i:Int = 0;
			
			while (i < activeAttackRange.length)
			{
				if (!Misc.hasLineOfSight(tilePos, activeAttackRange[i], activeAttackRange))
				{
					activeAttackRange.splice(i, 1);
					--i;
				}
				++i;
			}
		}
		else
			Browser.window.console.warn("Attack not found while generating attackRange of:" + attackName);
	}
	
	public function hideEveryTile():Void{
		hideHoverTile();
		hidePoolTiles();
	}
	
	override public function setTilePosition(position:Array<Int>):Void {
		super.setTilePosition(position);
		if (selectedAction != "move"){
			generateAttackRange(selectedAction);
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