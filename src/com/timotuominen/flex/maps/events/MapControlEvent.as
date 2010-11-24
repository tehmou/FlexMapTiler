package com.timotuominen.flex.maps.events
{
	import flash.events.Event;
	
	public class MapControlEvent extends Event
	{
		static public const ZOOM_IN:String = "zoomIn";
		static public const ZOOM_OUT:String = "zoomOut";
		
		public function MapControlEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}