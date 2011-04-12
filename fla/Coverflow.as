package {
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.MovieClip;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.navigateToURL;
	import flash.display.Stage;
	import flash.utils.setTimeout;

	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;

	import com.adobe.serialization.json.JSON;
	import flash.external.ExternalInterface;
	
	public class Coverflow extends Sprite {		
		private var m_background:Background;

		private var m_coverflowSpacing: Number = 30;
		private var m_coverflowItemsTotal:Number;
		private var m_coverflowImageWidth:Number;
		private var m_coverflowImageHeight:Number;
		private var m_coverLabelPositionY:Number;
		private var m_coverImagePadding:Number = 4;
		private var m_centerCoverflowZPosition:Number = -125;
		
		private var m_transitionTime:Number = 0.75;

		private var m_centerX:Number;
		private var m_centerY:Number;

		private var m_reflectionData;

		private var m_coverLabel:CoverflowTitle = new CoverflowTitle();
		private var m_coverSlider:Scrollbar;
		
		private var m_coverArray:Array = new Array();
		private var m_data:Array = new Array();

		private var m_startIndexInCenter:Boolean = true;
		private var m_startIndex:Number = 0;
		private var m_currentCover:Number;
		
		private var m_stage:Stage;
		private var m_testDataLoader:URLLoader;
		
		public function Coverflow(width:Number, height:Number, stage:Stage = null):void {
			m_stage = stage;
			
			m_centerX = (width >> 1);
			m_centerY = (height >> 1) - 20;
			
			m_background = new Background();
			
			m_background.width = width;
			m_background.height = height;
			
			try {
				ExternalInterface.addCallback("externalCreateCoverflow", createCoverflow);
				ExternalInterface.call("createCoverflow");
			} catch (e:Error) {
				trace(e.message);
				loadTestData();
			}
		}
		
		private function loadTestData():void {
			m_testDataLoader = new URLLoader();
			m_testDataLoader.load(new URLRequest("data/data.json"));
			m_testDataLoader.addEventListener(Event.COMPLETE, loadTestDataComplete);
			m_testDataLoader.addEventListener(IOErrorEvent.IO_ERROR, loadTestDataError);
		}
		
		private function loadTestDataComplete(e:Event):void {
			createCoverflow(e.target.data);
		}

		private function loadTestDataError(event:IOErrorEvent):void {
			trace("Coverflow XML Load Error: "+ event);
		}

		public function reset():void {
			if (m_stage) {
				m_stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			}
			
			while (numChildren) {
				removeChildAt(0);
			}
		}
		
		public function createCoverflow(data:String):void {
			var json:Object = JSON.decode(data);
			createCoverflowImpl(json);
		}
		
		public function createCoverflowImpl(data:*):void {
			reset();
			
			var backgColor:String = data.settings.backgroundColor;
			
			if (backgColor == null) {
				backgColor = "0x000000";
			}
			
			addChild(m_background);
			
			TweenPlugin.activate([TintPlugin]);
			TweenLite.to(m_background, 0, {tint:backgColor});
			
			var labelColor:String = data.settings.labelColor;
			if (labelColor == null) {
				labelColor = "0xFFFFFF";
			}
			
			addKeyboardEventListener();
			processJsonData(data, labelColor);
		}
		
		private function addKeyboardEventListener():void {
			try {
				if (m_stage) {
					m_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
				}
			} catch (e:Error) {
				trace("An error has been handled during addition of a keyboard handler: " + e.message);
			}
		}
		
		private function processJsonData(data:*, labelColor:String):void {
			m_coverflowItemsTotal = data.covers.length;
			m_coverflowSpacing = Number(data.settings.coverflowSpacing);
			m_coverflowImageWidth = Number(data.settings.imageWidth);
			m_coverflowImageHeight = Number(data.settings.imageHeight);
			m_coverLabelPositionY = Number(data.settings.coverLabelPositionY);
			m_transitionTime = Number(data.settings.transitionTime);
			m_centerCoverflowZPosition = Number(data.settings.centerCoverflowZPosition);

			m_coverImagePadding = Number(data.settings.imagePadding)
			
			m_reflectionData = {
				alpha: Number(data.settings.reflectionAlpha),
				ratio: Number(data.settings.reflectionRatio),
				distance: Number(data.settings.reflectionDistance),
				updateTime: Number(data.settings.reflectionUpdateTime),
				dropoff: Number(data.settings.reflectionDropoff)
			};
			
			m_startIndex = Number(data.settings.startIndex);
			m_startIndexInCenter = Boolean(data.settings.startIndexInCenter);
			
			if (data.covers.length > 0) {
				for (var i = 0; i < m_coverflowItemsTotal; i++) {
					var current:Object = new Object();
					
					current.image = data.covers[i].image;
					current.title = data.covers[i].title;
					current.id = data.covers[i].id;
					
					m_data[i] = current;
				}
				
				loadCover(labelColor);
			}
		}
		
		private function keyDownHandler(e:KeyboardEvent):void {
			if (e.keyCode == 37 || e.keyCode == 74) {
				gotoPreviousCover();
			}
			
			if (e.keyCode == 39 || e.keyCode == 75) {
				gotoNextCover();
			}
		}

		private function gotoPreviousCover(e:Event=null):void {
			m_currentCover--;
			
			if (m_currentCover < 0) {
				m_currentCover = m_coverflowItemsTotal - 1;
			}
			
			m_coverSlider.value = m_currentCover;
			gotoCoverflowItem(m_currentCover);
		}

		private function gotoNextCover(e:Event=null):void {
			m_currentCover++;
			
			if (m_currentCover > m_coverflowItemsTotal - 1) {
				m_currentCover = 0;
			}
			m_coverSlider.value = m_currentCover;
			gotoCoverflowItem(m_currentCover);
		}

		private function loadCover(labelColor:String):void {
			for (var i:int = 0; i < m_coverflowItemsTotal; i++) {
				var cover:Sprite = createCover(i, m_data[i].image);
				m_coverArray[i] = cover;
				cover.y = m_centerY;
				cover.z = 0;
			}

			if (m_startIndexInCenter) {
				m_startIndex = m_coverArray.length >> 1;
			}
			
			m_currentCover = m_startIndex;
			m_coverSlider = new Scrollbar(m_coverflowItemsTotal, m_stage);
			m_coverSlider.value = m_startIndex;
			m_coverSlider.x = (m_stage.stageWidth / 2) - (m_coverSlider.width / 2);
			m_coverSlider.y = m_stage.stageHeight - 40;
			m_coverSlider.addEventListener("UPDATE", coverSliderUpdate);
			m_coverSlider.addEventListener("PREVIOUS", coverSliderPrevious);
			m_coverSlider.addEventListener("NEXT", coverSliderNext);
			addChild(m_coverSlider);

			m_coverLabel.x = (m_stage.stageWidth / 2) - (m_coverLabel.width / 2);
			m_coverLabel.y = m_coverLabelPositionY;
			m_coverLabel.name = "coverLabel";
			addChild(m_coverLabel);
			
			TweenLite.to(m_coverLabel, 0, {tint: labelColor});
			
			gotoCoverflowItem(m_startIndex);
		}

		private function coverSliderUpdate(event:Event):void {
			var value:Number = m_coverSlider.value;
			gotoCoverflowItem(value);
			event.stopPropagation();
		}

		private function coverSliderPrevious(e:Event):void {
			gotoPreviousCover();
		}

		private function coverSliderNext(e:Event):void {
			gotoNextCover();
		}

		private function gotoCoverflowItem(index:int):void {
			m_currentCover = index;
			reOrderCover(index);
			if (m_coverSlider) {
				m_coverSlider.value = index;
			}
		}

		private function handleCoverSelected(event:CoverflowItemEvent):void {
			var currentCover:uint = event.data.id;

			if (m_coverArray[currentCover].rotationY == 0) {
				try {
					trace(m_data[currentCover].id);
					ExternalInterface.call("coverflowAction", m_data[currentCover].id);
				} catch (e:Error) {
					trace(e.message);
				}
			} else {
				gotoCoverflowItem(currentCover);
			}

		}

		private function reOrderCover(currentCover:uint):void {
			for (var i:uint = 0, len:uint = m_coverArray.length; i < len; i++) {
				var cover:Sprite = m_coverArray[i];

				if (i < currentCover) {
					//Left Side
					TweenLite.to(cover, m_transitionTime, {x: (m_centerX - (currentCover - i) * m_coverflowSpacing - m_coverflowImageWidth / 2), z: (m_coverflowImageWidth / 2), rotationY: -65});
				} else if (i > currentCover) {
					//Right Side
					TweenLite.to(cover, m_transitionTime, {x: (m_centerX + (i - currentCover) * m_coverflowSpacing + m_coverflowImageWidth / 2), z: (m_coverflowImageWidth / 2), rotationY: 65});
				} else {
					//Center Coverflow
					TweenLite.to(cover, m_transitionTime, {x: m_centerX, z: m_centerCoverflowZPosition, rotationY: 0});

					//Label Handling
					m_coverLabel.text.text = m_data[i].title;
					m_coverLabel.alpha = 0;
					TweenLite.to(m_coverLabel, 0.75, {alpha:1, delay:0.2});

				}
			}
			
			for (i = 0; i < currentCover; i++) {
				addChild(m_coverArray[i]);
			}
			
			for (i = m_coverArray.length - 1; i > currentCover; i--) {
				addChild(m_coverArray[i]);
			}

			addChild(m_coverArray[currentCover]);
			
			if (m_coverSlider) {
				addChild(m_coverSlider);
				addChild(m_coverLabel);
			}			
		}
		
		
		private function createCover(num:uint, url:String):Sprite {
			var data:Object = new Object();
			data.id = num;
			
			var cover:CoverflowItem = new CoverflowItem(data);

			cover.addEventListener(CoverflowItemEvent.COVERFLOWITEM_SELECTED, handleCoverSelected);

			cover.name = num.toString();
			cover.image = url;
			cover.padding = m_coverImagePadding;
			cover.imageWidth = m_coverflowImageWidth;
			cover.imageHeight = m_coverflowImageHeight;
			cover.setReflection(m_reflectionData);

			var coverItem:Sprite = new Sprite();
			cover.x =- m_coverflowImageWidth / 2 - m_coverImagePadding;
			cover.y =- m_coverflowImageHeight / 2 - m_coverImagePadding;
			coverItem.addChild(cover);
			coverItem.name = num.toString();

			return coverItem;
		}

	}
}