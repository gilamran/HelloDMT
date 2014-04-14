package
{
	import com.xtdstudios.DMT.DMTBasic;
	import com.xtdstudios.common.assetsLoader.AssetsLoaderFromByteArray;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import lup.utils.BoundsHelper;
	
	import starling.display.Sprite;
	
	public class Main extends starling.display.Sprite
	{
		[Embed(source="/../assets/HelloDMT-Assets.swf", mimeType="application/octet-stream")] 
		private var AllAssetsClass:Class;

		// Free vector graphics from: http://all-free-download.com/free-vector/
		[Embed(source="/../assets/symbols.swf", mimeType="application/octet-stream")] 
		private var SymbolsAssetsClass:Class;
		
		private var _dmtBasic			: DMTBasic;
		private var _assetsLoader		: AssetsLoaderFromByteArray;
		
		public function Main()
		{
			super();
			initDMT();
		}
		
		private function initDMT():void 
		{
			_dmtBasic = new DMTBasic("HelloDMT", true);
			_dmtBasic.addEventListener(flash.events.Event.COMPLETE, dmtComplete);
			if (_dmtBasic.cacheExist() == true)
				_dmtBasic.process();	// will use the existing cache
			else
				loadAssets();
		}
		
		private function loadAssets():void
		{
			var assetsByteArrays : Vector.<ByteArray> = new Vector.<ByteArray>;
			assetsByteArrays.push(new SymbolsAssetsClass());
			assetsByteArrays.push(new AllAssetsClass());
			_assetsLoader = new AssetsLoaderFromByteArray(assetsByteArrays);
			_assetsLoader.addEventListener(Event.COMPLETE, onAssetsReady);
			_assetsLoader.initializeAllAssets(); // Loads the given SWFs and add them to the current ApplicationDomain
		}
		
		protected function onAssetsReady(event:Event):void
		{
			addVectorsToDMT();
		}
		
		/**
		 * Converts a DisplayObject to a MovieClip containing a single Bitmap.
		 */
		public static function flatternDisplayObject(target:DisplayObject):Bitmap
		{
			if (!target.parent) {
				var tempSprite:flash.display.Sprite = new flash.display.Sprite;
				tempSprite.addChild(target);
			}
			
			var container:DisplayObjectContainer = target.parent as DisplayObjectContainer;
			var rectOrig:Rectangle = container.getBounds(target.parent);
			var utils:BoundsHelper = new BoundsHelper();
			var rect:Rectangle = utils.getRealBounds(container);
			
			var bmp:BitmapData = new BitmapData(rect.width + 1, rect.height, true, 0);
			
			// offset for drawing
			var matrix:Matrix = new Matrix();
			matrix.translate( -rect.x, -rect.y);
			
			// Note: we are drawing parent object, not target itself: 
			// this allows to save all transformations and filters of target
			bmp.draw(container, matrix);
			
			var bm:Bitmap = new Bitmap(bmp);
			bm.name = target.name;
			if(tempSprite)
				tempSprite.removeChild(target);
			return bm;
		} 
		
		public static function flatternDisplayObjectToMovieClip(target:DisplayObject):MovieClip
		{	
			var bm:Bitmap = flatternDisplayObject(target);
			var mc:MovieClip = new MovieClip();
			mc.addChild(bm);
			mc.name = target.name;
			
			return mc;
		}
		
		protected function addItemToRaster(definition:String, name:String=null, flattern:Boolean=false, scale:Number=1.0):DisplayObject
		{
			var disp:DisplayObject;
			try {
				disp = new (ApplicationDomain.currentDomain.getDefinition(definition));
				if(!name)
					name = definition;
				disp.name = name;
				disp.width *= scale;
				disp.height *= scale;
				if(flattern)
					disp = flatternDisplayObject(disp) as DisplayObject;
				_dmtBasic.addItemToRaster(disp);
			} catch (e:Error) { trace(e.message); }
			return disp;
		}
		
		private var stage:int = 0;
		private function addVectorsToDMT():void 
		{
			//_dmtBasic.
			//_assetsLoader.
			addItemToRaster("Square", "square");
			addItemToRaster("Circle", "circle");
			addItemToRaster("Triangle", "triangle");
			addItemToRaster("Triangle", "www", false, 1.2);
			addItemToRaster("toys03_Ovni", "ovni");
			addItemToRaster("toys03_Bicicleta", "bicicleta");
			addItemToRaster("cute_animals_Abeja", "abeja", false, 3); // abeja  Dictionary
			addItemToRaster("cute_animals_Gamo", "gamo", false);
			_dmtBasic.process(true, 0); // will rasterize the given assets
		}
		
		protected function getAsset(name:String):starling.display.DisplayObject
		{
			var ret:starling.display.DisplayObject;
			try {
				ret = _dmtBasic.getAssetByUniqueAlias(name);
			} catch (e:Error) { trace(e.message); }
				
			return ret;
		}
		
		protected function addAsset(name:String, x:int=0, y:int=0):starling.display.DisplayObject
		{
			var o : starling.display.DisplayObject = getAsset(name); 
			if(o) {
				if(x)
					o.x = x;
				if(y)
					o.y = y;
				addChild(o);
			}
			return o;
		}
		
		protected function dmtComplete(event:Event):void
		{
//			if(stage == 0) {
//				stage = 1;
//				addItemToRaster("cute_animals_Abeja", "abeja", false, 3); // abeja  Dictionary
//				addItemToRaster("cute_animals_Gamo", "gamo", false);
//				_dmtBasic.process(true, 0); // will rasterize the given assets
//			} else {
//				draw();
//			}
			draw();
		}
		
		protected function draw():void
		{
			var o : starling.display.DisplayObject;
			addAsset("ovni", 100, 100); 
			addAsset("gamo", 150, 150);
			//addAsset("square", 100, 150);
			//addAsset("circle", 150, 150);
//			var starlingTriangle : Sprite = getAsset("triangle") as starling.display.Sprite;
//			starlingTriangle.x = 100;
//			starlingTriangle.y = 300;
//			addChild(starlingTriangle);
//			starlingTriangle.getChildByName("right_eye_instance").rotation = Math.PI/2;
//			starlingTriangle.getChildByName("left_eye_instance").rotation = -Math.PI/2;
			
			addAsset("www", 50, 200);
			addAsset("abeja", 50, 250);

		}
	}
}
