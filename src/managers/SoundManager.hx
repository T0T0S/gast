package managers;
/**
 * ...
 * @author ToTos
 */

/*
 * importer howlerjs et tester des CutomEvents howler.
 * 
 * */
class SoundManager{
	public static var instance:SoundManager;
	
	public function new() {
		
	}
	
	
	public static function getInstance():SoundManager {
		if (instance == null) instance new SoundManager();
		return instance;
	}
}