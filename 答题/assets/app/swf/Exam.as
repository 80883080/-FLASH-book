package  
{
	import flash.display.Sprite;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.TransformAroundCenterPlugin;
	/**
	 * ...
	 * @author vincent
	 */
	dynamic public class Exam extends Sprite
	{
		public var BroadcastCenter:Object;
		public var CustomEvent:Object
		private var _data:XML;
		private var winController:WinController;
		public function Exam() 
		{
			win.visible = false;
			maskMC.visible = false;
			TweenPlugin.activate([TransformAroundCenterPlugin]);
			
			winController = new WinController(win);
		}

		public function set data(_ds:XML):void
		{
			_data = _ds;
			ExamManager.init( {
				list:_data.exams.exam,
				BroadcastCenter:BroadcastCenter
			});
			BroadcastCenter.instance.addEventListener(CustomEvent.TYPE,function(e:*):void{
				switch(e.name)
				{
					case "showRandomExam":
						showRandomExam();
						break;
					case "examFinish":
						examFinish();
						break;
				}
			});
		}

		public function get data():XML
		{
			return _data;
		}
		
		/**
		 * 循环显示题目
		 */
		private function showRandomExam():void
		{
			var randomExamSource = ExamManager.getRandomExam();
			winController.setSource(randomExamSource);
			winController.open(maskMC, this);
		}
		
		private function examFinish():void
		{
			ExamManager.reset();
		}
	}

}

import com.greensock.easing.Expo;
import com.greensock.TweenLite;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import ui.AnswerItemUI;
import flash.utils.setTimeout;

class ExamManager
{
	private static var list:XMLList;
	private static var selectableList:Array;
	private static var currentExamIdx:int = 0;
	private static const TOTAL_EXAM_COUNT:int = 10;
	private static var BroadcastCenter:Object;
	private static var examResult:int = 0;
	public static function init(option:Object):void
	{
		list = option.list;
		BroadcastCenter = option.BroadcastCenter;
		initSelectableList();
	}
	
	private static function initSelectableList():void
	{
		selectableList = [];
		var len:int = list.length();
		for (var i:int = 0; i < len;i++ )
		{
			selectableList.push(i);
		}
	}
	
	public static function getRandomExam():XML
	{
		var randomIdx:int = Math.round(Math.random() * (selectableList.length - 1));
		var result = XML(list[selectableList[randomIdx]]);
		selectableList.splice(randomIdx, 1);
		return result;
	}
	
	public static function checkAnswer(source:XML,selectedData:XML):Boolean
	{
		var len:int = source.answer.length();
		for (var i:int = 0; i < len;i++ )
		{
			if (source.answer[i].toXMLString() == selectedData.toXMLString() && source.answer[i].@selected != undefined)
			{
				return true;
			}
		}
		return false;
	}
	
	public static function handleAnswerResult(answerResult:Boolean):void
	{
		if (answerResult) examResult++;
		var canvasId:String = (answerResult?"r":"w")+currentExamIdx;
		send(<CanvasControlEvent id={canvasId} action='transition' effect='scaleIn' point='0,0' />);
		var btId:String = "sbt"+currentExamIdx;
		send(<CanvasControlEvent id={btId} action='set' mouseEnabled='false' />);
		nextExam();
	}
	
	private static function nextExam():void
	{
		currentExamIdx++;
		if (currentExamIdx<TOTAL_EXAM_COUNT)
		{
			var lineId:String = "line" + currentExamIdx;
			send(<CanvasControlEvent id={lineId} action='transition' effect='fadeIn' />);
			var btId:String = "sbt"+currentExamIdx;
			send(<CanvasControlEvent id={btId} action='set' alpha='1' mouseEnabled='true' />);
		}
		else
		{
			var btId:String = "sbt"+currentExamIdx;
			send(<CanvasControlEvent id={btId} action='set' alpha='1' mouseEnabled='true' />);
			send(<CanvasControlEvent id='resultLabel' action='set' text={examResult} />);
			setTimeout(function():void{trace(send(<NavigationEvent controllerId='nav' showIdx='2' effect='flyIn' />))}, 500);
			
			
		}
	}
	
	public static function send(msg:XML):void
	{
		var xmlList:XMLList = XMLList(<events></events>);
		xmlList.appendChild(msg);
		BroadcastCenter.sendEvent(xmlList);
	}
	
	public static function reset():void
	{
		currentExamIdx = 0;
		examResult = 0;
		initSelectableList();
		send(<Events src="reset" />);
	}
}

