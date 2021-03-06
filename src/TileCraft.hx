package ;

import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
#if !mobile
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
#end

import motion.Actuate;
import motion.easing.*;

import com.akifox.plik.*;
import com.akifox.plik.atlas.*;
import com.akifox.transform.Transformation;

import format.png.*;

import Shape;
import com.akifox.plik.gui.*;
import view.*;

import systools.Dialogs;
import systools.Clipboard;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.BytesInput;
import sys.FileSystem;
import sys.io.FileInput;
import sys.io.FileOutput;

using StringTools;
using hxColorToolkit.ColorToolkit;


class TileCraft extends Screen
{

	public function new () {
		super();
		cycle = false;
		title = "TileCraft";
	}

	private var _theModel:Model = Model.makeNew();
	private var _theSelectedShape:Shape = null;

	// INTERFACE -----------------------------------------------------------------

	var _mainToolbar:Toolbar;
	var _actionToolbar:Toolbar;
	var _colorToolbar:Toolbar;
	var _previewColorToolbar:Toolbar;
	var _outputActionToolbar:Toolbar;

	var _newVersionSprite:SpriteContainer = new SpriteContainer();

	var _colorPicker:ColorPickerView;

	var _shapeViewList:ShapeViewList;

	var _statusBar:Text;

	var _outputView:OutputView = null;
	var _modelView:ModelView = null;

	// status
	var _modelPreviewMode:Bool=true;
	var _colorPickerOnStage:Bool = false;

	// INTERFACE SIZE ------------------------------------------------------------

	public static inline var ACTIONBAR_HEIGHT = 40;
	public static inline var STATUSBAR_HEIGHT = 40;
	public static inline var TOOLBAR_WIDTH = 100;
	public static inline var SHAPELIST_WIDTH = 150;
	public static inline var PREVIEW_WIDTH = 200;
	public static inline var BASE_SPAN = 20;

	// RENDERER ------------------------------------------------------------------

	public static inline var RENDER_WIDTH = 320;
	public static inline var RENDER_HEIGHT = 480;

	var _theRenderer:Renderer = null;

	public static var fxaaModes = [[8,8],[8,8],[8,1]]; //passes + outline
	public static var renderModes = [0.5,0.25,0.125];
	var renderMode = 0;
	var renderOutline:Bool = false;

	//============================================================================

	public override function initialize():Void {

		_theRenderer = new Renderer(RENDER_WIDTH,RENDER_HEIGHT); //init renderer

		//initButtonTestCases(); // Just some button test
		initMainToolbar(); // The shape toolbar
		initColor(); // Color _mainToolbar + Color picker
		initActionToolbar(); // Top action bar
		initModelView(); // Model view
		initOutput(); // Preview toolbars + output view
		initAppTitle(); // App title top left
		initStatusbar(); // Bottom status bar
		initShapeList();

		// -------------------------------------------------------------------------

		//#if debug
			// EXAMPLE MODELS

			// stupid guy
			//var original = "EgQCAJn_Zv8zETxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVCh5FVRxVRO8cqkTv";

			// complex shape
			//var original = "Ff//1fb/QEW7PqXys9vuJDI/OVJXUpAjpswzUUY1p3At////9+F2vjJB33qSfoaPprO8Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq+8B";

			// easy cube
			//var original = "AgAAAXhWZxESeAE.";

			// question mark
			//var original = "BgAABmdnAUY5Z19ASGd9ADVnCwZnZ1ZgNWfP";

			// 32 shapes (scroll shapeview test)
			//var original = "HwAAFjxKKyZGRp4mm0aeRFaaeUSamnlEVokBRJqJAUNmmnhDqpp4FzxZvCxVV90sqmfdRGaaREYBRVVG70VVBh5FVRxVRO8cqkTvwQFWAcHvzQHBVs0BwQEBAVKa3gFSAc0BUu9FAVI0EgFSvO8BQu-aAUpF7wFKI6sBM81nAQ..";

			// home
			//var original = "DAAACGneAQk8XCgIPF0SWzdcv183er9rjFy_b4x6v2mMzJ1ZN7ydCDysmgBpXiVAaaxH";

			// random stuff
			//var original = "BxAA_wD_DCM0AQy8RQEMZ6sBXHgBAUwB3gFAq0UBEQgIvQ..";

			//var original = "AQAAAUpJCA.."; //just a cube


			//HOME (lostgarden test-case)
			//var original = "DP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1x4J11M2l9fDJvjJB33qSfoaPprO8a4xdrVs3Xa0JPE0IAGmNFEBpfTYIad4ACDxNAFo3e61ZN02Laox7rWmMTYsIPF2Z";

			//FACTORY (lostgarden test-case)
			//var original = "DP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1x4J11M2l9fDJvjJB33qSpmxRprO8CS1tCAA1jRYIJt4ACC1NAAgtfZlLmt5FSIvNNkleIwlLi32rCy19qghpzUUIms1Z";

			//STONE (lostgarden test-case)
			//var original = "CP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJBY2tzfoaPoK66HTwqAh48KjUfPCpnPkQzZz6qRGc-u3dnPlWIZz5nVmc.";

			//TREE (lostgarden test-case)
			//var original = "BP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJBorAneocaoK66HTwqAh48KjUePCqbHTwqaA..";

			//WOODCHUCK (lostgarden test-case)
			//var original = "DP__1fb_QEW7SGV9s9vuKztNOVJXUpAjpswzUUY1p3At6pA-9-F2vjJBorAneocaoK66FDwqGkRGmgFEm5oBQ0aaV0ObmldEVZpmRKqaZkQ2Vq5EnFauQqtWvUJFVr0ADwMK";

			// farm
			//var original = "E____wAA____PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJB33qSfoaPprO8OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..";

			// -------------------------------------------------------------------------

			// set the example test model
			//changeModel(Model.fromString(original));
		//#else //debug
			changeModel(Model.makeNew());
		//#end //debug

		//init background image
		_outputView.drawBackground();

		super.initialize(); // init_super at the end
	}

