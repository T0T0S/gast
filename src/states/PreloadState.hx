package states;

import managers.MapManager;
import managers.PoolManager;
import managers.StateManager;
import objects.State;
import pixi.core.graphics.Graphics;
import pixi.loaders.Loader;
import tweenx909.EaseX;
import tweenx909.rule.RgbX;
import tweenx909.TweenX;

/**
 * ...
 * @author ToTos
 */


class PreloadState extends State
{
	
	private var targetColor:Int = 0x101010; // 0x0d0d0d
	private var assetsLoaded:Bool = false;
	public function new() {
		super("Preload");
	}
	
	public override function Preload():Void {
		loadJson.set("preloadSpriteSheet", 	"assets/spriteSheets/preloadSpriteSheet.json");
		loadJson.set("maskLoading", 	"assets/spriteSheets/loadLineMask.json");
		TweenX.to( Main.getInstance().renderer, { backgroundColor: RgbX.of(targetColor) }, 1).ease( EaseX.linear );
	}
	
	override public function AllAssetsLoaded(loader:Loader):Void {
		super.AllAssetsLoaded(loader);
		assetsLoaded = true;
	}
	
	override public function Update():Void {
		super.Update();
		if (Main.getInstance().renderer.backgroundColor == targetColor && assetsLoaded)
			StateManager.getInstance().switchToState("Loading");
	}
}