package objects.attacks;
import managers.DrawManager;
import managers.PoolManager;
import objects.character.Character;
import objects.particle.Bullet;
import pixi.core.graphics.Graphics;
import pixi.core.text.Text;
import objects.particle.DmgText;
import utils.Misc;
import utils.TilePoint;

/**
 * ...
 * @author ToTos
 */
class Attack{

	public var waitForFinish:Bool = true;
	public var animationName:String = "no animation defined";
	
	public var framesData:Array<Array<Int>> = [];
	public var activeFrameData:Int = 0;
	public var frameElaped:Int = 0;
	
	public var targetPosition:TilePoint = new TilePoint();
	public var finished:Bool = false;
	
	public var minRange:Int = 0;
	public var maxRange:Int = 0;
	
	public var damage:Int = 0;
	public var apCost:Int = 0;
	
	private var attackFXName:String;
	private var attackFXType:String;
	
	public function new(jsonData:Dynamic) {
		framesData = jsonData.framesData;
		animationName = jsonData.animationName;
		waitForFinish = jsonData.waitForFinish;
		minRange = jsonData.minRange;
		maxRange = jsonData.maxRange;
		damage = jsonData.damage;
		apCost = jsonData.apCost;
		
		if (jsonData.effect != null)
		{
			attackFXName = jsonData.effect.name;
			attackFXType = jsonData.effect.type;
		}
	}
	
	public function updateAttack(launcherRef:Character):Void {
		if(frameElaped == framesData[activeFrameData][0]){
			if (attackFXType == "bullet")
				shootBullet(launcherRef);
			attackEffect(launcherRef.stats);
		}

		if (frameElaped == framesData[activeFrameData][0] + framesData[activeFrameData][1]){
			if (activeFrameData == framesData.length -1)
				endAction(launcherRef);
			else {
				frameElaped = 0;
				++activeFrameData;
			}
		}
		
		++frameElaped;
	}
	
	private function shootBullet(launcherRef:Character):Void{
		var bullet:Bullet = PoolManager.pullObject("bulletNormal");
		bullet.x = launcherRef.x;
		bullet.y = launcherRef.y - launcherRef.height * 0.75;
		bullet.anchor.set(0, 0.5);
		bullet.rotation = -Misc.angleBetweenTiles(cast launcherRef.tilePos, cast targetPosition) + (Math.PI * 0.01) * Misc.sign(Math.random() - 0.5);
		bullet.mask = null;
		
		var maxBulletWidth:Float = 0;
		
		for (i in 0...bullet.totalFrames)
		{
			bullet.gotoAndStop(i);
			maxBulletWidth = bullet.width > maxBulletWidth ? bullet.width : maxBulletWidth;
		}
		
		var distance:Float = Misc.getAbsoluteDistanceBetweenTiles(targetPosition, launcherRef.tilePos);
		var newScale:Float = distance / maxBulletWidth;
		
		bullet.scale.x = newScale > 1 ? newScale : 1;

		var bulletMask:Graphics;
		if (bullet.children.length != 0)
			bulletMask = cast bullet.children[0];
		else
			bulletMask = new Graphics();
			
		bulletMask.clear();	
		bulletMask.beginFill(0xFFFFFF, 0);
		bulletMask.moveTo(Main.tileSize.x * 0.25, -bullet.height* 0.5);
		bulletMask.lineTo(maxBulletWidth * newScale, -bullet.height* 0.5);
		bulletMask.lineTo(maxBulletWidth * newScale, bullet.height* 0.5);
		bulletMask.lineTo(Main.tileSize.x * 0.25, bullet.height * 0.5);
		bulletMask.lineTo(Main.tileSize.x * 0.25, -bullet.height* 0.5);
		bulletMask.endFill();
		
		if(bulletMask.parent == null)
			bullet.addChild(bulletMask);
		bullet.mask = bulletMask;
		
		bullet.visible = true;
		DrawManager.addToDisplay(bullet, Main.getInstance().gameCont, 0);
		bullet.gotoAndStop(0);
		bullet.gotoAndPlay(0);
	}
	
	public function activateAttack(position:TilePoint):Void{
		targetPosition = position;
		activeFrameData = 0;
		frameElaped = 0;
		finished = false;
	}
	
	public function attackEffect(stats:Stats):Void {
	}
	
	
	
	public function endAction(launcher:Character):Void{
		launcher.waitForNextTick = waitForFinish;
		finished = true;
	}
	
}