package managers;
import js.Error;
import objects.Camera;
import objects.State;
import pixi.core.display.Container;
import pixi.core.text.Text;
import states.DebugState;
import states.PreloadState;
import states.MenuState;

/**
 * ...
 * @author ToTos
 */
class StateManager{

	public static var instance:StateManager;
	
	private var statesArray:Map<String,State> = new Map.Map();
	private var activeState:String = "Preload";
	public var activatedState:State;
	private var skipNextLateUpdate:Bool = false;
	private var firstLoop:Bool = true;
	
	public var debugActiveState:Text = new Text("Init", { "fill":"white", "font":"30px gastFont" } );
	public static var debugText:Text = new Text("", { "fill" :"white", "font":"18px Arial" } );
	
	public static var loadingState:Bool = false;

	/**
	 * Classe de gestion des états,
	 * 
	 * POUR AJOUTER UN ETAT:
	 * - pusher dans statesArray une instance de votre état avec une clé correspondant au nom avec lequel vous voulez l'appeller (cf New())
	 * - appeller la fonction switchToState(nomDeVotreEtat), cette fonction va elever tout les enfants du stage pour rendre un truc noir,
	 * - coder votre état dans les trois fonctions Start() Update() et LateUpdate();
	 * - coder la fonction de changement d'état dans switchState() de chaque état: pour nettoyer une peu la mémoire 
	 */
	public function new() {
	
		addState(new PreloadState());
		addState(new MenuState());
		addState(new DebugState());
		
		Main.getInstance().debugCont.addChild(debugActiveState);
		debugActiveState.x = 10;
		debugActiveState.y = Main.getInstance().renderer.height - 30;
		
		debugText.x = 200;
		debugText.y = Main.getInstance().renderer.height - 30;
		Main.getInstance().debugCont.addChild(debugText);
		
		switchToState(activeState);
	}
	
	public function addState(state:State):Void{
		statesArray[state.name] = state;
	}
	
	public function switchToState(newState:String) {
		loadingState = true;
		if(!firstLoop)
			statesArray[activeState].switchState();
		firstLoop = false;
		DrawManager.switchState();
		Main.mapManager.switchState();
		Main.characterManager.switchState();
		Camera.getInstance().switchState();
		HudManager.getInstance().switchState();
		activeState = newState;
		activatedState = statesArray[activeState];
		debugActiveState.text = activeState;
		
		for (i in Main.getInstance().fullStage.children.iterator()) {
			if(i.name != "debugCont")
				cast(i,Container).removeChildren();
		}
		
		if (statesArray[activeState] == null)
			throw new Error("Erreur: State Inconnu => '"+activeState+"' \nLes states connus sont: "+Reflect.field(statesArray.keys(),"arr"));
		
		statesArray[activeState]._StartLoading();
		skipNextLateUpdate = true;
	}
	
	public function Update():Void {
		statesArray[activeState]._PrepareUpdate();
		Main.getInstance().Render();
		if(!skipNextLateUpdate)
			statesArray[activeState].LateUpdate();
		skipNextLateUpdate = false;
	}
	
	public static function getInstance():StateManager {
		if (instance == null) instance = new StateManager();
		return instance;
	}
}