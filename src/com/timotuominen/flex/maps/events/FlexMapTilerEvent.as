package com.timotuominen.flex.maps.events
{
	import flash.events.Event;

	public class FlexMapTilerEvent extends Event
	{
		static public const ZOOM_LEVEL_CHANGED:String = "zoomLevelChanged";
		static public const ZOOM_POINT_CHANGED:String = "zoomPointChanged";
		
		public function FlexMapTilerEvent(type:String, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
		}
	}
}