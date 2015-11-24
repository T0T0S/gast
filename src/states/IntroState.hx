package states;

import managers.StateManager;
import objects.State;
import pixi.core.math.shapes.Rectangle;
import pixi.loaders.Loader;
import pixi.core.graphics.Graphics;
import pixi.loaders.Resource;
import utils.DeviceCapabilities;

/**
 * ...
 * @author ToTos
 */


class IntroState extends State{
	private var loadingRecangle:Graphics = new Graphics();
	private var loadingFill:Graphics = new Graphics();
	private var loopCounter = 0;
	public function new() {
		super("Intro");
		LoadingText.text = "Loading asset: 0%";
		LoadingText.x = Main.getInstance().renderer.width * 0.5;
		LoadingText.y = Main.getInstance().renderer.height * 0.6;
		LoadingText.anchor.set(0.5, 0.5);
		loadingRecangle.lineStyle(3, 0xFFFFFF);
		loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35 , Main.getInstance().renderer.height*0.7, Main.getInstance().renderer.width *0.25, 50);
		loadingFill.lineStyle(3, 0xAAAAAA);
	}
	
	public override function Preload():Void {

		loadJson.set("tileSpriteSheet", "assets/spriteSheets/mapSpriteSheet.json");
		loadJson.set("tileSh2", "assets/spriteSheets/loadSpriteSheet.json");
		loadJson.set("buttons", "assets/spriteSheets/buttonSpriteSheet.json");
		loadJson.set("hero", "assets/spriteSheets/heroSpriteSheet.json");
		
		
		Main.getInstance().hudCont.addChild(loadingRecangle);
		Main.getInstance().hudCont.addChild(loadingFill);
		LoadingText.text = "Loading asset: 0%";
		Main.getInstance().hudCont.addChild(LoadingText);
	}
	
	public override function Start():Void  {
		StateManager.getInstance().switchToState("Menu");
	}

	public override function Update():Void  {
	
	}
	
	override public function AssetLoaded(loader:Loader, resource:Resource):Void {
		LoadingText.text = "Loading asset: "+loader.progress+"%";
		loadingRecangle.clear();
		loadingRecangle.lineStyle(4, 0xFFFFFF);
		loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35 , Main.getInstance().renderer.height*0.7, Main.getInstance().renderer.width *0.25, 50);
		loadingFill.clear();
		loadingFill.beginFill(0xAAAAAA);
		loadingFill.drawRect(Main.getInstance().renderer.width * 0.35 + 3, Main.getInstance().renderer.height*0.7+3,100 /loader.progress * ((Main.getInstance().renderer.width *0.25) - 4), 46);
		loadingFill.endFill();
	}
	
	public override function switchState():Void {
		loopCounter = null;
	}	
}