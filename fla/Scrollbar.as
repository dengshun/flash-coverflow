package {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.Stage;

	import com.greensock.*;
	import com.greensock.easing.*;

	public class Scrollbar extends Sprite {
		private var m_value:int;
		private var m_maxValue:int;
		private var m_stage:Stage;
		private var m_ratio:Number;
		
		public function Scrollbar(maxValue:Number, stage:Stage):void {
			m_maxValue = (maxValue - 1);
			m_ratio = ((track.width) - (scrubber.width)) / m_maxValue;
			m_stage = stage;

			left.buttonMode = true;
			left.addEventListener(MouseEvent.CLICK, handleLeftClick);

			right.buttonMode = true;
			right.addEventListener(MouseEvent.CLICK, handleRightClick);

			scrubber.buttonMode = true;
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, handleScrubberClick);
		}
		
		public function get value():int {
			return m_value;
		}
		
		public function set value(value:int):void {
			m_value = value;
			update();
		}
		
		private function update():void {
			TweenLite.to(scrubber, 0.25, {x: (m_value * m_ratio)});
		}
		
		private function handleScrubberClick(e:MouseEvent):void {
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			m_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, handleScrubberClick);
		}
		
		private function mouseMove(e:MouseEvent):void {
			var mouseX:Number = this.mouseX;

			var availableTrackLength:Number = track.width - scrubber.width;
			if ((mouseX < track.width) && (0 < mouseX)) {
				var xPos:int = (mouseX / m_ratio);

				if (mouseX < availableTrackLength) {
					m_value = xPos;
					scrubber.x = xPos * m_ratio;
				} else {
					m_value = m_maxValue;
					scrubber.x = availableTrackLength;
				}

				update();
				dispatchEvent(new Event("UPDATE"));
			}

		}
		
		private function mouseUp(e:MouseEvent):void {
			m_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, handleScrubberClick);
		}
		
		private function handleLeftClick(e:MouseEvent):void {
			if (m_value != 0) {
				m_value--;
			}
			
			update();
			dispatchEvent(new Event("PREVIOUS"));
		}
		
		private function handleRightClick(e:MouseEvent):void {

			if (m_value!=(m_maxValue - 1)) {
				m_value++;
			}
			
			update();
			dispatchEvent(new Event("NEXT"));
		}
	}
}