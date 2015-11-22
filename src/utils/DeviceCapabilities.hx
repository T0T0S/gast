package utils;

import js.Browser;
import pixi.core.display.DisplayObject;
import pixi.core.math.Point;
import pixi.core.math.shapes.Rectangle;
	
/**
 * Classe Utilitaire donnant accès à des propriétés du périphérique cible
 * Tous les périphériques ne se comportant pas comme on l'attend, DeviceCapabilities permet de
 * masquer les comportement différents et présenter une facade unique au reste du code
 * @version 0.1.0
 * @author Mathieu ANTHOINE
 */
class DeviceCapabilities 
{		
	/**
	  * hauteur du Canvas (change avec l'orientation)
	  */
	public static var height (get, never) : UInt;
	
	private static function get_height () {
		return Browser.window.innerHeight;
	}
	
	/**
	  * largeur du Canvas (change avec l'orientation)
	  */
	public static var width (get, never) : UInt;
	
	private static function get_width () {
		return Browser.window.innerWidth;
	}
	
	/**s
	 * retourne un objet Rectangle correspondant aux dimensions de l'écran dans le repère du DisplayObject passé en paramètre
	 * @param pTarget repère cible
	 * @return objet Rectangle
	 */
	
	public static function getScreenRect(pTarget:DisplayObject):Rectangle {
		if (pTarget.parent == null) return null;
		
		var lTopLeft:Point = new Point (0, 0);
		var lBottomRight:Point = new Point (width, height);
		
		lTopLeft = pTarget.parent.toLocal(lTopLeft);
		lBottomRight = pTarget.parent.toLocal(lBottomRight);
		return new Rectangle(lTopLeft.x, lTopLeft.y, lBottomRight.x - lTopLeft.x, lBottomRight.y - lTopLeft.y);
	}
}