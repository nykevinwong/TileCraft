package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.PLIK;
import com.akifox.plik.Utils;
import com.akifox.plik.Gfx;
import com.akifox.plik.Text;
import com.akifox.plik.SpriteContainer;
import com.akifox.plik.ShapeContainer;
import com.akifox.plik.Screen;
import com.akifox.transform.Transformation;
import com.akifox.plik.atlas.TextureAtlas;
import com.akifox.plik.atlas.*;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import Shape;
import gui.*;

using hxColorToolkit.ColorToolkit;


class ScreenMain extends Screen
{

	var _model:Model;

	public function new () {
		super();
		cycle = false;
		title = "Main";
		rwidth = 1024;
		rheight = 576;
	}

	public override function initialize():Void {
    trace(rwidth);
    trace(rheight);
    trace(PLIK.adjust(rwidth));
		trace(ModelIO.DEFAULT_PALETTE);


		// CLASS TEST
		// String -> Array<Int> -> Model (Shapes) -> Array<Int> -> String

		// EXAMPLE MODELS

		// stupid guy
		//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";

		// complex shape
		//var original = "FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B";

		// home
		var original = "DAAACGneAQk8XCgIPF0SWzdcv183er9rjFy_b4x6v2mMzJ1ZN7ydCDysmgBpXiVAaaxH";

		// random stuff
		//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";

		//var original = "AQAAAUpJCA.."; //just a cube

		// farm
		//var original = "EwAC____OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..";

		var decoded = Base64.decodeBase64(original);
		var model = _model = ModelIO.loadModel(decoded);
		var demodel = ModelIO.saveModel(model);
		var reencoded = Base64.encodeBase64(demodel,true);

		// trace('original:',original);
		// trace('decoded:',decoded);
		// trace('model:',model);
		// trace('demodel:',demodel);
		// trace('reencoded:',reencoded);

		var passed:Bool = true;
		if (original!=reencoded) passed = false;

		trace('original data: ' + original);
		trace('reencoded data: ' + original);
		trace('comparison test passed: ' + passed);
		trace('-----------------------------------');

		// END TEST

		var ren = new ModelRenderer(Std.int(320),Std.int(480));
		var bpd_preview = ren.render(model,-1,true);
		var bp = new Bitmap(bpd_preview);
		bp.smoothing = true;
		bp.x = rwidth/2-bp.width/2+PLIK.adjust(650);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var ren = new ModelRenderer(Std.int(320),Std.int(480));
		var bpd = ren.render(model,-1,false);
		var bp = new Bitmap(bpd);
		bp.smoothing = true;
		bp.x = rwidth/2-bp.width/2;
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		var bpd_fx = PostFX.scale(PostFX.fxaaOutline(bpd,8,8),0.25);
		//var bpd_fx = PostFX.scale(bpd,0.25);
		var bp = new Bitmap(bpd_fx);
		bp.x = rwidth/2-bp.width/2-PLIK.adjust(550);
		bp.y = rheight/2-bp.height/2;
		addChild(bp);

		//var b:openfl.utils.ByteArray = bpd_fx.encode("png", 1);
		//trace("data:image/png;base64,"+haxe.crypto.Base64.encode(b));

		// Saving the BitmapData to a file
		// var b:openfl.utils.ByteArray = bpd_fx.bitmapData.encode("png", 1);
		// var fo:sys.io.FileOutput = sys.io.File.write("test_out.png", true);
		// fo.writeString(b.toString());
		// fo.close();



		// STATIC INTERFACE ---------------------------------------------

		// model+color toolbar bg
		graphics.beginFill(0x242424,0.95);
		graphics.drawRect(0,0,103,rheight);

		// action toolbar bg
		graphics.beginFill(0x242424,0.95);
		graphics.drawRect(0,0,rwidth,50);

		// var button = new Button();
		// button.x = 130;
		// button.y = 100;
		// button.style = Style.button();
		// button.selectable = true;
		// button.listen = true;
		// button.actionF = function(button:Button) { trace(button); };
		// button.text = new Text("Button test",18,APP.COLOR_DARK,openfl.text.TextFormatAlign.CENTER);
		// button.icon = APP.atlasSprites.getRegion(APP.ICON_CHECKBOX).toBitmapData();
		// button.iconSelected = APP.atlasSprites.getRegion(APP.ICON_CHECKBOX_CHECKED).toBitmapData();
		// addChild(button);

		// MODEL TOOLBAR ---------------------------------------------

		var toolbar = new Toolbar(2,true,Style.toolbar(),Style.toolbarButton());
		toolbar.addButton("pointer",null,					APP.atlasSprites.getRegion(APP.ICON_POINTER).toBitmapData());
		toolbar.addButton("sh_cube",null,					APP.atlasSprites.getRegion(APP.ICON_SH_CUBE).toBitmapData());
		toolbar.addButton("sh_round_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_UP).toBitmapData());
		toolbar.addButton("sh_round_side",null,		APP.atlasSprites.getRegion(APP.ICON_SH_ROUND_SIDE).toBitmapData());
		toolbar.addButton("sh_cylinder_up",null,	APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_UP).toBitmapData());
		toolbar.addButton("sh_cylinder_side",null,APP.atlasSprites.getRegion(APP.ICON_SH_CYLINDER_SIDE).toBitmapData());
		toolbar.addButton("sh_ramp_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_UP).toBitmapData());
		toolbar.addButton("sh_ramp_down",null,		APP.atlasSprites.getRegion(APP.ICON_SH_RAMP_DOWN).toBitmapData());
		toolbar.addButton("sh_arch_up",null,			APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_UP).toBitmapData());
		toolbar.addButton("sh_arch_down",null,		APP.atlasSprites.getRegion(APP.ICON_SH_ARCH_DOWN).toBitmapData());
		toolbar.addButton("sh_corner_se",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SE).toBitmapData());
		toolbar.addButton("sh_corner_sw",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_SW).toBitmapData());
		toolbar.addButton("sh_corner_ne",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NE).toBitmapData());
		toolbar.addButton("sh_corner_nw",null,		APP.atlasSprites.getRegion(APP.ICON_SH_CORNER_NW).toBitmapData());

		toolbar.x = 20;
		toolbar.y = 60;
		addChild(toolbar);

		// COLOR TOOLBAR ---------------------------------------------
		var colorToolbar = new Toolbar(2,true,Style.toolbar(),Style.toolbarButtonFull());

		//---

		var colorPickerAction = function(color:Int) {
			var button:Button = colorToolbar.getSelected();
			var index:Int = cast(button.value,Int);
			if (index==0) return; //hole
			button.icon = APP.makeColorIcon(26,color);
			_model.setColor(index,color);
		}

		//---

		_colorPicker = new BoxColorPicker(colorPickerAction,function() {hideColorPicker();});
		_colorPicker.x = 120;
		_colorPicker.y = rheight-20-_colorPicker.height;

		//---

		var colorToolbarAction = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) {
					hideColorPicker();
					return; //hole
				}
				Lib.current.stage.color = _model.getColor(value);
				if (_colorPickerOnStage) showColorPicker(_model.getColor(value));
		};

		var colorToolbarActionAlt = function(button:Button) {
				var value:Int = cast(button.value,Int);
				if (value==0) return; //hole
				showColorPicker(_model.getColor(value));
		};

		//---

		//colorToolbar.setPalette(_model.getPalette());
		colorToolbar.addButton('palette0',0,APP.makeColorIcon(26,-1),colorToolbarAction);
		for (i in 1...16) {
			colorToolbar.addButton('palette$i',i,APP.makeColorIcon(26,_model.getColor(i)),colorToolbarAction,colorToolbarActionAlt);
		}
		colorToolbar.selectByIndex(1);
		colorToolbar.x = 20;
		colorToolbar.y = toolbar.y + toolbar.height + 20;
		addChild(colorToolbar);


		// ACTION TOOLBAR ---------------------------------------------

		var actionToolbarAction = function(button:Button) { trace("NOT IMPLEMENTED"); }
		var actionToolbar = new Toolbar(0,false,Style.toolbar(),Style.toolbarButton());
		actionToolbar.addButton("new",null,			APP.atlasSprites.getRegion(APP.ICON_NEW).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("open",null,		APP.atlasSprites.getRegion(APP.ICON_OPEN).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("save",null,		APP.atlasSprites.getRegion(APP.ICON_SAVE).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("render",null,	APP.atlasSprites.getRegion(APP.ICON_RENDER).toBitmapData(),	actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("copy",null,		APP.atlasSprites.getRegion(APP.ICON_COPY).toBitmapData(),		actionToolbarAction);
		actionToolbar.addButton("paste",null,	APP.atlasSprites.getRegion(APP.ICON_PASTE).toBitmapData(),	actionToolbarAction);
		actionToolbar.addButton("-");
		actionToolbar.addButton("quit",null,		APP.atlasSprites.getRegion(APP.ICON_QUIT).toBitmapData(),		actionToolbarAction);
		actionToolbar.x = 120;
		actionToolbar.y = 10;
		addChild(actionToolbar);

		// APP TITLE ---------------------------------------------

		var text = new Text("TILE\nCRAFT",18,APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_SQUARE);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = 50;
		text.t.y = 25;
		addChild(text);

		// ---------------------------------------------

		super.initialize(); // init_super at the end
	}

	public override function unload():Void {
		super.unload();
	}

	public override function start() {
		super.start();  // call resume
	}

	public override function hold():Void {
		super.hold();

		// HOOKERS OFF
	}

	public override function resume():Void {
		super.resume();

    // HOOKERS ON

	}

	var _colorPicker:BoxColorPicker;
	var _colorPickerOnStage:Bool = false;

	private function showColorPicker(color:Int) {
		_colorPicker.selector(color);
		if (_colorPickerOnStage) return;
		addChild(_colorPicker);
		_colorPicker.show();
		_colorPickerOnStage = true;
	}

	private function hideColorPicker() {
		if (!_colorPickerOnStage) return;
		_colorPicker.hide();
		removeChild(_colorPicker);
		_colorPickerOnStage = false;
	}

	private override function update(delta:Float):Void {

	}

	public override function resize() {

	}

	//########################################################################################
	//########################################################################################

}