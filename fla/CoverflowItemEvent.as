package {	
	import flash.events.Event;
	
	public class CoverflowItemEvent extends Event{
				
		public static const COVERFLOWITEM_SELECTED:String = "coverflowitem.selected";
		
		private var m_data:Object;
		
		public function CoverflowItemEvent(type:String, data:Object) {
			super(type);
			m_data = data;
		}
		
		public function get data():Object {
			return m_data;
		}
		
		public override function clone():Event {
			return new CoverflowItemEvent(type, this.m_data);
		}
		
		public override function toString():String {
			return "[ CoverflowItemEvent ]";
		}
	}
}