package 
{
	//进度
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	public class LoadingMC extends Sprite
	{
		[Embed(source="loading.png")]
		public static var Loading_png:Class;
		
		public static var skin:Bitmap;
		private var perText:TextField;
		private var rnd:Sprite;
		public function LoadingMC(_width:Number = 80,_height:Number = 80,size:Number = 16,autoRemove:Boolean = true)
		{
			if(skin == null)
			{
				skin = new Loading_png();
			}
			
			var bg_bpd:BitmapData = new BitmapData(133,133,true,0);
			bg_bpd.draw(skin,new Matrix(1,0,0,1,-6,-6));
			var bg:Bitmap = new Bitmap(bg_bpd);
			bg.smoothing = true;
			this.addChild(bg);
			bg.x = -135/2;
			bg.y = -120/2;
			
			rnd = new Sprite();
			rnd.graphics.beginFill(0xffffff,0);
			rnd.graphics.drawCircle(0,0,69/2);
			rnd.graphics.endFill();
			this.addChild(rnd);
			rnd.cacheAsBitmap = true;
			
			var light_bpd:BitmapData = new BitmapData(71,79,true,0);
			light_bpd.draw(skin,new Matrix(1,0,0,1,-178,-26),null,null);
			var light:Bitmap = new Bitmap(light_bpd);
			light.smoothing = true;
			rnd.addChild(light);
			light.x = -34.5-1;
			light.y = -34.5-9;
			
			skin = null;
			perText = new TextField();
			perText.width = _width;
			perText.height = 30;
			perText.x = -_width/2;
			perText.y = -11;
			perText.selectable = false;
			perText.cacheAsBitmap = true;
			this.addChild(perText);
			var perTextttf:TextFormat = new TextFormat();
			perTextttf.size = size;
			perTextttf.font = "宋体";
			perTextttf.color = 0xffffff;
			perTextttf.align = TextFormatAlign.CENTER;
			perText.defaultTextFormat = perTextttf;
			this.addEventListener(Event.ENTER_FRAME,EnterFrame);
			if(autoRemove)
			{
				this.addEventListener(Event.REMOVED_FROM_STAGE,onRemove);
			}
		}
		
		protected function onRemove(e:Event):void
		{
			perText = null;
			this.removeEventListener(Event.ENTER_FRAME,EnterFrame);
			this.removeEventListener(Event.REMOVED_FROM_STAGE,onRemove);
		}
		
		private function EnterFrame(e:Event):void
		{
			rnd.rotation+=2;
		}
		
		public function setValue(value:Number):void
		{
			perText.text = value+"%";
		}
		
		public function setText(str:String):void
		{
			perText.text = str;
		}
	}
}