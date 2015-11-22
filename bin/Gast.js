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
	this.Init = managers.InitManager.getInstance();
	this.renderer = PIXI.autoDetectRenderer(1280,720);
	this.renderMask.beginFill();
	this.renderMask.drawRect(0,0,this.renderer.width,this.renderer.height * 0.5);
	this.renderMask.endFill();
	this.fullStage.addChild(this.renderMask);
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
		Main.mouseManager = managers.MouseManager.getInstance();
		Main.camera = objects.Camera.getInstance();
		Main.stateManager = managers.StateManager.getInstance();
		Main.mapManager = managers.MapManager.getInstance();
		window.addEventListener("resize",$bind(this,this.resize));
		window.requestAnimationFrame($bind(this,this.Update));
	}
	,resize: function(pEvent) {
	}
	,Update: function() {
		window.requestAnimationFrame($bind(this,this.Update));
		this.mouseUpdate();
		Main.stateManager.Update();
	}
	,Render: function() {
		Main.drawManager.isometricSort(this.tileCont);
		Main.drawManager.isometricSort(this.gameCont);
		this.renderer.render(this.fullStage);
	}
	,mouseUpdate: function() {
		Main.mouseManager.calledPerFrame = 0;
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
managers.DrawManager = function() {
};
managers.DrawManager.__name__ = true;
managers.DrawManager.Update = function() {
};
managers.DrawManager.addToDisplay = function(element,newParent,layer) {
	if(layer == null) layer = 0;
	element.Zindex = layer;
	if(element.parent == null) newParent.addChild(element);
};
managers.DrawManager.removeFromDisplay = function(element) {
	Main.getInstance().tileCont.removeChild(element);
	Main.getInstance().gameCont.removeChild(element);
	Main.getInstance().hudCont.removeChild(element);
	Main.getInstance().effectCont.removeChild(element);
};
managers.DrawManager.switchState = function() {
};
managers.DrawManager.getInstance = function() {
	if(managers.DrawManager.instance == null) managers.DrawManager.instance = new managers.DrawManager();
	return managers.DrawManager.instance;
};
managers.DrawManager.prototype = {
	isometricSort: function(cont,layerIndex) {
		var array = cont.children;
		array.sort(function(a,b) {
			if(a.y > b.y) return 1; else if(a.y < b.y) return -1;
			return a.Zindex - b.Zindex;
		});
		var j = 0;
		var iter = new IntIterator(0,layerIndex);
		var $it0 = HxOverrides.iter(array);
		while( $it0.hasNext() ) {
			var i = $it0.next();
			cont.setChildIndex(i,j);
			j++;
		}
	}
	,__class__: managers.DrawManager
};
managers.InitManager = function() {
	var lConfig = new PIXI.loaders.Loader();
	lConfig.add("config","config.json");
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
		window.requestAnimationFrame(($_=Main.getInstance(),$bind($_,$_.Start)));
	}
	,__class__: managers.InitManager
};
managers.MapManager = function() {
	this.maps = new haxe.ds.StringMap();
	var value = new objects.GameMap(this.formatMap("testMapZig"),"testMapZig");
	this.maps.set("testMapZig",value);
	this.activeMap = this.maps.get("testMapZig");
};
managers.MapManager.__name__ = true;
managers.MapManager.getInstance = function() {
	if(managers.MapManager.instance == null) managers.MapManager.instance = new managers.MapManager();
	return managers.MapManager.instance;
};
managers.MapManager.prototype = {
	generateMapDisplay: function(mapName) {
		var newMap = this.maps.get(mapName);
		var i = 0;
		var j = 0;
		var tileSprite;
		var $it0 = HxOverrides.iter(newMap.graphicalData);
		while( $it0.hasNext() ) {
			var arrayY = $it0.next();
			j = 0;
			var $it1 = HxOverrides.iter(arrayY);
			while( $it1.hasNext() ) {
				var tileIndex = $it1.next();
				if(tileIndex != 0) {
					if(newMap.associatedTiles[tileIndex] == null) throw new Error("[ERROR] tile index " + tileIndex + " not found in " + newMap.name + ".json");
					var pos = utils.Misc.convertToAbsolutePosition([i,j]);
					tileSprite = new PIXI.Sprite(PIXI.Texture.fromImage(newMap.associatedTiles[tileIndex]));
					tileSprite.x = pos[0];
					tileSprite.y = pos[1];
					tileSprite.anchor.set(0.5,1);
					tileSprite.tilePositionX = pos[0];
					tileSprite.tilePositionY = pos[1];
					newMap.addTileToMap(tileSprite);
				}
				++j;
			}
			++i;
		}
		newMap.displayMap();
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
			var map = newMap.layers[i].data;
			while(j < newMap.layers[i].data.length) {
				if(mapLayer[j % newMap.width] == null) mapLayer[j % newMap.width] = [];
				mapLayer[j % newMap.width][Math.floor(j / newMap.width)] = newMap.layers[i].data[j];
				j++;
			}
			returnObject[newMap.layers[i].name] = mapLayer.slice();
			i++;
		}
		return returnObject;
	}
	,__class__: managers.MapManager
};
managers.MouseManager = function() {
	this.arrayPoints = [];
	this.refreshPerFrame = 1;
	this.calledPerFrame = 0;
	window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousedown",$bind(this,this.mouseDown));
	window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mouseup",$bind(this,this.mouseUp));
	window.document.getElementsByClassName("gastCanvas").item(0).addEventListener("mousemove",$bind(this,this.mouseMoveHandler));
};
managers.MouseManager.__name__ = true;
managers.MouseManager.convertClicToTilePosition = function(absoluteX,absoluteY) {
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
managers.MouseManager.getSquareTileAbove = function(posClicked,size) {
	var ArrayOfPos = [];
	var height = (size[0] - 1) * 2;
	var tileSize_0 = 64;
	var tileSize_1 = 32;
	var GridAround = [];
	var iter = new IntIterator(Math.floor(-height * 0.5),Math.floor(1 + height * 0.5));
	while( iter.hasNext() ) {
		var i = iter.next();
		var iter2 = new IntIterator(-height,height * 2);
		while( iter2.hasNext() ) {
			var j = iter2.next();
			GridAround.push([posClicked[0] + i,posClicked[1] - j]);
		}
	}
	var centerPosition = posClicked;
	ArrayOfPos.push([centerPosition[0],centerPosition[1]]);
	if(size[0] % 2 == 0) if(centerPosition[1] % 2 == 1) centerPosition[0] += 0.5; else centerPosition[0] += -0.5;
	centerPosition[1] += size[1];
	var dx;
	var dy;
	var centerAbsolutePos = utils.Misc.convertToAbsolutePosition(centerPosition);
	var $it0 = HxOverrides.iter(GridAround);
	while( $it0.hasNext() ) {
		var i1 = $it0.next();
		var absolutePosPoint = utils.Misc.convertToAbsolutePosition(i1);
		dx = (centerAbsolutePos[0] - absolutePosPoint[0]) / tileSize_0;
		dy = (centerAbsolutePos[1] - absolutePosPoint[1]) / tileSize_1;
		if(Math.abs(dx) + Math.abs(dy) <= 0.5 * (size[0] - 1) && HxOverrides.indexOf(ArrayOfPos,i1,0) == -1) ArrayOfPos.push(i1);
	}
	return ArrayOfPos;
};
managers.MouseManager.createLilCubes = function(position,color) {
	var iter = new IntIterator(0,position.length);
	var tileSize = managers.InitManager.data.config.tileSize;
	while( iter.hasNext() ) {
		var i = iter.next();
		var displayX = position[i][0] * tileSize[0] - 1 + Main.camera.offset[0];
		var displayY = position[i][1] * tileSize[1] / 2 - 1 + Main.camera.offset[1];
		if(Math.abs(position[i][1] % 2) == 1) displayX += tileSize[0] * 0.5;
		displayY += tileSize[1] * 0.5;
		var redPoint = new PIXI.Graphics();
		var specialColor;
		if(color != null) specialColor = color; else specialColor = 65280;
		redPoint.lineStyle(1,specialColor);
		redPoint.beginFill(16711680);
		redPoint.drawRect(displayX - 1,displayY - 1,3,3);
		redPoint.endFill();
		managers.DrawManager.addToDisplay(redPoint,Main.getInstance().debugCont);
	}
};
managers.MouseManager.getInstance = function() {
	if(managers.MouseManager.instance == null) managers.MouseManager.instance = new managers.MouseManager();
	return managers.MouseManager.instance;
};
managers.MouseManager.prototype = {
	mouseMoveHandler: function(e) {
		if(this.calledPerFrame > this.refreshPerFrame) return;
		++this.calledPerFrame;
		var clicPoint_0 = e.layerX - Main.camera.offset[0];
		var clicPoint_1 = e.layerY - Main.camera.offset[1];
		managers.MouseManager.gamehover.layerX = e.layerX;
		managers.MouseManager.gamehover.layerY = e.layerY;
		Reflect.setField(managers.MouseManager.gamehover,"tilePos",managers.MouseManager.convertClicToTilePosition(clicPoint_0,clicPoint_1));
		window.dispatchEvent(managers.MouseManager.gamehover);
	}
	,mouseUp: function(e) {
		var event = managers.MouseManager.gameMouseUp;
		var clicPoint_0 = e.layerX - Main.camera.offset[0];
		var clicPoint_1 = e.layerY - Main.camera.offset[1];
		event.layerX = e.layerX;
		event.layerY = e.layerY;
		Reflect.setField(event,"tilePos",managers.MouseManager.convertClicToTilePosition(clicPoint_0,clicPoint_1));
		managers.MouseManager.createLilCubes([managers.MouseManager.convertClicToTilePosition(clicPoint_0,clicPoint_1)]);
		window.dispatchEvent(event);
	}
	,mouseDown: function(e) {
		var event = managers.MouseManager.gameMouseDown;
		var clicPoint_0 = e.layerX - Main.camera.offset[0];
		var clicPoint_1 = e.layerY - Main.camera.offset[1];
		event.layerX = e.layerX;
		event.layerY = e.layerY;
		Reflect.setField(event,"tilePos",managers.MouseManager.convertClicToTilePosition(clicPoint_0,clicPoint_1));
		window.dispatchEvent(event);
	}
	,createNewTile: function(pos) {
		var tileSprite = new PIXI.Sprite(PIXI.Texture.fromImage("tilehover.png"));
		tileSprite.x = pos[0];
		tileSprite.y = pos[1] + managers.InitManager.data.config.tileSize[1] * 0.5;
		tileSprite.anchor.set(0.5,1);
		Main.getInstance().debugCont.addChild(tileSprite);
		return tileSprite;
	}
	,__class__: managers.MouseManager
};
managers.StateManager = function() {
	this.debugActiveState = new PIXI.Text("",{ fill : "white", font : "30px Calibri"});
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
		if(!this.firstLoop) this.statesArray.get(this.activeState).switchState();
		this.firstLoop = false;
		managers.DrawManager.switchState();
		objects.Camera.getInstance().switchState();
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
var objects = {};
objects.Camera = function() {
	this.hasMovedEnough = false;
	this.clicked = false;
	this.oldCameraPosition = [];
	this.mouseDownPosition = [];
	this.dragSensitivity = 2;
	this.minimumMovement = 10;
	this.size = [0,0];
	this.offset = [0,0];
	this.configTileSize = managers.InitManager.data.config.tileSize;
	this.minimumMovement = Reflect.field(managers.InitManager.data.config.camera,"minimumMovement");
	this.dragSensitivity = Reflect.field(managers.InitManager.data.config.camera,"sensitivity");
	window.addEventListener("gameMouseDown",$bind(this,this.mouseDownListener));
	window.addEventListener("gameHover",$bind(this,this.mouseMoveListener));
	window.addEventListener("gameMouseUp",$bind(this,this.mouseUpListener));
	window.addEventListener("resize",$bind(this,this.getContainerBounds));
	this.getContainerBounds();
	this.gameSize = Main.getInstance().fullStage.getBounds();
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
		if(!this.clicked) return;
		if(this.hasMovedEnough == false && Math.abs(this.mouseDownPosition[0] - e.layerX) < this.minimumMovement && Math.abs(this.mouseDownPosition[1] - e.layerY) < this.minimumMovement) return;
		this.hasMovedEnough = true;
		this.offset = [this.oldCameraPosition[0] - (this.mouseDownPosition[0] - e.layerX) * this.dragSensitivity,this.oldCameraPosition[1] - (this.mouseDownPosition[1] - e.layerY) * this.dragSensitivity];
		if(this.gameSize.width > this.size[0]) this.offset[0] = utils.Misc.clamp(this.offset[0],0,this.gameSize.width - this.size[0]);
		if(this.gameSize.height > this.size[1]) this.offset[1] = utils.Misc.clamp(this.offset[1],0,this.gameSize.height - this.size[1]);
		if(this.gameSize.width > this.size[0] && this.gameSize.height > this.size[1]) this.offset = [0,0];
		console.log(this.offset);
		this.translateOffsetToConts();
	}
	,mouseUpListener: function(e) {
		this.clicked = false;
		this.hasMovedEnough = false;
	}
	,setCameraPosition: function(newPosition) {
		this.offset = newPosition;
		this.translateOffsetToConts();
	}
	,translateOffsetToConts: function() {
		Main.getInstance().tileCont.x = this.offset[0];
		Main.getInstance().tileCont.y = this.offset[1];
		Main.getInstance().gameCont.x = this.offset[0];
		Main.getInstance().gameCont.y = this.offset[1];
	}
	,getContainerBounds: function(e) {
		this.size = [Main.getInstance().renderer.width,Main.getInstance().renderer.height];
	}
	,Update: function() {
		this.gameSize = Main.getInstance().fullStage.getBounds();
	}
	,switchState: function() {
		this.offset = [0,0];
	}
	,__class__: objects.Camera
};
objects.GameMap = function(datas,mapName) {
	this.mapContainer = new PIXI.ParticleContainer();
	this.OffsetY = 0;
	this.OffsetX = 0;
	this.name = mapName;
	this.json = managers.InitManager.data[this.name];
	this.OffsetY = managers.InitManager.data.config.tileSize[1] * 0.5;
	this.mapContainer.y = this.OffsetY;
	this.mapContainer.x = this.OffsetX;
	this.associatedTiles = managers.InitManager.data.config.mapsData[this.name].tiles;
	if(this.associatedTiles == null) throw new Error("[ERROR] No tileData defined in config for: " + this.name);
	this.associatedTiles.unshift(null);
	if(this.json == null) window.console.warn("%c[WARNING] no data json found for map '" + mapName + "' ","color:red;");
	this.setMapData(datas.graphics,datas.collisions);
};
objects.GameMap.__name__ = true;
objects.GameMap.prototype = {
	setMapData: function(newGraphicalData,newCollisionData) {
		this.graphicalData = newGraphicalData;
		this.collisionData = newCollisionData;
	}
	,addTileToMap: function(tile) {
		managers.DrawManager.addToDisplay(tile,this.mapContainer);
	}
	,displayMap: function() {
		if(this.mapContainer.parent == null) managers.DrawManager.addToDisplay(this.mapContainer,Main.getInstance().tileCont);
		this.mapContainer.visible = true;
	}
	,getTileAt: function(tilePosition) {
		return this.associatedTiles[this.graphicalData[tilePosition[0]][tilePosition[1]]];
	}
	,getColliAt: function(tilePosition) {
		return this.collisionData[tilePosition[0]][tilePosition[1]] != 0;
	}
	,hideMap: function() {
		this.mapContainer.visible = false;
	}
	,__class__: objects.GameMap
};
objects.State = function(newName) {
	this.loaderReady = 0;
	this.loadImage = new haxe.ds.StringMap();
	this.loadJson = new haxe.ds.StringMap();
	this.ButtonText = new PIXI.Text("",{ fill : "black", font : "30px Charlemagne"});
	this.LoadingText = new PIXI.Text("",{ fill : "white", font : "30px Charlemagne"});
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
objects.Tile = function(pname,tilePosition) {
	this.ID = utils.Id.newId();
	this.layer = 0;
	this.Zindex = 0;
	this.placed = false;
	this.tileTaken = [];
	this.tileSize = [];
	this.tilePosition = { x : 0, y : 0};
	this.tileSizeConfig = managers.InitManager.data.config.tileSize;
	this.tileInfo = managers.InitManager.data.config.tileTypes[pname];
	if(this.tileInfo == null) throw new Error("Le name '" + pname + "' n'a pas été trouvé dans la config lors de la création de la tile N°" + this.ID);
	this.tileSize = this.tileInfo.size;
	this.tileName = pname;
	if(this.tileInfo.frames != null) {
		var frames = [];
		var iter = new IntIterator(0,this.tileInfo.frames.length);
		while( iter.hasNext() ) {
			var i = iter.next();
			frames.push(PIXI.Texture.fromFrame(this.tileInfo.frames[i]));
		}
		PIXI.extras.MovieClip.call(this,frames);
		if(this.tileInfo.loop != null) this.loop = this.tileInfo.loop; else this.loop = false;
		this.animationSpeed = this.tileInfo.fps / 60;
		this.play();
	} else PIXI.extras.MovieClip.call(this,[PIXI.Texture.fromImage("assets/" + js.Boot.__cast(this.tileInfo.image , String))]);
	this.settilePosition(tilePosition[0],tilePosition[1]);
	this.anchor.set(0.5,1);
};
objects.Tile.__name__ = true;
objects.Tile.__super__ = PIXI.extras.MovieClip;
objects.Tile.prototype = $extend(PIXI.extras.MovieClip.prototype,{
	settilePosition: function(newX,newY) {
		if(newX != null) {
			this.tilePosition.x = newX;
			this.x = newX * this.tileSizeConfig[0] + Main.camera.offset[0];
		}
		if(newY != null) {
			this.tilePosition.y = newY;
			this.y = newY * this.tileSizeConfig[1] * 0.5 + Main.camera.offset[1];
			if(Math.abs(this.tilePosition.y % 2) == 1) this.x = this.tilePosition.x * this.tileSizeConfig[0] + this.tileSizeConfig[0] * 0.5 + Main.camera.offset[0];
		}
	}
	,getAbsolutePosition: function() {
		var arrayToReturn = [];
		arrayToReturn[0] = this.tilePosition.x * this.tileSizeConfig[0];
		arrayToReturn[1] = this.tilePosition.y * this.tileSizeConfig[1] / 2;
		if(Math.abs(this.tilePosition.y % 2) == 1) arrayToReturn[0] += this.tileSizeConfig[0] * 0.5;
		return arrayToReturn;
	}
	,followCamera: function(camPosition) {
		this.x = this.getAbsolutePosition()[0] + camPosition[0];
		this.y = this.getAbsolutePosition()[1] + camPosition[1];
	}
	,update: function() {
	}
	,placeEffect: function() {
	}
	,Destroy: function() {
		managers.DrawManager.removeFromDisplay(this);
	}
	,__class__: objects.Tile
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
		managers.MapManager.getInstance().generateMapDisplay("testMapZig");
		this.hoverSprite = new PIXI.Sprite(PIXI.Texture.fromImage("tilehover.png"));
		this.hoverSprite.x = -1000;
		this.hoverSprite.y = -1000;
		this.hoverSprite.anchor.set(0.5,1);
		managers.DrawManager.addToDisplay(this.hoverSprite,Main.getInstance().tileCont,10);
		window.addEventListener("gameHover",$bind(this,this.moveHover));
	}
	,Update: function() {
	}
	,moveHover: function(e) {
		this.hoverSprite.x = utils.Misc.convertToAbsolutePosition(e.tilePos)[0];
		this.hoverSprite.y = utils.Misc.convertToAbsolutePosition(e.tilePos)[1] + managers.InitManager.data.config.tileSize[1] * 0.5;
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
		this.loadJson.set("tileSpriteSheet","assets/spriteSheets/mapSpriteSheet.json");
		this.loadJson.set("tileSh2","assets/spriteSheets/loadSpriteSheet.json");
		this.loadImage.set("tileSpriteSheet","assets/misc/tilehover.png");
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
		this.sprite = new PIXI.Sprite(PIXI.Texture.fromImage("tile2.png"));
		this.sprite.interactive = true;
		this.sprite.on("mouseup",$bind(this,this.clickHandler));
		managers.DrawManager.addToDisplay(this.sprite,Main.getInstance().gameCont);
	}
	,clickHandler: function(e) {
		managers.StateManager.getInstance().switchToState("Debug");
	}
	,Update: function() {
	}
	,switchState: function() {
	}
	,__class__: states.MenuState
});
var utils = {};
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
utils.Misc.angleBetween = function(sX,sY,tX,tY) {
	return Math.atan2(tX - sX,tY - sY);
};
utils.Misc.convertToAbsolutePosition = function(tilePosition) {
	var configTileSize = managers.InitManager.data.config.tileSize;
	var returnPosition = [];
	returnPosition[0] = tilePosition[0] * configTileSize[0] - 1;
	if(tilePosition[1] % 2 == 1) returnPosition[0] += configTileSize[0] * 0.5;
	returnPosition[1] = tilePosition[1] * configTileSize[1] * 0.5 - 1;
	return returnPosition;
};
utils.Misc.convertToGridPosition = function(pixelPosition) {
	return [Math.floor(pixelPosition[0] / managers.InitManager.data.config.tileSize[0]),Math.floor(pixelPosition[1] / managers.InitManager.data.config.tileSize[1] * 2)];
};
utils.Misc.colliSquarePoint = function(obj,point,cameraAffected) {
	var offset;
	if(cameraAffected) offset = objects.Camera.getInstance().offset; else offset = [0,0];
	if(obj.x - obj.width * obj.anchor.x > point[0] + offset[0]) return false;
	if(obj.y - obj.height * obj.anchor.y > point[1] + offset[1]) return false;
	if(obj.x + obj.width - obj.width * obj.anchor.x < point[0] + offset[0]) return false;
	if(obj.y + obj.height - obj.height * obj.anchor.y < point[1] + offset[1]) return false;
	return true;
};
utils.Misc.colliSquareSquare = function(obj1,obj2) {
	if(obj1.x - obj1.width * obj1.anchor.x > obj2.x + obj2.width - obj2.width * obj2.anchor.x) return false;
	if(obj1.y - obj1.height * obj1.anchor.y > obj2.y + obj2.height - obj2.height * obj2.anchor.y) return false;
	if(obj1.x + obj1.width - obj1.width * obj1.anchor.x < obj2.x - obj2.width * obj2.anchor.x) return false;
	if(obj1.y + obj1.height - obj1.height * obj1.anchor.y < obj2.y - obj2.height * obj2.anchor.y) return false;
	return true;
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
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
Main.DEBUGMODE = true;
managers.InitManager.CONFIG_PATH = "config.json";
managers.InitManager.ASSETS_PATH = "assets/";
managers.MouseManager.gamehover = new CustomEvent("gameHover");
managers.MouseManager.gameMouseUp = new CustomEvent("gameMouseUp");
managers.MouseManager.gameMouseDown = new CustomEvent("gameMouseDown");
objects.State.FTUEStateBool = false;
utils.Id.numberIds = 0;
Main.main();
})();

//# sourceMappingURL=Gast.js.map