package managers;
import js.html.CustomEvent;
import objects.character.Player;

	
/**
 * ...
 * @author ToTos
 */
class FightManager {
	
	private static var instance: FightManager;


	public var alliedCharactersID:Array<String> = [];
	public var enemyCharactersID:Array<String> = [];
	
	public static var status:String = "normal";

	private function new() {
			
	}
	
	public function startSetup(enemiesID:Array<String>):Void{
		status = "setup";
		alliedCharactersID.push(Player.getInstance().ID);
		
		for (i in enemiesID.iterator())
		{
			enemyCharactersID.push(i);
		}
		
		//wait for server timeout
		startFight();
	}
	
	public function addAlliedCharacterToSetup(alliedID:String):Void{
		// contact server
		alliedCharactersID.push(alliedID);
	}
	
	
	public function startFight():Void{
		status = "fight";
	}
	
	public function testFightOver():Void{
		var numberAlliedDead:Int = 0;
		var numberEnemyDead:Int = 0;
		for (i in alliedCharactersID.iterator())
		{
			if (CharacterManager.getInstance().managedCharacters.get(i).isDead)
				++numberAlliedDead;
		}
		
		for (i in enemyCharactersID.iterator())
		{
			if (CharacterManager.getInstance().managedCharacters.get(i).isDead)
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
		status = "normal";
	}
	
	
	
	
	public static function getInstance (): FightManager {
		if (instance == null) instance = new FightManager();
		return instance;
	}
	
	public function destroy (): Void {
		instance = null;
	}

}