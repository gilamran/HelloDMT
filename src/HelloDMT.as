package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import starling.core.Starling;
	
	public class HelloDMT extends Sprite
	{
		private var m_starling:Starling;
		
		public function HelloDMT()
		{
			super();
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Starling.multitouchEnabled = true;
			Starling.handleLostContext = true;
			
			// initialize Starling
			m_starling = new Starling(Main, stage, new Rectangle(0,0, 480, 800));
			m_starling.simulateMultitouch  = false;
			m_starling.start();
		}
	}
}