package com.timotuominen.flex.maps.model
{
	import com.timotuominen.flex.maps.events.MapTileEvent;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	[Bindable]
	public class MapTile extends EventDispatcher
	{
		private var _zoomLevel:int;
		private var _size:int;
		private var _x:int;
		private var _y:int;
		private var _bitmapData:BitmapData;
		
		public var isVisible:Boolean = true;
		
		public var assigned:Boolean = false;
		public var isBroken:Boolean = false;
		public var isLoading:Boolean = false;
		public var bytesTotal:Number;
		public var bytesLoaded:Number;
		public var numRetriesForLoadingContent:Number = 5;
		
		public function MapTile(zoomLevel:int, x:int, y:int, size:int)
		{
			_zoomLevel = zoomLevel;
			_x = x;
			_y = y;
			_size = size;
		}
		
		public function get zoomLevel() : int
		{
			return _zoomLevel;
		}
		
		public function get x() : int
		{
			return _x;
		}

		public function get y() : int
		{
			return _y;
		}

		public function get size() : int
		{
			return _size;
		}

		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}
		
		public function set bitmapData(value:BitmapData):void
		{
			if(!value)
			{
				trace("Null BitmapData was set");
			}
			_bitmapData = value;
			dispatchEvent(new MapTileEvent(MapTileEvent.TILE_BITMAPDATA_LOADED, this));
		}
	}
}