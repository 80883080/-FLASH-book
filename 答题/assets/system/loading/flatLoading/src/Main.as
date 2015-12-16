package 
{
	import flash.display.Sprite;
	
	/**
	 * ...
	 * @author Blank
	 */
	public class Main extends Sprite 
	{
		private var loadingMC:LoadingMC;
		
		public function Main():void 
		{
			loadingMC = new LoadingMC();
			this.addChild(loadingMC);
			loadingMC.setValue(0);
		}
		
		public function set progress(value:Number):void
		{
			loadingMC.setValue(int(value));
		}
	}
	
}