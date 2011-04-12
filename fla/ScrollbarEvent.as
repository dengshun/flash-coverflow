package {	
	import flash.events.Event;
	
	public class ScrollbarEvent extends Event{
		private var data:Object;
		
		public function ScrollbarEvent(type:String, data:Object) {
			super(type);
			m_data = data;
		}
		
		public function get data():Object {
			return m_data;
		}
		
		public override function clone():Event {
			return new ScrollbarEvent(type, this.m_data);
		}
		
		public override function toString():String {
			return "[ ScrollbarEvent ]";
		}
	}
	
}