package states;

import managers.MapManager;
import managers.PoolManager;
import managers.StateManager;
import objects.State;
import pixi.core.graphics.Graphics;
import pixi.loaders.Loader;

/**
 * ...
 * @author ToTos
 */


class PreloadState extends State{
	private var loadingRecangle:Graphics = new Graphics();
	private var loadingFill:Graphics = new Graphics();
	private var loopCounter = 0;
	public function new() {
		super("Preload");
		LoadingText.text = "Loading asset: 0%";
		LoadingText.x = Main.getInstance().renderer.width * 0.5;
		LoadingText.y = Main.getInstance().renderer.height * 0.6;
		LoadingText.anchor.set(0.5, 0.5);
		loadingRecangle.lineStyle(3, 0xFFFFFF);
		loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35 , Main.getInstance().renderer.height*0.7, Main.getInstance().renderer.width *0.30, 50);
		loadingFill.lineStyle(3, 0xAAAAAA);
	}
	
	public override function Preload():Void {
		loadJson.set("Attack", 			"assets/spriteSheets/AttacksButtons.json");
		loadJson.set("hud_bottom", 		"assets/spriteSheets/hud_bottom.json");
		loadJson.set("tileSh2", 		"assets/spriteSheets/loadSpriteSheet.json");
		loadJson.set("buttons", 		"assets/spriteSheets/buttonSpriteSheet.json");
		loadJson.set("hero", 			"assets/spriteSheets/heroSpriteSheet.json");
		loadJson.set("hero2", 			"assets/spriteSheets/heroSpriteSheet2.json");
		loadJson.set("explosion", 		"assets/spriteSheets/testExplosion.json");
		loadJson.set("victim", 			"assets/spriteSheets/victim.json");
		loadJson.set("bullet", 			"assets/spriteSheets/bullet.json");
		
		loadJson.set("camShader", 		"assets/effects/camShade.json");
		
		
		Main.getInstance().hudCont.addChild(loadingRecangle);
		Main.getInstance().hudCont.addChild(loadingFill);
		LoadingText.text = "Loading asset: 0%";
		Main.getInstance().hudCont.addChild(LoadingText);
	}
	
	public override function Start():Void  {
		PoolManager.generatePool();
		MapManager.getInstance().Init();
		StateManager.getInstance().switchToState("Menu");
	}

	public override function Update():Void  {
	
	}
	
	override public function AssetLoad(loader:Loader):Void {
		LoadingText.text = "Loading asset: "+Math.fround(loader.progress)+"%";
		loadingRecangle.clear();
		loadingRecangle.lineStyle(4, 0xFFFFFF);
		loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35 , Main.getInstance().renderer.height*0.7, Main.getInstance().renderer.width *0.30, 50);
		loadingFill.clear();
		loadingFill.beginFill(0xAAAAAA);
		loadingFill.drawRect(
			Main.getInstance().renderer.width * 0.35 + 3, 
			Main.getInstance().renderer.height * 0.7 + 3,
			(loader.progress / 100) * ((Main.getInstance().renderer.width * 0.30) - 4), 
			46
		);
		loadingFill.endFill();
		
	}
	
	public override function switchState():Void {
		loopCounter = null;
	}	
}