class WinController
{
	public var view:MovieClip;
	private var items:Array = [];
	private var selectedItem:AnswerItemController;
	private var contentContainer:Sprite;
	private var maskMC:MovieClip;
	private var container:Sprite;
	private var source:XML;
	public function WinController(view:MovieClip)
	{
		this.view = view;
		contentContainer = new Sprite();
		this.view.addChild(contentContainer);
		view.titleTf.x = 0;
		view.titleTf.y = 0;
		contentContainer.addChild(view.titleTf);
		view.submitBt.buttonMode = true;
		this.view.addChild(view.submitBt);
		view.submitBt.addEventListener(MouseEvent.CLICK, submitHandler);
	}
	
	public function setSource(source:XML):void
	{
		clear();
		this.source = source;
		view.titleTf.width = 440;
		view.bg.scaleX = 1;
		view.bg.scaleY = 1;
		view.titleTf.text = source.title;
		view.titleTf.width = view.titleTf.textWidth + 8;
		view.titleTf.height = view.titleTf.textHeight + 8;
		var len:int = source.answer.length();
		for (var i:int = 0; i < len;i++ )
		{
			var ds:XML = XML(source.answer[i]);
			var item:AnswerItemController = new AnswerItemController(ds);
			item.view.x = 0;
			item.view.y = i * (item.view.height+10) + view.titleTf.height+10;
			contentContainer.addChild(item.view);
			item.addEventListener(AnswerItemController.ITEM_CLICK, itemSelectedHandler);
			items.push(item);
		}
		
		//set bg
		var scale:Number = 2.5;
		var ts = contentContainer.width / view.bg.width > contentContainer.height / view.bg.height ? contentContainer.width * scale / view.bg.width : contentContainer.height * (scale-0.5) / view.bg.height;
		view.bg.scaleX = ts;
		view.bg.scaleY = ts;
		
		contentContainer.x = (view.bg.width - contentContainer.width) * 0.5;
		contentContainer.y = (view.bg.height - contentContainer.height) * 0.5;
		
		//set submitBt
		view.submitBt.x = contentContainer.x + contentContainer.width;
		view.submitBt.y = contentContainer.y + contentContainer.height-50;
	}
	
	private function clear():void
	{
		while (items.length>0)
		{
			var item:AnswerItemController = items[0];
			contentContainer.removeChild(item.view);
			items.shift();
		}
		selectedItem = null;
		source = null;
	}
	
	private function itemSelectedHandler(e:Event):void
	{
		selectItem(e.target as AnswerItemController);
	}
	
	public function open(withMask:MovieClip,container:Sprite):void
	{
		this.maskMC = withMask;
		this.container = container;
		maskMC.visible = true;
		maskMC.x = 0;
		maskMC.y = 0;
		maskMC.width = 1920;
		maskMC.height = 1080;
		container.addChild(maskMC);
		view.visible = true;
		view.x = (1920 - view.width) * 0.5;
		view.y = (1080 - view.height) * 0.5;
		container.addChild(view);
		TweenLite.from(view,0.5,{transformAroundCenter:{scale:0},ease:Expo.easeInOut});
	}
	
	public function close():void
	{
		view.mouseChildren = false;
		TweenLite.to(maskMC,0.5,{alpha:0});
		TweenLite.to(view, 0.5, { transformAroundCenter: { scale:0 }, ease:Expo.easeInOut, onComplete:function():void {
			view.visible = false;
			TweenLite.to(view, 0, {transformAroundCenter: { scale:1 } });
			view.mouseChildren = true;
			maskMC.alpha = 1;
			container.removeChild(maskMC);
			container.removeChild(view);
		}});
	}
	
	private function selectItem(item:AnswerItemController):void
	{
		if (selectedItem != null)
		{
			selectedItem.selected = false;
		}
		selectedItem = item;
		selectedItem.selected = true;
	}
	
	private function submitHandler(e:MouseEvent):void
	{
		if (selectedItem == null) return;
		var answerIsRight:Boolean = ExamManager.checkAnswer(source, selectedItem.data);
		ExamManager.handleAnswerResult(answerIsRight);
		close();
	}
}

class AnswerItemController extends EventDispatcher
{
	public static const ITEM_CLICK:String = "itemClick";
	public var data:XML;
	public var view:MovieClip;
	public var bt:Sprite;
	public function AnswerItemController(data:XML)
	{
		this.data = data;
		view = new AnswerItemUI();
		view.cb.stop();
		view.tf.text = data;
		view.tf.width = view.tf.textWidth + 8;
		view.tf.height = view.tf.textHeight + 8;
		
		bt = new Sprite();
		bt.graphics.beginFill(0xff0000, 0);
		bt.graphics.drawRect(0, 0, view.tf.x + view.tf.width, view.tf.height);
		bt.graphics.endFill();
		view.addChild(bt);
		bt.buttonMode = true;
		bt.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
			dispatchEvent(new Event(ITEM_CLICK));
		} );
	}
	
	public function set selected(value:Boolean):void
	{
		view.cb.gotoAndStop(value?2:1);
	}
}