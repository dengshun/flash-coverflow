package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;

	import com.greensock.*;
	import com.greensock.easing.*;

	public class CoverflowItem extends Sprite {

		private var m_data:Object = new Object();
		private var m_loader:Loader = new Loader();
		private var m_padding:uint;
		private var m_holder:MovieClip = new MovieClip();
		
		private var m_alpha:Number = 35;
		private var m_ratio:Number = 50;
		private var m_distance:Number = 0;
		private var m_updateTime:Number = -1;
		private var m_reflectionDropoff:Number = 1;
		
		public function CoverflowItem(data:Object):void {
			m_data = data;
			addChild(m_holder)
			
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, click);
		}
		
		public function set image(input:String):void {
			m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageComplete);
			m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, imageIOError);
			m_loader.load(new URLRequest(input));
		}
		
		public function set padding(padding:uint):void {
			m_padding = padding;
			m_loader.x = m_loader.y = padding;
		}
		
		public function set imageWidth(width:Number):void {
			this.background.width = width + m_padding * 2;
		}

		public function set imageHeight(height:Number):void {
			this.background.height = height + m_padding * 2;
		}

		public function setReflection(data:Object) {
			m_alpha = data.alpha;
			m_ratio = data.ratio;
			m_distance = data.distance;
			m_updateTime = data.updateTime;
			m_reflectionDropoff = data.dropoff;
		}
		
		private function imageComplete(e:Event):void {
			m_holder.addChild(m_loader);
			
			var masterWidth = this.background.width - m_padding * 2;
			var masterHeight = this.background.height - m_padding * 2;
			
			var masterRatio =  masterWidth / masterHeight;
			
			var width:Number = m_loader.content.width;
			var height:Number = m_loader.content.height;
			
			var factor:Boolean = (width / masterRatio) > height;
			
			
			var scaleFactor = 1;
			if (factor) {
				if (width > masterWidth) {
					scaleFactor = masterWidth / width;
				}
			} else {
				if (height > masterHeight) {
					scaleFactor = masterHeight / height;
				}
			}
			
			m_loader.content.scaleX = scaleFactor;
			m_loader.content.scaleY = scaleFactor;
			
			m_loader.content.y = (masterHeight - m_loader.content.height) >> 1;
			m_loader.content.x = (masterWidth - m_loader.content.width) >> 1;
			
			var reflection:Reflect = new Reflect({ target: this,
											   alpha: m_alpha,
											   ratio: m_ratio,
											   distance: m_distance,
											   updateTime: m_updateTime,
											   reflectionDropoff: m_reflectionDropoff});
		}
		
		private function imageIOError(e:IOErrorEvent):void {
			trace("CoverflowItem - Error Loading");
		}
		
		private function click(e:MouseEvent):void {
			dispatchEvent(new CoverflowItemEvent(CoverflowItemEvent.COVERFLOWITEM_SELECTED, m_data));
		}
	}
}