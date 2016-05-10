package objects.character;
import js.Browser;
import js.html.RGBColor;
import managers.CharacterManager;
import managers.DrawManager;
import managers.FightManager;
import managers.HudManager;
import managers.MapManager;
import managers.PoolManager;
import objects.attacks.Attack;
import objects.attacks.NormalAttack;
import objects.attacks.TripleAttack;
import objects.character.Character;
import objects.modules.LOSModule.LOSPoint;
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
	
	private var tilePoolUsed:Array<Tile> = [];
	private var APFlash:OSmovieclip;
	private var pathPositions:Array<Dynamic> = [];
	
	private var mouseHovering:Bool = false;
	public var allowInput:Bool = true;
	
	private var inputCallBacks:Map<String, EventTarget->TilePoint->Void> = new Map.Map();
	private var inputHandledNames:Array<String> = ["mousemove", "mouseup"];

	private function new() {
		super("hero");
		setZ(2);
		entityType = EntityType.player;
		HudManager.getInstance().HPmeter.text = ""+stats.health;
		HudManager.getInstance().APmeter.text = ""+stats.AP;
		
		targetTile = new Tile(Texture.fromImage("selectedTile.png"));
		targetTile.visible = false;
		
		generateInputCallBacks();
		for (inputName in inputHandledNames.iterator())
		{
			Main.getInstance().tileCont.on(inputName, inputHandler);
		}
		
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
	
	override public function onCombatLost():Void {
		super.onCombatLost();
		respawn();
	}
	
	override public function onCombatWon():Void {
		super.onCombatWon();
		
	}
	
	private function generateInputCallBacks ():Void 
	{
		var availableStatuses:Array<String> = StatusModes.getConstructors();
		var tempCallbackName:String = "";
		for (inputName in inputHandledNames.iterator())
		{
			for (status in availableStatuses.iterator())
			{
				tempCallbackName = status +"_" + inputName;
				if (Reflect.getProperty(this, tempCallbackName))
					inputCallBacks.set(tempCallbackName, Reflect.getProperty(this, tempCallbackName));
				else
				{
					Browser.window.console.warn("InputHandler '"+tempCallbackName+"' was not found.");
					inputCallBacks.set(tempCallbackName, function (e, t) { } );
				}
			}
		}
		
	}
	
	
	private function normal_mousemove(e:EventTarget, tile:TilePoint):Void
	{
	}
	
	private function setup_mousemove(e:EventTarget, tile:TilePoint):Void
	{
	}
	
	private function fight_mousemove(e:EventTarget, tile:TilePoint):Void
	{
		if (selectedAction == "move" && !isMoving && !tile.equals(tilePos)) 
		{
			showPathMovement(findPathTo(tile));
		}
		else if (attacks.exists(selectedAction)) 
		{
			showAttackRange(selectedAction);
			if(Misc.targetInRange(tile, losModule.getLOS()))
				showHoverTile(tile, 0xFF0000);
		}
		
		if (tile.equals(tilePos))
		{
			mouseHovering = true;
			fight_mouseOverSelf(e);
		}
		else if (mouseHovering)
		{
			mouseHovering = false;
			fight_mouseOutSelf(e);
		}
	}
	
	private function normal_mouseup(e:EventTarget, tile:TilePoint):Void
	{
		changeSelectedAction("move");
		if (selectedAction == "move") 
		{
			if (!Camera.getInstance().isDragged && !tile.equals(tilePos)) 
				findPathTo(tile,true, true);
		}
	}
	
	private function setup_mouseup(e:EventTarget, tile:TilePoint):Void
	{
	}
	
	private function fight_mouseup(e:EventTarget, tile:TilePoint):Void
	{
		
		if (selectedAction == "move" && !isMoving) // force movement to be over before you can move again.
		{
			if (!Camera.getInstance().isDragged && !tile.equals(tilePos)) 
				findPathTo(tile,true);
		}
		else if (attacks.exists(selectedAction)) 
		{
			launchAttack(selectedAction, tile);
		}
		
		changeSelectedAction("move");
	}
	
	
	private function inputHandler(e:EventTarget)
	{
		if (!allowInput || !isActive)
			return;

		hidePoolTiles();
		hideHoverTile();
		
		var newtilePos = Misc.getTileFromEvent(e);
		Debug.log(""+newtilePos.toArray());

		for (inputType in inputHandledNames.iterator())
		{
			if (e.type == inputType)
			{
				Reflect.callMethod(this,inputCallBacks.get(FightManager.status +"_"+ inputType), [e, newtilePos]);
			}
		}
	}
	
	//custom input handlers (are not called normally)
	private function fight_mouseOverSelf(e:EventTarget):Void {
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement == true) {
				showRange(1, cast getMaxMovement(), 0x00FF00, 0.5);
			}
	}

	//custom input handlers (are not called normally)
	private function fight_mouseOutSelf(e:EventTarget):Void{
		if (selectedAction == "move")
			if (Options.data.player_showHoverMovement = true){
				hidePoolTiles();
			}
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
			fight_mouseOverSelf(null);
		
			
		lockHudButtons();
	}
	
	override public function damage(amount:Int):Void {
		super.damage(amount);
		HudManager.getInstance().HPmeter.text = ""+stats.health;
	}
	
	public function respawn():Void
	{
		trace("more code needed in respawn function for player !");
		stats.health = 1;
		stats.AP = stats.MaxAP;
		isDead = false;
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
			var newTile:Tile = PoolManager.pullObject(PoolType.tileWhite); 
			tilePoolUsed.push(newTile);
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
		
		var arrayIter:Array<TilePoint> = selectedAction != "move" ? losModule.getDisplayLOS() : Misc.getTilesAround(tilePos, min, max);
		for (i in arrayIter.iterator())
		{
			var newTile:Tile = PoolManager.pullObject(PoolType.tileWhite);
			tilePoolUsed.push(newTile);
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
	
	override public function onCharacterMove(characterId:String):Void {
		super.onCharacterMove(characterId);

		if(selectedAction != "move")
			losModule.forceRefresh();
	}
	
	public function hidePoolTiles():Void {
		for (tile in tilePoolUsed)
		{
			poolHide(tile);
		}
	}
	
	
	private function poolHide(i:Dynamic):Void{
		i.visible = false;
		i.tint = 0xFFFFFF;
		i.alpha = 1;
	}
	
	
	public function hideOnePoolTile(element:Dynamic):Void {
		PoolManager.applyFunctionToElement(PoolType.tileWhite, poolHide, element);
	}
	
	
	
	public function showHoverTile(tilePos:TilePoint, newTint:Int = null):Void {
		if (targetTile.parent == null){
			DrawManager.addToDisplay(targetTile, MapManager.getInstance().activeMap.mapContainer, untyped 0.7);
		}
		targetTile.setTilePosition(tilePos.x, tilePos.y);
		targetTile.visible = true;
		//targetTile.tint = newTint != null ? newTint : 0xFFFFFF;	
	}
	
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
		if (FightManager.status != StatusModes.fight)
		{
			selectedAction = "move";
			return;
		}
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
	
	private override function generateAttacks():Void{
		for (i in Reflect.fields(config.attacks)) {
			attacks.set(i, getAttackFromName(i, Reflect.field(config.attacks, i)));
		}	
	}
	
	private override function getAttackFromName(name:String, data:Dynamic):Attack{
		switch name{
			case "normal": return new NormalAttack(data);
			case "triple": return new TripleAttack(data);
		}
		Browser.window.console.warn("ATTACK NOT FOUND !");
		return new Attack(data);
	}
	
	override public function setTilePosition(nx:Int, ny:Int):Void {
		super.setTilePosition(nx, ny);
		
		if (selectedAction != "move"){
			showAttackRange(selectedAction);
		}
	}
	
	override public function Destroy():Void {
		super.Destroy();
		
		
		
		for (inputName in inputCallBacks.keys())
		{
			Main.getInstance().tileCont.off(inputName, untyped  inputCallBacks.get(inputName));
		}
	}
	
	public static function getInstance():Player{
		if (instance == null) instance = new Player();
		return instance;
	}
}