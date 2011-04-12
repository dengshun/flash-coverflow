package {
	
	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.display.GradientType;
	import flash.display.SpreadMethod;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;

	public class Reflect extends MovieClip {
		private var m_target:Sprite;
		private var m_bitmapData:BitmapData;
		private var m_reflectionBitmap:Bitmap;
		private var m_gradientMask:MovieClip;
		private var m_updateTime:Number;
		private var m_bounds:Object;
		
		
		private var _distance:Number = 0;

		function Reflect(args:Object) {
			
			m_target = args.target;
			
			var alpha:Number = args.alpha / 100;
			var ratio:Number = args.ratio;
			var m_updateTime:Number = args.updateTime;
			
			var reflectionDropoff:Number = args.reflectionDropoff;
			var m_distance:Number = args.distance;

			var spriteHeight = m_target.height;
			var spriteWidth  = m_target.width;

			m_bounds = new Object();
			m_bounds.width = spriteWidth;
			m_bounds.height = spriteHeight;

			if (m_bounds.width > 0) {
				m_bitmapData = new BitmapData(m_bounds.width, m_bounds.height, true, 0xFFFFFF);
				m_bitmapData.draw(m_target);

				m_reflectionBitmap = new Bitmap(m_bitmapData);
				
				// reflects the bitmap and move it to the bottom of ogiginal image
				m_reflectionBitmap.scaleY = -1;
				m_reflectionBitmap.y = (m_bounds.height * 2) + m_distance;

				var reflectionBitmapRef:DisplayObject = m_target.addChild(m_reflectionBitmap);
				var gradientMaskRef:DisplayObject = m_target.addChild(new MovieClip());
				
				reflectionBitmapRef.name  = "reflectionBitmap";
				gradientMaskRef.name="gradientMask";

				m_gradientMask = m_target.getChildByName("gradientMask") as MovieClip;
				
				
				var fillType:String = GradientType.LINEAR;
				var colors:Array = [0xFFFFFF,0xFFFFFF];
				var alphas:Array = [alpha, 0];
				var ratios:Array = [0, ratio];
				
				var spreadMethod:String = SpreadMethod.PAD;
				
				var matrix:Matrix = new Matrix();
				var matrixHeight:Number;
				if (reflectionDropoff <= 0) {
					matrixHeight = m_bounds.height;
				} else {
					matrixHeight= m_bounds.height / reflectionDropoff;
				}
				
				matrix.createGradientBox(m_bounds.width, matrixHeight, 0.5 * Math.PI, 0, 0);
				
				m_gradientMask.graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);
				m_gradientMask.graphics.drawRect(0, 0, m_bounds.width, m_bounds.height);
				
				
				m_gradientMask.y = m_target.getChildByName("reflectionBitmap").y - m_target.getChildByName("reflectionBitmap").height;
				m_gradientMask.cacheAsBitmap = true;
				
				m_target.getChildByName("reflectionBitmap").cacheAsBitmap = true;
				m_target.getChildByName("reflectionBitmap").mask = m_gradientMask;

				
				if (m_updateTime>-1) {
					m_updateTime = setInterval(update, m_updateTime, m_target);
				}
			}
		}


		public function setBounds(width:Number, height:Number):void {
			m_bounds.width = width;
			m_bounds.height = height;
			
			m_gradientMask.width = m_bounds.width;
			render(m_target);
		}
		
		public function render(target:Sprite):void {
			m_bitmapData.dispose();
			m_bitmapData = new BitmapData(m_bounds.width, m_bounds.height, true, 0xFFFFFF);
			m_bitmapData.draw(target);
		}
		
		private function update(target:Sprite):void {
			m_bitmapData = new BitmapData(m_bounds.width, m_bounds.height, true, 0xFFFFFF);
			m_bitmapData.draw(target);
			
			m_reflectionBitmap.bitmapData = m_bitmapData;
		}
		
		public function destroy():void {
			m_target.removeChild(m_target.getChildByName("reflectionBitmap"));
			m_reflectionBitmap = null;
			m_bitmapData.dispose();
			
			clearInterval(m_updateTime);
			m_target.removeChild(m_target.getChildByName("gradientMask"));
		}
	}
}