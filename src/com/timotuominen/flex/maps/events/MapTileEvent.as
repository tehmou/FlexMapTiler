package com.timotuominen.flex.maps.events
{
	import flash.events.Event;
	import com.timotuominen.flex.maps.model.MapTile;
	
	public class MapTileEvent extends Event
	{
		static public const TILE_BITMAPDATA_LOADED:String = "tileBitmapDataLoaded";
		
		public var tile:MapTile;
		
		public function MapTileEvent(type:String, tile:MapTile, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.tile = tile;
		}
	}
}