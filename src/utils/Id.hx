package utils;

/**
 * ...
 * @author ToTos
 */
class Id{
	private static var numberIds = 0;
	
	public static function newId ():String {
		var stringToReturn:String = "";
		stringToReturn += numberIds++;
		return stringToReturn;
	}
}