package com.timotuominen.flex.maps.events
{
	import com.timotuominen.flex.maps.utils.MapTileLoader;
	
	import flash.events.Event;
	
	public class MapTileLoaderEvent extends Event
	{
		static public const MAPTILE_LOADED:String = "mapTileLoaded";
		static public const MAPTILE_LOAD_FAILED:String = "mapTileLoadFailed";
		static public const MAPTILE_LOAD_TIMED_OUT:String = "mapTileLoadTimedOut";
		
		public var mapTileLoader:MapTileLoader;
		
		public function MapTileLoaderEvent(type:String, mapTileLoader:MapTileLoader, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.mapTileLoader = mapTileLoader;
		}
	}
}