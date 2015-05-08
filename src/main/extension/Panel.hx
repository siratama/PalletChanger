package extension;

import adobe.cep.CSEventType;
import adobe.cep.CSEventScope;
import adobe.cep.CSEvent;
import extension.overlay.OverlayWindow;
import extension.option.Setting;
import extension.color_sampler.palette.PaletteKind;
import extension.palette_change.PaletteChangeUI;
import extension.color_sampler.CanvasColorSamplerUI;
import js.Browser;
import haxe.Unserializer;
import haxe.Timer;

class Panel
{
	private var csInterface:AbstractCSInterface;
	private var timer:Timer;
	private var mainFunction:Void->Void;
	private var jsxLoader:JsxLoader;

	private var canvasColorSamplerRunner:CanvasColorSamplerRunner;
	private var canvasColorSamplerUI:CanvasColorSamplerUI;

	private var paletteChangeRunner:PaletteChangeRunner;
	private var paletteChangeUI:PaletteChangeUI;

	public static function main(){
		new Panel();
	}
	public function new(){
		Browser.window.addEventListener("load", initialize);
	}
	private function initialize(event)
	{
		csInterface = AbstractCSInterface.create();
		setPersistent();
		jsxLoader = new JsxLoader();

		canvasColorSamplerUI = CanvasColorSamplerUI.instance;
		paletteChangeUI = PaletteChangeUI.instance;
		Setting.instance;
		OverlayWindow.instance;
		canvasColorSamplerRunner = new CanvasColorSamplerRunner();
		paletteChangeRunner = new PaletteChangeRunner();

		mainFunction = loadJsx;
		timer = new Timer(100);
		timer.run = run;
	}
	private function setPersistent()
	{
		var csEvent = new CSEvent();
		csEvent.type = CSEventType.PERSISTENT;
		csEvent.scope = CSEventScope.APPLICATION;
		csEvent.extensionId = untyped window.__adobe_cep__.getExtensionId();
		csInterface.csInterface.dispatchEvent(csEvent);
	}

	private function run()
	{
		mainFunction();
	}
	private function loadJsx()
	{
		jsxLoader.run();
		if(jsxLoader.isFinished()){
			mainFunction = observeToClickUI;
		}
	}

	//
	private function observeToClickUI()
	{
		canvasColorSamplerUI.run();
		if(canvasColorSamplerUI.palletContainer.before.scanButton.isClicked()){
			initializeToCallCanvasColorSampler(PaletteKind.BEFORE);
		}
		else if(canvasColorSamplerUI.palletContainer.after.scanButton.isClicked()){
			initializeToCallCanvasColorSampler(PaletteKind.AFTER);
		}
		else if(paletteChangeUI.runButton.isClicked()){
			initializeToCallPaletteChange();
		}
	}

	//
	private function initializeToCallCanvasColorSampler(paletteKind:PaletteKind)
	{
		canvasColorSamplerRunner.call(paletteKind);
		mainFunction = callCanvasColorSampler;
	}
	private function callCanvasColorSampler()
	{
		canvasColorSamplerRunner.run();
		if(canvasColorSamplerRunner.isFinished()){
			mainFunction = observeToClickUI;
		}
	}

	//
	private function initializeToCallPaletteChange()
	{
		var rgbHexValueSets = canvasColorSamplerUI.palletContainer.getRgbHexValueSets();
		paletteChangeRunner.call(rgbHexValueSets);
		mainFunction = callPaletteChange;
	}
	private function callPaletteChange()
	{
		paletteChangeRunner.run();
		if(paletteChangeRunner.isFinished()){
			mainFunction = observeToClickUI;
		}
	}
}

