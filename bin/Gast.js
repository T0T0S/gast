(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var IntIterator = function(min,max) {
	this.min = min;
	this.max = max;
};
IntIterator.__name__ = ["IntIterator"];
IntIterator.prototype = {
	hasNext: function() {
		return this.min < this.max;
	}
	,next: function() {
		return this.min++;
	}
	,__class__: IntIterator
};
var Lambda = function() { };
Lambda.__name__ = ["Lambda"];
Lambda.array = function(it) {
	var a = new Array();
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var i = $it0.next();
		a.push(i);
	}
	return a;
};
Lambda.has = function(it,elt) {
	var $it0 = $iterator(it)();
	while( $it0.hasNext() ) {
		var x = $it0.next();
		if(x == elt) return true;
	}
	return false;
};
Lambda.count = function(it,pred) {
	var n = 0;
	if(pred == null) {
		var $it0 = $iterator(it)();
		while( $it0.hasNext() ) {
			var _ = $it0.next();
			n++;
		}
	} else {
		var $it1 = $iterator(it)();
		while( $it1.hasNext() ) {
			var x = $it1.next();
			if(pred(x)) n++;
		}
	}
	return n;
};
var Main = function() {
	this.renderMask = new PIXI.Graphics();
	this.debugCont = new PIXI.Container();
	this.effectCont = new PIXI.Container();
	this.hudCont = new PIXI.Container();
	this.gameCont = new PIXI.Container();
	this.tileCont = new PIXI.Container();
	this.fullStage = new PIXI.Container();
	Main.gameOptions = objects.Options.getInstance();
	Main.gameOptions.loadOptions();
	var font = new Font();
	font.onload = function() {
		window.requestAnimationFrame(managers.InitManager.getInstance);
	};
	font.fontFamily = "gastFont";
	font.src = "assets/fonts/Days.otf";
	this.renderer = PIXI.autoDetectRenderer(1600,900,{ });
	this.renderer.backgroundColor = 1513508;
	this.renderMask.beginFill();
	this.renderMask.drawRect(0,0,this.renderer.width,this.renderer.height);
	this.renderMask.endFill();
	Main.screenRatio = [this.renderer.width / 1920,this.renderer.height / 1080];
	this.fullStage.addChild(this.renderMask);
	this.tileCont.interactive = true;
	this.gameCont.interactive = true;
	this.hudCont.interactive = true;
	this.fullStage.mask = this.renderMask;
	this.tileCont.isoSort = true;
	this.gameCont.isoSort = true;
	this.hudCont.isoSort = true;
	this.fullStage.addChildAt(this.tileCont,0);
	this.fullStage.addChildAt(this.gameCont,1);
	this.fullStage.addChildAt(this.hudCont,2);
	this.fullStage.addChildAt(this.effectCont,3);
	if(Main.DEBUGMODE) this.fullStage.addChildAt(this.debugCont,4);
	this.debugCont.name = "debugCont";
	this.renderer.render(this.fullStage);
	this.renderer.view.className = "gastCanvas";
	window.document.body.appendChild(this.renderer.view);
	window.addEventListener("keydown",$bind(this,this.keyDownListener));
};
Main.__name__ = ["Main"];
Main.main = function() {
	Main.getInstance();
};
Main.getInstance = function() {
	if(Main.instance == null) Main.instance = new Main();
	return Main.instance;
};
Main.prototype = {
	Start: function() {
		Main.drawManager = managers.DrawManager.getInstance();
		Main.timeManager = managers.TimeManager.getInstance();
		Main.mouseManager = managers.MouseManager.getInstance();
		Main.camera = objects.Camera.getInstance();
		Main.mapManager = managers.MapManager.getInstance();
		Main.characterManager = managers.CharacterManager.getInstance();
		Main.poolManager = managers.PoolManager.getInstance();
		Main.stateManager = managers.StateManager.getInstance();
		window.addEventListener("resize",$bind(this,this.resize));
		window.requestAnimationFrame($bind(this,this.Update));
	}
	,resize: function(pEvent) {
		Main.screenRatio = [this.renderer.width / 1920,this.renderer.height / 1080];
	}
	,Update: function() {
		window.requestAnimationFrame($bind(this,this.Update));
		if(Main.timeManager != null) Main.timeManager.Update();
		if(Main.GAMESTOPPED && Main.DEBUGMODE) return;
		this.mouseUpdate();
		Main.characterManager.Update();
		Main.camera.Update();
		Main.stateManager.Update();
	}
	,Render: function() {
		Main.drawManager.isometricSort(managers.MapManager.getInstance().activeMap.mapContainer);
		this.renderer.render(this.fullStage);
	}
	,mouseUpdate: function() {
		Main.mouseManager.calledPerFrame = 0;
	}
	,keyDownListener: function(e) {
		if(String.fromCharCode(e.keyCode) == "A" && e.altKey) Main.GAMESTOPPED = !Main.GAMESTOPPED;
	}
	,destroy: function() {
		Main.instance = null;
	}
	,__class__: Main
};
var IMap = function() { };
IMap.__name__ = ["IMap"];
Math.__name__ = ["Math"];
var Reflect = function() { };
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.getProperty = function(o,field) {
	var tmp;
	if(o == null) return null; else if(o.__properties__ && (tmp = o.__properties__["get_" + field])) return o[tmp](); else return o[field];
};
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) return false;
	delete(o[field]);
	return true;
};
var Std = function() { };
Std.__name__ = ["Std"];
Std["is"] = function(v,t) {
	return js.Boot.__instanceof(v,t);
};
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
};
var haxe = {};
haxe.Timer = function(time_ms) {
	var me = this;
	this.id = setInterval(function() {
		me.run();
	},time_ms);
};
haxe.Timer.__name__ = ["haxe","Timer"];
haxe.Timer.prototype = {
	stop: function() {
		if(this.id == null) return;
		clearInterval(this.id);
		this.id = null;
	}
	,run: function() {
	}
	,__class__: haxe.Timer
};
haxe.ds = {};
haxe.ds.ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
haxe.ds.ObjectMap.__name__ = ["haxe","ds","ObjectMap"];
haxe.ds.ObjectMap.__interfaces__ = [IMap];
haxe.ds.ObjectMap.prototype = {
	set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe.ds.ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,__class__: haxe.ds.ObjectMap
};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,remove: function(key) {
		key = "$" + key;
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key.substr(1));
		}
		return HxOverrides.iter(a);
	}
	,iterator: function() {
		return { ref : this.h, it : this.keys(), hasNext : function() {
			return this.it.hasNext();
		}, next : function() {
			var i = this.it.next();
			return this.ref["$" + i];
		}};
	}
	,__class__: haxe.ds.StringMap
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = ["js","Boot"];
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) str2 += ", \n";
		str2 += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js.Boot.__cast = function(o,t) {
	if(js.Boot.__instanceof(o,t)) return o; else throw "Cannot cast " + Std.string(o) + " to " + Std.string(t);
};
js.Browser = function() { };
js.Browser.__name__ = ["js","Browser"];
js.Browser.getLocalStorage = function() {
	try {
		var s = window.localStorage;
		s.getItem("");
		return s;
	} catch( e ) {
		return null;
	}
};
var managers = {};
managers.CharacterManager = function() {
	this.positions = [];
	this.managedCharacters = new haxe.ds.StringMap();
};
managers.CharacterManager.__name__ = ["managers","CharacterManager"];
managers.CharacterManager.getInstance = function() {
	if(managers.CharacterManager.instance == null) managers.CharacterManager.instance = new managers.CharacterManager();
	return managers.CharacterManager.instance;
};
managers.CharacterManager.prototype = {
	findCharacterAtTilePos: function(position) {
		if(this.positions[position[0]] == null) return null;
		if(this.positions[position[0]][position[1]] != null) return this.managedCharacters.get(this.positions[position[0]][position[1]]); else return null;
	}
	,updateCharacterCoordinatesFromTo: function(element,newPosition) {
		var oldGrid = managers.MapManager.finder.getGrid();
		if(this.positions[element.tilePos[0]] == null) this.positions[element.tilePos[0]] = [];
		this.positions[element.tilePos[0]][element.tilePos[1]] = null;
		managers.MapManager.finder.setColliTile(element.tilePos[0],element.tilePos[1],true);
		if(this.positions[newPosition[0]] == null) this.positions[newPosition[0]] = [];
		this.positions[newPosition[0]][newPosition[1]] = element.charaName;
		managers.MapManager.finder.setColliTile(newPosition[0],newPosition[1],false);
	}
	,addCharacter: function(element) {
		this.managedCharacters.set(element.charaName,element);
	}
	,removeCharacter: function(element) {
		this.managedCharacters.remove(element.charaName);
		this.positions[element.tilePos[0]][element.tilePos[1]] = null;
		managers.MapManager.finder.setColliTile(element.tilePos[0],element.tilePos[1],true);
	}
	,Update: function() {
		var $it0 = this.managedCharacters.iterator();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(i == null) continue;
			i._selfUpdate();
		}
	}
	,switchState: function() {
		var $it0 = this.managedCharacters.iterator();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			this.managedCharacters.remove(i.charaName);
		}
		this.positions = [[]];
	}
	,__class__: managers.CharacterManager
};
managers.DrawManager = function() {
};
managers.DrawManager.__name__ = ["managers","DrawManager"];
managers.DrawManager.Update = function() {
};
managers.DrawManager.addToDisplay = function(element,newParent,layer) {
	if(layer == null) layer = 0;
	if(element.setZ != null && layer != 0) element.setZ(layer);
	if(element.parent == null) newParent.addChild(element);
};
managers.DrawManager.removeFromDisplay = function(element) {
	if(element.parent != null) element.parent.removeChild(element);
};
managers.DrawManager.switchState = function() {
};
managers.DrawManager.getInstance = function() {
	if(managers.DrawManager.instance == null) managers.DrawManager.instance = new managers.DrawManager();
	return managers.DrawManager.instance;
};
managers.DrawManager.prototype = {
	isometricSort: function(cont,layerIndex) {
		cont.children.sort(function(a,b) {
			if(b.z == a.z) return a.depth - b.depth; else return a.z - b.z;
		});
	}
	,__class__: managers.DrawManager
};
managers.HudManager = function() {
	this.attackButtons = new haxe.ds.StringMap();
};
managers.HudManager.__name__ = ["managers","HudManager"];
managers.HudManager.getInstance = function() {
	if(managers.HudManager.instance == null) managers.HudManager.instance = new managers.HudManager();
	return managers.HudManager.instance;
};
managers.HudManager.prototype = {
	generateFightHud: function() {
		managers.HudManager.mode = "fight";
		var rightHud = new objects.HudElement(PIXI.Texture.fromImage("hud_bottom_right.png"));
		rightHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		rightHud.anchor.set(1,1);
		rightHud.x = Main.getInstance().renderer.width;
		rightHud.y = Main.getInstance().renderer.height;
		rightHud.name = "right_bottom";
		var attackHud = new objects.HudElement(PIXI.Texture.fromImage("hud_bottom_center.png"));
		attackHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		attackHud.anchor.set(1,1);
		attackHud.x = rightHud.x - (rightHud.width + 20);
		attackHud.y = Main.getInstance().renderer.height;
		attackHud.name = "center";
		var attackButton = new objects.HudButton("button_attack","normal");
		attackButton.x = -695;
		attackButton.y = -73;
		this.attackButtons.set(attackButton.actionName,attackButton);
		var tripleAttackButton = new objects.HudButton("button_triple_attack","triple");
		tripleAttackButton.anchor.set(0.5,0.5);
		tripleAttackButton.x = -570;
		tripleAttackButton.y = -73;
		this.attackButtons.set(tripleAttackButton.actionName,tripleAttackButton);
		var tickTimer = new PIXI.Sprite(PIXI.Texture.fromImage("timerFill.png"));
		tickTimer.anchor.set(0.5,0.5);
		tickTimer.x = -(tickTimer.width * 0.5 + 50);
		tickTimer.y = -(tickTimer.height * 0.5 + 48);
		tickTimer.name = "tickTimer";
		var HPText = new PIXI.Text("",{ fill : "white", font : "35px gastFont", stroke : "black", strokeThickness : 5});
		HPText.anchor.set(0.5,0.5);
		HPText.name = "HP";
		HPText.x = -342;
		HPText.y = -65;
		this.HPmeter = HPText;
		var APText = new PIXI.Text("",{ fill : "white", font : "35px gastFont", stroke : "black", strokeThickness : 5});
		APText.anchor.set(0.5,0.5);
		APText.name = "AP";
		APText.x = -342;
		APText.y = -175;
		this.APmeter = APText;
		managers.DrawManager.addToDisplay(attackHud,Main.getInstance().hudCont);
		managers.DrawManager.addToDisplay(attackButton,attackHud);
		managers.DrawManager.addToDisplay(tripleAttackButton,attackHud);
		managers.DrawManager.addToDisplay(rightHud,Main.getInstance().hudCont);
		managers.DrawManager.addToDisplay(tickTimer,rightHud);
		managers.DrawManager.addToDisplay(APText,rightHud);
		managers.DrawManager.addToDisplay(HPText,rightHud);
	}
	,switchState: function() {
		managers.HudManager.mode = "none";
	}
	,destroy: function() {
		managers.HudManager.instance = null;
	}
	,__class__: managers.HudManager
};
managers.InitManager = function() {
	var lConfig = new PIXI.loaders.Loader();
	lConfig.add("config","assets/config/" + "config.json");
	lConfig.add("hero","assets/config/" + "/" + "hero.json");
	lConfig.add("victim","assets/config/" + "/" + "victim.json");
	lConfig.add("testMapZig","assets/" + "maps/testMapZig.json");
	lConfig.once("complete",$bind(this,this.LoadedJson));
	lConfig.load();
};
managers.InitManager.__name__ = ["managers","InitManager"];
managers.InitManager.getInstance = function() {
	if(managers.InitManager.instance == null) managers.InitManager.instance = new managers.InitManager();
	return managers.InitManager.instance;
};
managers.InitManager.prototype = {
	LoadedJson: function(loader,resource) {
		managers.InitManager.data = { };
		var _g = 0;
		var _g1 = Reflect.fields(resource);
		while(_g < _g1.length) {
			var i = _g1[_g];
			++_g;
			if(Reflect.field(resource,i).data == null) throw new Error("/!\\ [ERROR] while loading json /!\\ ");
			managers.InitManager.data[i] = Reflect.field(resource,i).data;
		}
		if(Main.DEBUGMODE) window.data = managers.InitManager.data;
		Main.tileSize = managers.InitManager.data.config.tileSize;
		window.requestAnimationFrame(($_=Main.getInstance(),$bind($_,$_.Start)));
	}
	,__class__: managers.InitManager
};
managers.MapManager = function() {
	this.maps = new haxe.ds.StringMap();
	this.activeMap = new objects.GameMap();
	var value = new objects.GameMap(this.formatMap("testMapZig"),"testMapZig");
	this.maps.set("testMapZig",value);
};
managers.MapManager.__name__ = ["managers","MapManager"];
managers.MapManager.displayDebugColliMap = function(nodes) {
	var _g = 0;
	var _g1 = Reflect.fields(nodes);
	while(_g < _g1.length) {
		var y = _g1[_g];
		++_g;
		var _g2 = 0;
		var _g3 = Reflect.fields(nodes[x]);
		while(_g2 < _g3.length) {
			var x = _g3[_g2];
			++_g2;
			if(nodes[y][x] < 2) managers.MouseManager.createLilCubes([[x,y]],255); else managers.MouseManager.createLilCubes([[x,y]],16711680);
		}
	}
};
managers.MapManager.getInstance = function() {
	if(managers.MapManager.instance == null) managers.MapManager.instance = new managers.MapManager();
	return managers.MapManager.instance;
};
managers.MapManager.prototype = {
	generateMapDisplay: function(mapName,select) {
		if(select == null) select = false;
		var newMap = this.maps.get(mapName);
		var i = 0;
		var j = 0;
		var tileSprite;
		var $it0 = HxOverrides.iter(newMap.graphicalData);
		while( $it0.hasNext() ) {
			var arrayX = $it0.next();
			j = 0;
			var $it1 = HxOverrides.iter(arrayX);
			while( $it1.hasNext() ) {
				var tileIndex = $it1.next();
				if(tileIndex != 0) {
					if(newMap.json.tiles[tileIndex] == null) throw new Error("[ERROR] tile index " + tileIndex + " not found in " + newMap.name + ".json");
					tileSprite = new objects.Tile(PIXI.Texture.fromImage("" + newMap.json.tiles[tileIndex]));
					tileSprite.setTilePosition([j,i]);
					tileSprite.x += this.activeMap.OffsetX;
					tileSprite.y += 16;
					tileSprite.setZ(newMap.json.tilesHeight[tileIndex]);
					newMap.addTileToMap(tileSprite,newMap.json.tilesHeight[tileIndex]);
					if(newMap.tileMap[j] == null) newMap.tileMap[j] = [];
					newMap.tileMap[j][i] = tileSprite;
				}
				++j;
			}
			++i;
		}
		newMap.displayMap();
		if(select) this.setActiveMap(newMap);
	}
	,formatMap: function(mapName) {
		if(managers.InitManager.data[mapName] == null) {
			window.console.warn("%c[WARNING] unknown map '" + mapName + "'","color:red;");
			return [[]];
		}
		var mapData = managers.InitManager.data[mapName];
		return this.convertMapDataToXY(mapData);
	}
	,convertMapDataToXY: function(newMap) {
		var mapLayer;
		var returnObject = { };
		var i = 0;
		var j = 0;
		while(i < newMap.layers.length) {
			mapLayer = [];
			j = 0;
			if(newMap.layers == null) break;
			var map = newMap.layers[i].data;
			while(j < newMap.layers[i].data.length) {
				if(mapLayer[Math.floor(j / newMap.width)] == null) mapLayer[Math.floor(j / newMap.width)] = [];
				mapLayer[Math.floor(j / newMap.width)][j % newMap.width] = newMap.layers[i].data[j];
				j++;
			}
			returnObject[newMap.layers[i].name] = mapLayer.slice();
			i++;
		}
		return returnObject;
	}
	,setActiveMap: function(newMap) {
		this.activeMap = newMap;
		Main.camera.updateMapSize(this.activeMap);
	}
	,switchState: function() {
		this.activeMap.hideMap(true);
	}
	,__class__: managers.MapManager
};
managers.MouseManager = function() {
	this.arrayPoints = [];
	this.refreshPerFrame = 1;
	this.calledPerFrame = 0;
	Main.getInstance().tileCont.on("mousedown",$bind(this,this.mouseDown));
	Main.getInstance().tileCont.on("mouseup",$bind(this,this.mouseUp));
	Main.getInstance().tileCont.on("mousemove",$bind(this,this.mouseMoveHandler));
};
managers.MouseManager.__name__ = ["managers","MouseManager"];
managers.MouseManager.getSquareTileAround = function(posClicked,size) {
	if(size == null) size = 1;
	if(size == 0) return [posClicked];
	var ArrayOfPos = [];
	var tileSize = Main.tileSize;
	var GridAround = [];
	var iter = new IntIterator(Math.floor(-size),Math.floor(1 + size));
	while( iter.hasNext() ) {
		var i = iter.next();
		var iter2 = new IntIterator(-size * 2,size * 4);
		while( iter2.hasNext() ) {
			var j = iter2.next();
			GridAround.push([posClicked[0] + i,posClicked[1] - j]);
		}
	}
	var centerPosition = posClicked;
	ArrayOfPos.push([centerPosition[0],centerPosition[1]]);
	var dx;
	var dy;
	var centerAbsolutePos = utils.Misc.convertToAbsolutePosition(centerPosition);
	var $it0 = HxOverrides.iter(GridAround);
	while( $it0.hasNext() ) {
		var i1 = $it0.next();
		var absolutePosPoint = utils.Misc.convertToAbsolutePosition(i1);
		dx = (centerAbsolutePos[0] - absolutePosPoint[0]) / tileSize[0];
		dy = (centerAbsolutePos[1] - absolutePosPoint[1]) / tileSize[1];
		if(Math.abs(dx) + Math.abs(dy) <= size && HxOverrides.indexOf(ArrayOfPos,i1,0) == -1) ArrayOfPos.push(i1);
	}
	return ArrayOfPos;
};
managers.MouseManager.createLilCubes = function(position,color) {
	var iter = new IntIterator(0,position.length);
	var tileSize = Main.tileSize;
	var redPoint;
	while( iter.hasNext() ) {
		var i = iter.next();
		var displayX = position[i][0] * tileSize[0] - 1;
		var displayY = position[i][1] * tileSize[1] / 2 - 1;
		if(Math.abs(position[i][1] % 2) == 1) displayX += tileSize[0] * 0.5;
		displayY += tileSize[1] * 0.5;
		redPoint = new PIXI.Graphics();
		var specialColor;
		if(color != null) specialColor = color; else specialColor = 65280;
		redPoint.lineStyle(1,specialColor);
		redPoint.beginFill(16711680);
		redPoint.drawRect(-1,-1,3,3);
		redPoint.endFill();
		redPoint.y = displayY - 1;
		redPoint.x = displayX - 1;
		managers.DrawManager.addToDisplay(redPoint,Main.getInstance().tileCont,100);
	}
	return redPoint;
};
managers.MouseManager.getInstance = function() {
	if(managers.MouseManager.instance == null) managers.MouseManager.instance = new managers.MouseManager();
	return managers.MouseManager.instance;
};
managers.MouseManager.prototype = {
	mouseMoveHandler: function(e) {
		if(this.calledPerFrame > this.refreshPerFrame || managers.StateManager.loadingState || managers.MouseManager.lockedMouseEvents) return;
		++this.calledPerFrame;
		var clicPoint = [e.data.global.x + Main.camera.offset[0],e.data.global.y + Main.camera.offset[1]];
		var tilePos = utils.Misc.convertToGridPosition(clicPoint[0],clicPoint[1]);
		managers.MouseManager.gamehover.layerX = e.data.global.x;
		managers.MouseManager.gamehover.layerY = e.data.global.y;
		managers.MouseManager.gamehover.tilePos = tilePos;
		managers.MouseManager.gamehover.gamePos = clicPoint;
		window.dispatchEvent(managers.MouseManager.gamehover);
	}
	,mouseUp: function(e) {
		if(managers.StateManager.loadingState || managers.MouseManager.lockedMouseEvents) return;
		var event = managers.MouseManager.gameMouseUp;
		var clicPoint = [e.data.global.x + Main.camera.offset[0],e.data.global.y + Main.camera.offset[1]];
		event.layerX = e.data.global.x;
		event.layerY = e.data.global.y;
		Reflect.setField(event,"tilePos",utils.Misc.convertToGridPosition(clicPoint[0],clicPoint[1]));
		event.gamePos = clicPoint;
		event.drag = objects.Camera.getInstance().isDragged;
		window.dispatchEvent(event);
	}
	,mouseDown: function(e) {
		if(managers.StateManager.loadingState || managers.MouseManager.lockedMouseEvents) return;
		var event = managers.MouseManager.gameMouseDown;
		var clicPoint = [e.data.global.x + Main.camera.offset[0],e.data.global.y + Main.camera.offset[1]];
		event.layerX = e.data.global.x;
		event.layerY = e.data.global.y;
		Reflect.setField(event,"tilePos",utils.Misc.convertToGridPosition(clicPoint[0],clicPoint[1]));
		event.gamePos = clicPoint;
		window.dispatchEvent(event);
	}
	,__class__: managers.MouseManager
};
managers.PoolManager = function() {
	managers.PoolManager.Pools.set("tile",[]);
	managers.PoolManager.Pools.set("dmgText",[]);
};
managers.PoolManager.__name__ = ["managers","PoolManager"];
managers.PoolManager.generatePool = function() {
	var _g = 0;
	while(_g < 30) {
		var i = _g++;
		managers.PoolManager.Pools.get("tile").push(new objects.Tile(PIXI.Texture.fromImage("tile.png")));
		managers.PoolManager.Pools.get("dmgText").push(new objects.particle.DmgText());
	}
};
managers.PoolManager.pullObject = function(poolName,number) {
	if(!managers.PoolManager.Pools.exists(poolName)) return [];
	if(number > managers.PoolManager.Pools.get(poolName).length) {
		var iter = new IntIterator(0,Math.abs(managers.PoolManager.Pools.get(poolName).length - number));
		while( iter.hasNext() ) {
			var i = iter.next();
			managers.PoolManager.Pools.get(poolName).push(managers.PoolManager.findClass(poolName));
			if(managers.PoolManager.Pools.get(poolName)[managers.PoolManager.Pools.get(poolName).length - 1] == null) return [];
		}
	}
	var returnArray = [];
	var _g = 0;
	while(_g < number) {
		var i1 = _g++;
		returnArray.push(managers.PoolManager.Pools.get(poolName).pop());
		returnArray[i1].visible = true;
	}
	return returnArray;
};
managers.PoolManager.returnObject = function(poolName,object) {
	if(!managers.PoolManager.Pools.exists(poolName)) return;
	object.visible = false;
	managers.PoolManager.Pools.get(poolName).push(object);
};
managers.PoolManager.findClass = function(name) {
	switch(name) {
	case "tile":
		return new objects.Tile(PIXI.Texture.fromImage("tile.png"));
	case "dmgText":
		return new objects.particle.DmgText();
	}
	console.log("class not found in PoolManager: " + name);
	return null;
};
managers.PoolManager.getInstance = function() {
	if(managers.PoolManager.instance == null) managers.PoolManager.instance = new managers.PoolManager();
	return managers.PoolManager.instance;
};
managers.PoolManager.prototype = {
	destroy: function() {
		managers.PoolManager.instance = null;
	}
	,__class__: managers.PoolManager
};
managers.StateManager = function() {
	this.debugActiveState = new PIXI.Text("Init",{ fill : "white", font : "30px gastFont"});
	this.firstLoop = true;
	this.skipNextLateUpdate = false;
	this.activeState = "Preload";
	this.statesArray = new haxe.ds.StringMap();
	this.addState(new states.PreloadState());
	this.addState(new states.MenuState());
	this.addState(new states.DebugState());
	Main.getInstance().debugCont.addChild(this.debugActiveState);
	this.debugActiveState.x = 10;
	this.debugActiveState.y = Main.getInstance().renderer.height - 30;
	managers.StateManager.debugText.x = 200;
	managers.StateManager.debugText.y = Main.getInstance().renderer.height - 30;
	Main.getInstance().debugCont.addChild(managers.StateManager.debugText);
	this.switchToState(this.activeState);
};
managers.StateManager.__name__ = ["managers","StateManager"];
managers.StateManager.getInstance = function() {
	if(managers.StateManager.instance == null) managers.StateManager.instance = new managers.StateManager();
	return managers.StateManager.instance;
};
managers.StateManager.prototype = {
	addState: function(state) {
		this.statesArray.set(state.name,state);
		state;
	}
	,switchToState: function(newState) {
		managers.StateManager.loadingState = true;
		if(!this.firstLoop) this.statesArray.get(this.activeState).switchState();
		this.firstLoop = false;
		managers.DrawManager.switchState();
		Main.mapManager.switchState();
		Main.characterManager.switchState();
		objects.Camera.getInstance().switchState();
		managers.HudManager.getInstance().switchState();
		this.activeState = newState;
		this.activatedState = this.statesArray.get(this.activeState);
		this.debugActiveState.text = this.activeState;
		var $it0 = HxOverrides.iter(Main.getInstance().fullStage.children);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(i.name != "debugCont") (js.Boot.__cast(i , PIXI.Container)).removeChildren();
		}
		if(this.statesArray.get(this.activeState) == null) throw new Error("Erreur: State Inconnu => '" + this.activeState + "' \nLes states connus sont: " + Std.string(Reflect.field(this.statesArray.keys(),"arr")));
		this.statesArray.get(this.activeState)._StartLoading();
		this.skipNextLateUpdate = true;
	}
	,Update: function() {
		this.statesArray.get(this.activeState)._PrepareUpdate();
		Main.getInstance().Render();
		if(!this.skipNextLateUpdate) this.statesArray.get(this.activeState).LateUpdate();
		this.skipNextLateUpdate = false;
	}
	,__class__: managers.StateManager
};
managers.TimeManager = function() {
	this.numberOfTicks = 0;
	this.tickInterval = 90;
	this.frameElapsed = 0;
	this.timeNow = new Date().getTime();
};
managers.TimeManager.__name__ = ["managers","TimeManager"];
managers.TimeManager.getInstance = function() {
	if(managers.TimeManager.instance == null) managers.TimeManager.instance = new managers.TimeManager();
	return managers.TimeManager.instance;
};
managers.TimeManager.prototype = {
	Update: function() {
		managers.TimeManager.elapsedTime += new Date().getTime() - this.timeNow;
		managers.TimeManager.deltaTime = (new Date().getTime() - this.timeNow) / 1000;
		this.timeNow = new Date().getTime();
		if(Main.FIGHTMODE) this.combatTick();
		if(3600 * managers.TimeManager.deltaTime > 60) managers.TimeManager.FPS = 60; else managers.TimeManager.FPS = Math.floor(3600 * managers.TimeManager.deltaTime);
	}
	,combatTick: function() {
		++this.frameElapsed;
		if(this.frameElapsed % this.tickInterval == 0) {
			++this.numberOfTicks;
			this.newTick();
		}
		if(managers.HudManager.mode == "fight") (js.Boot.__cast(Main.getInstance().hudCont.getChildByName("right_bottom") , PIXI.Container)).getChildByName("tickTimer").rotation = 2 * Math.PI * (this.frameElapsed % this.tickInterval / this.tickInterval);
	}
	,newTick: function() {
		var $it0 = managers.CharacterManager.getInstance().managedCharacters.iterator();
		while( $it0.hasNext() ) {
			var element = $it0.next();
			element.newTick(this.numberOfTicks);
		}
	}
	,switchState: function() {
	}
	,__class__: managers.TimeManager
};
var objects = {};
objects.Animation = function(newName,newData,endCallback) {
	this.direction = 0;
	this.callback = function() {
	};
	this.name = newName;
	this.loop = newData.loop;
	this.data = newData.frameData;
	this.fps = newData.fps;
};
objects.Animation.__name__ = ["objects","Animation"];
objects.Animation.prototype = {
	getFrames: function(newDirection) {
		this.direction = newDirection;
		return this.data[this.direction];
	}
	,getLastIndex: function() {
		return this.data[this.direction][this.data[this.direction].length - 1];
	}
	,endAction: function() {
		this.callback();
	}
	,__class__: objects.Animation
};
objects.Button = function(name) {
	this.locked = false;
	this.isAbove = false;
	this.isDown = false;
	this.text = new PIXI.Text("",{ fill : "white", font : "60px gastFont"});
	this.arrayCallbacks = { };
	var arrayTextures = [];
	arrayTextures.push(PIXI.Texture.fromImage(name + "_idle.png"));
	arrayTextures.push(PIXI.Texture.fromImage(name + "_hover.png"));
	arrayTextures.push(PIXI.Texture.fromImage(name + "_down.png"));
	PIXI.extras.MovieClip.call(this,arrayTextures);
	this.interactive = true;
	this.buttonMode = true;
	this.defaultCursor = "pointer";
	this.anchor.set(0.5,0.5);
	this.arrayCallbacks.down = function() {
	};
	this.arrayCallbacks.up = function() {
	};
	this.arrayCallbacks.hover = function() {
	};
	this.arrayCallbacks.out = function() {
	};
	this.on("mousedown",$bind(this,this.p_onDown));
	this.on("mouseup",$bind(this,this.p_onUp));
	this.on("mouseover",$bind(this,this.p_onHover));
	this.on("mouseout",$bind(this,this.p_onOut));
	var shadow = new PIXI.filters.DropShadowFilter();
	shadow.color = 0;
	shadow.distance = 5;
	shadow.alpha = 0.55;
	shadow.angle = 45;
	shadow.blur = 5;
	this.filters = [shadow];
};
objects.Button.__name__ = ["objects","Button"];
objects.Button.__super__ = PIXI.extras.MovieClip;
objects.Button.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	setText: function(newText) {
		this.text.text = newText;
		this.text.visible = true;
		if(this.text.parent == null && newText != "") {
			this.text.anchor.set(0.5,0.5);
			this.text.scale.set(1 / this.scale.x,1 / this.scale.y);
			this.addChild(this.text);
		} else if(newText == "") this.text.visible = false;
	}
	,setSpecialTexture: function(actionName) {
		if(actionName == "hover") this.gotoAndStop(1); else if(actionName == "down") this.gotoAndStop(2); else this.gotoAndStop(0);
	}
	,p_onDown: function(e) {
		if(this.locked) return;
		this.isDown = true;
		this.setSpecialTexture("down");
		this.arrayCallbacks.down(e);
		e.stopPropagation();
	}
	,p_onUp: function(e) {
		if(this.locked) return;
		if(!this.isDown) return;
		this.isDown = false;
		this.setSpecialTexture("hover");
		this.arrayCallbacks.up(e);
		e.stopPropagation();
	}
	,p_onOut: function(e) {
		if(this.locked) return;
		this.isDown = false;
		this.setSpecialTexture("idle");
		this.arrayCallbacks.out(e);
		e.stopPropagation();
	}
	,p_onHover: function(e) {
		if(this.locked) return;
		if(this.isDown) this.setSpecialTexture("down"); else this.setSpecialTexture("hover");
		this.arrayCallbacks.hover(e);
	}
	,mouseIsAbove: function(e) {
		return utils.Misc.colliSquarePoint(this,[e.data.global.x,e.data.global.y]);
	}
	,Destroy: function() {
		this.destroy();
	}
	,onDown: function(newFunction) {
		this.arrayCallbacks.down = newFunction;
	}
	,onUp: function(newFunction) {
		this.arrayCallbacks.up = newFunction;
	}
	,onHover: function(newFunction) {
		this.arrayCallbacks.hover = newFunction;
	}
	,onOut: function(newFunction) {
		this.arrayCallbacks.out = newFunction;
	}
	,lock: function() {
		this.isDown = false;
		this.locked = true;
		this.tint = 6710886;
		this.buttonMode = false;
	}
	,unlock: function() {
		this.locked = false;
		this.tint = 16777215;
		this.buttonMode = true;
	}
	,__class__: objects.Button
});
objects.Camera = function() {
	this.clampedCam = true;
	this.isDragged = false;
	this.clicked = false;
	this.oldCameraPosition = [];
	this.mouseDownPosition = [];
	this.dragSensitivity = 2;
	this.minimumMovement = 10;
	this.size = [0,0];
	this.offset = [0,0];
	this.minimumMovement = Reflect.field(managers.InitManager.data.config.camera,"minimumMovement");
	this.dragSensitivity = Reflect.field(managers.InitManager.data.config.camera,"sensitivity");
	window.addEventListener("gameMouseDown",$bind(this,this.mouseDownListener));
	window.addEventListener("gameHover",$bind(this,this.mouseMoveListener));
	window.addEventListener("gameMouseUp",$bind(this,this.mouseUpListener));
	window.addEventListener("resize",$bind(this,this.getContainerBounds));
	this.getContainerBounds();
	this.mapSize = Main.getInstance().fullStage.getBounds();
};
objects.Camera.__name__ = ["objects","Camera"];
objects.Camera.getInstance = function() {
	if(objects.Camera.instance == null) objects.Camera.instance = new objects.Camera();
	return objects.Camera.instance;
};
objects.Camera.prototype = {
	mouseDownListener: function(e) {
		this.clicked = true;
		this.mouseDownPosition = [e.layerX,e.layerY];
		this.oldCameraPosition = this.offset;
	}
	,mouseMoveListener: function(e) {
		if(!managers.MapManager.getInstance().activeMap.scrollable || objects.Camera.targetToFollow != null) return;
		if(!this.clicked) return;
		if(this.isDragged == false && Math.abs(this.mouseDownPosition[0] - e.layerX) < this.minimumMovement && Math.abs(this.mouseDownPosition[1] - e.layerY) < this.minimumMovement) return; else if(!this.isDragged) {
			this.mouseDownPosition[0] = e.layerX;
			this.mouseDownPosition[1] = e.layerY;
		}
		this.isDragged = true;
		this.offset = [this.oldCameraPosition[0] - (e.layerX - this.mouseDownPosition[0]) * this.dragSensitivity,this.oldCameraPosition[1] - (e.layerY - this.mouseDownPosition[1]) * this.dragSensitivity];
		if(this.clampedCam) this.constrainCam();
		this.translateOffsetToConts();
	}
	,mouseUpListener: function(e) {
		this.clicked = false;
		this.isDragged = false;
	}
	,setCameraPosition: function(newPosition) {
		this.offset = newPosition;
		this.translateOffsetToConts();
	}
	,translateOffsetToConts: function() {
		Main.getInstance().tileCont.x = -this.offset[0];
		Main.getInstance().tileCont.y = -this.offset[1];
		Main.getInstance().gameCont.x = -this.offset[0];
		Main.getInstance().gameCont.y = -this.offset[1];
	}
	,getContainerBounds: function(e) {
		this.size = [Main.getInstance().renderer.width,Main.getInstance().renderer.height];
	}
	,updateMapSize: function(newMap) {
		this.mapSize.width = newMap.graphicalData[0].length * Main.tileSize[0];
		this.mapSize.height = newMap.graphicalData.length * Main.tileSize[1] * 0.5;
	}
	,Update: function() {
		if(objects.Camera.targetToFollow != null) {
			this.offset[0] = objects.Camera.targetToFollow.x - this.size[0] * 0.5;
			this.offset[1] = objects.Camera.targetToFollow.y - this.size[1] * 0.5;
			if(this.clampedCam) this.constrainCam();
			this.translateOffsetToConts();
		}
	}
	,constrainCam: function() {
		this.offset[0] = utils.Misc.clamp(this.offset[0],0,Math.max(this.mapSize.width - this.size[0] - Main.tileSize[0],0));
		this.offset[1] = utils.Misc.clamp(this.offset[1],0,Math.max(this.mapSize.height - this.size[1] - Main.tileSize[1] * 1.5,0));
	}
	,clampCam: function() {
		this.clampedCam = true;
	}
	,unClampCam: function() {
		this.clampedCam = false;
	}
	,setFollowTarget: function(target,absolutePos) {
		if(absolutePos == null) absolutePos = false;
		objects.Camera.targetToFollow = target;
		this.clampedCam = !absolutePos;
	}
	,switchState: function() {
		this.setCameraPosition([0,0]);
		objects.Camera.targetToFollow = null;
	}
	,__class__: objects.Camera
};
objects.GameMap = function(datas,mapName) {
	this.tileMap = [];
	this.scrollable = false;
	this.mapContainer = new PIXI.Container();
	this.OffsetY = 0;
	this.OffsetX = 0;
	if(datas == null) return;
	this.name = mapName;
	this.json = managers.InitManager.data.config.mapJson[this.name];
	this.OffsetY = Main.tileSize[1] * 0.5;
	if(this.json == null) window.console.warn("%c[WARNING] no data json found for map '" + mapName + "' ","color:red;");
	this.json.tiles.unshift(null);
	this.json.tilesHeight.unshift(null);
	this.setMapData(datas.graphics,datas.collisions);
	this.generatePathfinding();
};
objects.GameMap.__name__ = ["objects","GameMap"];
objects.GameMap.prototype = {
	setMapData: function(newGraphicalData,newCollisionData) {
		this.graphicalData = newGraphicalData;
		this.collisionData = newCollisionData;
	}
	,addTileToMap: function(tile,layer) {
		managers.DrawManager.addToDisplay(tile,this.mapContainer,layer);
	}
	,displayMap: function() {
		if(this.mapContainer.parent == null) managers.DrawManager.addToDisplay(this.mapContainer,Main.getInstance().tileCont);
		this.mapContainer.visible = true;
		managers.MapManager.displayDebugColliMap(managers.MapManager.finder.getGrid());
	}
	,hideMap: function(remove) {
		if(remove == null) remove = false;
		this.mapContainer.visible = false;
		if(remove) managers.DrawManager.removeFromDisplay(this.mapContainer);
	}
	,getTileAt: function(tilePosition) {
		return this.json.tiles[this.graphicalData[tilePosition[1]][tilePosition[0]]];
	}
	,getColliAt: function(tilePosition) {
		console.log(this.mapContainer.y);
		return this.collisionData[tilePosition[1]][tilePosition[0]] != 0;
	}
	,generatePathfinding: function() {
		var finder = managers.MapManager.finder;
		finder.setGrid(this.collisionData);
		finder.setAcceptableTiles(managers.InitManager.data.config.tileCollisions.walkable);
		finder.enableDiagonals();
		finder.enableSync();
		window.finder = finder;
	}
	,getWalkableAt: function(target) {
		return managers.MapManager.finder.isTileWalkable(managers.MapManager.finder.getGrid(),[managers.InitManager.data.config.tileCollisions.walkable],target[0],target[1]);
	}
	,findPath: function(source,target) {
		var finder = managers.MapManager.finder;
		var path = [];
		if(source[0] > this.collisionData[0].length - 1 || target[0] > this.collisionData[0].length - 1 || source[1] > this.collisionData.length - 1 || target[1] > this.collisionData.length - 1 || source[0] < 0 || source[1] < 0 || target[0] < 0 || target[1] < 0) return [];
		finder.findPath(source[0],source[1],target[0],target[1],function(newpath) {
			if(newpath != null) path = newpath;
		});
		finder.calculate();
		return path;
	}
	,__class__: objects.GameMap
};
objects.HudButton = function(textureName,actionName) {
	objects.Button.call(this,textureName);
	this.anchor.set(0.5,0.5);
	this.actionName = actionName;
	this.name = actionName;
	this.onUp(function() {
		objects.character.Player.getInstance().changeSelectedAction(actionName);
		objects.character.Player.getInstance().generateAttackRange(actionName);
	});
};
objects.HudButton.__name__ = ["objects","HudButton"];
objects.HudButton.__super__ = objects.Button;
objects.HudButton.prototype = $extend(objects.Button.prototype,{
	__class__: objects.HudButton
});
objects.HudElement = function(texture) {
	this.stopping = false;
	PIXI.Sprite.call(this,texture);
	this.interactive = true;
	this.on("mousemove",$bind(this,this.p_onMove));
};
objects.HudElement.__name__ = ["objects","HudElement"];
objects.HudElement.__super__ = PIXI.Sprite;
objects.HudElement.prototype = $extend(PIXI.Sprite.prototype,{
	mouseIsAbove: function(point) {
		return utils.Misc.colliSquarePoint(this,point);
	}
	,p_onMove: function(e) {
		this.stopping = this.mouseIsAbove([e.data.global.x,e.data.global.y]);
		if(this.stopping) {
			objects.character.Player.getInstance().hideEveryTile();
			e.stopPropagation();
		}
	}
	,__class__: objects.HudElement
});
objects.Options = function() {
	objects.Options.setOption("player_showHoverMovement",true);
};
objects.Options.__name__ = ["objects","Options"];
objects.Options.setOption = function(name,value) {
	objects.Options.data[name] = value;
	objects.Options.saveOptions();
};
objects.Options.saveOptions = function() {
	js.Browser.getLocalStorage().setItem("gastOptions",JSON.stringify(objects.Options.data));
};
objects.Options.getInstance = function() {
	if(objects.Options.instance == null) objects.Options.instance = new objects.Options();
	return objects.Options.instance;
};
objects.Options.prototype = {
	loadOptions: function() {
		var storageString = js.Browser.getLocalStorage().getItem("gastOptions");
		if(storageString.length == 0) return;
		objects.Options.data = JSON.parse(storageString);
	}
	,__class__: objects.Options
};
objects.State = function(newName) {
	this.loadJson = new haxe.ds.StringMap();
	this.ButtonText = new PIXI.Text("",{ fill : "black", font : "30px gastFont"});
	this.LoadingText = new PIXI.Text("",{ fill : "white", font : "30px gastFont"});
	this.canPlaceBuildings = false;
	this.name = "default";
	this.StateLoaded = false;
	this.name = newName;
	this.LoadingText.x = this.LoadingText.y = 300;
	this.ButtonText.x = this.ButtonText.y = 300;
};
objects.State.__name__ = ["objects","State"];
objects.State.prototype = {
	_StartLoading: function() {
		this.Preload();
		if(Lambda.count(this.loadJson) == 0) {
			this.StateLoaded = true;
			this.Start();
			managers.StateManager.loadingState = false;
			return;
		}
		var jsonLoader = new PIXI.loaders.Loader();
		var $it0 = this.loadJson.iterator();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			jsonLoader.add(i,this.loadJson.get(i));
		}
		jsonLoader.once("complete",$bind(this,this._assetLoaded));
		jsonLoader.on("progress",$bind(this,this.AssetLoad));
		jsonLoader.load();
	}
	,_onAssetLoadProgress: function(loader,resource) {
		this.AssetLoad(loader);
	}
	,_assetLoaded: function(loader) {
		this.AllAssetsLoaded(loader);
		this.StateLoaded = true;
		this.Start();
		managers.StateManager.loadingState = false;
	}
	,Preload: function() {
	}
	,AssetLoad: function(loader) {
	}
	,AllAssetsLoaded: function(loader) {
	}
	,_PrepareUpdate: function() {
		if(this.StateLoaded) this.Update();
	}
	,Start: function() {
	}
	,Update: function() {
	}
	,LateUpdate: function() {
	}
	,switchState: function() {
	}
	,__class__: objects.State
};
objects.Tile = function(texture) {
	this.tilePos = [0,0];
	this.z = 0;
	PIXI.Sprite.call(this,texture);
	this.anchor.set(0.5,1);
};
objects.Tile.__name__ = ["objects","Tile"];
objects.Tile.__super__ = PIXI.Sprite;
objects.Tile.prototype = $extend(PIXI.Sprite.prototype,{
	setTilePosition: function(position) {
		this.tilePos[0] = position[0];
		this.x = position[0] * Main.tileSize[0] + managers.MapManager.getInstance().activeMap.OffsetX;
		this.tilePos[1] = position[1];
		this.y = position[1] * Main.tileSize[1] * 0.5 + managers.MapManager.getInstance().activeMap.OffsetY;
		if(Math.abs(this.tilePos[1] % 2) == 1) this.x += Main.tileSize[0] * 0.5;
		this.setZ(this.z);
	}
	,setAbsolutePosition: function(newX,newY) {
		this.x = newX;
		this.y = newY;
		this.setZ(this.z);
	}
	,setZ: function(newZ) {
		this.z = newZ;
		this.depth = this.y + this.z;
	}
	,getAbsolutePosition: function() {
		var arrayToReturn = [];
		arrayToReturn[0] = this.tilePos[0] * Main.tileSize[0];
		arrayToReturn[1] = this.tilePos[1] * Main.tileSize[1] * 0.5;
		if(Math.abs(this.tilePos[1] % 2) == 1) arrayToReturn[0] += Main.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	,__class__: objects.Tile
});
objects.attacks = {};
objects.attacks.Attack = function(jsonData) {
	this.apCost = 0;
	this.damage = 0;
	this.maxRange = 0;
	this.minRange = 0;
	this.finished = false;
	this.targetPosition = [];
	this.frameElaped = 0;
	this.activeFrameData = 0;
	this.framesData = [];
	this.animationName = "no animation defined";
	this.waitForFinish = true;
	this.framesData = jsonData.framesData;
	this.animationName = jsonData.animationName;
	this.waitForFinish = jsonData.waitForFinish;
	this.minRange = jsonData.minRange;
	this.maxRange = jsonData.maxRange;
	this.damage = jsonData.damage;
	this.apCost = jsonData.apCost;
};
objects.attacks.Attack.__name__ = ["objects","attacks","Attack"];
objects.attacks.Attack.prototype = {
	updateAttack: function(launcher) {
		if(this.frameElaped == this.framesData[this.activeFrameData][0]) this.attackEffect(launcher.stats);
		if(this.frameElaped == this.framesData[this.activeFrameData][0] + this.framesData[this.activeFrameData][1]) {
			if(this.activeFrameData == this.framesData.length - 1) this.endAction(launcher); else {
				this.frameElaped = 0;
				++this.activeFrameData;
			}
		}
		++this.frameElaped;
	}
	,activateAttack: function(position) {
		this.targetPosition = position;
		this.activeFrameData = 0;
		this.frameElaped = 0;
		this.finished = false;
	}
	,attackEffect: function(stats) {
	}
	,endAction: function(launcher) {
		launcher.waitForNextTick = this.waitForFinish;
		this.finished = true;
	}
	,__class__: objects.attacks.Attack
};
objects.attacks.NormalAttack = function(jsonData) {
	objects.attacks.Attack.call(this,jsonData);
};
objects.attacks.NormalAttack.__name__ = ["objects","attacks","NormalAttack"];
objects.attacks.NormalAttack.__super__ = objects.attacks.Attack;
objects.attacks.NormalAttack.prototype = $extend(objects.attacks.Attack.prototype,{
	attackEffect: function(stats) {
		objects.attacks.Attack.prototype.attackEffect.call(this,stats);
		if(managers.CharacterManager.getInstance().findCharacterAtTilePos(this.targetPosition)) managers.CharacterManager.getInstance().findCharacterAtTilePos(this.targetPosition).damage(this.damage * (stats.strength / 100 * 10));
	}
	,__class__: objects.attacks.NormalAttack
});
objects.attacks.TripleAttack = function(jsonData) {
	objects.attacks.Attack.call(this,jsonData);
};
objects.attacks.TripleAttack.__name__ = ["objects","attacks","TripleAttack"];
objects.attacks.TripleAttack.__super__ = objects.attacks.Attack;
objects.attacks.TripleAttack.prototype = $extend(objects.attacks.Attack.prototype,{
	attackEffect: function(stats) {
		if(managers.CharacterManager.getInstance().findCharacterAtTilePos(this.targetPosition)) managers.CharacterManager.getInstance().findCharacterAtTilePos(this.targetPosition).damage(this.damage * (stats.strength / 100 * 10));
	}
	,__class__: objects.attacks.TripleAttack
});
objects.character = {};
objects.character.Character = function(newName) {
	this.isDead = false;
	this.waitForNextTick = false;
	this.updateBlocked = false;
	this.lastTickRegistered = 0;
	this.depth = 0;
	this.z = 0;
	this.animationFrame = 0;
	this.animations = new haxe.ds.StringMap();
	this.dmgTextPool = [];
	this.activeAttackRange = [];
	this.attacks = new haxe.ds.StringMap();
	this.refreshSpeed = 1;
	this.pathIndex = 1;
	this.activePath = [];
	this.stats = { health : 100, strength : 10, endurance : 10, regeneration : 10, moveSpeed : 2.5, precision : 10, luck : 10, AP : 10, MaxAP : 10};
	this.directionFacing = 0;
	this.tilePos = [0,0];
	this.charaName = newName;
	this.config = managers.InitManager.data[newName];
	PIXI.extras.MovieClip.call(this,this.generateTextures(this.charaName));
	this.generateStats();
	this.generateAnimations();
	this.generateAttacks();
	this.loop = true;
	this.anchor.set(0.5,1);
	this.dmgTextPool = managers.PoolManager.pullObject("dmgText",5);
	managers.CharacterManager.getInstance().addCharacter(this);
};
objects.character.Character.__name__ = ["objects","character","Character"];
objects.character.Character.__super__ = PIXI.extras.MovieClip;
objects.character.Character.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	generateStats: function() {
		this.stats.health = this.config.stats.health;
		this.stats.strength = this.config.stats.strength;
		this.stats.endurance = this.config.stats.endurance;
		this.stats.regeneration = this.config.stats.regeneration;
		this.stats.moveSpeed = this.config.stats.moveSpeed;
		this.stats.precision = this.config.stats.precision;
		this.stats.luck = this.config.stats.luck;
		this.stats.MaxAP = this.config.stats.MaxAP;
		this.stats.AP = this.stats.MaxAP;
	}
	,getUnusedDmgTextIndex: function() {
		var $it0 = HxOverrides.iter(this.dmgTextPool);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(!i.visible) return HxOverrides.indexOf(this.dmgTextPool,i,0);
		}
		this.dmgTextPool.push(managers.PoolManager.pullObject("dmgText",1)[0]);
		return this.dmgTextPool.length - 1;
	}
	,generateTextures: function(newName) {
		var returnArray = [];
		var textureData = this.config.texturesUrls;
		if(textureData == null) window.console.warn("NO TEXTUREDATA FOUND FOR: " + newName);
		var $it0 = HxOverrides.iter(textureData);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			returnArray.push(PIXI.Texture.fromImage(i));
		}
		return returnArray;
	}
	,generateAttacks: function() {
		var _g = 0;
		var _g1 = Reflect.fields(this.config.attacks);
		while(_g < _g1.length) {
			var i = _g1[_g];
			++_g;
			var value = utils.Misc.getAttackFromName(i,Reflect.field(this.config.attacks,i));
			this.attacks.set(i,value);
		}
	}
	,generateAnimations: function() {
		var _g = 0;
		var _g1 = Reflect.fields(this.config.animations);
		while(_g < _g1.length) {
			var i = _g1[_g];
			++_g;
			this.addAnimation(i,Reflect.field(this.config.animations,i));
		}
		this.setAnimation("idle");
	}
	,addAnimation: function(newName,data,endCallback) {
		var value = new objects.Animation(newName,data,endCallback);
		this.animations.set(newName,value);
	}
	,damage: function(amount) {
		var index = this.getUnusedDmgTextIndex();
		if(amount > 0) this.dmgTextPool[index].text = "-" + amount; else this.dmgTextPool[index].text = "+" + amount;
		this.dmgTextPool[index].alpha = 1;
		this.dmgTextPool[index].visible = true;
		this.dmgTextPool[index].x = this.x + Math.random() * this.width * 0.5 - this.width * 0.25;
		this.dmgTextPool[index].y = this.y - this.height * 0.5;
		this.dmgTextPool[index].anchor.set(0.5,0.5);
		if(this.dmgTextPool[index].parent == null) managers.DrawManager.addToDisplay(this.dmgTextPool[index],Main.getInstance().gameCont);
		this.dmgTextPool[index].animate(0.5);
		this.setAnimation("damage");
		this.stats.health -= amount;
		if(this.stats.health <= 0) {
			this.stats.health = 0;
			this.kill();
		}
	}
	,_selfUpdate: function() {
		this.manageAnim();
		if(!this.updateBlocked) {
			this.managePathFinding();
			if(Main.FIGHTMODE) this.fightUpdate(); else if(Main.FIGHTMODE) this.normalUpdate();
		}
	}
	,manageAnim: function() {
		if(this.activeAnimation == null) return;
		if(this.activeAttack != null) {
			if(!this.activeAttack.finished) this.activeAttack.updateAttack(this); else {
				this.activeAttack = null;
				if(this.activePathPoint == null) this.setAnimation("idle"); else {
					this.setDirection(utils.Misc.getDirectionToPoint(this.tilePos,[this.activePathPoint.x,this.activePathPoint.y]));
					this.setAnimation("run");
				}
			}
		}
		if(this.activeAnimation.data[0].length > 1) {
			if(this.animationFrame >= this.activeAnimation.getFrames(this.directionFacing).length - 1) {
				if(!this.activeAnimation.loop) {
					this.stop();
					this.setAnimation("idle");
					this.activeAnimation.endAction();
				} else this.gotoAndStop(this.activeAnimation.getFrames(this.directionFacing)[0]);
				this.animationFrame = 0;
			} else {
				this.animationFrame += this.activeAnimation.fps / 60;
				this.gotoAndStop(this.activeAnimation.getFrames(this.directionFacing)[Math.floor(this.animationFrame)]);
			}
		}
	}
	,managePathFinding: function() {
		if(this.activePath.length != 0 && this.stats.AP > 0) {
			if(this.activePathPoint == null) this.getNextPathPoint();
			if(this.tilePos[0] != this.activePath[this.activePath.length - 1].x || this.tilePos[1] != this.activePath[this.activePath.length - 1].y) {
				var arrayPos = [this.activePathPoint.x,this.activePathPoint.y];
				this.setAbsolutePosition(this.x + Math.cos(utils.Misc.angleBetweenTiles(this.tilePos,arrayPos)) * this.stats.moveSpeed * managers.TimeManager.deltaTime,this.y - Math.sin(utils.Misc.angleBetweenTiles(this.tilePos,arrayPos)) * this.stats.moveSpeed * managers.TimeManager.deltaTime);
				if(utils.Misc.getDistance(this.x,this.y,utils.Misc.convertToAbsolutePosition(arrayPos)[0],utils.Misc.convertToAbsolutePosition(arrayPos)[1] + Main.tileSize[1] * 0.5) < this.stats.moveSpeed * managers.TimeManager.deltaTime) {
					this.setTilePosition(arrayPos);
					this.pathIndex++;
					this.useAp(1);
					if(this.pathIndex <= this.activePath.length - 1) this.getNextPathPoint(); else {
						this.setAnimation("idle");
						this.activePath = [];
						this.activePathPoint = null;
					}
				}
			}
		}
	}
	,getNextPathPoint: function() {
		this.activePathPoint = this.activePath[this.pathIndex];
		this.setDirection(utils.Misc.getDirectionToPoint(this.tilePos,[this.activePathPoint.x,this.activePathPoint.y]));
	}
	,normalUpdate: function() {
	}
	,fightUpdate: function() {
	}
	,setAnimation: function(animName) {
		if(!this.animations.exists(animName)) {
			window.console.warn("anim not found: " + animName);
			return;
		}
		this.activeAnimation = this.animations.get(animName);
		this.activeAnimationName = this.activeAnimation.name;
		if(this.activeAnimation.getFrames(this.directionFacing).length == 1) this.gotoAndStop(this.activeAnimation.getFrames(this.directionFacing)[0]); else this.gotoAndPlay(this.activeAnimation.getFrames(this.directionFacing)[0]);
		this.animationSpeed = this.activeAnimation.fps / 60;
	}
	,setDirection: function(newDir) {
		this.directionFacing = newDir % 4;
		this.setAnimation(this.activeAnimationName);
	}
	,kill: function() {
		console.log("TARGET '" + this.charaName + "' is dead !");
		this.setAnimation("death");
		this.updateBlocked = true;
		this.isDead = true;
		this.Destroy();
	}
	,setTilePosition: function(position) {
		managers.CharacterManager.getInstance().updateCharacterCoordinatesFromTo(this,position);
		this.tilePos[0] = position[0];
		this.x = position[0] * Main.tileSize[0] + managers.MapManager.getInstance().activeMap.OffsetX;
		this.tilePos[1] = position[1];
		this.y = position[1] * Main.tileSize[1] * 0.5 + managers.MapManager.getInstance().activeMap.OffsetY;
		if(Math.abs(this.tilePos[1] % 2) == 1) this.x += Main.tileSize[0] * 0.5;
		this.setZ(this.z);
	}
	,getAbsolutePosition: function() {
		var arrayToReturn = [];
		arrayToReturn[0] = this.tilePos[0] * Main.tileSize[0];
		arrayToReturn[1] = this.tilePos[1] * Main.tileSize[1] * 0.5;
		if(Math.abs(this.tilePos[1] % 2) == 1) arrayToReturn[0] += Main.tileSize[0] * 0.5;
		return arrayToReturn;
	}
	,setAbsolutePosition: function(newX,newY) {
		this.x = newX;
		this.y = newY;
		this.setZ(this.z);
	}
	,setZ: function(newZ) {
		this.z = newZ;
		this.depth = this.y + this.z;
	}
	,findPathTo: function(target,follow) {
		if(follow == null) follow = false;
		managers.MapManager.finder.setColliTile(this.tilePos[0],this.tilePos[1],true);
		var returnPath = managers.MapManager.getInstance().activeMap.findPath(this.getPathFindingPoint(),target);
		managers.MapManager.finder.setColliTile(this.tilePos[0],this.tilePos[1],false);
		if(follow) this.followPath(returnPath);
		return returnPath;
	}
	,followPath: function(path) {
		if(path.length == 0 || path.length - 1 > this.stats.AP) return;
		this.activePath = path;
		if(this.activePathPoint != null) this.pathIndex = 0; else this.pathIndex = 1;
		this.setAnimation("run");
	}
	,launchAttack: function(attackName,targetPosition) {
		if(this.attacks.get(attackName) == null) {
			window.console.warn("attack not found: " + attackName);
			return;
		}
		if(!utils.Misc.targetInRange(this.tilePos,targetPosition,this.activeAttackRange)) {
			window.console.warn("target not in range");
			return;
		}
		if(this.attacks.get(attackName).apCost > this.stats.AP) {
			window.console.warn("not enough AP");
			return;
		}
		this.activeAttack = this.attacks.get(attackName);
		this.useAp(this.activeAttack.apCost);
		this.setAnimation(this.activeAttack.animationName);
		this.updateBlocked = this.activeAttack.waitForFinish;
		this.activeAttack.activateAttack(targetPosition);
		this.setDirection(utils.Misc.getDirectionToPoint(this.tilePos,targetPosition));
	}
	,getPathFindingPoint: function() {
		if(this.activePathPoint != null) return [this.activePathPoint.x,this.activePathPoint.y];
		return this.tilePos;
	}
	,newTick: function(tickNumber) {
		if(this.stats.AP < this.stats.MaxAP) this.stats.AP += tickNumber - this.lastTickRegistered;
		this.lastTickRegistered = tickNumber;
		if(this.waitForNextTick) {
			this.waitForNextTick = false;
			this.updateBlocked = false;
		}
	}
	,useAp: function(amount) {
		this.stats.AP -= amount;
	}
	,Destroy: function() {
		managers.CharacterManager.getInstance().removeCharacter(this);
		managers.DrawManager.removeFromDisplay(this);
		if(objects.Camera.targetToFollow == this) objects.Camera.targetToFollow = null;
		this.destroy();
	}
	,__class__: objects.character.Character
});
objects.character.Player = function() {
	this.mouseHovering = false;
	this.pathPositions = [];
	this.tilePool = [];
	objects.character.Character.call(this,"hero");
	managers.HudManager.getInstance().HPmeter.text = "" + this.stats.health;
	managers.HudManager.getInstance().APmeter.text = "" + this.stats.AP;
	this.tilePool = managers.PoolManager.pullObject("tile",this.stats.MaxAP * 2);
	var $it0 = HxOverrides.iter(this.tilePool);
	while( $it0.hasNext() ) {
		var i = $it0.next();
		i.tint = 65280;
	}
	this.targetTile = new objects.Tile(PIXI.Texture.fromImage("selectedTile.png"));
	this.targetTile.visible = false;
	Main.getInstance().tileCont.on("mousemove",$bind(this,this.mapHover));
	Main.getInstance().tileCont.on("mouseup",$bind(this,this.mapClick));
	this.APFlash = new objects.particle.OSmovieclip([PIXI.Texture.fromFrame("y_explo_0"),PIXI.Texture.fromFrame("y_explo_1"),PIXI.Texture.fromFrame("y_explo_2"),PIXI.Texture.fromFrame("y_explo_3"),PIXI.Texture.fromFrame("y_explo_4"),PIXI.Texture.fromFrame("y_explo_5"),PIXI.Texture.fromFrame("y_explo_6")]);
	this.APFlash.anchor.set(0.5,0.5);
	this.APFlash.animationSpeed = 0.5;
};
objects.character.Player.__name__ = ["objects","character","Player"];
objects.character.Player.getInstance = function() {
	if(objects.character.Player.instance == null) objects.character.Player.instance = new objects.character.Player();
	return objects.character.Player.instance;
};
objects.character.Player.__super__ = objects.character.Character;
objects.character.Player.prototype = $extend(objects.character.Character.prototype,{
	mouseOverSelf: function(e) {
		if(objects.character.Player.selectedAction == "move") {
			if(objects.Options.data.player_showHoverMovement = true) this.showRange(0,this.stats.AP,65280,0.7,utils.Misc.getRangeTileAround(this.tilePos,1,this.stats.AP));
		}
	}
	,mouseOutSelf: function(e) {
		if(objects.character.Player.selectedAction == "move") {
			if(objects.Options.data.player_showHoverMovement = true) this.hidePoolTiles();
		}
	}
	,mapClick: function(e) {
		var newtilePos = utils.Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x,e.data.getLocalPosition(e.target).y);
		if(objects.character.Player.selectedAction == "move") {
			if(!objects.Camera.getInstance().isDragged) this.findPathTo(newtilePos,true);
		} else if(this.attacks.exists(objects.character.Player.selectedAction)) this.launchAttack(objects.character.Player.selectedAction,newtilePos);
		this.hideHoverTile();
		this.hidePoolTiles();
		this.changeSelectedAction("move");
	}
	,mapHover: function(e) {
		var newtilePos = utils.Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x,e.data.getLocalPosition(e.target).y);
		this.hidePoolTiles();
		this.hideHoverTile();
		if(objects.character.Player.selectedAction == "move") this.showPathMovement(this.findPathTo(newtilePos)); else if(this.attacks.exists(objects.character.Player.selectedAction)) {
			this.showRange(this.attacks.get(objects.character.Player.selectedAction).minRange,this.attacks.get(objects.character.Player.selectedAction).maxRange,16729927,0.3);
			if(utils.Misc.targetInRange(this.tilePos,newtilePos,this.activeAttackRange)) this.showHoverTile(newtilePos,16711680);
		}
		if(newtilePos[0] == this.tilePos[0] && newtilePos[1] == this.tilePos[1]) {
			this.mouseHovering = true;
			this.mouseOverSelf(e);
		} else if(this.mouseHovering) {
			this.mouseHovering = false;
			this.mouseOutSelf(e);
		}
		utils.Debug.log("" + Std.string(newtilePos));
	}
	,newTick: function(tickNumber) {
		objects.character.Character.prototype.newTick.call(this,tickNumber);
		managers.HudManager.getInstance().APmeter.text = "" + this.stats.AP;
		if(this.APFlash.parent == null) {
			managers.DrawManager.addToDisplay(this.APFlash,managers.HudManager.getInstance().APmeter);
			this.APFlash.scale.set(2 * (1 / this.APFlash.parent.parent.scale.x),2 * (1 / this.APFlash.parent.parent.scale.y));
		}
		this.APFlash.gotoAndPlay(0);
		this.lockHudButtons();
	}
	,damage: function(amount) {
		objects.character.Character.prototype.damage.call(this,amount);
		managers.HudManager.getInstance().HPmeter.text = "" + this.stats.health;
	}
	,lockHudButtons: function() {
		var $it0 = managers.HudManager.getInstance().attackButtons.keys();
		while( $it0.hasNext() ) {
			var attackName = $it0.next();
			if(this.stats.AP < this.attacks.get(attackName).apCost) managers.HudManager.getInstance().attackButtons.get(attackName).lock(); else managers.HudManager.getInstance().attackButtons.get(attackName).unlock();
		}
	}
	,showPathMovement: function(path) {
		path.shift();
		if(path.length == 0 || path.length > this.stats.AP) return;
		var $it0 = HxOverrides.iter(this.pathPositions);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			this.hideOnePoolTile(i);
		}
		this.pathPositions = [];
		var $it1 = HxOverrides.iter(path);
		while( $it1.hasNext() ) {
			var i1 = $it1.next();
			var tileIndex = this.getUnusedTileIndex();
			this.pathPositions.push(tileIndex);
			this.tilePool[tileIndex].visible = true;
			this.tilePool[tileIndex].tint = 65280;
			this.tilePool[tileIndex].setTilePosition([i1.x,i1.y]);
			if(this.tilePool[tileIndex].parent == null) {
				if(this.parent != null) managers.DrawManager.addToDisplay(this.tilePool[tileIndex],this.parent,0.5);
			}
		}
	}
	,showRange: function(min,max,color,alpha,customRange) {
		var arrayIter;
		if(customRange == null) arrayIter = this.activeAttackRange; else arrayIter = customRange;
		var $it0 = HxOverrides.iter(arrayIter);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(!managers.MapManager.getInstance().activeMap.getWalkableAt(i) && managers.CharacterManager.getInstance().findCharacterAtTilePos(i) == null) continue;
			var tileIndex = this.getUnusedTileIndex();
			this.tilePool[tileIndex].visible = true;
			this.tilePool[tileIndex].setTilePosition([i[0],i[1]]);
			if(this.tilePool[tileIndex].parent == null) {
				if(this.parent != null) managers.DrawManager.addToDisplay(this.tilePool[tileIndex],this.parent,0.5);
			}
			if(color != null) this.tilePool[tileIndex].tint = color;
			if(alpha != null) this.tilePool[tileIndex].alpha = alpha;
		}
	}
	,hidePoolTiles: function(customCont) {
		var $it0 = HxOverrides.iter(this.tilePool);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			i.visible = false;
			i.tint = 16777215;
			i.alpha = 1;
		}
	}
	,hideOnePoolTile: function(index) {
		this.tilePool[index].visible = false;
		this.tilePool[index].tint = 16777215;
		this.tilePool[index].alpha = 1;
	}
	,getUnusedTileIndex: function() {
		var $it0 = HxOverrides.iter(this.tilePool);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			if(!i.visible) return HxOverrides.indexOf(this.tilePool,i,0);
		}
		this.tilePool.push(managers.PoolManager.pullObject("tile",1)[0]);
		return this.tilePool.length - 1;
	}
	,showHoverTile: function(tilePos,newTint) {
		if(this.targetTile.parent == null) managers.DrawManager.addToDisplay(this.targetTile,managers.MapManager.getInstance().activeMap.mapContainer,0.7);
		this.targetTile.setTilePosition(tilePos);
		this.targetTile.visible = true;
	}
	,hideHoverTile: function(remove) {
		if(remove == null) remove = false;
		this.targetTile.visible = false;
		if(remove) managers.DrawManager.removeFromDisplay(this.targetTile);
	}
	,useAp: function(amount) {
		objects.character.Character.prototype.useAp.call(this,amount);
		this.lockHudButtons();
		managers.HudManager.getInstance().APmeter.text = "" + this.stats.AP;
	}
	,changeSelectedAction: function(newActionName) {
		if(objects.character.Player.selectedAction == newActionName) objects.character.Player.selectedAction = "move"; else objects.character.Player.selectedAction = newActionName;
	}
	,generateAttackRange: function(attackName) {
		if(this.attacks.exists(attackName)) this.activeAttackRange = utils.Misc.getRangeTileAround(this.tilePos,this.attacks.get(attackName).minRange,this.attacks.get(attackName).maxRange); else window.console.warn("Attack not found while generating attackRange of:" + attackName);
		this.showRange(this.attacks.get(attackName).minRange,this.attacks.get(attackName).maxRange,16729927,0.3);
	}
	,hideEveryTile: function() {
		this.hideHoverTile();
		this.hidePoolTiles();
	}
	,Destroy: function() {
		objects.character.Character.prototype.Destroy.call(this);
		Main.getInstance().tileCont.off("mousemove",$bind(this,this.mapHover));
		Main.getInstance().tileCont.off("mouseup",$bind(this,this.mapClick));
	}
	,__class__: objects.character.Player
});
objects.character.Pnj = function(newName) {
	objects.character.Character.call(this,newName);
};
objects.character.Pnj.__name__ = ["objects","character","Pnj"];
objects.character.Pnj.__super__ = objects.character.Character;
objects.character.Pnj.prototype = $extend(objects.character.Character.prototype,{
	processAI: function() {
	}
	,__class__: objects.character.Pnj
});
objects.character.Victim = function(newName) {
	objects.character.Pnj.call(this,newName);
	this.stats.health = 1000;
};
objects.character.Victim.__name__ = ["objects","character","Victim"];
objects.character.Victim.__super__ = objects.character.Pnj;
objects.character.Victim.prototype = $extend(objects.character.Pnj.prototype,{
	__class__: objects.character.Victim
});
objects.particle = {};
objects.particle.DmgText = function() {
	PIXI.Text.call(this,"",{ fill : "#ff6c00", font : "30px gastFont", stroke : "#790000", strokeThickness : 10});
};
objects.particle.DmgText.__name__ = ["objects","particle","DmgText"];
objects.particle.DmgText.__super__ = PIXI.Text;
objects.particle.DmgText.prototype = $extend(PIXI.Text.prototype,{
	animate: function(newTime) {
		var _g = this;
		tweenx909.TweenX.serial([tweenx909.TweenX.to(this,{ y : this.y - 50},null,null,null,null,null,null,null,null,{ fileName : "DmgText.hx", lineNumber : 23, className : "objects.particle.DmgText", methodName : "animate"}).time(newTime).ease(tweenx909.EaseX.quadIn).skip(),tweenx909.TweenX.to(this,{ alpha : 0},null,null,null,null,null,null,null,null,{ fileName : "DmgText.hx", lineNumber : 24, className : "objects.particle.DmgText", methodName : "animate"}).time(newTime).ease(tweenx909.EaseX.expoIn).onFinish(function() {
			_g.visible = false;
		})],null,{ fileName : "DmgText.hx", lineNumber : 22, className : "objects.particle.DmgText", methodName : "animate"});
	}
	,__class__: objects.particle.DmgText
});
objects.particle.OSmovieclip = function(textures,newCallback) {
	this.callback = function() {
	};
	PIXI.extras.MovieClip.call(this,textures);
	if(newCallback != null) this.callback = newCallback;
	this.onComplete = $bind(this,this.complete);
	this.loop = false;
	this.gotoAndPlay(0);
};
objects.particle.OSmovieclip.__name__ = ["objects","particle","OSmovieclip"];
objects.particle.OSmovieclip.__super__ = PIXI.extras.MovieClip;
objects.particle.OSmovieclip.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	complete: function() {
		this.callback();
		if(this.parent != null) this.parent.removeChild(this);
	}
	,__class__: objects.particle.OSmovieclip
});
var states = {};
states.DebugState = function() {
	objects.State.call(this,"Debug");
};
states.DebugState.__name__ = ["states","DebugState"];
states.DebugState.__super__ = objects.State;
states.DebugState.prototype = $extend(objects.State.prototype,{
	Preload: function() {
	}
	,Start: function() {
		Main.FIGHTMODE = true;
		managers.HudManager.getInstance().generateFightHud();
		var camShader = new PIXI.Sprite(PIXI.Texture.fromImage("camShader.png"));
		camShader.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		managers.DrawManager.addToDisplay(camShader,Main.getInstance().effectCont);
		managers.MapManager.getInstance().generateMapDisplay("testMapZig",true);
		var hero = objects.character.Player.getInstance();
		hero.setTilePosition([13,30]);
		hero.scale.set(0.4,0.4);
		managers.DrawManager.addToDisplay(hero,managers.MapManager.getInstance().activeMap.mapContainer,1);
		objects.Camera.getInstance().setFollowTarget(hero);
		var victim = new objects.character.Victim("victim");
		victim.setTilePosition([10,24]);
		victim.scale.set(0.4,0.4);
		managers.DrawManager.addToDisplay(victim,managers.MapManager.getInstance().activeMap.mapContainer,1);
	}
	,Update: function() {
	}
	,__class__: states.DebugState
});
states.MenuState = function() {
	objects.State.call(this,"Menu");
};
states.MenuState.__name__ = ["states","MenuState"];
states.MenuState.__super__ = objects.State;
states.MenuState.prototype = $extend(objects.State.prototype,{
	Preload: function() {
	}
	,Start: function() {
		this.playButton = new objects.Button("baseButton");
		this.playButton.onUp($bind(this,this.clickHandler));
		this.playButton.x = Main.getInstance().renderer.width * 0.5;
		this.playButton.y = Main.getInstance().renderer.height * 0.6;
		this.playButton.scale.set(0.5,0.5);
		this.playButton.setText("PLAY");
		managers.DrawManager.addToDisplay(this.playButton,Main.getInstance().hudCont);
	}
	,clickHandler: function(e) {
		this.playButton.Destroy();
		managers.StateManager.getInstance().switchToState("Debug");
	}
	,Update: function() {
	}
	,switchState: function() {
	}
	,__class__: states.MenuState
});
states.PreloadState = function() {
	this.loopCounter = 0;
	this.loadingFill = new PIXI.Graphics();
	this.loadingRecangle = new PIXI.Graphics();
	objects.State.call(this,"Preload");
	this.LoadingText.text = "Loading asset: 0%";
	this.LoadingText.x = Main.getInstance().renderer.width * 0.5;
	this.LoadingText.y = Main.getInstance().renderer.height * 0.6;
	this.LoadingText.anchor.set(0.5,0.5);
	this.loadingRecangle.lineStyle(3,16777215);
	this.loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35,Main.getInstance().renderer.height * 0.7,Main.getInstance().renderer.width * 0.30,50);
	this.loadingFill.lineStyle(3,11184810);
};
states.PreloadState.__name__ = ["states","PreloadState"];
states.PreloadState.__super__ = objects.State;
states.PreloadState.prototype = $extend(objects.State.prototype,{
	Preload: function() {
		this.loadJson.set("buttonTripleAttack","assets/spriteSheets/buttonTripleAttack.json");
		this.loadJson.set("buttonAttack","assets/spriteSheets/buttonAttack.json");
		this.loadJson.set("buttonMove","assets/spriteSheets/buttonMove.json");
		this.loadJson.set("hud_bottom","assets/spriteSheets/hud_bottom.json");
		this.loadJson.set("tileSh2","assets/spriteSheets/loadSpriteSheet.json");
		this.loadJson.set("buttons","assets/spriteSheets/buttonSpriteSheet.json");
		this.loadJson.set("hero","assets/spriteSheets/heroSpriteSheet.json");
		this.loadJson.set("hero2","assets/spriteSheets/heroSpriteSheet2.json");
		this.loadJson.set("explosion","assets/spriteSheets/testExplosion.json");
		this.loadJson.set("enemy","assets/spriteSheets/victim.json");
		this.loadJson.set("camShader","assets/effects/camShade.json");
		Main.getInstance().hudCont.addChild(this.loadingRecangle);
		Main.getInstance().hudCont.addChild(this.loadingFill);
		this.LoadingText.text = "Loading asset: 0%";
		Main.getInstance().hudCont.addChild(this.LoadingText);
	}
	,Start: function() {
		managers.PoolManager.generatePool();
		managers.StateManager.getInstance().switchToState("Menu");
	}
	,Update: function() {
	}
	,AssetLoad: function(loader) {
		this.LoadingText.text = "Loading asset: " + Math.round(loader.progress) + "%";
		this.loadingRecangle.clear();
		this.loadingRecangle.lineStyle(4,16777215);
		this.loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35,Main.getInstance().renderer.height * 0.7,Main.getInstance().renderer.width * 0.30,50);
		this.loadingFill.clear();
		this.loadingFill.beginFill(11184810);
		this.loadingFill.drawRect(Main.getInstance().renderer.width * 0.35 + 3,Main.getInstance().renderer.height * 0.7 + 3,loader.progress / 100 * (Main.getInstance().renderer.width * 0.30 - 4),46);
		this.loadingFill.endFill();
	}
	,switchState: function() {
		this.loopCounter = null;
	}
	,__class__: states.PreloadState
});
var tweenx909 = {};
tweenx909.EaseX = function() { };
tweenx909.EaseX.__name__ = ["tweenx909","EaseX"];
tweenx909.EaseX.linear = function(t) {
	return t;
};
tweenx909.EaseX.sineIn = function(t) {
	if(t == 0) return 0; else if(t == 1) return 1; else return 1 - Math.cos(t * 1.5707963267948966);
};
tweenx909.EaseX.sineOut = function(t) {
	if(t == 0) return 0; else if(t == 1) return 1; else return Math.sin(t * 1.5707963267948966);
};
tweenx909.EaseX.sineInOut = function(t) {
	if(t == 0) return 0; else if(t == 1) return 1; else return -0.5 * (Math.cos(Math.PI * t) - 1);
};
tweenx909.EaseX.sineOutIn = function(t) {
	if(t == 0) return 0; else if(t == 1) return 1; else if(t < 0.5) return 0.5 * Math.sin(t * 2 * 1.5707963267948966); else return -0.5 * Math.cos((t * 2 - 1) * 1.5707963267948966) + 1;
};
tweenx909.EaseX.quadIn = function(t) {
	return t * t;
};
tweenx909.EaseX.quadOut = function(t) {
	return -t * (t - 2);
};
tweenx909.EaseX.quadInOut = function(t) {
	if(t < 0.5) return 2 * t * t; else return -2 * ((t -= 1) * t) + 1;
};
tweenx909.EaseX.quadOutIn = function(t) {
	if(t < 0.5) return -0.5 * (t = t * 2) * (t - 2); else return 0.5 * (t = t * 2 - 1) * t + 0.5;
};
tweenx909.EaseX.cubicIn = function(t) {
	return t * t * t;
};
tweenx909.EaseX.cubicOut = function(t) {
	return (t = t - 1) * t * t + 1;
};
tweenx909.EaseX.cubicInOut = function(t) {
	if((t *= 2) < 1) return 0.5 * t * t * t; else return 0.5 * ((t -= 2) * t * t + 2);
};
tweenx909.EaseX.cubicOutIn = function(t) {
	return 0.5 * ((t = t * 2 - 1) * t * t + 1);
};
tweenx909.EaseX.quartIn = function(t) {
	return t * t * t * t;
};
tweenx909.EaseX.quartOut = function(t) {
	return 1 - (t = (t = t - 1) * t) * t;
};
tweenx909.EaseX.quartInOut = function(t) {
	if((t *= 2) < 1) return 0.5 * t * t * t * t; else return -0.5 * ((t -= 2) * t * t * t - 2);
};
tweenx909.EaseX.quartOutIn = function(t) {
	if(t < 0.5) return -0.5 * (t = t * 2 - 1) * t * t * t + 0.5; else return 0.5 * (t = t * 2 - 1) * t * t * t + 0.5;
};
tweenx909.EaseX.quintIn = function(t) {
	return t * t * t * t * t;
};
tweenx909.EaseX.quintOut = function(t) {
	return (t = t - 1) * t * t * t * t + 1;
};
tweenx909.EaseX.quintInOut = function(t) {
	if((t *= 2) < 1) return 0.5 * t * t * t * t * t; else return 0.5 * (t -= 2) * t * t * t * t + 1;
};
tweenx909.EaseX.quintOutIn = function(t) {
	return 0.5 * ((t = t * 2 - 1) * t * t * t * t + 1);
};
tweenx909.EaseX.expoIn = function(t) {
	if(t == 0) return 0; else return Math.pow(2,10 * (t - 1));
};
tweenx909.EaseX.expoOut = function(t) {
	if(t == 1) return 1; else return 1 - Math.pow(2,-10 * t);
};
tweenx909.EaseX.expoInOut = function(t) {
	if(t == 0) return 0; else if(t == 1) return 1; else if((t *= 2) < 1) return 0.5 * Math.pow(2,10 * (t - 1)); else return 0.5 * (2 - Math.pow(2,-10 * --t));
};
tweenx909.EaseX.expoOutIn = function(t) {
	if(t < 0.5) return 0.5 * (1 - Math.pow(2,-20 * t)); else if(t == 0.5) return 0.5; else return 0.5 * (Math.pow(2,20 * (t - 1)) + 1);
};
tweenx909.EaseX.circIn = function(t) {
	return 1 - Math.sqrt(1 - t * t);
};
tweenx909.EaseX.circOut = function(t) {
	return Math.sqrt(t * (2 - t));
};
tweenx909.EaseX.circInOut = function(t) {
	if((t *= 2) < 1) return -0.5 * (Math.sqrt(1 - t * t) - 1); else return 0.5 * (Math.sqrt(1 - (t -= 2) * t) + 1);
};
tweenx909.EaseX.circOutIn = function(t) {
	if(t < 0.5) return 0.5 * Math.sqrt(1 - (t = t * 2 - 1) * t); else return -0.5 * (Math.sqrt(1 - (t = t * 2 - 1) * t) - 1 - 1);
};
tweenx909.EaseX.bounceIn = function(t) {
	if((t = 1 - t) < 0.36363636363636365) return 1 - 7.5625 * t * t;
	if(t < 0.72727272727272729) return 1 - (7.5625 * (t -= 0.54545454545454541) * t + 0.75);
	if(t < 0.90909090909090906) return 1 - (7.5625 * (t -= 0.81818181818181823) * t + 0.9375);
	return 1 - (7.5625 * (t -= 0.95454545454545459) * t + 0.984375);
};
tweenx909.EaseX.bounceOut = function(t) {
	if(t < 0.36363636363636365) return 7.5625 * t * t;
	if(t < 0.72727272727272729) return 7.5625 * (t -= 0.54545454545454541) * t + 0.75;
	if(t < 0.90909090909090906) return 7.5625 * (t -= 0.81818181818181823) * t + 0.9375;
	return 7.5625 * (t -= 0.95454545454545459) * t + 0.984375;
};
tweenx909.EaseX.bounceInOut = function(t) {
	if(t < 0.5) {
		if((t = 1 - t * 2) < 0.36363636363636365) return (1 - 7.5625 * t * t) * 0.5;
		if(t < 0.72727272727272729) return (1 - (7.5625 * (t -= 0.54545454545454541) * t + 0.75)) * 0.5;
		if(t < 0.90909090909090906) return (1 - (7.5625 * (t -= 0.81818181818181823) * t + 0.9375)) * 0.5;
		return (1 - (7.5625 * (t -= 0.95454545454545459) * t + 0.984375)) * 0.5;
	} else {
		if((t = t * 2 - 1) < 0.36363636363636365) return 7.5625 * t * t * 0.5 + 0.5;
		if(t < 0.72727272727272729) return (7.5625 * (t -= 0.54545454545454541) * t + 0.75) * 0.5 + 0.5;
		if(t < 0.90909090909090906) return (7.5625 * (t -= 0.81818181818181823) * t + 0.9375) * 0.5 + 0.5;
		return (7.5625 * (t -= 0.95454545454545459) * t + 0.984375) * 0.5 + 0.5;
	}
};
tweenx909.EaseX.bounceOutIn = function(t) {
	if(t < 0.5) {
		if((t = t * 2) < 0.36363636363636365) return 0.5 * (7.5625 * t * t);
		if(t < 0.72727272727272729) return 0.5 * (7.5625 * (t -= 0.54545454545454541) * t + 0.75);
		if(t < 0.90909090909090906) return 0.5 * (7.5625 * (t -= 0.81818181818181823) * t + 0.9375);
		return 0.5 * (7.5625 * (t -= 0.95454545454545459) * t + 0.984375);
	} else {
		if((t = 1 - (t * 2 - 1)) < 0.36363636363636365) return 0.5 - 0.5 * (7.5625 * t * t) + 0.5;
		if(t < 0.72727272727272729) return 0.5 - 0.5 * (7.5625 * (t -= 0.54545454545454541) * t + 0.75) + 0.5;
		if(t < 0.90909090909090906) return 0.5 - 0.5 * (7.5625 * (t -= 0.81818181818181823) * t + 0.9375) + 0.5;
		return 0.5 - 0.5 * (7.5625 * (t -= 0.95454545454545459) * t + 0.984375) + 0.5;
	}
};
tweenx909.EaseX.backIn = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	return t * t * (2.70158 * t - 1.70158);
};
tweenx909.EaseX.backOut = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	return (t = t - 1) * t * (2.70158 * t + 1.70158) + 1;
};
tweenx909.EaseX.backInOut = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	if((t *= 2) < 1) return 0.5 * (t * t * (3.5949095 * t - 2.5949095));
	return 0.5 * ((t -= 2) * t * (3.5949095 * t + 2.5949095) + 2);
};
tweenx909.EaseX.backOutIn = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	if(t < 0.5) return 0.5 * ((t = t * 2 - 1) * t * (2.70158 * t + 1.70158) + 1);
	return 0.5 * (t = t * 2 - 1) * t * (2.70158 * t - 1.70158) + 0.5;
};
tweenx909.EaseX.elasticIn = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	var s = 7.5e-005;
	return -(1 * Math.pow(2,10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * Math.PI) / 0.0003));
};
tweenx909.EaseX.elasticOut = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	var s = 7.5e-005;
	return Math.pow(2,-10 * t) * Math.sin((t * 0.001 - s) * (2 * Math.PI) / 0.0003) + 1;
};
tweenx909.EaseX.elasticInOut = function(t) {
	if(t == 0) return 0;
	if(t == 1) return 1;
	var s = 7.5e-005;
	if((t *= 2) < 1) return -0.5 * (1 * Math.pow(2,10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * Math.PI) / 0.0003)); else return 1 * Math.pow(2,-10 * (t -= 1)) * Math.sin((t * 0.001 - s) * (2 * Math.PI) / 0.0003) * 0.5 + 1;
};
tweenx909.EaseX.elasticOutIn = function(t) {
	if(t < 0.5) {
		if((t *= 2) == 0) return 0;
		var s = 7.5e-005;
		return 1 / 2 * Math.pow(2,-10 * t) * Math.sin((t * 0.001 - s) * (2 * Math.PI) / 0.0003) + 0.5;
	} else {
		if(t == 0.5) return 0.5;
		if(t == 1) return 1;
		t = t * 2 - 1;
		var s1 = 7.5e-005;
		return -(1 / 2 * Math.pow(2,10 * (t -= 1)) * Math.sin((t * 0.001 - s1) * (2 * Math.PI) / 0.0003)) + 0.5;
	}
};
tweenx909.EventX = { __ename__ : true, __constructs__ : ["PLAY","DELAY","HEAD","UPDATE","FOOT","INTERVAL","REPEAT","REST","FINISH","STOP"] };
tweenx909.EventX.PLAY = ["PLAY",0];
tweenx909.EventX.PLAY.__enum__ = tweenx909.EventX;
tweenx909.EventX.DELAY = ["DELAY",1];
tweenx909.EventX.DELAY.__enum__ = tweenx909.EventX;
tweenx909.EventX.HEAD = ["HEAD",2];
tweenx909.EventX.HEAD.__enum__ = tweenx909.EventX;
tweenx909.EventX.UPDATE = ["UPDATE",3];
tweenx909.EventX.UPDATE.__enum__ = tweenx909.EventX;
tweenx909.EventX.FOOT = ["FOOT",4];
tweenx909.EventX.FOOT.__enum__ = tweenx909.EventX;
tweenx909.EventX.INTERVAL = ["INTERVAL",5];
tweenx909.EventX.INTERVAL.__enum__ = tweenx909.EventX;
tweenx909.EventX.REPEAT = ["REPEAT",6];
tweenx909.EventX.REPEAT.__enum__ = tweenx909.EventX;
tweenx909.EventX.REST = ["REST",7];
tweenx909.EventX.REST.__enum__ = tweenx909.EventX;
tweenx909.EventX.FINISH = ["FINISH",8];
tweenx909.EventX.FINISH.__enum__ = tweenx909.EventX;
tweenx909.EventX.STOP = ["STOP",9];
tweenx909.EventX.STOP.__enum__ = tweenx909.EventX;
tweenx909.advanced = {};
tweenx909.advanced.CommandX = function(command,posInfos) {
	this.command = command;
	this.definedPosInfos = posInfos;
};
tweenx909.advanced.CommandX.__name__ = ["tweenx909","advanced","CommandX"];
tweenx909.advanced.CommandX.prototype = {
	__class__: tweenx909.advanced.CommandX
};
tweenx909.rule = {};
tweenx909.rule.BoolRuleX = function() { };
tweenx909.rule.BoolRuleX.__name__ = ["tweenx909","rule","BoolRuleX"];
tweenx909.rule.BoolRuleX.calc = function(_from,_to,t1,t2,tween) {
	return 0 < (_from?1:0) * t2 + (_to?1:0) * t1;
};
tweenx909.rule.BoolRuleX.defaultFrom = function(value,_to,tween) {
	return value;
};
tweenx909.rule.ArrayRuleX = function() { };
tweenx909.rule.ArrayRuleX.__name__ = ["tweenx909","rule","ArrayRuleX"];
tweenx909.rule.ArrayRuleX.calc = function(_from,_to,t1,t2,tween) {
	var fi = $iterator(_from)();
	var arr = [];
	var $it0 = $iterator(_to)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		var f = fi.next();
		arr.push(tweenx909.rule.ArrayRuleX._calc(f,t,t1,t2,tween));
	}
	return arr;
};
tweenx909.rule.ArrayRuleX._calc = function(_from,_to,t1,t2,tween) {
	if(typeof(_to) == "number") return _from * t2 + _to * t1; else {
		var result = null;
		var ok = false;
		var $it0 = $iterator(tweenx909.TweenX.get_rules())();
		while( $it0.hasNext() ) {
			var r = $it0.next();
			if(js.Boot.__instanceof(_to,r.inputClass)) {
				ok = true;
				result = r.calc(_from,_to,t1,t2,tween);
				break;
			}
		}
		if(!ok) {
			var eh = tween;
			throw eh.error("The tween rule for " + Type.getClassName(Type.getClass(_to)) + " is not defined");
		}
		return result;
	}
};
tweenx909.rule.ArrayRuleX.defaultFrom = function(value,_to,tween) {
	var eh = tween;
	if(value != null) {
		var arr = [];
		var $it0 = $iterator(_to)();
		while( $it0.hasNext() ) {
			var t = $it0.next();
			arr.push(null);
		}
	} else if(Lambda.count(value) != Lambda.count(_to)) throw eh.error("The array length must be same with start.");
	var result = [];
	var it = $iterator(_to)();
	var $it1 = $iterator(value)();
	while( $it1.hasNext() ) {
		var v = $it1.next();
		var t1 = it.next();
		result.push(tweenx909.rule.ArrayRuleX._defaultFrom(v,t1,tween));
	}
	return result;
};
tweenx909.rule.ArrayRuleX._defaultFrom = function(value,_to,tween) {
	if(typeof(_to) == "number") return value;
	var $it0 = $iterator(tweenx909.TweenX.get_rules())();
	while( $it0.hasNext() ) {
		var r = $it0.next();
		if(js.Boot.__instanceof(_to,r.inputClass)) return r.defaultFrom(value,_to,tween);
	}
	var eh = tween;
	throw eh.error("The tween rule for " + Type.getClassName(Type.getClass(_to)) + " is not defined");
	return null;
};
tweenx909.rule.TimelineX = function(data,intervals) {
	this.data = Lambda.array(data);
	if(intervals == null) {
		var arr = [];
		var _g1 = 0;
		var _g = this.data.length;
		while(_g1 < _g) {
			var i = _g1++;
			arr.push(i);
		}
		this.timeline = arr;
	} else {
		var arr1 = [];
		var n = 0;
		var $it0 = $iterator(intervals)();
		while( $it0.hasNext() ) {
			var i1 = $it0.next();
			arr1.push(n += i1);
		}
		this.timeline = arr1;
	}
	if(this.timeline.length != this.data.length) throw "times length must be same with data length.";
	this.length = this.timeline[this.timeline.length - 1] + 1;
};
tweenx909.rule.TimelineX.__name__ = ["tweenx909","rule","TimelineX"];
tweenx909.rule.TimelineX.calc = function(_from,_to,t1,t2,tween) {
	var t = t1 * _to.length;
	var ts = _to.timeline;
	var l = ts.length;
	var min = 0;
	var max = l;
	var n = max >> 1;
	while(max - min > 1) {
		var val = ts[n];
		if(t < val) max = n; else min = n;
		n = min + (max - min >> 1);
	}
	return _to.data[min];
};
tweenx909.rule.TimelineX.defaultFrom = function(value,_to,tween) {
	return null;
};
tweenx909.rule.TimelineX.prototype = {
	__class__: tweenx909.rule.TimelineX
};
tweenx909.rule.RgbX = function(red,green,blue) {
	this.r = red;
	this.g = green;
	this.b = blue;
};
tweenx909.rule.RgbX.__name__ = ["tweenx909","rule","RgbX"];
tweenx909.rule.RgbX.calc = function(_from,_to,t1,t2,tween) {
	var r = (_from.r * t2 + _to.r * t1) * 255 | 0;
	if(r < 0) r = 0; else if(r > 255) r = 255;
	var g = (_from.g * t2 + _to.g * t1) * 255 | 0;
	if(g < 0) g = 0; else if(g > 255) g = 255;
	var b = (_from.b * t2 + _to.b * t1) * 255 | 0;
	if(b < 0) b = 0; else if(b > 255) b = 255;
	return r << 16 | g << 8 | b;
};
tweenx909.rule.RgbX.defaultFrom = function(value,_to,tween) {
	return tweenx909.rule.RgbX.of(value);
};
tweenx909.rule.RgbX.of = function(color) {
	return new tweenx909.rule.RgbX((color >> 16 & 255) / 255,(color >> 8 & 255) / 255,(color & 255) / 255);
};
tweenx909.rule.RgbX.prototype = {
	__class__: tweenx909.rule.RgbX
};
tweenx909.rule.HsvX = function(hue,saturation,value) {
	this.h = hue;
	this.s = saturation;
	this.v = value;
};
tweenx909.rule.HsvX.__name__ = ["tweenx909","rule","HsvX"];
tweenx909.rule.HsvX.calc = function(_from,_to,t1,t2,tween) {
	var h = _from.h * t2 + _to.h * t1;
	var s = _from.s * t2 + _to.s * t1;
	var v = _from.v * t2 + _to.v * t1;
	h = (h - Math.floor(h)) * 6;
	var hi = Math.floor(h);
	if(s > 1) s = 1;
	if(s < 0) s = 0;
	if(v > 1) v = 1;
	if(v < 0) v = 0;
	var m = v * (1 - s);
	var f = h - hi;
	var r = .0;
	var g = .0;
	var b = .0;
	switch(hi) {
	case 0:
		r = v;
		g = v * (1 - s * (1 - f));
		b = m;
		break;
	case 1:
		r = v * (1 - s * f);
		g = v;
		b = m;
		break;
	case 2:
		r = m;
		g = v;
		b = v * (1 - s * (1 - f));
		break;
	case 3:
		r = m;
		g = v * (1 - s * f);
		b = v;
		break;
	case 4:
		r = v * (1 - s * (1 - f));
		g = m;
		b = v;
		break;
	case 5:
		r = v;
		g = m;
		b = v * (1 - s * f);
		break;
	}
	return (r * 255 | 0) << 16 | (g * 255 | 0) << 8 | (b * 255 | 0);
};
tweenx909.rule.HsvX.defaultFrom = function(value,_to,tween) {
	return tweenx909.rule.HsvX.of(value);
};
tweenx909.rule.HsvX.of = function(color,hueIndex) {
	if(hueIndex == null) hueIndex = 0;
	var r = (color >> 16 & 255) / 255;
	var g = (color >> 8 & 255) / 255;
	var b = (color & 255) / 255;
	var max;
	var min;
	var diff;
	var h;
	if(r < g) {
		if(g < b) {
			max = b;
			min = r;
			h = (4 + (r - g) / (diff = max - min)) / 6;
		} else {
			max = g;
			if(r < b) min = r; else min = b;
			h = (2 + (b - r) / (diff = max - min)) / 6;
		}
	} else if(r < b) {
		max = b;
		min = g;
		h = (4 + (r - g) / (diff = max - min)) / 6;
	} else {
		max = r;
		if(g < b) min = g; else min = b;
		h = (g - b) / (diff = max - min) / 6;
	}
	if(h < 0) h += 1;
	var s = diff / max;
	return new tweenx909.rule.HsvX(h + hueIndex,s,max);
};
tweenx909.rule.HsvX.prototype = {
	__class__: tweenx909.rule.HsvX
};
tweenx909.rule.ArgbX = function(alpha,red,green,blue) {
	this.a = alpha;
	this.r = red;
	this.g = green;
	this.b = blue;
};
tweenx909.rule.ArgbX.__name__ = ["tweenx909","rule","ArgbX"];
tweenx909.rule.ArgbX.calc = function(_from,_to,t1,t2,tween) {
	var a = (_from.a * t2 + _to.a * t1) * 255 | 0;
	if(a < 0) a = 0; else if(a > 255) a = 255;
	var r = (_from.r * t2 + _to.r * t1) * 255 | 0;
	if(r < 0) r = 0; else if(r > 255) r = 255;
	var g = (_from.g * t2 + _to.g * t1) * 255 | 0;
	if(g < 0) g = 0; else if(g > 255) g = 255;
	var b = (_from.b * t2 + _to.b * t1) * 255 | 0;
	if(b < 0) b = 0; else if(b > 255) b = 255;
	return a << 24 | r << 16 | g << 8 | b;
};
tweenx909.rule.ArgbX.defaultFrom = function(value,_to,tween) {
	return tweenx909.rule.ArgbX.of(value);
};
tweenx909.rule.ArgbX.of = function(color) {
	return new tweenx909.rule.ArgbX((color >>> 24 & 255) / 255,(color >> 16 & 255) / 255,(color >> 8 & 255) / 255,(color & 255) / 255);
};
tweenx909.rule.ArgbX.prototype = {
	__class__: tweenx909.rule.ArgbX
};
tweenx909.rule.AhsvX = function(alpha,hue,saturation,value) {
	this.a = alpha;
	this.h = hue;
	this.s = saturation;
	this.v = value;
};
tweenx909.rule.AhsvX.__name__ = ["tweenx909","rule","AhsvX"];
tweenx909.rule.AhsvX.calc = function(_from,_to,t1,t2,tween) {
	var a = _from.a * t2 + _to.a * t1;
	if(a > 1) a = 1;
	if(a < 0) a = 0;
	var h = _from.h * t2 + _to.h * t1;
	var s = _from.s * t2 + _to.s * t1;
	var v = _from.v * t2 + _to.v * t1;
	h = (h - Math.floor(h)) * 6;
	var hi = Math.floor(h);
	if(s > 1) s = 1;
	if(s < 0) s = 0;
	if(v > 1) v = 1;
	if(v < 0) v = 0;
	var m = v * (1 - s);
	var f = h - hi;
	var r = .0;
	var g = .0;
	var b = .0;
	switch(hi) {
	case 0:
		r = v;
		g = v * (1 - s * (1 - f));
		b = m;
		break;
	case 1:
		r = v * (1 - s * f);
		g = v;
		b = m;
		break;
	case 2:
		r = m;
		g = v;
		b = v * (1 - s * (1 - f));
		break;
	case 3:
		r = m;
		g = v * (1 - s * f);
		b = v;
		break;
	case 4:
		r = v * (1 - s * (1 - f));
		g = m;
		b = v;
		break;
	case 5:
		r = v;
		g = m;
		b = v * (1 - s * f);
		break;
	}
	return (a * 255 | 0) << 24 | (r * 255 | 0) << 16 | (g * 255 | 0) << 8 | (b * 255 | 0);
};
tweenx909.rule.AhsvX.defaultFrom = function(value,_to,tween) {
	return tweenx909.rule.AhsvX.of(value);
};
tweenx909.rule.AhsvX.of = function(color,hueIndex) {
	if(hueIndex == null) hueIndex = 0;
	var a = (color >>> 24 & 255) / 255;
	var r = (color >> 16 & 255) / 255;
	var g = (color >> 8 & 255) / 255;
	var b = (color & 255) / 255;
	var max;
	var min;
	var diff;
	var h;
	if(r < g) {
		if(g < b) {
			max = b;
			min = r;
			h = (4 + (r - g) / (diff = max - min)) / 6;
		} else {
			max = g;
			if(r < b) min = r; else min = b;
			h = (2 + (b - r) / (diff = max - min)) / 6;
		}
	} else if(r < b) {
		max = b;
		min = g;
		h = (4 + (r - g) / (diff = max - min)) / 6;
	} else {
		max = r;
		if(g < b) min = g; else min = b;
		h = (g - b) / (diff = max - min) / 6;
	}
	if(h < 0) h += 1;
	var s = diff / max;
	return new tweenx909.rule.AhsvX(a,h + hueIndex,s,max);
};
tweenx909.rule.AhsvX.prototype = {
	__class__: tweenx909.rule.AhsvX
};
tweenx909.rule.QuakeX = function(value,scale,ease) {
	this.value = value;
	this.scale = scale;
	if(ease == null) this.ease = $bind(this,this.none); else this.ease = ease;
};
tweenx909.rule.QuakeX.__name__ = ["tweenx909","rule","QuakeX"];
tweenx909.rule.QuakeX.calc = function(_from,_to,t1,t2,tween) {
	var p;
	if(t1 < 0.5) p = _from.ease(t1 * 2); else p = _to.ease(t2 * 2);
	return _from.value * t2 + _to.value * t1 + p * (Math.random() * 2 - 1) * (_from.scale * t2 + _to.scale * t1);
};
tweenx909.rule.QuakeX.defaultFrom = function(value,_to,tween) {
	return new tweenx909.rule.QuakeX(value,_to.scale,_to.ease);
};
tweenx909.rule.QuakeX.prototype = {
	none: function(t) {
		if(t <= 0) return 0; else return 1;
	}
	,__class__: tweenx909.rule.QuakeX
};
tweenx909.advanced.UpdateModeX = { __ename__ : true, __constructs__ : ["MANUAL","TIME"] };
tweenx909.advanced.UpdateModeX.MANUAL = ["MANUAL",0];
tweenx909.advanced.UpdateModeX.MANUAL.__enum__ = tweenx909.advanced.UpdateModeX;
tweenx909.advanced.UpdateModeX.TIME = function(frameRate) { var $x = ["TIME",1,frameRate]; $x.__enum__ = tweenx909.advanced.UpdateModeX; return $x; };
tweenx909.TweenX = function(type,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	this.timeScale = 1;
	this._skip = null;
	this._currentTime = 0;
	tweenx909.advanced.CommandX.call(this,tweenx909.advanced.CommandTypeX.TWEEN(this),posInfos);
	this._type = type;
	this._currentTime = 0;
	switch(type[1]) {
	case 0:
		var g = type[2];
		this._easeIsDefault = false;
		if(ease == null) this._ease = tweenx909.EaseX.linear; else this._ease = ease;
		break;
	default:
		if(this._easeIsDefault = ease == null) this._ease = tweenx909.TweenX.defaultEase; else this._ease = ease;
	}
	if(this._timeIsDefault = time == null) this._time = tweenx909.TweenX.defaultTime; else this._time = time;
	if(this._delayIsDefault = delay == null) this._delay = tweenx909.TweenX.defaultDelay; else this._delay = delay;
	if(this._intervalIsDefault = interval == null) this._interval = tweenx909.TweenX.defaultInterval; else this._interval = interval;
	if(this._repeatIsDefault = repeat == null) this._repeat = tweenx909.TweenX.defaultRepeat; else this._repeat = repeat;
	if(this._yoyoIsDefault = yoyo == null) this._yoyo = tweenx909.TweenX.defaultYoyo; else this._yoyo = yoyo;
	if(this._zigzagIsDefault = zigzag == null) this._zigzag = tweenx909.TweenX.defaultZigZag; else this._zigzag = zigzag;
	if(this._autoPlayIsDefault = autoPlay == null) this._autoPlay = tweenx909.TweenX.defaultAutoPlay; else this._autoPlay = autoPlay;
	this._rest = 0;
	this._eventListeners = [];
	this.id = tweenx909.TweenX.idCounter++;
	tweenx909.TweenX._addedTweens.push(this);
	if(!tweenx909.TweenX.managerInited) tweenx909.TweenX.initManager();
};
tweenx909.TweenX.__name__ = ["tweenx909","TweenX"];
tweenx909.TweenX.__properties__ = {set_updateMode:"set_updateMode",get_rules:"get_rules",get_tweens:"get_tweens"}
tweenx909.TweenX.get_tweens = function() {
	return tweenx909.TweenX._tweens;
};
tweenx909.TweenX.get_rules = function() {
	return tweenx909.TweenX._rules;
};
tweenx909.TweenX.dumpDefaults = function() {
	return new tweenx909.advanced.DefaultsX().dump();
};
tweenx909.TweenX.setDefaults = function(defaults) {
	defaults.apply();
};
tweenx909.TweenX.initDefaults = function() {
	new tweenx909.advanced.DefaultsX().apply();
};
tweenx909.TweenX.set_updateMode = function(value) {
	tweenx909.TweenX.updateMode = value;
	tweenx909.TweenX.initManager();
	return value;
};
tweenx909.TweenX.initManager = function() {
	tweenx909.TweenX.managerInited = true;
	tweenx909.TweenX.stopUpdater();
	{
		var _g = tweenx909.TweenX.updateMode;
		switch(_g[1]) {
		case 1:
			var f = _g[2];
			tweenx909.TweenX.prevTime = new Date().getTime();
			tweenx909.TweenX.setInterval(tweenx909.TweenX.mainLoop,Math.round(1000 / f));
			break;
		case 0:
			break;
		}
	}
};
tweenx909.TweenX.mainLoop = function() {
	{
		var _g = tweenx909.TweenX.updateMode;
		switch(_g[1]) {
		case 1:
			var f = _g[2];
			tweenx909.TweenX.manualUpdate((new Date().getTime() - tweenx909.TweenX.prevTime) / 1000);
			tweenx909.TweenX.prevTime = new Date().getTime();
			break;
		case 0:
			throw "invalid auto update";
			break;
		}
	}
};
tweenx909.TweenX.stopUpdater = function() {
	if(tweenx909.TweenX._timer != null) {
		tweenx909.TweenX._timer.stop();
		tweenx909.TweenX._timer = null;
	}
};
tweenx909.TweenX.manualUpdate = function(time) {
	tweenx909.TweenX.initTweens();
	var l = tweenx909.TweenX._tweens.length;
	var i = 0;
	while(i < l) {
		var t = tweenx909.TweenX._tweens[i++];
		t._update(time * t.timeScale * tweenx909.TweenX.topLevelTimeScale);
		if(!t.playing) {
			tweenx909.TweenX._tweens.splice(--i,1);
			l--;
		}
	}
	tweenx909.TweenX._resetLog();
};
tweenx909.TweenX.initTweens = function() {
	var _g = 0;
	var _g1 = tweenx909.TweenX._addedTweens;
	while(_g < _g1.length) {
		var t = _g1[_g];
		++_g;
		t._init();
	}
	tweenx909.TweenX._addedTweens.splice(0,tweenx909.TweenX._addedTweens.length);
};
tweenx909.TweenX.clear = function() {
	var _g = 0;
	var _g1 = tweenx909.TweenX._addedTweens;
	while(_g < _g1.length) {
		var t = _g1[_g];
		++_g;
		t._autoPlay = false;
	}
	tweenx909.TweenX.stopAll(tweenx909.TweenX.get_tweens());
};
tweenx909.TweenX.addRule = function(rule) {
	var i = 0;
	var l = tweenx909.TweenX._rules.length;
	while(i < l) {
		var r = tweenx909.TweenX._rules[i++];
		if(r.inputClass == rule.inputClass) {
			tweenx909.TweenX._rules.splice(i--,1);
			l--;
		}
	}
	tweenx909.TweenX._rules.push(rule);
};
tweenx909.TweenX.addRules = function(rules) {
	var $it0 = $iterator(rules)();
	while( $it0.hasNext() ) {
		var r = $it0.next();
		tweenx909.TweenX.addRule(r);
	}
};
tweenx909.TweenX.from = function(target,_to,delay,repeat,interval,autoPlay,posInfos) {
	if(_to == null) _to = { };
	if(!tweenx909.TweenX.isIterable(target)) return new tweenx909.advanced.StandardTweenX(tweenx909.advanced.TweenTypeX.FROM_TO(target,{ },_to),0,tweenx909.EaseX.linear,delay,repeat,false,false,interval,autoPlay,posInfos); else return new tweenx909.advanced.StandardTweenX(tweenx909.advanced.TweenTypeX.ARRAY(target,[{ }],[_to]),0,tweenx909.EaseX.linear,delay,repeat,false,false,interval,autoPlay,posInfos);
};
tweenx909.TweenX.to = function(target,_to,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	if(_to == null) _to = { };
	if(!tweenx909.TweenX.isIterable(target)) return new tweenx909.advanced.StandardTweenX(tweenx909.advanced.TweenTypeX.FROM_TO(target,{ },_to),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos); else return new tweenx909.advanced.StandardTweenX(tweenx909.advanced.TweenTypeX.ARRAY(target,[{ }],[_to]),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.tweenFunc = function(func,_from,_to,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.FUNC(func,Lambda.array(_from),Lambda.array(_to)),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.tweenFunc1 = function(func,from1,to1,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.FUNC(func,[from1],[to1]),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.tweenFunc2 = function(func,from1,from2,to1,to2,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.FUNC(func,[from1,from2],[to1,to2]),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.tweenFunc3 = function(func,from1,from2,from3,to1,to2,to3,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.FUNC(func,[from1,from2,from3],[to1,to2,to3]),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.tweenFunc4 = function(func,from1,from2,from3,from4,to1,to2,to3,to4,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.FUNC(func,[from1,from2,from3,from4],[to1,to2,to3,to4]),time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.TweenX.func = function(func,delay,repeat,interval,posInfos) {
	return new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.CALL(func),0,tweenx909.EaseX.linear,delay,repeat,false,false,interval,false,posInfos);
};
tweenx909.TweenX.playAll = function(tweens) {
	var $it0 = $iterator(tweens)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		{
			var _g = t.command;
			switch(_g[1]) {
			case 1:
				break;
			case 0:
				var o = _g[2];
				o.play();
				break;
			}
		}
	}
};
tweenx909.TweenX.stopAll = function(tweens) {
	var $it0 = $iterator(tweens)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		{
			var _g = t.command;
			switch(_g[1]) {
			case 1:
				break;
			case 0:
				var o = _g[2];
				o.stop();
				break;
			}
		}
	}
};
tweenx909.TweenX.gotoAll = function(tweens,time,andPlay) {
	if(andPlay == null) andPlay = false;
	if(time == null) time = 0;
	var $it0 = $iterator(tweens)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		{
			var _g = t.command;
			switch(_g[1]) {
			case 1:
				break;
			case 0:
				var o = _g[2];
				o["goto"](time,andPlay);
				break;
			}
		}
	}
};
tweenx909.TweenX.updateAll = function(tweens,time) {
	var $it0 = $iterator(tweens)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		{
			var _g = t.command;
			switch(_g[1]) {
			case 1:
				break;
			case 0:
				var o = _g[2];
				if(!o._inited) o._init();
				o.update(time);
				break;
			}
		}
	}
};
tweenx909.TweenX.serial = function(tweens,defaults,posInfos) {
	return tweenx909.TweenX._group(tweens,tweenx909.advanced._GroupX.GroupTypeX.SERIAL,defaults,posInfos);
};
tweenx909.TweenX.lag = function(tweens,delay,defaults,posInfos) {
	if(delay == null) delay = 0.1;
	return tweenx909.TweenX._group(tweens,tweenx909.advanced._GroupX.GroupTypeX.LAG(delay),defaults,posInfos);
};
tweenx909.TweenX.parallel = function(tweens,defaults,posInfos) {
	return tweenx909.TweenX._group(tweens,tweenx909.advanced._GroupX.GroupTypeX.LAG(0),defaults,posInfos);
};
tweenx909.TweenX.wait = function(delay,posInfos) {
	if(delay == null) delay = 0.1;
	return new tweenx909.advanced.CommandX(tweenx909.advanced.CommandTypeX.WAIT(delay),posInfos);
};
tweenx909.TweenX._group = function(tweens,type,defaults,posInfos) {
	var parent = new tweenx909.TweenX(tweenx909.advanced.TweenTypeX.GROUP(new tweenx909.advanced.GroupX(tweens,type,defaults)),null,null,null,null,null,null,null,null,posInfos);
	var $it0 = $iterator(tweens)();
	while( $it0.hasNext() ) {
		var t = $it0.next();
		if(t == null) continue;
		{
			var _g = t.command;
			switch(_g[1]) {
			case 0:
				var o = _g[2];
				if(o._inited) throw o.error("Can't serialize initialized TweenCommandX");
				o._autoPlay = false;
				o._parent = parent;
				break;
			default:
			}
		}
	}
	return parent;
};
tweenx909.TweenX._lock = function(o) {
	if(o._inited) throw o.error("Can't serialize initialized TweenCommandX");
	o._autoPlay = false;
};
tweenx909.TweenX.getTime = function() {
	return new Date().getTime();
};
tweenx909.TweenX.setInterval = function(f,t) {
	if(tweenx909.TweenX._timer != null) tweenx909.TweenX._timer.stop();
	tweenx909.TweenX._timer = new haxe.Timer(t);
	tweenx909.TweenX._timer.run = f;
};
tweenx909.TweenX.fields = function(t) {
	return Reflect.fields(t);
};
tweenx909.TweenX.hashObject = function(o) {
	if(tweenx909.TweenX.dictionary.get(o) != null) return tweenx909.TweenX.dictionary.get(o); else {
		tweenx909.TweenX._objCounter = 1 + tweenx909.TweenX._objCounter % 33029;
		tweenx909.TweenX.dictionary.set(o,tweenx909.TweenX._objCounter);
		return tweenx909.TweenX._objCounter;
	}
};
tweenx909.TweenX._resetLog = function() {
	tweenx909.TweenX._initLog = [];
	tweenx909.TweenX.dictionary = new haxe.ds.ObjectMap();
};
tweenx909.TweenX.field = function(o,key) {
	var tmp;
	if(o == null) return null; else if(o.__properties__ && (tmp = o.__properties__["get_" + key])) return o[tmp](); else return o[key];
};
tweenx909.TweenX.setField = function(o,key,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + key])) o[tmp](value); else o[key] = value;
};
tweenx909.TweenX.isIterable = function(d) {
	return d != null && ((d instanceof Array) && d.__enum__ == null || Object.prototype.hasOwnProperty.call(d,"iterator") && Reflect.isFunction($iterator(d)) && $iterator(d)() != null);
};
tweenx909.TweenX.__super__ = tweenx909.advanced.CommandX;
tweenx909.TweenX.prototype = $extend(tweenx909.advanced.CommandX.prototype,{
	get_currentTime: function() {
		var t = this.get_totalTime();
		var p;
		if(this.backward) p = t - this._currentTime; else p = this._currentTime;
		if(p < 0) p = 0;
		if(p > t) p = t;
		return p;
	}
	,get_singleTime: function() {
		return this._time + this._interval;
	}
	,get_totalTime: function() {
		return this._delay + this.get_singleTime() * this._repeat - this._interval + this._rest;
	}
	,set_timeScale: function(value) {
		if(this._parent != null) throw this.error("Can't change timeScale of serialized object directly"); else return this.timeScale = value;
	}
	,error: function(msg) {
		var p = this.definedPosInfos;
		return msg + "(Tween_" + this.id + " was generated at " + p.className + "/" + p.methodName + "() [" + p.fileName + ":" + p.lineNumber + "])";
	}
	,play: function() {
		if(this._parent != null) throw this.error("Can't play serialized object directly");
		if(this.playing) return this;
		if(!this._inited) this._init();
		this.playing = true;
		tweenx909.TweenX._tweens.push(this);
		this.dispatch(0);
		if(this._onPlay != null) this._onPlay();
		this.update(1.4901161415892264e-008);
		return this;
	}
	,stop: function() {
		if(this._parent != null) throw this.error("Can't stop serialized object directly");
		this._stop();
		return this;
	}
	,_stop: function() {
		if(!this.playing) return;
		this.playing = false;
		this.dispatch(9);
		if(this._onStop != null) this._onStop();
	}
	,update: function(time) {
		if(this._parent != null) throw this.error("Can't stop serialized object directly");
		this._update(time * this.timeScale * tweenx909.TweenX.topLevelTimeScale);
		return this;
	}
	,'goto': function(time,andPlay) {
		if(andPlay == null) andPlay = false;
		if(time == null) time = 0;
		if(this._parent != null) throw this.error("Can't move serialized object directly");
		if(!this._inited) this._init();
		var t = time;
		if(t < 0) t = 0; else if(t > this._totalTime) t = this._totalTime;
		this._update(t - this.get_currentTime());
		if(andPlay) this.play();
		return this;
	}
	,_invert: function() {
		this._currentTime = this._totalTime - this._currentTime;
		if(this._repeat % 2 == 0) this._odd = !this._odd;
		this._inverted = !this._inverted;
		var d = this._delay;
		this._delay = this._rest;
		this._rest = d;
	}
	,_init: function() {
		if(this._inited) return;
		this._inited = true;
		if(tweenx909.TweenX._groupDefaults) {
			if(this._easeIsDefault) this._ease = tweenx909.TweenX.defaultEase;
			if(this._timeIsDefault) this._time = tweenx909.TweenX.defaultTime;
			if(this._delayIsDefault) this._delay = tweenx909.TweenX.defaultDelay;
			if(this._intervalIsDefault) this._interval = tweenx909.TweenX.defaultInterval;
			if(this._repeatIsDefault) this._repeat = tweenx909.TweenX.defaultRepeat;
			if(this._yoyoIsDefault) this._yoyo = tweenx909.TweenX.defaultYoyo;
			if(this._zigzagIsDefault) this._zigzag = tweenx909.TweenX.defaultZigZag;
			if(this._autoPlayIsDefault) this._autoPlay = tweenx909.TweenX.defaultAutoPlay;
		}
		if(this._repeat == 0) this._repeat = 2147483646;
		if(this._time < 1.4901161415892264e-008) this._time = 1.4901161415892264e-008;
		var ot = new Date().getTime();
		this._fastMode = true;
		{
			var _g = this._type;
			switch(_g[1]) {
			case 2:
				var _to = _g[4];
				var _from = _g[3];
				var target = _g[2];
				this._initFromTo(target,_from,_to);
				this._toKeys = Reflect.fields(_to);
				break;
			case 1:
				var toArr = _g[4];
				var fromArr = _g[3];
				var targets = _g[2];
				var i = 0;
				var $it0 = $iterator(targets)();
				while( $it0.hasNext() ) {
					var target1 = $it0.next();
					var _from1 = fromArr[i];
					var _to1 = toArr[i];
					this._initFromTo(target1,_from1,_to1);
					if(i == 0) this._toKeys = Reflect.fields(_to1);
					i++;
				}
				break;
			case 0:
				var g = _g[2];
				this.initGroup(g);
				break;
			default:
			}
		}
		this._singleTime = this.get_singleTime();
		this._totalTime = this.get_totalTime();
		if(this._autoPlay) this.play();
	}
	,_initFromTo: function(target,_from,_to) {
		throw this.error("must be standard tween.");
	}
	,_update: function(spent) {
		if(!this._inited) this._init();
		if(spent == 0) return;
		if(this.backward) spent = -spent;
		if(spent < 0) {
			this._invert();
			this.backward = !this.backward;
			spent = -spent;
		}
		var _currentTime = this._currentTime;
		var _singleTime = this.get_singleTime();
		var _totalTime = this._totalTime;
		var time = this._time;
		var delay = this._delay;
		var untilRest = _totalTime - this._rest;
		var delaying = _currentTime - delay < 1.4901161415892264e-008;
		var resting = !delaying && 1.4901161415892264e-008 > untilRest - _currentTime;
		var body = _currentTime - delay;
		var repeatNum = Math.floor(body / _singleTime);
		var position = body - repeatNum * _singleTime;
		var intervending = 1.4901161415892264e-008 > time - position;
		this._currentTime = _currentTime += spent;
		position += spent;
		body += spent;
		if(_currentTime - delay < 1.4901161415892264e-008) {
			this.dispatch(1);
			if(this._onDelay != null) this._onDelay();
			return;
		} else if(delaying) {
			this._apply(0,0);
			this.dispatch(2);
			if(this._onHead != null) this._onHead();
			this.dispatch(3);
			if(this._onUpdate != null) this._onUpdate();
			delaying = false;
		}
		if(1.4901161415892264e-008 > untilRest - _currentTime) {
			if(!resting) {
				if(intervending) {
					this.dispatch(6);
					if(this._onRepeat != null) this._onRepeat();
					this._apply(0,repeatNum);
					this.dispatch(2);
					if(this._onHead != null) this._onHead();
					this.dispatch(3);
					if(this._onUpdate != null) this._onUpdate();
				}
				this._apply(this._time,this._repeat - 1);
				this.dispatch(3);
				if(this._onUpdate != null) this._onUpdate();
				this.dispatch(4);
				if(this._onFoot != null) this._onFoot();
			}
			if(1.4901161415892264e-008 > _totalTime - _currentTime) {
				this._currentTime = this._totalTime;
				this.dispatch(8);
				if(this._onFinish != null) this._onFinish();
				this._stop();
			} else {
				this.dispatch(7);
				if(this._onRest != null) this._onRest();
			}
		} else {
			if(1.4901161415892264e-008 > time - position) {
				if(!intervending && repeatNum >= 0) {
					this._apply(this._time,repeatNum);
					this.dispatch(3);
					if(this._onUpdate != null) this._onUpdate();
					this.dispatch(4);
					if(this._onFoot != null) this._onFoot();
				}
				if(position < _singleTime) {
					this.dispatch(5);
					if(this._onInterval != null) this._onInterval();
					return;
				} else {
					if(repeatNum >= 0) {
						this.dispatch(6);
						if(this._onRepeat != null) this._onRepeat();
						this._apply(0,repeatNum);
						this.dispatch(2);
						if(this._onHead != null) this._onHead();
						this.dispatch(3);
						if(this._onUpdate != null) this._onUpdate();
					}
					repeatNum = body / _singleTime | 0;
					position = body - repeatNum * _singleTime;
					if(1.4901161415892264e-008 > time - position) {
						this._apply(this._time,repeatNum);
						this.dispatch(3);
						if(this._onUpdate != null) this._onUpdate();
						this.dispatch(4);
						if(this._onFoot != null) this._onFoot();
						this.dispatch(5);
						if(this._onInterval != null) this._onInterval();
						return;
					}
				}
			} else if(intervending) {
				this.dispatch(6);
				if(this._onRepeat != null) this._onRepeat();
				this._apply(0,repeatNum);
				this.dispatch(2);
				if(this._onHead != null) this._onHead();
				this.dispatch(3);
				if(this._onUpdate != null) this._onUpdate();
			}
			this._apply(position,repeatNum);
			this.dispatch(3);
			if(this._onUpdate != null) this._onUpdate();
		}
	}
	,_head: function(repeatNum) {
		this._apply(0,repeatNum);
		this.dispatch(2);
		if(this._onHead != null) this._onHead();
		this.dispatch(3);
		if(this._onUpdate != null) this._onUpdate();
	}
	,_foot: function(repeatNum) {
		this._apply(this._time,repeatNum);
		this.dispatch(3);
		if(this._onUpdate != null) this._onUpdate();
		this.dispatch(4);
		if(this._onFoot != null) this._onFoot();
	}
	,_finish: function() {
		this._currentTime = this._totalTime;
		this.dispatch(8);
		if(this._onFinish != null) this._onFinish();
		this._stop();
	}
	,_apply: function(p,repeatNum) {
		var t = this._getPosition(p,repeatNum % 2 == 1);
		{
			var _g = this._type;
			switch(_g[1]) {
			case 2:
				var _to = _g[4];
				var _from = _g[3];
				var target = _g[2];
				var t2 = 1 - t;
				if(this._fastMode) {
					var _g1 = 0;
					var _g2 = this._toKeys;
					while(_g1 < _g2.length) {
						var key = _g2[_g1];
						++_g1;
						tweenx909.TweenX.setField(target,key,this._fastCalc(tweenx909.TweenX.field(_from,key),tweenx909.TweenX.field(_to,key),t,t2));
					}
				} else {
					var _g11 = 0;
					var _g21 = this._toKeys;
					while(_g11 < _g21.length) {
						var key1 = _g21[_g11];
						++_g11;
						tweenx909.TweenX.setField(target,key1,this._calc(tweenx909.TweenX.field(_from,key1),tweenx909.TweenX.field(_to,key1),t,t2));
					}
				}
				break;
			case 1:
				var tos = _g[4];
				var froms = _g[3];
				var targets = _g[2];
				var t21 = 1 - t;
				var i = 0;
				var $it0 = $iterator(targets)();
				while( $it0.hasNext() ) {
					var target1 = $it0.next();
					var _to1 = tos[i];
					var _from1 = froms[i++];
					var _g12 = 0;
					var _g22 = this._toKeys;
					while(_g12 < _g22.length) {
						var key2 = _g22[_g12];
						++_g12;
						tweenx909.TweenX.setField(target1,key2,this._calc(tweenx909.TweenX.field(_from1,key2),tweenx909.TweenX.field(_to1,key2),t,t21));
					}
				}
				break;
			case 3:
				var _to2 = _g[4];
				var _from2 = _g[3];
				var func = _g[2];
				var t22 = 1 - t;
				var arr = [];
				var _g23 = 0;
				var _g13 = _to2.length;
				while(_g23 < _g13) {
					var i1 = _g23++;
					arr[i1] = this._calc(_from2[i1],_to2[i1],t,t22);
				}
				func.apply(null,arr);
				break;
			case 0:
				var g = _g[2];
				var ts = g.tweens;
				var spent = (this._time * t - g.current) * 1.00000001;
				if(spent < 0) {
					var _g14 = 1 - ts.length;
					while(_g14 < 1) {
						var i2 = _g14++;
						ts[-i2]._update(spent);
					}
				} else {
					var _g24 = 0;
					var _g15 = ts.length;
					while(_g24 < _g15) {
						var i3 = _g24++;
						ts[i3]._update(spent);
					}
				}
				g.current = g.tweens[0].get_currentTime();
				break;
			case 4:
				var f = _g[2];
				if(t == 1) f();
				break;
			}
		}
	}
	,_fastCalc: function(_from,_to,t1,t2) {
		return _from * t2 + _to * t1;
	}
	,_calc: function(_from,_to,t1,t2) {
		if(typeof(_to) == "number") {
			var d = _from * t2 + _to * t1;
			return d;
		} else {
			var i = 0;
			var l = tweenx909.TweenX._rules.length;
			var f;
			var result = null;
			var ok = false;
			while(i < l) if(js.Boot.__instanceof(_to,(f = tweenx909.TweenX._rules[i++]).inputClass)) {
				ok = true;
				result = f.calc(_from,_to,t1,t2,this);
				break;
			}
			if(!ok) throw this.error("The tween rule for " + Type.getClassName(Type.getClass(_to)) + " is not defined");
			return result;
		}
	}
	,time: function(value) {
		if(value < 0) throw this.error("Can't be negative value");
		this.checkInited();
		this._timeIsDefault = false;
		this._time = value;
		return this;
	}
	,ease: function(value) {
		this.checkInited();
		this._easeIsDefault = false;
		this._ease = value;
		return this;
	}
	,delay: function(value) {
		if(value < 0) throw this.error("Can't be negative value");
		this.checkInited();
		this._delayIsDefault = false;
		this._delay = value;
		return this;
	}
	,rest: function(value) {
		if(value < 0) throw this.error("Can't be negative value");
		this.checkInited();
		this._rest = value;
		return this;
	}
	,interval: function(value) {
		if(value < 0) throw this.error("Can't be negative value");
		this.checkInited();
		this._intervalIsDefault = false;
		this._interval = value;
		return this;
	}
	,repeat: function(value) {
		if(value == null) value = 0;
		if(value < 0) throw this.error("Can't be negative value");
		this.checkInited();
		this._repeatIsDefault = false;
		this._repeat = value;
		return this;
	}
	,yoyo: function(value) {
		if(value == null) value = true;
		this.checkInited();
		this._yoyoIsDefault = false;
		this._yoyo = value;
		return this;
	}
	,zigzag: function(value) {
		if(value == null) value = true;
		this.checkInited();
		this._zigzagIsDefault = false;
		this._zigzag = value;
		return this;
	}
	,autoPlay: function(value) {
		if(value == null) value = true;
		this.checkInited();
		this._autoPlayIsDefault = false;
		this._autoPlay = value;
		return this;
	}
	,skip: function(delay) {
		if(delay == null) delay = 0;
		this.checkInited();
		this._skip = delay;
		return this;
	}
	,setTimeScale: function(value) {
		if(value == null) value = 0;
		this.set_timeScale(value);
		return this;
	}
	,onPlay: function(handler) {
		this._onPlay = handler;
		return this;
	}
	,onStop: function(handler) {
		this._onStop = handler;
		return this;
	}
	,onDelay: function(handler) {
		this._onDelay = handler;
		return this;
	}
	,onHead: function(handler) {
		this._onHead = handler;
		return this;
	}
	,onUpdate: function(handler) {
		this._onUpdate = handler;
		return this;
	}
	,onFoot: function(handler) {
		this._onFoot = handler;
		return this;
	}
	,onRest: function(handler) {
		this._onRest = handler;
		return this;
	}
	,onInterval: function(handler) {
		this._onInterval = handler;
		return this;
	}
	,onRepeat: function(handler) {
		this._onRepeat = handler;
		return this;
	}
	,onFinish: function(handler) {
		this._onFinish = handler;
		return this;
	}
	,addEventListener: function(type,listener) {
		this._addEventListener(type,listener);
		return this;
	}
	,removeEventListener: function(type,listener) {
		this._removeEventListener(type,listener);
		return this;
	}
	,_addEventListener: function(type,listener) {
		var i = type[1];
		var arr;
		if(this._eventListeners[i] == null) arr = this._eventListeners[i] = []; else arr = this._eventListeners[i];
		if(!Lambda.has(arr,listener)) arr.push(listener);
	}
	,_removeEventListener: function(type,listener) {
		var i = type[1];
		if(this._eventListeners[i] != null) {
			var x = listener;
			HxOverrides.remove(this._eventListeners[i],x);
		}
	}
	,_getPosition: function(p,back) {
		var t = p / this._time;
		if(this._odd) back = !back;
		if(this._inverted) t = 1 - t;
		if(back) {
			if(this._yoyo) t = 1 - t;
			t = this._ease(t);
			if(this._zigzag) t = 1 - t;
		} else t = this._ease(t);
		return t;
	}
	,checkInited: function() {
		if(this._inited) throw this.error("Can't change params after initialization");
	}
	,dispatch: function(num) {
		var listeners = this._eventListeners[num];
		if(listeners != null) {
			var _g = 0;
			while(_g < listeners.length) {
				var f = listeners[_g];
				++_g;
				f(this);
			}
		}
	}
	,initGroup: function(g) {
		var df = null;
		var gd = false;
		if(g.defaults != null) {
			df = tweenx909.TweenX.dumpDefaults();
			gd = tweenx909.TweenX._groupDefaults;
			tweenx909.TweenX._groupDefaults = true;
			tweenx909.TweenX.setDefaults(g.defaults);
			tweenx909.TweenX.defaultAutoPlay = false;
		}
		var delay = 0.0;
		var max = 0.0;
		var result = [];
		{
			var _g = g.type;
			switch(_g[1]) {
			case 0:
				var $it0 = $iterator(g.source)();
				while( $it0.hasNext() ) {
					var t = $it0.next();
					if(t == null) continue;
					{
						var _g1 = t.command;
						switch(_g1[1]) {
						case 1:
							var d = _g1[2];
							delay += d;
							break;
						case 0:
							var o = _g1[2];
							result.push(o);
							o._autoPlay = false;
							if(tweenx909.TweenX._groupDefaults && o._delayIsDefault) o._delay = tweenx909.TweenX.defaultDelay;
							o._init();
							o._delay += delay;
							o._totalTime += delay;
							var totalTime = o._totalTime;
							if(o._skip != null) delay = delay + o._skip; else delay = totalTime;
							if(max < totalTime) max = totalTime;
							break;
						}
					}
				}
				break;
			case 1:
				var lag = _g[2];
				var $it1 = $iterator(g.source)();
				while( $it1.hasNext() ) {
					var t1 = $it1.next();
					if(t1 == null) continue;
					{
						var _g11 = t1.command;
						switch(_g11[1]) {
						case 1:
							var d1 = _g11[2];
							delay += d1;
							break;
						case 0:
							var o1 = _g11[2];
							result.push(o1);
							o1._init();
							o1._delay += delay;
							o1._totalTime += delay;
							var totalTime1 = o1._totalTime;
							if(o1._skip != null) delay += o1._skip; else delay += lag;
							if(max < totalTime1) max = totalTime1;
							break;
						}
					}
				}
				break;
			}
		}
		var _g2 = 0;
		while(_g2 < result.length) {
			var t2 = result[_g2];
			++_g2;
			var diff = max - t2._totalTime;
			t2._rest += diff;
			t2._totalTime += diff;
		}
		this._time = max;
		g.tweens = result;
		g.source = null;
		if(g.defaults != null) {
			tweenx909.TweenX._groupDefaults = gd;
			tweenx909.TweenX.setDefaults(df);
		}
	}
	,__class__: tweenx909.TweenX
	,__properties__: {set_timeScale:"set_timeScale",get_totalTime:"get_totalTime",get_singleTime:"get_singleTime",get_currentTime:"get_currentTime"}
});
tweenx909.advanced.CommandTypeX = { __ename__ : true, __constructs__ : ["TWEEN","WAIT"] };
tweenx909.advanced.CommandTypeX.TWEEN = function(tween) { var $x = ["TWEEN",0,tween]; $x.__enum__ = tweenx909.advanced.CommandTypeX; return $x; };
tweenx909.advanced.CommandTypeX.WAIT = function(delay) { var $x = ["WAIT",1,delay]; $x.__enum__ = tweenx909.advanced.CommandTypeX; return $x; };
tweenx909.advanced.DefaultsX = function() {
	this._autoPlay = true;
	this._zigzag = false;
	this._yoyo = false;
	this._repeat = 1;
	this._interval = 0;
	this._delay = 0;
	this._time = 0.3;
	this._ease = tweenx909.TweenX.DEFAULT_EASE;
};
tweenx909.advanced.DefaultsX.__name__ = ["tweenx909","advanced","DefaultsX"];
tweenx909.advanced.DefaultsX.prototype = {
	dump: function() {
		this._time = tweenx909.TweenX.defaultTime;
		this._ease = tweenx909.TweenX.defaultEase;
		this._delay = tweenx909.TweenX.defaultDelay;
		this._interval = tweenx909.TweenX.defaultInterval;
		this._repeat = tweenx909.TweenX.defaultRepeat;
		this._yoyo = tweenx909.TweenX.defaultYoyo;
		this._zigzag = tweenx909.TweenX.defaultZigZag;
		this._autoPlay = tweenx909.TweenX.defaultAutoPlay;
		return this;
	}
	,apply: function() {
		tweenx909.TweenX.defaultTime = this._time;
		tweenx909.TweenX.defaultEase = this._ease;
		tweenx909.TweenX.defaultDelay = this._delay;
		tweenx909.TweenX.defaultInterval = this._interval;
		tweenx909.TweenX.defaultRepeat = this._repeat;
		tweenx909.TweenX.defaultYoyo = this._yoyo;
		tweenx909.TweenX.defaultZigZag = this._zigzag;
		tweenx909.TweenX.defaultAutoPlay = this._autoPlay;
	}
	,clone: function() {
		var child = new tweenx909.advanced.DefaultsX();
		child._time = this._time;
		child._ease = this._ease;
		child._delay = this._delay;
		child._interval = this._interval;
		child._repeat = this._repeat;
		child._yoyo = this._yoyo;
		child._zigzag = this._zigzag;
		child._autoPlay = this._autoPlay;
		return child;
	}
	,time: function(value) {
		this._time = value;
		return this;
	}
	,ease: function(value) {
		this._ease = value;
		return this;
	}
	,delay: function(value) {
		this._delay = value;
		return this;
	}
	,interval: function(value) {
		this._interval = value;
		return this;
	}
	,repeat: function(value) {
		if(value == null) value = 0;
		this._repeat = value;
		return this;
	}
	,yoyo: function(value) {
		if(value == null) value = true;
		this._yoyo = value;
		return this;
	}
	,zigzag: function(value) {
		if(value == null) value = true;
		this._zigzag = value;
		return this;
	}
	,autoPlay: function(value) {
		if(value == null) value = true;
		this._autoPlay = value;
		return this;
	}
	,__class__: tweenx909.advanced.DefaultsX
};
tweenx909.advanced.GroupX = function(source,type,defaults) {
	this.current = 0;
	this.source = source;
	this.type = type;
	if(defaults != null) this.defaults = defaults.clone();
};
tweenx909.advanced.GroupX.__name__ = ["tweenx909","advanced","GroupX"];
tweenx909.advanced.GroupX.prototype = {
	__class__: tweenx909.advanced.GroupX
};
tweenx909.advanced._GroupX = {};
tweenx909.advanced._GroupX.GroupTypeX = { __ename__ : true, __constructs__ : ["SERIAL","LAG"] };
tweenx909.advanced._GroupX.GroupTypeX.SERIAL = ["SERIAL",0];
tweenx909.advanced._GroupX.GroupTypeX.SERIAL.__enum__ = tweenx909.advanced._GroupX.GroupTypeX;
tweenx909.advanced._GroupX.GroupTypeX.LAG = function(lag) { var $x = ["LAG",1,lag]; $x.__enum__ = tweenx909.advanced._GroupX.GroupTypeX; return $x; };
tweenx909.advanced.StandardTweenX = function(type,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos) {
	this._autoFrom = true;
	switch(type[1]) {
	case 1:
		var toArr = type[4];
		var fromArr = type[3];
		var targets = type[2];
		var _from = fromArr.pop();
		var _to = toArr.pop();
		var $it0 = $iterator(targets)();
		while( $it0.hasNext() ) {
			var t = $it0.next();
			toArr.push(tweenx909.advanced.StandardTweenX.clone(_to));
			fromArr.push(tweenx909.advanced.StandardTweenX.clone(_from));
		}
		break;
	default:
	}
	tweenx909.TweenX.call(this,type,time,ease,delay,repeat,yoyo,zigzag,interval,autoPlay,posInfos);
};
tweenx909.advanced.StandardTweenX.__name__ = ["tweenx909","advanced","StandardTweenX"];
tweenx909.advanced.StandardTweenX.clone = function(obj) {
	var result = { };
	var _g = 0;
	var _g1 = Reflect.fields(obj);
	while(_g < _g1.length) {
		var key = _g1[_g];
		++_g;
		Reflect.setProperty(result,key,Reflect.getProperty(obj,key));
	}
	return result;
};
tweenx909.advanced.StandardTweenX.__super__ = tweenx909.TweenX;
tweenx909.advanced.StandardTweenX.prototype = $extend(tweenx909.TweenX.prototype,{
	checkField: function(target,key) {
		if(!Std["is"](Reflect.field(target,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(target)) + " does not have field '" + key + "'");
	}
	,_getTarget: function() {
		return this;
	}
	,_setTo: function(key,value) {
		this.checkInited();
		{
			var _g = this._type;
			switch(_g[1]) {
			case 2:
				var _to = _g[4];
				var _from = _g[3];
				var target = _g[2];
				if(!Std["is"](Reflect.field(target,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(target)) + " does not have field '" + key + "'");
				Reflect.deleteField(_to,"$$$$" + key);
				tweenx909.TweenX.setField(_to,key,value);
				break;
			case 1:
				var toArr = _g[4];
				var fromArr = _g[3];
				var targets = _g[2];
				var i = 0;
				var $it0 = $iterator(targets)();
				while( $it0.hasNext() ) {
					var t = $it0.next();
					if(!Std["is"](Reflect.field(t,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(t)) + " does not have field '" + key + "'");
					var _to1 = toArr[i++];
					Reflect.deleteField(_to1,"$$$$" + key);
					tweenx909.TweenX.setField(_to1,key,value);
				}
				break;
			default:
			}
		}
	}
	,_setRelativeTo: function(key,value) {
		this.checkInited();
		{
			var _g = this._type;
			switch(_g[1]) {
			case 2:
				var _to = _g[4];
				var _from = _g[3];
				var target = _g[2];
				if(!Std["is"](Reflect.field(target,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(target)) + " does not have field '" + key + "'");
				Reflect.deleteField(_to,"$$$$" + key);
				tweenx909.TweenX.setField(_to,key,tweenx909.TweenX.field(target,key) + value);
				break;
			case 1:
				var toArr = _g[4];
				var fromArr = _g[3];
				var targets = _g[2];
				var i = 0;
				var $it0 = $iterator(targets)();
				while( $it0.hasNext() ) {
					var t = $it0.next();
					if(!Std["is"](Reflect.field(t,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(t)) + " does not have field '" + key + "'");
					var _to1 = toArr[i++];
					Reflect.deleteField(_to1,"$$$$" + key);
					tweenx909.TweenX.setField(_to1,key,tweenx909.TweenX.field(t,key) + value);
				}
				break;
			default:
			}
		}
	}
	,_setRelativeTo2: function(key,value) {
		this.checkInited();
		{
			var _g = this._type;
			switch(_g[1]) {
			case 2:
				var _to = _g[4];
				var _from = _g[3];
				var target = _g[2];
				if(!Std["is"](Reflect.field(target,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(target)) + " does not have field '" + key + "'");
				Reflect.deleteField(_to,key);
				tweenx909.TweenX.setField(_to,"$$$$" + key,value);
				break;
			case 1:
				var toArr = _g[4];
				var fromArr = _g[3];
				var targets = _g[2];
				var i = 0;
				var $it0 = $iterator(targets)();
				while( $it0.hasNext() ) {
					var t = $it0.next();
					if(!Std["is"](Reflect.field(t,key),Dynamic)) throw this.error(Type.getClassName(Type.getClass(t)) + " does not have field '" + key + "'");
					var _to1 = toArr[i++];
					Reflect.deleteField(_to1,key);
					tweenx909.TweenX.setField(_to1,"$$$$" + key,value);
				}
				break;
			default:
			}
		}
	}
	,_initFromTo: function(target,_from,_to) {
		if(this._autoFrom == null) this._autoFrom = tweenx909.TweenX.defaultAutoFrom;
		this._initFrom(target,_from,_to);
		var data = { };
		var fs = Reflect.fields(_from);
		var _g = 0;
		while(_g < fs.length) {
			var key = fs[_g];
			++_g;
			if(!Object.prototype.hasOwnProperty.call(_to,key)) tweenx909.TweenX.setField(_to,key,tweenx909.TweenX.field(_from,key));
			var t = this._getPosition(this._time,this._repeat % 2 == 0);
			tweenx909.TweenX.setField(data,key,this._calc(tweenx909.TweenX.field(_from,key),tweenx909.TweenX.field(_to,key),t,1 - t));
		}
		var id;
		if(tweenx909.TweenX.dictionary.get(target) != null) id = tweenx909.TweenX.dictionary.get(target); else {
			tweenx909.TweenX._objCounter = 1 + tweenx909.TweenX._objCounter % 33029;
			tweenx909.TweenX.dictionary.set(target,tweenx909.TweenX._objCounter);
			id = tweenx909.TweenX._objCounter;
		}
		if(tweenx909.TweenX._initLog[id] == null) tweenx909.TweenX._initLog[id] = [{ target : target, data : data}]; else {
			var flag = false;
			var _g1 = 0;
			var _g11 = tweenx909.TweenX._initLog[id];
			while(_g1 < _g11.length) {
				var log = _g11[_g1];
				++_g1;
				if(log.target == target) {
					var _g2 = 0;
					var _g3 = Reflect.fields(data);
					while(_g2 < _g3.length) {
						var key1 = _g3[_g2];
						++_g2;
						tweenx909.TweenX.setField(log.data,key1,tweenx909.TweenX.field(data,key1));
					}
					flag = true;
					break;
				}
			}
			if(!flag) tweenx909.TweenX._initLog[id].push({ target : target, data : data});
		}
	}
	,_initFrom: function(target,_from,_to) {
		var data = null;
		var _g = 0;
		var _g1 = Reflect.fields(_to);
		while(_g < _g1.length) {
			var key0 = _g1[_g];
			++_g;
			if(!(typeof(tweenx909.TweenX.field(_to,key0)) == "number")) this._fastMode = false;
			var relative = HxOverrides.substr(key0,0,4) == "$$$$";
			var key;
			if(relative) key = HxOverrides.substr(key0,4,null); else key = key0;
			var fromValue;
			var toValue = tweenx909.TweenX.field(_to,key0);
			if(!Object.prototype.hasOwnProperty.call(_from,key)) {
				if(this._autoFrom) {
					if(data == null) {
						data = { };
						var logs = tweenx909.TweenX._initLog[tweenx909.TweenX.dictionary.get(target) != null?tweenx909.TweenX.dictionary.get(target):(function($this) {
							var $r;
							tweenx909.TweenX._objCounter = 1 + tweenx909.TweenX._objCounter % 33029;
							tweenx909.TweenX.dictionary.set(target,tweenx909.TweenX._objCounter);
							$r = tweenx909.TweenX._objCounter;
							return $r;
						}(this))];
						if(logs != null) {
							var _g2 = 0;
							while(_g2 < logs.length) {
								var log = logs[_g2];
								++_g2;
								if(log.target == target) data = log.data;
							}
						}
					}
					if(Object.prototype.hasOwnProperty.call(data,key)) fromValue = this._defaultFrom(tweenx909.TweenX.field(data,key),toValue); else fromValue = this._defaultFrom(tweenx909.TweenX.field(target,key),toValue);
				} else fromValue = this._defaultFrom(tweenx909.TweenX.field(target,key),toValue);
				tweenx909.TweenX.setField(_from,key,fromValue);
			} else fromValue = tweenx909.TweenX.field(_from,key);
			if(relative) {
				tweenx909.TweenX.setField(_to,key,toValue + fromValue);
				Reflect.deleteField(_to,key0);
			}
		}
	}
	,_defaultFrom: function(value,_to) {
		if(typeof(_to) == "number") return value;
		var _g = 0;
		var _g1 = tweenx909.TweenX._rules;
		while(_g < _g1.length) {
			var r = _g1[_g];
			++_g;
			if(js.Boot.__instanceof(_to,r.inputClass)) return r.defaultFrom(value,_to,this);
		}
		throw this.error("The tween rule for " + Type.getClassName(Type.getClass(_to)) + " is not defined");
		return null;
	}
	,play: function() {
		tweenx909.TweenX.prototype.play.call(this);
		return this;
	}
	,stop: function() {
		tweenx909.TweenX.prototype.stop.call(this);
		return this;
	}
	,update: function(time) {
		tweenx909.TweenX.prototype.update.call(this,time);
		return this;
	}
	,'goto': function(time,andPlay) {
		if(andPlay == null) andPlay = false;
		if(time == null) time = 0;
		tweenx909.TweenX.prototype["goto"].call(this,time,andPlay);
		return this;
	}
	,onDelay: function(handler) {
		tweenx909.TweenX.prototype.onDelay.call(this,handler);
		return this;
	}
	,onFinish: function(handler) {
		tweenx909.TweenX.prototype.onFinish.call(this,handler);
		return this;
	}
	,onFoot: function(handler) {
		tweenx909.TweenX.prototype.onFoot.call(this,handler);
		return this;
	}
	,onHead: function(handler) {
		tweenx909.TweenX.prototype.onHead.call(this,handler);
		return this;
	}
	,onInterval: function(handler) {
		tweenx909.TweenX.prototype.onInterval.call(this,handler);
		return this;
	}
	,onStop: function(handler) {
		tweenx909.TweenX.prototype.onStop.call(this,handler);
		return this;
	}
	,onPlay: function(handler) {
		tweenx909.TweenX.prototype.onPlay.call(this,handler);
		return this;
	}
	,onRepeat: function(handler) {
		tweenx909.TweenX.prototype.onRepeat.call(this,handler);
		return this;
	}
	,onRest: function(handler) {
		tweenx909.TweenX.prototype.onRest.call(this,handler);
		return this;
	}
	,onUpdate: function(handler) {
		tweenx909.TweenX.prototype.onUpdate.call(this,handler);
		return this;
	}
	,addEventListener: function(type,listener) {
		this._addEventListener(type,listener);
		return this;
	}
	,removeEventListener: function(type,listener) {
		this._removeEventListener(type,listener);
		return this;
	}
	,time: function(value) {
		tweenx909.TweenX.prototype.time.call(this,value);
		return this;
	}
	,ease: function(value) {
		tweenx909.TweenX.prototype.ease.call(this,value);
		return this;
	}
	,delay: function(value) {
		tweenx909.TweenX.prototype.delay.call(this,value);
		return this;
	}
	,rest: function(value) {
		tweenx909.TweenX.prototype.rest.call(this,value);
		return this;
	}
	,interval: function(value) {
		tweenx909.TweenX.prototype.interval.call(this,value);
		return this;
	}
	,repeat: function(value) {
		if(value == null) value = 1;
		tweenx909.TweenX.prototype.repeat.call(this,value);
		return this;
	}
	,yoyo: function(value) {
		if(value == null) value = true;
		tweenx909.TweenX.prototype.yoyo.call(this,value);
		return this;
	}
	,zigzag: function(value) {
		if(value == null) value = true;
		tweenx909.TweenX.prototype.zigzag.call(this,value);
		return this;
	}
	,autoPlay: function(value) {
		if(value == null) value = true;
		tweenx909.TweenX.prototype.autoPlay.call(this,value);
		return this;
	}
	,setTimeScale: function(value) {
		if(value == null) value = 0;
		tweenx909.TweenX.prototype.setTimeScale.call(this,value);
		return this;
	}
	,skip: function(delay) {
		if(delay == null) delay = 0;
		tweenx909.TweenX.prototype.skip.call(this);
		return this;
	}
	,autoFrom: function(value) {
		if(value == null) value = true;
		this.checkInited();
		this._autoFrom = value;
		return this;
	}
	,__class__: tweenx909.advanced.StandardTweenX
});
tweenx909.advanced.TweenTypeX = { __ename__ : true, __constructs__ : ["GROUP","ARRAY","FROM_TO","FUNC","CALL"] };
tweenx909.advanced.TweenTypeX.GROUP = function(group) { var $x = ["GROUP",0,group]; $x.__enum__ = tweenx909.advanced.TweenTypeX; return $x; };
tweenx909.advanced.TweenTypeX.ARRAY = function(targets,_from,_to) { var $x = ["ARRAY",1,targets,_from,_to]; $x.__enum__ = tweenx909.advanced.TweenTypeX; return $x; };
tweenx909.advanced.TweenTypeX.FROM_TO = function(target,_from,_to) { var $x = ["FROM_TO",2,target,_from,_to]; $x.__enum__ = tweenx909.advanced.TweenTypeX; return $x; };
tweenx909.advanced.TweenTypeX.FUNC = function(func,_from,_to) { var $x = ["FUNC",3,func,_from,_to]; $x.__enum__ = tweenx909.advanced.TweenTypeX; return $x; };
tweenx909.advanced.TweenTypeX.CALL = function(func) { var $x = ["CALL",4,func]; $x.__enum__ = tweenx909.advanced.TweenTypeX; return $x; };
var utils = {};
utils.Debug = function() { };
utils.Debug.__name__ = ["utils","Debug"];
utils.Debug.log = function(message,color) {
	managers.StateManager.debugText.text = message;
};
utils.DeviceCapabilities = function() { };
utils.DeviceCapabilities.__name__ = ["utils","DeviceCapabilities"];
utils.DeviceCapabilities.__properties__ = {get_width:"get_width",get_height:"get_height"}
utils.DeviceCapabilities.get_height = function() {
	return window.innerHeight;
};
utils.DeviceCapabilities.get_width = function() {
	return window.innerWidth;
};
utils.DeviceCapabilities.getScreenRect = function(pTarget) {
	if(pTarget.parent == null) return null;
	var lTopLeft = new PIXI.Point(0,0);
	var lBottomRight = new PIXI.Point((function($this) {
		var $r;
		var this1 = utils.DeviceCapabilities.get_width();
		var $int = this1;
		$r = $int < 0?4294967296.0 + $int:$int + 0.0;
		return $r;
	}(this)),(function($this) {
		var $r;
		var this2 = utils.DeviceCapabilities.get_height();
		var int1 = this2;
		$r = int1 < 0?4294967296.0 + int1:int1 + 0.0;
		return $r;
	}(this)));
	lTopLeft = pTarget.parent.toLocal(lTopLeft);
	lBottomRight = pTarget.parent.toLocal(lBottomRight);
	return new PIXI.Rectangle(lTopLeft.x,lTopLeft.y,lBottomRight.x - lTopLeft.x,lBottomRight.y - lTopLeft.y);
};
utils.Id = function() { };
utils.Id.__name__ = ["utils","Id"];
utils.Id.newId = function() {
	var stringToReturn = "";
	stringToReturn += utils.Id.numberIds++;
	return stringToReturn;
};
utils.Misc = function() { };
utils.Misc.__name__ = ["utils","Misc"];
utils.Misc.getDistance = function(x1,y1,x2,y2) {
	var dx = x1 - x2;
	var dy = y1 - y2;
	return Math.sqrt(dx * dx + dy * dy);
};
utils.Misc.angleBetween = function(s,t) {
	return -Math.atan2(t[1] - s[1],t[0] - s[0]);
};
utils.Misc.convertAngleToDirection = function(angle) {
	if(Math.abs(angle) / Math.PI > 0.5) {
		if(angle > 0) return 1; else return 0;
	} else if(angle > 0) return 2; else return 3;
};
utils.Misc.getDirectionToPoint = function(source,target) {
	return utils.Misc.convertAngleToDirection(utils.Misc.angleBetweenTiles(source,target));
};
utils.Misc.angleBetweenTiles = function(from,to) {
	return utils.Misc.angleBetween(utils.Misc.convertToAbsolutePosition(from),utils.Misc.convertToAbsolutePosition(to));
};
utils.Misc.convertToAbsolutePosition = function(tilePosition) {
	var returnPosition = [];
	returnPosition[0] = tilePosition[0] * Main.tileSize[0];
	if(Math.abs(tilePosition[1] % 2) == 1) returnPosition[0] += Main.tileSize[0] * 0.5;
	returnPosition[1] = tilePosition[1] * Main.tileSize[1] * 0.5;
	return returnPosition;
};
utils.Misc.convertToGridPosition = function(absoluteX,absoluteY,withCamera) {
	if(withCamera) {
		absoluteX += objects.Camera.getInstance().offset[0];
		absoluteY += objects.Camera.getInstance().offset[1];
	}
	var tileSize = Main.tileSize;
	var halfMousePosX = Math.floor(absoluteX / (tileSize[0] / 2)) / 2;
	var halfMousePosY = Math.floor(absoluteY / (tileSize[1] / 2)) / 2;
	if(halfMousePosX % 1 != 0) halfMousePosX += 0.5;
	if(halfMousePosY % 1 != 0) halfMousePosY += 0.5;
	var dx = (absoluteX - halfMousePosX * tileSize[0]) / tileSize[0] * 2;
	var dy = (absoluteY - halfMousePosY * tileSize[1]) / tileSize[1] * 2;
	var SelectedPos;
	if(Math.abs(dx) + Math.abs(dy) <= 1) SelectedPos = [halfMousePosX,halfMousePosY]; else SelectedPos = [halfMousePosX + dx / Math.abs(dx) * 0.5,halfMousePosY + dy / Math.abs(dy) * 0.5];
	SelectedPos[0] = Math.floor(SelectedPos[0]);
	SelectedPos[1] *= 2;
	return SelectedPos;
};
utils.Misc.getRangeTileAround = function(tilePos,minRange,maxRange) {
	if(maxRange == null) maxRange = 10;
	if(minRange == null) minRange = 0;
	if(minRange == 0 && maxRange == 0) return [tilePos];
	var ArrayOfPos = [];
	var GridAround = [];
	var iter = new IntIterator(Math.floor(-maxRange * 0.5),Math.floor(2 + maxRange * 0.5));
	while( iter.hasNext() ) {
		var i = iter.next();
		var iter2 = new IntIterator(-maxRange,1 + maxRange);
		while( iter2.hasNext() ) {
			var j = iter2.next();
			GridAround.push([tilePos[0] + i,tilePos[1] - j]);
		}
	}
	var centerAbsolutePos = utils.Misc.convertToAbsolutePosition(tilePos);
	if(utils.Misc.squareColliMax == null) {
		utils.Misc.squareColliMax = managers.PoolManager.pullObject("tile",1)[0];
		utils.Misc.squareColliMax.anchor.set(0.5,0.5);
	}
	if(utils.Misc.squareColliMin == null) {
		utils.Misc.squareColliMin = managers.PoolManager.pullObject("tile",1)[0];
		utils.Misc.squareColliMin.anchor.set(0.5,0.5);
	}
	utils.Misc.squareColliMin.width = (minRange - 1) * Main.tileSize[0] + 4;
	utils.Misc.squareColliMin.height = (minRange - 1) * Main.tileSize[1] + 4;
	utils.Misc.squareColliMin.x = centerAbsolutePos[0] - 2;
	utils.Misc.squareColliMin.y = centerAbsolutePos[1] - 2;
	utils.Misc.squareColliMax.width = maxRange * Main.tileSize[0] + 4;
	utils.Misc.squareColliMax.height = maxRange * Main.tileSize[1] + 4;
	utils.Misc.squareColliMax.x = centerAbsolutePos[0] - 2;
	utils.Misc.squareColliMax.y = centerAbsolutePos[1] - 2;
	var $it0 = HxOverrides.iter(GridAround);
	while( $it0.hasNext() ) {
		var i1 = $it0.next();
		var absolutePosPoint = utils.Misc.convertToAbsolutePosition(i1);
		if(utils.Misc.colliSquarePoint(utils.Misc.squareColliMax,absolutePosPoint)) {
			if(!utils.Misc.colliSquarePoint(utils.Misc.squareColliMin,absolutePosPoint) || minRange == 0) ArrayOfPos.push(i1);
		}
	}
	return ArrayOfPos;
};
utils.Misc.colliSquarePoint = function(obj,point,cameraAffected) {
	var offset;
	if(cameraAffected) offset = objects.Camera.getInstance().offset; else offset = [0,0];
	var target = obj.getGlobalPosition(null);
	var size = { width : obj.width, height : obj.height};
	if(obj.parent != null) size = obj.getBounds(null);
	if(obj.anchor == null) obj.anchor = new PIXI.Point(0,0);
	if(target.x - size.width * obj.anchor.x > point[0] + offset[0]) return false;
	if(target.y - size.height * obj.anchor.y > point[1] + offset[1]) return false;
	if(target.x + size.width - size.width * obj.anchor.x < point[0] + offset[0]) return false;
	if(target.y + size.height - size.height * obj.anchor.y < point[1] + offset[1]) return false;
	return true;
};
utils.Misc.colliSquareSquare = function(obj1,obj2) {
	if(obj1.x - obj1.width * obj1.anchor.x > obj2.x + obj2.width - obj2.width * obj2.anchor.x) return false;
	if(obj1.y - obj1.height * obj1.anchor.y > obj2.y + obj2.height - obj2.height * obj2.anchor.y) return false;
	if(obj1.x + obj1.width - obj1.width * obj1.anchor.x < obj2.x - obj2.width * obj2.anchor.x) return false;
	if(obj1.y + obj1.height - obj1.height * obj1.anchor.y < obj2.y - obj2.height * obj2.anchor.y) return false;
	return true;
};
utils.Misc.sign = function(number) {
	if(number > 0) return 1; else return -1;
};
utils.Misc.clamp = function(number,min,max) {
	if(number < min) return min;
	if(number > max) return max;
	return number;
};
utils.Misc.getAttackFromName = function(name,data) {
	switch(name) {
	case "normal":
		return new objects.attacks.NormalAttack(data);
	case "triple":
		return new objects.attacks.TripleAttack(data);
	}
	window.console.warn("ATTACK NOT FOUND !");
	return new objects.attacks.Attack(data);
};
utils.Misc.targetInRange = function(source,target,tilesInRange) {
	var $it0 = HxOverrides.iter(tilesInRange);
	while( $it0.hasNext() ) {
		var i = $it0.next();
		if(i[0] == target[0] && i[1] == target[1]) return true;
	}
	return false;
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
Math.NaN = Number.NaN;
Math.NEGATIVE_INFINITY = Number.NEGATIVE_INFINITY;
Math.POSITIVE_INFINITY = Number.POSITIVE_INFINITY;
Math.isFinite = function(i) {
	return isFinite(i);
};
Math.isNaN = function(i1) {
	return isNaN(i1);
};
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
Date.prototype.__class__ = Date;
Date.__name__ = ["Date"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
var q = window.jQuery;
js.JQuery = q;
(function()
{
var Uint8Array = window.Uint8Array;
/**

  Font.js v2012.01.25
  (c) Mike "Pomax" Kamermans, 2012
  Licensed under MIT ("expat" flavour) license.
  Hosted on http://github.com/Pomax/Font.js

  This library adds Font objects to the general pool
  of available JavaScript objects, so that you can load
  fonts through a JavaScript object similar to loading
  images through a new Image() object.

  Font.js is compatible with all browsers that support
  <canvas> and Object.defineProperty - This includes
  all versions of Firefox, Chrome, Opera, IE and Safari
  that were 'current' (Firefox 9, Chrome 16, Opera 11.6,
  IE9, Safari 5.1) at the time Font.js was released.

  Font.js will not work on IE8 or below due to the lack
  of Object.defineProperty - I recommend using the
  solution outlined in http://ie6update.com/ for websites
  that are not corporate intranet sites, because as a home
  user you have no excuse not to have upgraded to Internet
  Explorer 9 yet, or simply not using Internet Explorer if
  you're still using Windows XP. If you have friends or
  family that still use IE8 or below: intervene.

  You may remove every line in this header except for
  the first block of four lines, for the purposes of
  saving space and minification. If minification strips
  the header, you'll have to paste that paragraph back in.

  Issue tracker: https://github.com/Pomax/Font.js/issues

**/

(function(window){

  // 1) Do we have a mechanism for binding implicit get/set?
  if(!Object.defineProperty) {
    throw("Font.js requires Object.defineProperty, which this browser does not support.");
  }

  // 2) Do we have Canvas2D available?
  if(!document.createElement("canvas").getContext) {
    throw("Font.js requires <canvas> and the Canvas2D API, which this browser does not support.");
  }

  // Make sure type arrays are available in IE9
  // Code borrowed from pdf.js (https://gist.github.com/1057924)
  (function(window) {
    try { var a = new Uint8Array(1); return; } catch (e) { }
    function subarray(start, end) { return this.slice(start, end); }
    function set_(array, offset) {
      var i, n = array.length;
      if (arguments.length < 2) { offset = 0; }
      for (i = 0; i < n; ++i, ++offset) { this[offset] = array[i] & 0xFF; }}
    function TypedArray(arg1) {
      var result, i;
      if (typeof arg1 === "number") {
        result = new Array(arg1);
        for (i = 0; i < arg1; ++i) { result[i] = 0; }
      } else { result = arg1.slice(0); }
      result.subarray = subarray;
      result.buffer = result;
      result.byteLength = result.length;
      result.set = set_;
      if (typeof arg1 === "object" && arg1.buffer) {
        result.buffer = arg1.buffer; }
      return result; }
    window.Uint8Array = TypedArray;
    window.Uint32Array = TypedArray;
    window.Int32Array = TypedArray;
  }(window));

  // Also make sure XHR understands typing.
  // Code based on pdf.js (https://gist.github.com/1057924)
  (function(window) {
    // shortcut for Opera - it's already fine
    if(window.opera) return;
    // shortcuts for browsers that already implement XHR minetyping
    if ("response" in XMLHttpRequest.prototype ||
        "mozResponseArrayBuffer" in XMLHttpRequest.prototype ||
        "mozResponse" in XMLHttpRequest.prototype ||
        "responseArrayBuffer" in XMLHttpRequest.prototype) { return; }
    var getter;
    // If we have access to the VBArray (i.e., we're in IE), use that
    if(window.VBArray) {
      getter = function() {
        return new Uint8Array(new VBArray(this.responseBody).toArray()); }}
    // Okay... umm.. untyped arrays? This may break completely.
    // (Android browser 2.3 and 3 don't do typed arrays)
    else { getter = function() { this.responseBody; }}
    Object.defineProperty(XMLHttpRequest.prototype, "response", {get: getter});
  }(window));


  // IE9 does not have binary-to-ascii built in O_O
  if(!window.btoa) {
    // Code borrowed from PHP.js (http://phpjs.org/functions/base64_encode:358)
    window.btoa = function(data) {
      var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
      var o1, o2, o3, h1, h2, h3, h4, bits, i = 0, ac = 0, enc = "", tmp_arr = [];
      if (!data) { return data; }
      do { // pack three octets into four hexets
          o1 = data.charCodeAt(i++);
          o2 = data.charCodeAt(i++);
          o3 = data.charCodeAt(i++);
          bits = o1 << 16 | o2 << 8 | o3;
          h1 = bits >> 18 & 0x3f;
          h2 = bits >> 12 & 0x3f;
          h3 = bits >> 6 & 0x3f;
          h4 = bits & 0x3f;
          // use hexets to index into b64, and append result to encoded string
          tmp_arr[ac++] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
      } while (i < data.length);
      enc = tmp_arr.join('');
      var r = data.length % 3;
      return (r ? enc.slice(0, r - 3) : enc) + '==='.slice(r || 3);
    };
  }

  /**

    Not-borrowed-code starts here!

   **/
  function Font() {
    // if this is not specified, a random name is used
    this.fontFamily = "fjs" + (999999 * Math.random() | 0);
  }

  // the font resource URL
  Font.prototype.url = "";

  // the font's format ('truetype' for TT-OTF or 'opentype' for CFF-OTF)
  Font.prototype.format = "";

  // the font's byte code
  Font.prototype.data = "";

  // custom font, implementing the letter 'A' as zero-width letter.
  Font.prototype.base64 = "AAEAAAAKAIAAAwAgT1MvMgAAAAAAAACsAAAAWGNtYXAA"+
                          "AAAAAAABBAAAACxnbHlmAAAAAAAAATAAAAAQaGVhZAAAA"+
                          "AAAAAFAAAAAOGhoZWEAAAAAAAABeAAAACRobXR4AAAAAA"+
                          "AAAZwAAAAIbG9jYQAAAAAAAAGkAAAACG1heHAAAAAAAAA"+
                          "BrAAAACBuYW1lAAAAAAAAAcwAAAAgcG9zdAAAAAAAAAHs"+
                          "AAAAEAAEAAEAZAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                          "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"+
                          "AAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAABAAMAAQA"+
                          "AAAwABAAgAAAABAAEAAEAAABB//8AAABB////wAABAAAA"+
                          "AAABAAAAAAAAAAAAAAAAMQAAAQAAAAAAAAAAAABfDzz1A"+
                          "AAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAEAAg"+
                          "AAAAAAAAABAAAAAQAAAAEAAAAAAAAAAAAAAAAAAAAAAAA"+
                          "AAAAAAAAAAQAAAAAAAAAAAAAAAAAIAAAAAQAAAAIAAQAB"+
                          "AAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAIAHgADAAEEC"+
                          "QABAAAAAAADAAEECQACAAIAAAAAAAEAAAAAAAAAAAAAAA"+
                          "AAAA==";

  // these metrics represent the font-indicated values,
  // not the values pertaining to text as it is rendered
  // on the page (use fontmetrics.js for this instead).
  Font.prototype.metrics = {
    quadsize: 0,
    leading: 0,
    ascent: 0,
    descent: 0,
    weightclass: 400
  };

  // Will this be a remote font, or a system font?
  Font.prototype.systemfont = false;

  // internal indicator that the font is done loading
  Font.prototype.loaded = false;

  /**
   * This function gets called once the font is done
   * loading, its metrics have been determined, and it
   * has been parsed for use on-page. By default, this
   * function does nothing, and users can bind their
   * own handler function.
   */
  Font.prototype.onload = function () {};

  /**
   * This function gets called when there is a problem
   * loading the font.
   */
  Font.prototype.onerror = function () {};

  // preassigned quad ? quad context, for measurements
  Font.prototype.canvas = false;
  Font.prototype.context = false;

  /**
   * validation function to see if the zero-width styled
   * text is no longer zero-width. If this is true, the
   * font is properly done loading. If this is false, the
   * function calls itself via a timeout
   */
  Font.prototype.validate = function (target, zero, mark, font, timeout) {
    if (timeout !== false && timeout < 0 ) {
      this.onerror("Requested system font '"+this.fontFamily+"' could not be loaded (it may not be installed).");
      return;
    }
    var width = getComputedStyle(target, null).getPropertyValue("width").replace("px", '');
    // font has finished loading - remove the zero-width and
    // validation paragraph, but leave the actual font stylesheet (mark);
    if (width > 0) {
      document.head.removeChild(zero);
      document.body.removeChild(target);
      this.loaded = true;
      this.onload();
    }
    // font has not finished loading - wait 50ms and try again
    else {
      console.log("timing out");
      setTimeout(function () {
        font.validate(target, zero, mark, font, timeout === false ? false : timeout-50);
      },
      1000);
    }
  };

  /**
   * This gets called when the file is done downloading.
   */
  Font.prototype.ondownloaded = function () {
    var instance = this;

    // decimal to character
    var chr = function (val) {
      return String.fromCharCode(val);
    };

    // decimal to ushort
    var chr16 = function (val) {
      if (val < 256) { return chr(0) + chr(val); }
      var b1 = val >> 8;
      var b2 = val & 0xFF;
      return chr(b1) + chr(b2);
    };

    // decimal to hexadecimal
    // See http://phpjs.org/functions/dechex:382
    var dechex =  function (val) {
      if (val < 0) { val = 0xFFFFFFFF + val + 1; }
      return parseInt(val, 10).toString(16);
    };

    // unsigned short to decimal
    var ushort = function (b1, b2) {
      return 256 * b1 + b2;
    };

    // signed short to decimal
    var fword = function (b1, b2) {
      var negative = b1 >> 7 === 1, val;
      b1 = b1 & 0x7F;
      val = 256 * b1 + b2;
      // positive numbers are already done
      if (!negative) { return val; }
      // negative numbers need the two's complement treatment
      return val - 0x8000;
    };

    // unsigned long to decimal
    var ulong = function (b1, b2, b3, b4) {
      return 16777216 * b1 + 65536 * b2 + 256 * b3 + b4;
    };

    // unified error handling
    var error = function (msg) {
      instance.onerror(msg);
    };

    // we know about TTF (0x00010000) and CFF ('OTTO') fonts
    var ttf = chr(0) + chr(1) + chr(0) + chr(0);
    var cff = "OTTO";

    // so what kind of font is this?
    var data = this.data;
    var version = chr(data[0]) + chr(data[1]) + chr(data[2]) + chr(data[3]);
    var isTTF = (version === ttf);
    var isCFF = (isTTF ? false : version === cff);
    if (isTTF) { this.format = "truetype"; }
    else if (isCFF) { this.format = "opentype"; }
    // terminal error: stop running code
    else { error("Error: file at " + this.url + " cannot be interpreted as OpenType font."); return; }

    // ================================================================
    // if we get here, this is a legal font. Extract some font metrics,
    // and then wait for the font to be available for on-page styling.
    // ================================================================

    // first, we parse the SFNT header data
    var numTables = ushort(data[4], data[5]),
        tagStart = 12, ptr, end = tagStart + 16 * numTables, tags = {},
        tag;
    for (ptr = tagStart; ptr < end; ptr += 16) {
      tag = chr(data[ptr]) + chr(data[ptr + 1]) + chr(data[ptr + 2]) + chr(data[ptr + 3]);
      tags[tag] = {
        name: tag,
        checksum: ulong(data[ptr+4], data[ptr+5], data[ptr+6], data[ptr+7]),
        offset:   ulong(data[ptr+8], data[ptr+9], data[ptr+10], data[ptr+11]),
        length:   ulong(data[ptr+12], data[ptr+13], data[ptr+14], data[ptr+15])
      };
    }

    // first we define a quick error shortcut function:
    var checkTableError = function (tag) {
      if (!tags[tag]) {
        error("Error: font is missing the required OpenType '" + tag + "' table.");
        // return false, so that the result of this function can be used to stop running code
        return false;
      }
      return tag;
    };

    // Then we access the HEAD table for the "font units per EM" value.
    tag = checkTableError("head");
    if (tag === false) { return; }
    ptr = tags[tag].offset;
    tags[tag].version = "" + data[ptr] + data[ptr+1] + data[ptr+2] + data[ptr+3];
    var unitsPerEm = ushort(data[ptr+18], data[ptr+19]);
    this.metrics.quadsize = unitsPerEm;

    // We follow up by checking the HHEA table for ascent, descent, and leading values.
    tag = checkTableError("hhea");
    if (tag===false) { return; }
    ptr = tags[tag].offset;
    tags[tag].version = "" + data[ptr] + data[ptr+1] + data[ptr+2] + data[ptr+3];
    this.metrics.ascent  = fword(data[ptr+4], data[ptr+5]) / unitsPerEm;
    this.metrics.descent = fword(data[ptr+6], data[ptr+7]) / unitsPerEm;
    this.metrics.leading = fword(data[ptr+8], data[ptr+9]) / unitsPerEm;

    // And then finally we check the OS/2 table for the font-indicated weight class.
    tag = checkTableError("OS/2");
    if (tag===false) { return; }
    ptr = tags[tag].offset;
    tags[tag].version = "" + data[ptr] + data[ptr+1];
    this.metrics.weightclass = ushort(data[ptr+4], data[ptr+5]);

    // ==================================================================
    // Then the mechanism for determining whether the font is not
    // just done downloading, but also fully parsed and ready for
    // use on the page for typesetting: we pick a letter that we know
    // is supported by the font, and generate a font that implements
    // only that letter, as a zero-width glyph. We can then test
    // whether the font is available by checking whether a paragraph
    // consisting of just that letter, styled with "desiredfont, zwfont"
    // has zero width, or a real width. As long as it's zero width, the
    // font has not finished loading yet.
    // ==================================================================

    // To find a letter, we must consult the character map ("cmap") table
    tag = checkTableError("cmap");
    if (tag===false) { return; }
    ptr = tags[tag].offset;
    tags[tag].version = "" + data[ptr] + data[ptr+1];
    numTables = ushort(data[ptr+2], data[ptr+3]);

    // For the moment, we only look for windows/unicode records, with
    // a cmap subtable format 4 because OTS (the sanitiser used in
    // Chrome and Firefox) does not actually support anything else
    // at the moment.
    //
    // When http://code.google.com/p/chromium/issues/detail?id=110175
    // is resolved, remember to stab me to add support for the other
    // maps, too.
    //
    var encodingRecord, rptr, platformID, encodingID, offset, cmap314 = false;
    for (var encodingRecord = 0; encodingRecord < numTables; encodingRecord++) {
      rptr = ptr + 4 + encodingRecord * 8;
      platformID = ushort(data[rptr], data[rptr+1]);
      encodingID = ushort(data[rptr+2], data[rptr+3]);
      offset     = ulong(data[rptr+4], data[rptr+5], data[rptr+6], data[rptr+7]);
      if (platformID === 3 && encodingID === 1) { cmap314 = offset; }
    }

    // This is our fallback font - a minimal font that implements
    // the letter "A". We can transform this font to implementing
    // any character between 0x0000 and 0xFFFF by altering a
    // handful of letters.
    var printChar = "A";

    // Now, if we found a format 4 {windows/unicode} cmap subtable,
    // we can find a suitable glyph and modify the 'base64' content.
    if (cmap314 !== false) {

      ptr += cmap314;
      version = ushort(data[ptr], data[ptr+1]);
      if (version === 4) {
        // First find the number of segments in this map
        var segCount = ushort(data[ptr+6], data[ptr+7]) / 2;

        // Then, find the segment end characters. We'll use
        // whichever of those isn't a whitespace character
        // for our verification font, which we check based
        // on the list of Unicode 6.0 whitespace code points:
        var printable = function (chr) {
          return [// ascii range:
                  0x0009,0x000A,0x000B,0x000C,0x000D,0x0020,
                  // ansi range:
                  0x007F,0x0080,0x0081,0x008D,0x008E,0x008F,0x0090,
                  0x0095,0x009D,0x009E,0x00A0,
                  // general punctuation :
                  0x2000,0x2001,0x2002,0x2003,0x2004,0x2005,0x2006,
                  0x2007,0x2008,0x2009,0x200A,0x200B,0x200C,0x200D,
                  0x200E,0x200F,0x2028,0x2029,0x202A,0x202B,0x202B,
                  0x202C,0x202D,0x202E,0x202F,0x205F,0x2060,0x2061,
                  0x2062,0x2063,0x2064,0x3000].indexOf(chr) === -1; }

        // Loop through the segments in search of a usable character code:
        var i = ptr + 14, e = ptr + 14 + 2 * segCount, endChar = false;
        for (; i < e; i += 2) {
          endChar = ushort(data[i], data[i+1]);
          if (printable(endChar)) { break; }
          endChar = false;
        }

        if (endChar != false) {
          // We now have a printable character to validate with!
          // We need to make sure to encode the correct "idDelta"
          // value for this character, because our "glyph" will
          // always be at index 1 (index 0 is reserved for .notdef).
          // As such, we need to set up a delta value such that:
          //
          //   [character code] + [delta value] == 1
          //
          printChar = String.fromCharCode(endChar);

          var delta = (-(endChar - 1) + 65536) % 65536;

          // Now we need to substitute the values in our
          // base64 font template. The CMAP modification
          // consists of generating a new base64 string
          // for the bit that indicates the encoded char.
          // In our 'A'-encoding font, this is:
          //
          //   0x00 0x41 0xFF 0xFF 0x00 0x00
          //   0x00 0x41 0xFF 0xFF 0xFF 0xC0
          //
          // which is the 20 letter base64 string at [380]:
          //
          //   AABB//8AAABB////wAAB
          //
          // We replace this with our new character:
          //
          //   [hexchar] 0xFF 0xFF 0x00 0x00
          //   [hexchar] 0xFF 0xFF [ delta ]
          //
          // Note: in order to do so properly, we need to
          // make sure that the bytes are base64 aligned, so
          // we have to add a leading 0x00:
          var newcode = chr(0) +                         // base64 padding byte
                        chr16(endChar) + chr16(0xFFFF) + // "endCount" array
                        chr16(0) +                       // cmap required padding
                        chr16(endChar) + chr16(0xFFFF) + // "startCount" array
                        chr16(delta) +                   // delta value
                        chr16(1);                        // delta terminator
          var newhex = btoa(newcode);

          // And now we replace the text in 'base64' at
          // position 380 with this new base64 string:
          this.base64 = this.base64.substring(0, 380) + newhex +
                         this.base64.substring(380 + newhex.length);
        }
      }
    }

    this.bootstrapValidation(printChar, false);
  }

  Font.prototype.bootstrapValidation = function (printChar, timeout) {
    // Create a stylesheet for using the zero-width font:
    var tfName = this.fontFamily+" testfont";
    var zerowidth = document.createElement("style");
    zerowidth.setAttribute("type", "text/css");
    zerowidth.innerHTML =  "@font-face {\n" +
                          "  font-family: '" + tfName + "';\n" +
                          "  src: url('data:application/x-font-ttf;base64," + this.base64 + "')\n" +
                          "       format('truetype');}";
    document.head.appendChild(zerowidth);

    // Create a validation stylesheet for the requested font, if it's a remote font:
    var realfont = false;
    if (!this.systemfont) {
      realfont = this.toStyleNode();
      document.head.appendChild(realfont);
    }

    // Create a validation paragraph, consisting of the zero-width character
    var para = document.createElement("p");
    para.style.cssText = "position: absolute; top: 0; left: 0; opacity: 0;";
    para.style.fontFamily = "'" + this.fontFamily + "', '" + tfName + "'";
    para.innerHTML = printChar + printChar + printChar + printChar + printChar +
                     printChar + printChar + printChar + printChar + printChar;
    document.body.appendChild(para);

    // Quasi-error: if there is no getComputedStyle, claim loading is done.
    if (typeof getComputedStyle === "undefined") {
      this.onload();
      error("Error: getComputedStyle is not supported by this browser.\n" +
            "Consequently, Font.onload() cannot be trusted."); }

    // If there is getComputedStyle, we do proper load completion verification.
    else {
      // If this is a remote font, we rely on the indicated quad size
      // for measurements. If it's a system font there will be no known
      // quad size, so we simply fix it at 1000 pixels.
      var quad = this.systemfont ? 1000 : this.metrics.quadsize;

      // Because we need to 'preload' a canvas with this
      // font, we have no idea how much surface area
      // we'll need for text measurements later on. So
      // be safe, we assign a surface that is quad? big,
      // and then when measureText is called, we'll
      // actually build a quick <span> to see how much
      // of that surface we don't need to look at.
      var canvas = document.createElement("canvas");
      canvas.width = quad;
      canvas.height = quad;
      this.canvas = canvas;

      // The reason we preload is because some browsers
      // will also take a few milliseconds to assign a font
      // to a Canvas2D context, so if measureText is called
      // later, without this preloaded context, there is no
      // time for JavaScript to "pause" long enough for the
      // context to properly load the font, and metrics may
      // be completely wrong. The solution is normally to
      // add in a setTimeout call, to give the browser a bit
      // of a breather, but then we can't do synchronous
      // data returns, and we need a callback just to get
      // string metrics, which is about as far from desired
      // as is possible.
      var context = canvas.getContext("2d");
      context.font = "1em '" + this.fontFamily + "'";
      context.fillStyle = "white";
      context.fillRect(-1, -1, quad+2, quad+2);
      context.fillStyle = "black";
      context.fillText("test text", 50, quad / 2);
      this.context = context;

      // ===================================================
      // Thanks to Opera and Firefox, we need to add in more
      // "you can do your thing, browser" moments. If we
      // call validate() as a straight function call, the
      // browser doesn't get the breathing space to perform
      // page styling. This is a bit mad, but until there's
      // a JS function for "make the browser update the page
      // RIGHT NOW", we're stuck with this.
      // ===================================================

      // We need to alias "this" because the keyword "this"
      // becomes the global context after the timeout.
      var local = this;
      var delayedValidate = function() {
        local.validate(para, zerowidth, realfont, local, timeout);
      };
      setTimeout(delayedValidate, 50);
    }
  };

  /**
   * We take a different path for System fonts, because
   * we cannot inspect the actual byte code.
   */
  Font.prototype.processSystemFont = function () {
    // Mark system font use-case
    this.systemfont = true;
    // There are font-declared metrics to work with.
    this.metrics = false;
    // However, we do need to check whether the font
    // is actually installed.
    this.bootstrapValidation("A", 1000);
  }

  /**
   * This gets called when font.src is set, (the binding
   * for which is at the end of this file).
   */
  Font.prototype.loadFont = function () {
    var font = this;

    // System font?
    if(this.url.indexOf(".") === -1) {
      setTimeout(function(){
        font.processSystemFont();
      }, 10);
      return;
    }

    // Remote font.
    var xhr = new XMLHttpRequest();
    xhr.open('GET', font.url, true);
    xhr.responseType = "arraybuffer";
    xhr.onload = function (evt) {
      var arrayBuffer = xhr.response;
      if (arrayBuffer) {
        font.data = new Uint8Array(arrayBuffer);
        font.ondownloaded();
      } else {
        font.onerror("Error downloading font resource from "+font.url);
      }
    };
    xhr.onerror = function (evt) {
      font.onerror("Error downloading font resource from "+font.url);
    };
    xhr.send(null);
  };

  // The stylenode can be added to the document head
  // to make the font available for on-page styling,
  // but it should be requested with .toStyleNode()
  Font.prototype.styleNode = false;

  /**
   * Get the DOM node associated with this Font
   * object, for page-injection.
   */
  Font.prototype.toStyleNode = function () {
    // If we already built it, pass that reference.
    if (this.styleNode) { return this.styleNode; }
    // If not, build a style element
    this.styleNode = document.createElement("style");
    this.styleNode.type = "text/css";
    var styletext = "@font-face {\n";
       styletext += "  font-family: '" + this.fontFamily + "';\n";
       styletext += "  src: url('" + this.url + "') format('" + this.format + "');\n";
       styletext += "}";
    this.styleNode.innerHTML = styletext;
    return this.styleNode;
  }

  /**
   * Measure a specific string of text, given this font.
   * If the text is too wide for our preallocated canvas,
   * it will be chopped up and the segments measured
   * separately.
   */
  Font.prototype.measureText = function (textString, fontSize) {
    if (!this.loaded) {
      this.onerror("measureText() was called while the font was not yet loaded");
      return false;
    }

    // Set up the right font size.
    this.context.font = fontSize + "px '"+this.fontFamily+"'";

    // Get the initial string width through our preloaded Canvas2D context
    var metrics = this.context.measureText(textString);

    // Assign the remaining default values, because the
    // TextMetrics object is horribly deficient.
    metrics.fontsize = fontSize;
    metrics.ascent  = 0;
    metrics.descent = 0;
    metrics.bounds  = { minx: 0,
                        maxx: metrics.width,
                        miny: 0,
                        maxy: 0 };
    metrics.height = 0;

    // Does the text fit on the canvas? If not, we have to
    // chop it up and measure each segment separately.
    var segments = [],
        minSegments = metrics.width / this.metrics.quadsize;
    if (minSegments <= 1) { segments.push(textString); }
    else {
      // TODO: add the chopping code here. For now this
      // code acts as placeholder
      segments.push(textString);
    }

    // run through all segments, updating the metrics as we go.
    var segmentLength = segments.length, i;
    for (i = 0; i < segmentLength; i++) {
      this.measureSegment(segments[i], fontSize, metrics);
    }
    return metrics;
  };

  /**
   * Measure a section of text, given this font, that is
   * guaranteed to fit on our preallocated canvas.
   */
  Font.prototype.measureSegment = function(textSegment, fontSize, metrics) {
    // Shortcut function for getting computed CSS values
    var getCSSValue = function (element, property) {
      return document.defaultView.getComputedStyle(element, null).getPropertyValue(property);
    };

    // We are going to be using you ALL over the place, little variable.
    var i;

    // For text leading values, we measure a multiline
    // text container as built by the browser.
    var leadDiv = document.createElement("div");
    leadDiv.style.position = "absolute";
    leadDiv.style.opacity = 0;
    leadDiv.style.font = fontSize + "px '" + this.fontFamily + "'";
    var numLines = 10;
    leadDiv.innerHTML = textSegment;
    for (i = 1; i < numLines; i++) {
      leadDiv.innerHTML += "<br/>" + textSegment;
    }
    document.body.appendChild(leadDiv);

    // First we guess at the leading value, using the standard TeX ratio.
    metrics.leading = 1.2 * fontSize;

    // We then try to get the real value based on how
    // the browser renders the text.
    var leadDivHeight = getCSSValue(leadDiv,"height");
    leadDivHeight = leadDivHeight.replace("px","");
    if (leadDivHeight >= fontSize * numLines) {
      metrics.leading = (leadDivHeight / numLines) | 0;
    }
    document.body.removeChild(leadDiv);

    // If we're not with a white-space-only string,
    // this is all we will be able to do.
    if (/^\s*$/.test(textSegment)) { return metrics; }

    // If we're not, let's try some more things.
    var canvas = this.canvas,
        ctx = this.context,
        quad = this.systemfont ? 1000 : this.metrics.quadsize,
        w = quad,
        h = quad,
        baseline = quad / 2,
        padding = 50,
        xpos = (quad - metrics.width) / 2;

    // SUPER IMPORTANT, HARDCORE NECESSARY STEP:
    // xpos may be a fractional number at this point, and
    // that will *complete* screw up line scanning, because
    // cropping a canvas on fractional coordiantes does
    // really funky edge interpolation. As such, we force
    // it to an integer.
    if (xpos !== (xpos | 0)) { xpos = xpos | 0; }

    // Set all canvas pixeldata values to 255, with all the content
    // data being 0. This lets us scan for data[i] != 255.
    ctx.fillStyle = "white";
    ctx.fillRect(-padding, -padding, w + 2 * padding, h + 2 * padding);
    // Then render the text centered on the canvas surface.
    ctx.fillStyle = "black";
    ctx.fillText(textSegment, xpos, baseline);

    // Rather than getting all four million+ subpixels, we
    // instead get a (much smaller) subset that we know
    // contains our text. Canvas pixel data is w*4 by h*4,
    // because {R,G,B,A} is stored as separate channels in
    // the array. Hence the factor 4.
    var scanwidth = (metrics.width + padding) | 0,
        scanheight = 4 * fontSize,
        x_offset = xpos - padding / 2,
        y_offset = baseline-scanheight / 2,
        pixelData = ctx.getImageData(x_offset, y_offset, scanwidth, scanheight).data;

    // Set up our scanline variables
    var i = 0,
        j = 0,
        w4 = scanwidth * 4,
        len = pixelData.length,
        mid = scanheight / 2;

    // Scan 1: find the ascent using a normal, forward scan
    while (++i < len && pixelData[i] === 255) {}
    var ascent = (i / w4) | 0;

    // Scan 2: find the descent using a reverse scan
    i = len - 1;
    while (--i > 0 && pixelData[i] === 255) {}
    var descent = (i / w4) | 0;

    // Scan 3: find the min-x value, using a forward column scan
    for (i = 0, j = 0; j < scanwidth && pixelData[i] === 255;) {
      i += w4;
      if (i >= len) { j++; i = (i - len) + 4; }}
    var minx = j;

    // Scan 3: find the max-x value, using a reverse column scan
    var step = 1;
    for (i = len-3, j = 0; j<scanwidth && pixelData[i] === 255; ) {
      i -= w4;
      if (i < 0) { j++; i = (len - 3) - (step++) * 4; }}
    var maxx = scanwidth - j;

    // We have all our metrics now, so fill in the
    // metrics object and return it to the user.
    metrics.ascent  = (mid - ascent);
    metrics.descent = (descent - mid);
    metrics.bounds  = { minx: minx - (padding / 2),
                        maxx: maxx - (padding / 2),
                        miny: -metrics.descent,
                        maxy: metrics.ascent };
    metrics.height = 1 + (descent - ascent);
    return metrics;
  };

  /**
   * we want Font to do the same thing Image does when
   * we set the "src" property value, so we use the
   * Object.defineProperty function to bind a setter
   * that does more than just bind values.
   */
  Object.defineProperty(Font.prototype, "src", { set: function(url) { this.url=url; this.loadFont(); }});

  /**
   * Bind to global scope
   */
  if(typeof define !== "undefined") {
    define(function() {
      return Font;
    });
  } else {
    window.Font = Font;
  }
}(window));
;
})();
Main.tileSize = [0,0];
Main.screenRatio = [1,1];
Main.DEBUGMODE = true;
Main.GAMESTOPPED = false;
Main.FIGHTMODE = false;
haxe.ds.ObjectMap.count = 0;
managers.HudManager.mode = "none";
managers.InitManager.CONFIG_PATH = "assets/config/";
managers.InitManager.ASSETS_PATH = "assets/";
managers.MapManager.finder = new EasyStar.js();
managers.MouseManager.gamehover = new CustomEvent("gameHover");
managers.MouseManager.gameMouseUp = new CustomEvent("gameMouseUp");
managers.MouseManager.gameMouseDown = new CustomEvent("gameMouseDown");
managers.MouseManager.lockedMouseEvents = false;
managers.PoolManager.Pools = new haxe.ds.StringMap();
managers.StateManager.debugText = new PIXI.Text("",{ fill : "white", font : "18px Arial"});
managers.StateManager.loadingState = false;
managers.TimeManager.elapsedTime = 0;
managers.TimeManager.deltaTime = 0;
managers.TimeManager.FPS = 0;
objects.Options.data = { };
objects.State.FTUEStateBool = false;
objects.character.Player.selectedAction = "move";
tweenx909.EaseX.PI = 3.1415926535897932384626433832795;
tweenx909.EaseX.PI_H = 1.5707963267948966;
tweenx909.EaseX.overshoot = 1.70158;
tweenx909.EaseX.amplitude = 1;
tweenx909.EaseX.period = 0.0003;
tweenx909.rule.BoolRuleX.inputClass = Bool;
tweenx909.rule.ArrayRuleX.inputClass = Array;
tweenx909.rule.TimelineX.inputClass = tweenx909.rule.TimelineX;
tweenx909.rule.RgbX.inputClass = tweenx909.rule.RgbX;
tweenx909.rule.HsvX.inputClass = tweenx909.rule.HsvX;
tweenx909.rule.ArgbX.inputClass = tweenx909.rule.ArgbX;
tweenx909.rule.AhsvX.inputClass = tweenx909.rule.AhsvX;
tweenx909.rule.QuakeX.inputClass = tweenx909.rule.QuakeX;
tweenx909.TweenX._tweens = new Array();
tweenx909.TweenX._addedTweens = new Array();
tweenx909.TweenX.managerInited = false;
tweenx909.TweenX.DEFAULT_EASE = tweenx909.EaseX.linear;
tweenx909.TweenX.DEFAULT_TIME = 0.3;
tweenx909.TweenX.DEFAULT_DELAY = 0;
tweenx909.TweenX.DEFAULT_REPEAT = 1;
tweenx909.TweenX.DEFAULT_INTERVAL = 0;
tweenx909.TweenX.DEFAULT_YOYO = false;
tweenx909.TweenX.DEFAULT_ZIGZAG = false;
tweenx909.TweenX.DEFAULT_AUTO_PLAY = true;
tweenx909.TweenX.DEFAULT_AUTO_FROM = true;
tweenx909.TweenX.defaultEase = tweenx909.TweenX.DEFAULT_EASE;
tweenx909.TweenX.defaultTime = 0.3;
tweenx909.TweenX.defaultDelay = 0;
tweenx909.TweenX.defaultInterval = 0;
tweenx909.TweenX.defaultRepeat = 1;
tweenx909.TweenX.defaultYoyo = false;
tweenx909.TweenX.defaultZigZag = false;
tweenx909.TweenX.defaultAutoPlay = true;
tweenx909.TweenX.defaultAutoFrom = true;
tweenx909.TweenX._rules = [tweenx909.rule.BoolRuleX,tweenx909.rule.ArrayRuleX,tweenx909.rule.TimelineX,tweenx909.rule.RgbX,tweenx909.rule.HsvX,tweenx909.rule.ArgbX,tweenx909.rule.AhsvX,tweenx909.rule.QuakeX];
tweenx909.TweenX.topLevelTimeScale = 1;
tweenx909.TweenX._groupDefaults = false;
tweenx909.TweenX.updateMode = tweenx909.advanced.UpdateModeX.TIME(60);
tweenx909.TweenX._initLog = [];
tweenx909.TweenX.dictionary = new haxe.ds.ObjectMap();
tweenx909.TweenX._objCounter = 0;
tweenx909.TweenX._MIN = 1.4901161415892264e-008;
tweenx909.TweenX._DELAY = 1;
tweenx909.TweenX._FINISH = 8;
tweenx909.TweenX._FOOT = 4;
tweenx909.TweenX._HEAD = 2;
tweenx909.TweenX._INTERVAL = 5;
tweenx909.TweenX._PLAY = 0;
tweenx909.TweenX._REPEAT = 6;
tweenx909.TweenX._REST = 7;
tweenx909.TweenX._STOP = 9;
tweenx909.TweenX._UPDATE = 3;
tweenx909.TweenX.idCounter = 0;
utils.Id.numberIds = 0;
Main.main();
})();

//# sourceMappingURL=Gast.js.map