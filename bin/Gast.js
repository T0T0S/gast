(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.__name__ = true;
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
IntIterator.__name__ = true;
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
Lambda.__name__ = true;
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
	var font = new Font();
	font.onload = function() {
		window.requestAnimationFrame(managers.InitManager.getInstance);
	};
	font.fontFamily = "gastFont";
	font.src = "assets/fonts/CharlemagneStd-Bold.otf";
	this.renderer = PIXI.autoDetectRenderer(1280,720,{ });
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
Main.__name__ = true;
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
IMap.__name__ = true;
Math.__name__ = true;
var Reflect = function() { };
Reflect.__name__ = true;
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
var Std = function() { };
Std.__name__ = true;
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var haxe = {};
haxe.ds = {};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = true;
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
js.Boot.__name__ = true;
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
var managers = {};
managers.CharacterManager = function() {
	this.positions = [];
	this.managedCharacters = new haxe.ds.StringMap();
};
managers.CharacterManager.__name__ = true;
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
managers.DrawManager.__name__ = true;
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
};
managers.HudManager.__name__ = true;
managers.HudManager.generateFightHud = function() {
	managers.HudManager.mode = "fight";
	var rightHud = new PIXI.Sprite(PIXI.Texture.fromImage("hud_bottom_right.png"));
	rightHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
	rightHud.anchor.set(1,1);
	rightHud.x = Main.getInstance().renderer.width;
	rightHud.y = Main.getInstance().renderer.height;
	rightHud.name = "right_bottom";
	var attackHud = new PIXI.Sprite(PIXI.Texture.fromImage("hud_bottom_center.png"));
	attackHud.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
	attackHud.anchor.set(1,1);
	attackHud.x = rightHud.x - (rightHud.width + 20);
	attackHud.y = Main.getInstance().renderer.height;
	var moveButton = new objects.Button("button_move");
	moveButton.anchor.set(0.5,0.5);
	moveButton.x = -695;
	moveButton.y = -73;
	moveButton.onUp(function() {
		if(objects.character.Player.selectedAction == null) objects.character.Player.selectedAction = "move"; else objects.character.Player.selectedAction = null;
	});
	var attackButton = new objects.Button("button_attack");
	attackButton.anchor.set(0.5,0.5);
	attackButton.x = -570;
	attackButton.y = -73;
	attackButton.onUp(function() {
		if(objects.character.Player.selectedAction == null) objects.character.Player.selectedAction = "attack"; else objects.character.Player.selectedAction = null;
	});
	var tickTimer = new PIXI.Sprite(PIXI.Texture.fromImage("timerFill.png"));
	tickTimer.anchor.set(0.5,0.5);
	tickTimer.x = -(tickTimer.width * 0.5 + 50);
	tickTimer.y = -(tickTimer.height * 0.5 + 48);
	tickTimer.name = "tickTimer";
	var APText = new PIXI.Text("",{ fill : "white", font : "35px gastFont", stroke : "black", strokeThickness : 5});
	APText.anchor.set(0.5,0.5);
	APText.name = "HP";
	APText.x = -342;
	APText.y = -65;
	var HPText = new PIXI.Text("",{ fill : "white", font : "35px gastFont", stroke : "black", strokeThickness : 5});
	HPText.anchor.set(0.5,0.5);
	HPText.name = "AP";
	HPText.x = -342;
	HPText.y = -175;
	managers.DrawManager.addToDisplay(attackHud,Main.getInstance().hudCont);
	managers.DrawManager.addToDisplay(moveButton,attackHud);
	managers.DrawManager.addToDisplay(attackButton,attackHud);
	managers.DrawManager.addToDisplay(rightHud,Main.getInstance().hudCont);
	managers.DrawManager.addToDisplay(tickTimer,rightHud);
	managers.DrawManager.addToDisplay(APText,rightHud);
	managers.DrawManager.addToDisplay(HPText,rightHud);
};
managers.HudManager.getInstance = function() {
	if(managers.HudManager.instance == null) managers.HudManager.instance = new managers.HudManager();
	return managers.HudManager.instance;
};
managers.HudManager.prototype = {
	switchState: function() {
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
	lConfig.add("hero","assets/animations/" + "hero.json");
	lConfig.add("testMapZig","assets/" + "maps/testMapZig.json");
	lConfig.once("complete",$bind(this,this.LoadedJson));
	lConfig.load();
};
managers.InitManager.__name__ = true;
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
managers.MapManager.__name__ = true;
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
managers.MouseManager.__name__ = true;
managers.MouseManager.getSquareTileAround = function(posClicked,size) {
	if(size == null) size = 1;
	if(size == 0) return [posClicked];
	var ArrayOfPos = [];
	var tileSize = managers.InitManager.data.config.tileSize;
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
	var tileSize = managers.InitManager.data.config.tileSize;
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
managers.StateManager = function() {
	this.debugActiveState = new PIXI.Text("Init",{ fill : "white", font : "30px gastFont"});
	this.firstLoop = true;
	this.skipNextLateUpdate = false;
	this.activeState = "Intro";
	this.statesArray = new haxe.ds.StringMap();
	this.addState(new states.IntroState());
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
managers.StateManager.__name__ = true;
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
	this.tickInterval = 120;
	this.frameElapsed = 0;
	this.timeNow = new Date().getTime();
};
managers.TimeManager.__name__ = true;
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
	this.name = newName;
	this.loop = newData.loop;
	this.data = newData.frameData;
	this.fps = newData.fps;
	this.callback = endCallback;
};
objects.Animation.__name__ = true;
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
	this.on("mousedown",$bind(this,this.p_onDown));
	this.on("mouseup",$bind(this,this.p_onUp));
	this.on("mousemove",$bind(this,this.p_onHover));
	var shadow = new PIXI.filters.DropShadowFilter();
	shadow.color = 0;
	shadow.distance = 5;
	shadow.alpha = 0.55;
	shadow.angle = 45;
	shadow.blur = 5;
	this.filters = [shadow];
};
objects.Button.__name__ = true;
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
		this.isDown = true;
		this.setSpecialTexture("down");
		this.arrayCallbacks.down(e);
		e.stopPropagation();
	}
	,p_onUp: function(e) {
		this.isDown = false;
		this.setSpecialTexture("hover");
		this.arrayCallbacks.up(e);
		e.stopPropagation();
	}
	,p_onHover: function(e) {
		this.isAbove = this.mouseIsAbove(e);
		if(this.isAbove) {
			if(this.isDown) this.setSpecialTexture("down"); else this.setSpecialTexture("hover");
			this.arrayCallbacks.hover(e);
		} else if(this.currentFrame != 0) this.gotoAndStop(0);
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
objects.Camera.__name__ = true;
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
		if(!managers.MapManager.getInstance().activeMap.scrollable || this.targetToFollow != null) return;
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
		if(this.targetToFollow != null) {
			this.offset[0] = this.targetToFollow.x - this.size[0] * 0.5;
			this.offset[1] = this.targetToFollow.y - this.size[1] * 0.5;
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
		this.targetToFollow = target;
		this.clampedCam = !absolutePos;
	}
	,switchState: function() {
		this.setCameraPosition([0,0]);
		this.targetToFollow = null;
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
objects.GameMap.__name__ = true;
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
objects.OSmovieclip = function(textures,newCallback) {
	this.callback = function() {
	};
	PIXI.extras.MovieClip.call(this,textures);
	if(newCallback != null) this.callback = newCallback;
	this.onComplete = $bind(this,this.complete);
	this.loop = false;
	this.gotoAndPlay(0);
};
objects.OSmovieclip.__name__ = true;
objects.OSmovieclip.__super__ = PIXI.extras.MovieClip;
objects.OSmovieclip.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	complete: function() {
		this.callback();
		if(this.parent != null) this.parent.removeChild(this);
	}
	,__class__: objects.OSmovieclip
});
objects.State = function(newName) {
	this.loaderReady = 0;
	this.loadImage = new haxe.ds.StringMap();
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
objects.State.__name__ = true;
objects.State.prototype = {
	_StartLoading: function() {
		this.Preload();
		if(Lambda.count(this.loadJson) == 0) this.loaderReady += 1; else this.loaderReady += 0;
		if(Lambda.count(this.loadImage) == 0) this.loaderReady += 1; else this.loaderReady += 0;
		if(this.loaderReady == 2) {
			this.StateLoaded = true;
			this.Start();
			managers.StateManager.loadingState = false;
			return;
		}
		var jsonLoader = new PIXI.loaders.Loader();
		var assetLoader = new PIXI.loaders.Loader();
		var $it0 = this.loadJson.iterator();
		while( $it0.hasNext() ) {
			var i = $it0.next();
			jsonLoader.add(i,this.loadJson.get(i));
		}
		var $it1 = this.loadImage.iterator();
		while( $it1.hasNext() ) {
			var i1 = $it1.next();
			assetLoader.add(i1,this.loadImage.get(i1));
		}
		jsonLoader.once("complete",$bind(this,this._assetLoaded));
		assetLoader.once("complete",$bind(this,this._assetLoaded));
		assetLoader.load($bind(this,this._onAssetLoadProgress));
		jsonLoader.load();
	}
	,_onAssetLoadProgress: function(loader,resource) {
		this.AssetLoaded(loader,resource);
	}
	,_assetLoaded: function(loader) {
		++this.loaderReady;
		if(this.loaderReady == 2) {
			this.AllAssetsLoaded(loader);
			this.StateLoaded = true;
			this.Start();
			managers.StateManager.loadingState = false;
		}
	}
	,Preload: function() {
	}
	,AssetLoaded: function(loader,resource) {
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
objects.Tile.__name__ = true;
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
objects.character = {};
objects.character.Character = function(newName) {
	this.lastTickRegistered = 0;
	this.depth = 0;
	this.z = 0;
	this.animations = new haxe.ds.StringMap();
	this.refreshSpeed = 1;
	this.pathIndex = 1;
	this.activePath = [];
	this.stats = { health : 100, strength : 10, endurance : 10, regeneration : 10, moveSpeed : 2.5, precision : 10, luck : 10, AP : 10, MaxAP : 10};
	this.directionFacing = 0;
	this.tilePos = [0,0];
	this.charaName = newName;
	this.config = managers.InitManager.data[newName];
	PIXI.extras.MovieClip.call(this,this.generateTextures(this.charaName));
	this.generateAnimations();
	this.loop = true;
	this.anchor.set(0.5,1);
	managers.CharacterManager.getInstance().addCharacter(this);
};
objects.character.Character.__name__ = true;
objects.character.Character.__super__ = PIXI.extras.MovieClip;
objects.character.Character.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	generateTextures: function(newName) {
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
		this.stats.health -= amount;
		if(this.stats.health <= 0) {
			this.stats.health = 0;
			this.kill();
		}
	}
	,_selfUpdate: function() {
		this.manageAnim();
		this.managePathFinding();
		this.customUpdate();
	}
	,manageAnim: function() {
		if(this.activeAnimation == null) return;
		if(this.currentFrame - this.activeAnimation.getLastIndex() >= this.activeAnimation.getFrames(this.directionFacing).length - 1) {
			if(!this.activeAnimation.loop) {
				this.stop();
				this.activeAnimation.endAction();
			} else if(this.activeAnimation.getFrames(this.directionFacing).length == 1) this.gotoAndStop(this.activeAnimation.getFrames(this.directionFacing)[0]); else this.gotoAndPlay(this.activeAnimation.getFrames(this.directionFacing)[0]);
		}
	}
	,managePathFinding: function() {
		if(this.activePath.length != 0 && this.stats.AP > 0) {
			if(this.activePathPoint == null) this.getNextPathPoint();
			if(this.tilePos[0] != this.activePath[this.activePath.length - 1].x || this.tilePos[1] != this.activePath[this.activePath.length - 1].y) {
				var arrayPos = [this.activePathPoint.x,this.activePathPoint.y];
				this.setAbsolutePosition(this.x + Math.cos(utils.Misc.angleBetweenTiles(this.tilePos,arrayPos)) * this.stats.moveSpeed,this.y - Math.sin(utils.Misc.angleBetweenTiles(this.tilePos,arrayPos)) * this.stats.moveSpeed);
				if(utils.Misc.getDistance(this.x,this.y,utils.Misc.convertToAbsolutePosition(arrayPos)[0],utils.Misc.convertToAbsolutePosition(arrayPos)[1] + Main.tileSize[1] * 0.5) < this.stats.moveSpeed) {
					this.setTilePosition(arrayPos);
					this.pathIndex++;
					this.useAp(1);
					if(this.pathIndex <= this.activePath.length - 1) this.getNextPathPoint(); else {
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
	,customUpdate: function() {
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
	,launchAttack: function(targetPosition) {
		if(managers.CharacterManager.getInstance().findCharacterAtTilePos(targetPosition)) managers.CharacterManager.getInstance().findCharacterAtTilePos(targetPosition).damage(this.stats.strength);
	}
	,getPathFindingPoint: function() {
		if(this.activePathPoint != null) return [this.activePathPoint.x,this.activePathPoint.y];
		return this.tilePos;
	}
	,newTick: function(tickNumber) {
		if(this.stats.AP < this.stats.MaxAP) this.stats.AP += tickNumber - this.lastTickRegistered;
		this.lastTickRegistered = tickNumber;
	}
	,useAp: function(amount) {
		this.stats.AP -= amount;
	}
	,Destroy: function() {
		managers.CharacterManager.getInstance().removeCharacter(this);
		managers.DrawManager.removeFromDisplay(this);
		this.destroy();
	}
	,__class__: objects.character.Character
});
objects.character.Player = function(newName) {
	this.movementTile = [];
	objects.character.Character.call(this,newName);
	Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("HP").text = this.stats.health;
	Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = this.stats.AP;
	var _g1 = 0;
	var _g = this.stats.MaxAP + 1;
	while(_g1 < _g) {
		var i = _g1++;
		this.movementTile.push(new objects.Tile(PIXI.Texture.fromImage("tile.png")));
		this.movementTile[i].visible = false;
		this.movementTile[i].tint = 65280;
	}
	this.targetTile = new objects.Tile(PIXI.Texture.fromImage("tile.png"));
	this.targetTile.visible = false;
	Main.getInstance().tileCont.on("mousemove",$bind(this,this.mouseHover));
	Main.getInstance().tileCont.on("mouseup",$bind(this,this.mapClick));
	this.APFlash = new objects.OSmovieclip([PIXI.Texture.fromFrame("y_explo_0"),PIXI.Texture.fromFrame("y_explo_1"),PIXI.Texture.fromFrame("y_explo_2"),PIXI.Texture.fromFrame("y_explo_3"),PIXI.Texture.fromFrame("y_explo_4"),PIXI.Texture.fromFrame("y_explo_5"),PIXI.Texture.fromFrame("y_explo_6")]);
	this.APFlash.anchor.set(0.5,0.5);
	this.APFlash.animationSpeed = 0.5;
};
objects.character.Player.__name__ = true;
objects.character.Player.__super__ = objects.character.Character;
objects.character.Player.prototype = $extend(objects.character.Character.prototype,{
	mapClick: function(e) {
		var tilePos = utils.Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x,e.data.getLocalPosition(e.target).y,true);
		if(objects.character.Player.selectedAction == "move") {
			if(!objects.Camera.getInstance().isDragged) this.findPathTo(tilePos,true); else if(objects.character.Player.selectedAction == "attack") this.launchAttack(tilePos);
		}
		this.hideHoverTile();
		this.hidePathMovement();
		objects.character.Player.selectedAction = null;
	}
	,mouseHover: function(e) {
		var tilePos = utils.Misc.convertToGridPosition(e.data.getLocalPosition(e.target).x,e.data.getLocalPosition(e.target).y,true);
		if(objects.character.Player.selectedAction == "move") this.showPathMovement(this.findPathTo(tilePos)); else if(objects.character.Player.selectedAction == "attack") this.showHoverTile(tilePos,16711680);
		utils.Debug.log("" + Std.string(tilePos));
	}
	,newTick: function(tickNumber) {
		objects.character.Character.prototype.newTick.call(this,tickNumber);
		Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = this.stats.AP;
		if(this.APFlash.parent == null) {
			managers.DrawManager.addToDisplay(this.APFlash,Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP"));
			this.APFlash.scale.set(2 * (1 / this.APFlash.parent.parent.scale.x),2 * (1 / this.APFlash.parent.parent.scale.y));
		}
		this.APFlash.gotoAndPlay(0);
	}
	,damage: function(amount) {
		objects.character.Character.prototype.damage.call(this,amount);
		Main.getInstance().hudCont.getChildByName("HP").text = this.stats.health;
	}
	,showPathMovement: function(path) {
		this.hidePathMovement();
		path.shift();
		if(path.length == 0 || path.length > this.stats.AP) return;
		var j = 0;
		var $it0 = HxOverrides.iter(path);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			this.movementTile[j].visible = true;
			this.movementTile[j].setTilePosition([i.x,i.y]);
			if(this.movementTile[j].parent == null) {
				if(this.parent != null) managers.DrawManager.addToDisplay(this.movementTile[j],this.parent,0.5);
			}
			j++;
		}
	}
	,hidePathMovement: function() {
		var $it0 = HxOverrides.iter(this.movementTile);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			i.visible = false;
		}
	}
	,showHoverTile: function(tilePos,newTint) {
		if(this.targetTile.parent == null) managers.DrawManager.addToDisplay(this.targetTile,managers.MapManager.getInstance().activeMap.mapContainer,0.5);
		this.targetTile.setTilePosition(tilePos);
		this.targetTile.visible = true;
		if(newTint != null) this.targetTile.tint = newTint; else this.targetTile.tint = null;
	}
	,hideHoverTile: function(remove) {
		if(remove == null) remove = false;
		this.targetTile.visible = false;
		if(remove) managers.DrawManager.removeFromDisplay(this.targetTile);
	}
	,useAp: function(amount) {
		objects.character.Character.prototype.useAp.call(this,amount);
		Main.getInstance().hudCont.getChildByName("right_bottom").getChildByName("AP").text = this.stats.AP;
	}
	,__class__: objects.character.Player
});
var states = {};
states.DebugState = function() {
	objects.State.call(this,"Debug");
};
states.DebugState.__name__ = true;
states.DebugState.__super__ = objects.State;
states.DebugState.prototype = $extend(objects.State.prototype,{
	Preload: function() {
	}
	,Start: function() {
		Main.FIGHTMODE = true;
		managers.HudManager.generateFightHud();
		managers.MapManager.getInstance().generateMapDisplay("testMapZig",true);
		this.hero = new objects.character.Player("hero");
		this.hero.setTilePosition([13,30]);
		this.hero.scale.set(0.4,0.4);
		managers.DrawManager.addToDisplay(this.hero,managers.MapManager.getInstance().activeMap.mapContainer,1);
		objects.Camera.getInstance().setFollowTarget(this.hero);
		var camShader = new PIXI.Sprite(PIXI.Texture.fromImage("camShader.png"));
		camShader.scale.set(Main.screenRatio[0],Main.screenRatio[1]);
		managers.DrawManager.addToDisplay(camShader,Main.getInstance().effectCont);
	}
	,Update: function() {
	}
	,__class__: states.DebugState
});
states.IntroState = function() {
	this.loopCounter = 0;
	this.loadingFill = new PIXI.Graphics();
	this.loadingRecangle = new PIXI.Graphics();
	objects.State.call(this,"Intro");
	this.LoadingText.text = "Loading asset: 0%";
	this.LoadingText.x = Main.getInstance().renderer.width * 0.5;
	this.LoadingText.y = Main.getInstance().renderer.height * 0.6;
	this.LoadingText.anchor.set(0.5,0.5);
	this.loadingRecangle.lineStyle(3,16777215);
	this.loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35,Main.getInstance().renderer.height * 0.7,Main.getInstance().renderer.width * 0.25,50);
	this.loadingFill.lineStyle(3,11184810);
};
states.IntroState.__name__ = true;
states.IntroState.__super__ = objects.State;
states.IntroState.prototype = $extend(objects.State.prototype,{
	Preload: function() {
		this.loadJson.set("buttonAttack","assets/spriteSheets/buttonAttack.json");
		this.loadJson.set("buttonMove","assets/spriteSheets/buttonMove.json");
		this.loadJson.set("hud_bottom","assets/spriteSheets/hud_bottom.json");
		this.loadJson.set("tileSh2","assets/spriteSheets/loadSpriteSheet.json");
		this.loadJson.set("buttons","assets/spriteSheets/buttonSpriteSheet.json");
		this.loadJson.set("hero","assets/spriteSheets/heroSpriteSheet.json");
		this.loadJson.set("explosion","assets/spriteSheets/testExplosion.json");
		this.loadJson.set("camShader","assets/effects/camShade.json");
		Main.getInstance().hudCont.addChild(this.loadingRecangle);
		Main.getInstance().hudCont.addChild(this.loadingFill);
		this.LoadingText.text = "Loading asset: 0%";
		Main.getInstance().hudCont.addChild(this.LoadingText);
	}
	,Start: function() {
		managers.StateManager.getInstance().switchToState("Menu");
	}
	,Update: function() {
	}
	,AssetLoaded: function(loader,resource) {
		this.LoadingText.text = "Loading asset: " + loader.progress + "%";
		this.loadingRecangle.clear();
		this.loadingRecangle.lineStyle(4,16777215);
		this.loadingRecangle.drawRect(Main.getInstance().renderer.width * 0.35,Main.getInstance().renderer.height * 0.7,Main.getInstance().renderer.width * 0.25,50);
		this.loadingFill.clear();
		this.loadingFill.beginFill(11184810);
		this.loadingFill.drawRect(Main.getInstance().renderer.width * 0.35 + 3,Main.getInstance().renderer.height * 0.7 + 3,100 / loader.progress * (Main.getInstance().renderer.width * 0.25 - 4),46);
		this.loadingFill.endFill();
	}
	,switchState: function() {
		this.loopCounter = null;
	}
	,__class__: states.IntroState
});
states.MenuState = function() {
	objects.State.call(this,"Menu");
};
states.MenuState.__name__ = true;
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
var utils = {};
utils.Debug = function() { };
utils.Debug.__name__ = true;
utils.Debug.log = function(message,color) {
	managers.StateManager.debugText.text = message;
};
utils.DeviceCapabilities = function() { };
utils.DeviceCapabilities.__name__ = true;
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
utils.Id.__name__ = true;
utils.Id.newId = function() {
	var stringToReturn = "";
	stringToReturn += utils.Id.numberIds++;
	return stringToReturn;
};
utils.Misc = function() { };
utils.Misc.__name__ = true;
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
	var configTileSize = Main.tileSize;
	var returnPosition = [];
	returnPosition[0] = tilePosition[0] * configTileSize[0];
	if(Math.abs(tilePosition[1] % 2) == 1) returnPosition[0] += configTileSize[0] * 0.5;
	returnPosition[1] = tilePosition[1] * configTileSize[1] * 0.5;
	return returnPosition;
};
utils.Misc.convertToGridPosition = function(absoluteX,absoluteY,withCamera) {
	if(withCamera == null) withCamera = true;
	var tileSize = managers.InitManager.data.config.tileSize;
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
utils.Misc.colliSquarePoint = function(obj,point,cameraAffected) {
	var offset;
	if(cameraAffected) offset = objects.Camera.getInstance().offset; else offset = [0,0];
	var target = obj.getGlobalPosition(null);
	if(target.x - obj.width * obj.anchor.x > point[0] + offset[0]) return false;
	if(target.y - obj.height * obj.anchor.y > point[1] + offset[1]) return false;
	if(target.x + obj.width - obj.width * obj.anchor.x < point[0] + offset[0]) return false;
	if(target.y + obj.height - obj.height * obj.anchor.y < point[1] + offset[1]) return false;
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
String.__name__ = true;
Array.__name__ = true;
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
managers.HudManager.mode = "none";
managers.InitManager.CONFIG_PATH = "assets/config/";
managers.InitManager.ASSETS_PATH = "assets/";
managers.MapManager.finder = new EasyStar.js();
managers.MouseManager.gamehover = new CustomEvent("gameHover");
managers.MouseManager.gameMouseUp = new CustomEvent("gameMouseUp");
managers.MouseManager.gameMouseDown = new CustomEvent("gameMouseDown");
managers.MouseManager.lockedMouseEvents = false;
managers.StateManager.debugText = new PIXI.Text("",{ fill : "white", font : "18px Arial"});
managers.StateManager.loadingState = false;
managers.TimeManager.elapsedTime = 0;
managers.TimeManager.deltaTime = 0;
managers.TimeManager.FPS = 0;
objects.State.FTUEStateBool = false;
utils.Id.numberIds = 0;
Main.main();
})();

//# sourceMappingURL=Gast.js.map