	public override function unload():Void {
		super.unload();
	}

	public override function start() {
		super.start();  // call resume
		#if app_checkupdates
		APP.checkVersion(showNewVersion);
		#end
		if (!openfl.display.OpenGLView.isSupported) {
			messageCall("OpenGL PostFX are not supported on this machine\nThe render quality will be low!");
		}
	}

	public override function resize() {
		var screenWidth = Lib.current.stage.stageWidth;
		var screenHeight = Lib.current.stage.stageHeight;

		if (screenWidth<800) screenWidth = 800;
		if (screenHeight<600) screenHeight = 600;

		rwidth = screenWidth;
		rheight = screenHeight;

		// DRAW BACKGROUND INTERFACE

		graphics.clear();
		// _theModel+color _mainToolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,
											TOOLBAR_WIDTH,rheight);
		// action _mainToolbar bg
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,0,
											rwidth,ACTIONBAR_HEIGHT);
		// shapelist
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH,
											0,rwidth,rheight);
		// preview
		graphics.beginFill(0x242424,0.8);
		graphics.drawRect(rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH,
											0,rwidth-SHAPELIST_WIDTH,rheight);
		// status bar
		graphics.beginFill(0x242424,0.9);
		graphics.drawRect(0,rheight-STATUSBAR_HEIGHT,
											rwidth,rheight);
		// model
		graphics.beginFill(0x808080,1);
		graphics.drawRect(TOOLBAR_WIDTH,ACTIONBAR_HEIGHT,
											rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH-TOOLBAR_WIDTH,rheight-STATUSBAR_HEIGHT-ACTIONBAR_HEIGHT);

		// INTERFACE POSITIONING
		_outputView.t.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH;
		_outputView.t.y = rheight-STATUSBAR_HEIGHT;

		_modelView.x = TOOLBAR_WIDTH+(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH)/2-RENDER_WIDTH/2-ModelView.PADDING;
		_modelView.y = (rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT)/2-RENDER_HEIGHT/2+ACTIONBAR_HEIGHT-ModelView.PADDING;

		_mainToolbar.x = TOOLBAR_WIDTH/2-_mainToolbar.getGrossWidth()/2;
		_mainToolbar.y = ACTIONBAR_HEIGHT+10;

		_statusBar.t.x = TOOLBAR_WIDTH+10;
		_statusBar.t.y = rheight-STATUSBAR_HEIGHT/2;

		_colorPicker.x = TOOLBAR_WIDTH;
		_colorPicker.y = rheight-_colorPicker.getGrossHeight()-STATUSBAR_HEIGHT-20;
		_colorPicker.updateWidth(rwidth-TOOLBAR_WIDTH-SHAPELIST_WIDTH-PREVIEW_WIDTH);

		_colorToolbar.x = TOOLBAR_WIDTH/2-_colorToolbar.getGrossWidth()/2;
		_colorToolbar.y = _mainToolbar.y + _mainToolbar.height + BASE_SPAN;

		_actionToolbar.x = TOOLBAR_WIDTH+BASE_SPAN;
		_actionToolbar.y = ACTIONBAR_HEIGHT/2-_actionToolbar.getGrossHeight()/2;

		_previewColorToolbar.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH+BASE_SPAN/2;
		_previewColorToolbar.y = rheight-STATUSBAR_HEIGHT/2-_previewColorToolbar.getGrossHeight()/2;

		_outputActionToolbar.x = rwidth-SHAPELIST_WIDTH-BASE_SPAN/2-_outputActionToolbar.getGrossWidth();
		_outputActionToolbar.y = rheight-STATUSBAR_HEIGHT/2-_outputActionToolbar.getGrossHeight()/2;

		_shapeViewList.x = rwidth-SHAPELIST_WIDTH;
		_shapeViewList.y = ACTIONBAR_HEIGHT;
		_shapeViewList.updateHeight(rheight-ACTIONBAR_HEIGHT-STATUSBAR_HEIGHT);

		_newVersionSprite.x = rwidth-SHAPELIST_WIDTH-PREVIEW_WIDTH;
		_newVersionSprite.y = 0;

	}

	//############################################################################

	public function renderModel() {
		//TODO this should be part of ModelView

		// avoid too many calls at once
		if (APP.isDelayLocked()) return;

		// _modelView.setBitmapData(null); //TODO show some kind of modal while rendering

		var bpd:BitmapData = _theRenderer.render(_theModel,_theModel.getIndexOfShape(getSelectedShape()),_modelPreviewMode);
		_modelView.setBitmapData(bpd);
		APP.updateDelay(); // Only updater for delay!
	}

	public function renderOutput(?changedScale=false) {
		#if (!v2 || neko) //TODO POSTFX need support for OpenFL3
		var supportOpenGL = false;
		#else
		var supportOpenGL = openfl.display.OpenGLView.isSupported;
		#end

		//TODO show some kind of modal while rendering
		if (_modelPreviewMode) render(false);

		var source:BitmapData = _modelView.getBitmapData();
		if (!supportOpenGL) source = source.clone();
		var output:BitmapData = source;

		if (supportOpenGL) {
			#if (v2 && !neko)
			// output = PostFX.prepassEdgeColor(source); //TODO left for testing the prepass alone

			if (renderOutline) {
				// one passage fxaa with black outline
				output = postfx.PostFX.fxaaOutline(
									source,
									getRenderFxaaPasses(),
									getRenderFxaaOutline());
			} else {
				// two passages fxaa with alpha blending
				output = postfx.PostFX.fxaa(
								 		postfx.PostFX.prepassEdgeColor(source),
								 	getRenderFxaaPasses());
			}

			// scale
			output = postfx.PostFX.scale(output, getOutputScale());
			#end
		}

		// set output view
		_outputView.setBitmapData(output,(supportOpenGL?0:getOutputScale()));

		if (changedScale) _outputView.drawBackground();
	}

	public function render(preview:Bool) {
		#if (!v2 || neko)
		preview = true; //TODO POSTFX need support for OpenFL3
		#end
		//if (preview==_modelPreviewMode && !forceRender) return;
		_modelPreviewMode = preview;
		if (preview==false && getSelectedShape()!=null) {
			deselect(); //this will call again render()
			return;
		} else {
			renderModel();
		}
		//if (preview==false) renderOutput();
	}

	//============================================================================

	// used by outputview
	public function getOutputScale():Float {
		return renderModes[renderMode];
	}

	public function getRenderFxaaPasses():Int {
		return fxaaModes[renderMode][0];
	}

	public function getRenderFxaaOutline():Int {
		return fxaaModes[renderMode][1];
	}

	//============================================================================

	// used when changing model (new, open)
	private function changeModel(model:Model) {
		if (model==null) {
			//TODO report the problem to the user (CHECK ALL PROJECT FOR THIS KIND OF MISSING FEEDBACKS)
			APP.error('Unable to change the model');
			messageCall("Error\nUnable to load the Model");
			return;
		}
		setCurrentPath(); // no file name
		if (_theModel!=null) _theModel.destroy();
		_theModel = model;
		refreshPalette();
		refreshShapeList();
		render(false);
		renderOutput();
		//APP.log(_theModel.toString(true));
		//APP.log(_theModel.toPNGString(_outputBitmap.bitmapData)); //TODO should be a TextField to output this on request
	}

	//============================================================================

	// Dispatchers TODO need to be rewritten with events

	public function updateModel() {
		// called when something change the model
		renderModel();
	}

	public function updateShapeLocked(shape:Shape) {
		if (shape==getSelectedShape() && shape.locked==true) {
			deselect();
		}
	}

	public function setSelectedShape(shape:Shape):Shape {
		if (shape==_theSelectedShape) return null;
		_theSelectedShape = shape;
		_shapeViewList.selectByShape(shape); //dispatch
		_modelView.select(shape); //dispatch
		if (shape!=null) {
			_colorToolbar.selectByIndex(shape.color);
			_mainToolbar.select(_mainToolbar.getButtonByValue(shape.shapeType));
			render(true);
		} else {
			_mainToolbar.selectById('pointer'); //select pointer
			render(false);
			renderOutput();
		}
		return shape;
	}

	public function getSelectedShape():Shape {
		return _theSelectedShape;
	}

	public function deselect() {
		// called when something want to deselect the shape
		setSelectedShape(null);
		hideColorPicker();
	}


	public function getShapeInCoordinates(x:Int,y:Int):Shape {
		// used by ModelView
		return _theModel.getShapeByIndex(_theRenderer.getSelect(x,y));
	}

	public function addShape(shape:Shape) {
		// called to add a shape
		_theModel.addShape(shape);

		_shapeViewList.add(shape); //dispatch
	}

	public function swapShapes(shape1:Shape,shape2:Shape) {
		// called only by shapeviewlist to swap shape order (no dispatcher)
		_theModel.swapShapes(shape1,shape2);
		updateModel();
	}

	public function removeShape(shape:Shape) {
		// called to remove a shape
		_theModel.removeShape(shape);

		if (_theSelectedShape == shape) setSelectedShape(null);
		else render(_modelPreviewMode);
		_shapeViewList.remove(shape); //dispatch
	}

	public function changeShapeType(shapeType:ShapeType) {
		// called when something want to change the shapetype
		var shape = getSelectedShape();
		if (shape==null) return;
		shape.shapeType = shapeType;
		updateShape(shape);
		updateModel();
	}

	public function getColor(index:Int):Int {
		if (_theModel==null) return -1;
		return _theModel.getColor(index);
	}

	public function updateShape(shape:Shape) {
		_shapeViewList.updateShape(shape); //dispatch
	}

	public function changeColor(index:Int,color:Int) {
		_theModel.setColor(index,color);
		_shapeViewList.refreshColor(index);
	}

	public function refreshShapeList(){
		_shapeViewList.removeAll();
		for (i in 0..._theModel.getShapeCount()) {
			_shapeViewList.add(_theModel.getShapeByIndex(i));
		}
	}

	public function refreshPalette(){
		for (i in 1...16) {
			_colorToolbar.getButtonByIndex(i).icon = APP.makeColorIcon(_colorToolbar.styleButton,
																																			_theModel.getColor(i));
		}
	}

	//============================================================================
	// TOOLBAR AND VIEWS ACTIONS

	// a color was selected in the color picker
	private function colorPickerSelect(color:Int) {

		// get the current palette button
		var button:Button = _colorToolbar.getSelected();
		var index:Int = cast(button.value,Int);
		if (index==0) return; //hole, nothing to do

		// update the palette icon
		button.icon = APP.makeColorIcon(_colorToolbar.styleButton,color);

		// dispatch a color changed
		changeColor(index,color);

		// render model preview
		render(true);
	}

	// a shapetype was selected in the main _mainToolbar
	private function toolbarShapeTypeSelect(button:Button) {
		var shapeType:ShapeType = cast(button.value,ShapeType);
		changeShapeType(shapeType);
	}

	// the pointer was selected in the main _mainToolbar
	private function toolbarPointerSelect(button:Button) {
		deselect();
	}

	private function colorToolbarSelect(button:Button) {
		var value:Int = cast(button.value,Int);

		// change shape color
		var shape:Shape = getSelectedShape();
		if (shape!=null) {
			shape.color = value;
			updateShape(shape);
			updateModel();
		}

		if (value==0) {
			//hole, hide the color picker
			hideColorPicker();
		} else if (_colorPickerOnStage) {
			// if the colorpicker is on stage set its color to the current value
			showColorPicker(_theModel.getColor(value));
		}
	}

	private function colorToolbarDoubleClick(button:Button) {
		//on double click show the colorpicker with current color
		var value:Int = cast(button.value,Int);
		if (value==0) return; //hole, nothing to show
		showColorPicker(_theModel.getColor(value));
	};

	public function renderModeLoop(_) {
		// called by the output toolbar
		renderMode++;
		if (renderMode>=renderModes.length) renderMode = 0;
		renderOutput(true); //changed scale
	}

	public function outlineModeLoop(_) {
		// called by the output toolbar
		renderOutline = !renderOutline;
		renderOutput(false); //same scale
	}

	public function newShape(_) {
		// called by the main toolbar
		var shapeType = ShapeType.CUBE;
		var buttonShape = _mainToolbar.getSelected();
		//if (Type.getEnum(button.value)==ShapeType)
		if (buttonShape.value!=null) {
			shapeType = buttonShape.value;
		}

		var color:Int = 1;
		var buttonColor = _colorToolbar.getSelected();
		if (buttonColor!=null) color = buttonColor.value;

		var shape = new Shape(shapeType);
		shape.color = color;
		shape.x2 = shape.y2 = shape.z2 = 2; //2x2 size

		addShape(shape);
		setSelectedShape(shape);
	}

	public function cloneShape(_) {
		// called by the main toolbar
		var master = getSelectedShape();
		if (master==null) return;

		var shape = master.clone();
		shape.locked = false;

		addShape(shape);
		setSelectedShape(shape);
	}

	//============================================================================

	#if app_checkupdates
	public function showNewVersion() {
		var text = new Text("New version "+APP.onlineVersion+" available\nClick here to download",12,
												APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_LATO_BOLD);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = PREVIEW_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2;
		addChild(_newVersionSprite);
		_newVersionSprite.addChild(text);
		_newVersionSprite.addEventListener(MouseEvent.CLICK,
			function(e:MouseEvent){com.akifox.plik.Utils.gotoWebsite(APP.LINK_UPDATE);});
	}
	#end

	//============================================================================

	private function updateStatusBar() {
		var filename = _currentFilename;
		if (filename=="") filename = "Untitled model";
		_statusBar.text = 'Model: $filename';
	}

	//============================================================================

	public function newModelCall() {
		changeModel(Model.makeNew());
	}

	//============================================================================

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

		//out of preview
		if (_modelPreviewMode && getSelectedShape()==null) {
			render(false);
		}
	}
	//============================================================================

	private function quitCall() {
		var _dialog:DialogMessage = new DialogMessage(quitResponse,
																		false, //no input
																		"Do you really want to quit?",
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.dialogText'));
		_dialog.textOk = "Quit";
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
	}

	private function quitResponse(dialog:Dialog) {
		if (cast(dialog.value,Bool)) PLIK.quit();
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}

	//============================================================================

	private function importBase64Call() {
		var _dialog:DialogMessage = new DialogMessage(importBase64Response,
																		true, //input
																		"",
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.textInput'));
		_dialog.textOk = "Import";
		_dialog.textCancel = "Cancel";
		_dialog.selectable = true;
		_dialog.setWordWrap(true,400,400);
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
		_dialog.setFocus(); //set focus to textfield (need to be on stage)
	}

	private function importBase64Response(dialog:Dialog) {
		var response:String = cast(dialog.value,String);
		if (response!="") {
			changeModel(Model.fromString(response));
		}
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}

	//============================================================================

	private function exportBase64Call() {
		var _dialog:DialogMessage = new DialogMessage(exportBase64Response,
																		false, //no input
																		_theModel.toString(true),
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.dialogText'));
		_dialog.textOk = "Close";
		_dialog.textCancel = "Copy";
		_dialog.selectable = true;
		_dialog.setWordWrap(true,400);
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
	}

	private function exportBase64Response(dialog:Dialog) {
		if (!cast(dialog.value,Bool)) {
			//Copy
			systools.Clipboard.setText(_theModel.toString(true));
		}
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}

	//============================================================================

	public function saveFileCall() {
		if (hasCurrentFilename()) {
			if (saveFile(getCurrentPath())) {
				messageCall('File saved\n'+getCurrentPath()); //give feedback
			}
		} else {
			saveAsFileCall();
		}
	}

	#if (windows)

	public function saveAsFileCall() {
		var saveAsDir = _currentDir;
		var response = Dialogs.saveFile
			( "Choose a name or select a PNG image"
			, "TileCraft will save the model data inside the rendered image"
			, _currentDir
			, _fileFilters
			);
		if (response!=null) {
			response = normalisePngPath(response);

			if (saveFile(response)) {
				setCurrentPath(response);
			}
		}
	}

	#else

	// TODO when fixed systools for Linux this has to be removed in favour of the native SaveFile Dialog
	private function saveAsFileCall() {
		var _dialog:DialogMessage = new DialogMessage(saveAsFileResponse,
																		true, //input
																		_currentDir + "/",
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.textInput'));
		_dialog.textOk = "Save";
		_dialog.textCancel = "Cancel";
		_dialog.selectable = true;
		_dialog.setWordWrap(true,400,100);
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
		_dialog.setFocus(); //set focus to textfield (need to be on stage)
	}

	private function saveAsFileResponse(dialog:Dialog) {
		var response:String = cast(dialog.value,String);
		if (response!="") {
			response = normalisePngPath(response);

			if (saveFile(response)) {
				setCurrentPath(response);
			}
		}
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}

	#end

	#if (windows)
	public function openFileCall() {
		var filters: FILEFILTERS =
			{ count: 1
			, descriptions: ["TileCraft PNG Model"]
			, extensions: ["*.png"]
			};
		var result = Dialogs.openFile
			( "Select a PNG image"
			, "Only PNG files made by TileCraft contains a valid model"
			, _fileFilters
			);
		if (result!=null) {
			var response = normalisePngPath(result[0]);
			if (openFile(response)) {
				setCurrentPath(response);
			}
		}
	}
	#else
	// TODO when fixed systools for Linux and Mac this has to be removed in favour of the native OpenFile Dialog
	private function openFileCall() {
		var _dialog:DialogMessage = new DialogMessage(openFileResponse,
																		true, //input
																		_currentDir + "/",
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.textInput'));
		_dialog.textOk = "Load";
		_dialog.textCancel = "Cancel";
		_dialog.selectable = true;
		_dialog.setWordWrap(true,400,100);
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
		_dialog.setFocus(); //set focus to textfield (need to be on stage)
	}

	private function openFileResponse(dialog:Dialog) {
		var response:String = cast(dialog.value,String);
		if (response!="") {
			response = normalisePngPath(response);
			if (openFile(response)) {
				setCurrentPath(response);
			}
		}
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}
	#end

	//============================================================================

	private function messageCall(string:String) {
		var _dialog:DialogMessage = new DialogMessage(dummyResponse,
																		false, //no input
																		string,
																		Style.getStyle('.dialog'),
																		Style.getStyle('.dialogBox'),
																		Style.getStyle('.button'),
																		Style.getStyle('.dialogText'));
		_dialog.showCancelButton = false;
		_dialog.drawDialogBox(rwidth,rheight);
		addChild(_dialog);
	}

	private function dummyResponse(dialog:Dialog) {
		removeChild(dialog);
		dialog.destroy();
		dialog = null;
	}

	//============================================================================

	public function saveFile(filename:String):Bool {
		#if sys
		// Render the _outputBitmap (TODO need to be better, maybe this system in ModelView)
		render(false);

		if (filename==null) return false;

		// Get FileOutput
		var fo:haxe.io.Output = null;
		try { fo = sys.io.File.write(filename,true); }
		catch (e:Dynamic){
			APP.error('File write error $e');
			fo = null;
		}

		// Export the model
		fo = _theModel.toPNG(fo,_outputView.getBitmapData());

		// Check if everything is ok
		if (fo==null) {
			messageCall("Unable to save: file I/O error\n"+filename);
			APP.error('Unable to save the Model to "$filename"');
			return false;
		} else {
			try { fo.close(); } catch(e:Dynamic) {}
			APP.error('Saved model to "$filename"');
			return true;
		}
		#else
		return false;
		#end
	}
		// messageCall("Unable to load: file I/O error\n"+filename);

	public function openFile(filename:String):Bool {
		#if sys
		if (filename==null) return false;

		// Get FileInput
		var fr:FileInput = null;
		try { fr = sys.io.File.read(filename,true); }
		catch (e:Dynamic){ APP.error('File read error $e'); fr = null; }

		// Import the model
		var model:Model = Model.fromPNG(fr);

		// Close the FileInput
		if (fr!=null) try { fr.close(); } catch(e:Dynamic) {}

		// Check if everything is ok
		if (model==null) {
			APP.error('Unable to load the model "$filename"');
			messageCall("Unable to load: file error\n"+filename);
			return false;
		} else {
			// prepare context
			changeModel(model);
			APP.error('Loaded model from "$filename"');
			return true;
		}
		#else
		return false;
		#end
	}

	private var _currentFilename:String = "";
	#if windows
	private var _currentDir:String = '';
	#else
	private var _currentDir:String = Sys.getEnv('HOME');
	#end

	private var _fileFilters: FILEFILTERS =
			{ count: 1
			, descriptions: ["TileCraft PNG Model"]
			, extensions: ["*.png"]
			};

	private static function directoryFromPath(path:String):String{
		var dirname = "";
    var r = ~/^(.*)[\\\/]([^\\\/]+)$/i; //win+unix
    if (r.match(path)) {
	   dirname = r.matched(1);
    }
		return dirname;
	}
	private static function filenameFromPath(path:String):String{
		var filename = "";
		var r = ~/[\\\/]([^\\\/]+)$/i; //win+unix
    if (r.match(path)) {
	   filename = r.matched(1);
    }
		return filename;
	}

	private function setCurrentPath(path:String="") {
		if (path!="") _currentDir = TileCraft.directoryFromPath(path);
		_currentFilename = TileCraft.filenameFromPath(path);
		updateStatusBar();
	}

	private function getCurrentPath():String {
		#if windows
		return _currentDir+"\\"+_currentFilename;
		#else
		return _currentDir+"/"+_currentFilename;
		#end
	}

	private function hasCurrentFilename():Bool {
		return _currentFilename!="";
	}

	private function normalisePngPath(path:String):String {
		// if not .png add extension to path
		var r = ~/\.png$/i;
    if (!r.match(path)) path+=".png";
		return path;
	}

	//============================================================================

	///////////////////////////////////////////////////////////////////////////
	// INTERFACE INITIALISER

	private inline function initButtonTestCases() {
		var button = new Button("TEST");
		button.x = 130;
		button.y = 100;
		button.style = Style.getStyle('button');
		button.selectable = true;
		button.listen = true;
		button.actionF = function(button:Button) { APP.log(button.toString()); };
		button.makeText("Button test");
		button.icon = APP.atlasSPRITES.getRegion(APP.ICON_CHECKBOX).toBitmapData();
		button.iconSelected = APP.atlasSPRITES.getRegion(APP.ICON_CHECKBOX_CHECKED).toBitmapData();
		addChild(button);

		var button = new Button("TEST2");
		button.x = 130;
		button.y = 150;
		button.style = Style.getStyle('button');
		button.listen = true;
		button.makeText("Button test");
		addChild(button);

		var button = new Button("TEST3");
		button.x = 130;
		button.y = 200;
		button.style = Style.getStyle('button');
		button.listen = true;
		button.icon = APP.atlasSPRITES.getRegion(APP.ICON_CHECKBOX).toBitmapData();
		addChild(button);

		var button = new Button("TEST4");
		button.x = 130;
		button.y = 250;
		button.style = Style.getStyle('button');
		button.listen = true;
		addChild(button);
	}

	private inline function initMainToolbar() {
		// MODEL TOOLBAR --------------------------------------------------------
		_mainToolbar = new Toolbar(2,true,
				Style.getStyle('.toolbar'),
				Style.getStyle('.button.toolbarButton'));
		_mainToolbar.addButton("new_shape",null,false,
											[APP.atlasSPRITES.getRegion(APP.ICON_NEW_SHAPE).toBitmapData()],
											newShape);
		_mainToolbar.addButton("copy_shape",null,false,
											[APP.atlasSPRITES.getRegion(APP.ICON_COPY_SHAPE).toBitmapData()],
											cloneShape);
		_mainToolbar.addButton("pointer",null,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_POINTER).toBitmapData()],
											toolbarPointerSelect);
		_mainToolbar.addButton("cube",
											ShapeType.CUBE,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CUBE).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("round_up",
											ShapeType.ROUND_UP,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_ROUND_UP).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("round_side",
											ShapeType.ROUND_SIDE,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_ROUND_SIDE).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("cylinder_up",
											ShapeType.CYLINDER_UP,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CYLINDER_UP).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("cylinder_side",
											ShapeType.CYLINDER_SIDE,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CYLINDER_SIDE).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("ramp_up",
											ShapeType.RAMP_UP,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_RAMP_UP).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("ramp_down",
											ShapeType.RAMP_DOWN,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_RAMP_DOWN).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("arch_up",
											ShapeType.ARCH_UP,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_ARCH_UP).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("arch_down",
											ShapeType.ARCH_DOWN,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_ARCH_DOWN).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("corner_se",
											ShapeType.CORNER_SE,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CORNER_SE).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("corner_sw",
											ShapeType.CORNER_SW,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CORNER_SW).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("corner_nw",
											ShapeType.CORNER_NW,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CORNER_NW).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.addButton("corner_ne",
											ShapeType.CORNER_NE,true,
											[APP.atlasSPRITES.getRegion(APP.ICON_SH_CORNER_NE).toBitmapData()],
											toolbarShapeTypeSelect);
		_mainToolbar.selectById('pointer');
		addChild(_mainToolbar);
	}

	private static inline var SAVE_FOLDER = "export"; //TODO to be removed

	private inline function initActionToolbar() {

		// ACTION TOOLBAR ----------------------------------------------------------

		var _actionToolbarAction = function(button:Button) { APP.log("NOT IMPLEMENTED"); }
		_actionToolbar = new Toolbar(0,false,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton'));
		_actionToolbar.addButton("new",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_NEW).toBitmapData()],
					function(_) { newModelCall(); });
		_actionToolbar.addButton("open",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_OPEN).toBitmapData()],
					function(_) { openFileCall(); });
		_actionToolbar.addButton("save",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_SAVE).toBitmapData()],
					function(_) { saveFileCall(); });
		_actionToolbar.addButton("saveas",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_SAVEAS).toBitmapData()],
					function(_) { saveAsFileCall(); });
		//_actionToolbar.addButton("-");
		_actionToolbar.addButton("render",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_RENDER).toBitmapData()],
					function(_) { renderOutput(false); });
		_actionToolbar.addButton("base64_input",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_BASE64_INPUT).toBitmapData()],
					function(_) { importBase64Call(); });
		_actionToolbar.addButton("base64_output",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_BASE64_OUTPUT).toBitmapData()],
					function(_) { exportBase64Call(); });
		_actionToolbar.addButton("quit",null,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_QUIT).toBitmapData()],
					function(_) { quitCall(); });
		addChild(_actionToolbar);
	}

	private inline function initOutput() {

		// OUTPUT VIEW -------------------------------------------------------------

		_outputView = new OutputView(this,PREVIEW_WIDTH);
		_outputView.t.setAnchoredPivot(Transformation.ANCHOR_BOTTOM_LEFT);
		_outputView.addEventListener(MouseEvent.CLICK,function(e:MouseEvent) { renderOutput(); });
		addChild(_outputView);

		// PREVIEW TOOLBAR ---------------------------------------------------------

		var _previewColorToolbarAction = function(button:Button) {
			_outputView.setBackgroundColor(cast(button.value,Int));
		};

		_previewColorToolbar = new Toolbar(0,true,Style.getStyle('.toolbar'),
					Style.getStyle('.button.toolbarButton.toolbarMiniButton.toolbarMiniButtonFull'));
		_previewColorToolbar.addButton('preview0',-1,true,
					[APP.makeColorIcon(_previewColorToolbar.styleButton,-1)],
					_previewColorToolbarAction);
		_previewColorToolbar.addButton('preview1',0xFFFFFF,true,
					[APP.makeColorIcon(_previewColorToolbar.styleButton,0xCCCCCC)],
					_previewColorToolbarAction);
		_previewColorToolbar.addButton('preview2',0,true,
					[APP.makeColorIcon(_previewColorToolbar.styleButton,0x333333)],
					_previewColorToolbarAction);
		addChild(_previewColorToolbar);

		// OUTPUT ACTION TOOLBAR ---------------------------------------------------

		_outputActionToolbar = new Toolbar(0,false,Style.getStyle('.toolbar'),
					Style.getStyle('.button.toolbarButton.toolbarMiniButton'));
		_outputActionToolbar.addButton('resize',0,false,
					[APP.atlasSPRITES.getRegion(APP.ICON_RESIZE).toBitmapData()],
					renderModeLoop);
		_outputActionToolbar.addButton('outline',0,true,
					[APP.atlasSPRITES.getRegion(APP.ICON_OUTLINE_NO).toBitmapData(),
							null,
							APP.atlasSPRITES.getRegion(APP.ICON_OUTLINE).toBitmapData()],
					outlineModeLoop);
		addChild(_outputActionToolbar);
	}

	private inline function initStatusbar() {

		// APP TITLE ---------------------------------------------------------------

		_statusBar = new Text("",18,APP.COLOR_WHITE,openfl.text.TextFormatAlign.CENTER,APP.FONT_LATO_BOLD);
		_statusBar.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_LEFT);
		addChild(_statusBar);
	}

	private inline function initAppTitle() {

		// APP TITLE ---------------------------------------------------------------

		var text = new Text(APP.APP_NAME.toUpperCase(),18,APP.COLOR_ORANGE,openfl.text.TextFormatAlign.CENTER,APP.FONT_SQUARE);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2;
		addChild(text);

		var text = new Text(APP.APP_STAGE.toUpperCase(),9,APP.COLOR_WHITE,openfl.text.TextFormatAlign.CENTER,APP.FONT_LATO_BOLD);
		text.t.setAnchoredPivot(Transformation.ANCHOR_MIDDLE_CENTER);
		text.t.x = TOOLBAR_WIDTH/2;
		text.t.y = ACTIONBAR_HEIGHT/2+12;
		addChild(text);
	}

	private inline function initColor() {

		// COLOR TOOLBAR --------------------------------------------------------

		_colorToolbar = new Toolbar(2,true,Style.getStyle('.toolbar'),Style.getStyle('.button.toolbarButton.toolbarButtonFull'));

		//---

		_colorPicker = new ColorPickerView(100,colorPickerSelect,function() {hideColorPicker();});

		//---

		_colorToolbar.addButton('palette0',0,true,
					[APP.makeColorIcon(_colorToolbar.styleButton,-1)],colorToolbarSelect);
		for (i in 1...16) {
			_colorToolbar.addButton('palette$i',i,true,
					[APP.makeColorIcon(_colorToolbar.styleButton,_theModel.getColor(i))],
					colorToolbarSelect,colorToolbarDoubleClick);
		}
		_colorToolbar.selectByIndex(1);

		addChild(_colorToolbar);
	}

	private inline function initModelView() {
		_modelView = new ModelView(this,RENDER_WIDTH,RENDER_HEIGHT);
		addChild(_modelView);
	}

	private inline function initShapeList() {
		_shapeViewList = new ShapeViewList(this,SHAPELIST_WIDTH,100);
		addChild(_shapeViewList);
	}
}
