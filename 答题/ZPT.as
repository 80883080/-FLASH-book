package
{
	import com.zoolon.core.CoreSystem;
	import flash.display.Sprite;
	
	public class ZPT extends Sprite
	{
		public function ZPT()
		{
			CoreSystem.waterMarkerEnable = false;
			CoreSystem.start(this);
		}
	}
}