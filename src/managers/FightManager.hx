package managers;
import js.html.CustomEvent;
import objects.character.Character;
import objects.character.Player;
import pixi.core.textures.Texture;

enum StatusModes {
	normal;
	setup;
	fight;
}
	
/**
 * ...
 * @author ToTos
 */
class FightManager {
	
	private static var instance: FightManager;

	
	
	private var alliedCharactersID:Array<String> = [];
	private var enemyCharactersID:Array<String> = [];
	
	public static var status:StatusModes = StatusModes.normal;
	
	private function new() {
			
	}
	
	public function startSetup(enemiesID:Array<String>):Void{
		status = StatusModes.setup;
		addAlliedCharacterToSetup(Player.getInstance().ID);
		for (i in enemiesID.iterator())
			addEnemyCharacterToSetup(i);
		
		//wait for server timeout
		startFight();
	}
	
	public function addAlliedCharacterToSetup(alliedID:String):Void{
		// contact server
		CharacterManager.getInstance().findCharacterById(alliedID).generatePosTile(true);
		alliedCharactersID.push(alliedID);
	}
	
	public function addEnemyCharacterToSetup(enemyID:String):Void{
		// contact server
		CharacterManager.getInstance().findCharacterById(enemyID).generatePosTile(false);
		enemyCharactersID.push(enemyID);
	}
	
	
	private function startFight():Void{
		status = StatusModes.fight;
	}
	
	public function testFightOver():Void{
		var numberAlliedDead:Int = 0;
		var numberEnemyDead:Int = 0;
		for (i in alliedCharactersID.iterator())
		{
			if (CharacterManager.getInstance().findCharacterById(i).isDead)
				++numberAlliedDead;
		}
		
		for (i in enemyCharactersID.iterator())
		{
			if (CharacterManager.getInstance().findCharacterById(i).isDead)
				++numberEnemyDead;
		}
		
		if (alliedCharactersID.length == numberAlliedDead){
			Player.getInstance().loseCombat();
			fightEnd();
		}
		else if(numberEnemyDead == enemyCharactersID.length){
			Player.getInstance().winCombat();
			fightEnd();
		}
	}
	
	public function fightEnd():Void{
		status = StatusModes.normal;
	}
	
	public function isEnemy(elementId:String):Bool{ return alliedCharactersID.indexOf(elementId) == -1; }
	public function isAllied(elementId:String):Bool{ return alliedCharactersID.indexOf(elementId) != -1; }
	
	
	public static function getInstance (): FightManager {
		if (instance == null) instance = new FightManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}