package
{
	import com.xtdstudios.DMT.DMTBasic;
	import com.xtdstudios.common.assetsLoader.AssetsLoaderFromByteArray;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.utils.ByteArray;
	
	import starling.display.Sprite;
	
	public class Main extends starling.display.Sprite
	{
		[Embed(source="/../assets/HelloDMT-Assets.swf", mimeType="application/octet-stream")] 
		private var AllAssetsClass:Class;
		
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
			assetsByteArrays.push(new AllAssetsClass());
			_assetsLoader = new AssetsLoaderFromByteArray(assetsByteArrays);
			_assetsLoader.addEventListener(Event.COMPLETE, onAssetsReady);
			_assetsLoader.initializeAllAssets(); // Loads the SWF
		}
		
		protected function onAssetsReady(event:Event):void
		{
			addVectorsToDMT();
		}
		
		private function addVectorsToDMT():void 
		{
			var square : DisplayObject = new (_assetsLoader.getAssetClass("Square") as Class) as DisplayObject;
			square.name = "square";
			
			var circle : DisplayObject = new (_assetsLoader.getAssetClass("Circle") as Class) as DisplayObject;
			circle.name = "circle";
			
			var triangle : DisplayObject = new (_assetsLoader.getAssetClass("Triangle") as Class) as DisplayObject;
			triangle.name = "triangle";
			
			_dmtBasic.addItemToRaster(square);
			_dmtBasic.addItemToRaster(circle);
			_dmtBasic.addItemToRaster(triangle);
			_dmtBasic.process(); // will rasterize the given assets
		}
		
		protected function dmtComplete(event:Event):void
		{
			var starlingSquare : Sprite = _dmtBasic.getAssetByUniqueAlias("square") as starling.display.Sprite;
			starlingSquare.x = 100;
			starlingSquare.y = 100;
			addChild(starlingSquare);

			var starlingCirlce : Sprite = _dmtBasic.getAssetByUniqueAlias("circle") as starling.display.Sprite;
			starlingCirlce.x = 100;
			starlingCirlce.y = 300;
			addChild(starlingCirlce);

			var starlingTriangle : Sprite = _dmtBasic.getAssetByUniqueAlias("triangle") as starling.display.Sprite;
			starlingTriangle.x = 100;
			starlingTriangle.y = 500;
			addChild(starlingTriangle);
			
			starlingTriangle.getChildByName("right_eye_instance").rotation = Math.PI/2;
			starlingTriangle.getChildByName("left_eye_instance").rotation = -Math.PI/2;
		}
	}
}
