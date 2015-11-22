package objects;

/**
 * ...
 * @author ToTos
 */
class Player{
	public static var instance:Player;
	
	public function new() {
	}
	
	
	public static function getInstance():Player{
		if (instance == null) instance = new Player();
		return instance;
	}
	
}