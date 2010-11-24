package com.timotuominen.flex.maps.utils
{
	import com.timotuominen.flex.maps.events.MapTileLoaderEvent;
	import com.timotuominen.flex.maps.model.MapTile;
	
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class MapTileLoader extends EventDispatcher
	{
		static public const RETRY_DELAY:Number = 300;

		static private const LOAD_TIMEOUT:Number = 15000;
		
		static public var ENDPOINT:String = "";

		public var mapTile:MapTile;

		private var url:String;
		private var loader:Loader;
		private var failToken:int = -1;
		
		public function MapTileLoader(mapTile:MapTile)
		{
			this.mapTile = mapTile;
			createRequestURL();
		}
		
		private function createRequestURL() : void
		{
			var requestString:String = ENDPOINT;
			requestString = requestString.replace("{zoomLevel}", mapTile.zoomLevel);
			requestString = requestString.replace("{x}", mapTile.x);
			requestString = requestString.replace("{y}", mapTile.y);
			requestString = requestString.replace("{size}", mapTile.size);
			url = requestString;			
		}
		
		public function load() : void
		{
			if(loader) return;

			if(mapTile.numRetriesForLoadingContent <= 0)
			{
				dispatchEvent(new MapTileLoaderEvent(MapTileLoaderEvent.MAPTILE_LOAD_FAILED, this));				
			}

			
			loader = new Loader;
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, successHandler);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);

			var request:URLRequest = new URLRequest(url);
			loader.load(request);
			mapTile.isLoading = true;
			
			failToken = setTimeout(timeOut, LOAD_TIMEOUT);
		}
		
		private function progressHandler(e:ProgressEvent) : void
		{
			mapTile.bytesLoaded = e.bytesLoaded;
			mapTile.bytesTotal = e.bytesTotal;
		}
		
		private function errorHandler(e:Event) : void
		{
			if(!mapTile) return;
			fail();
			setTimeout(load, RETRY_DELAY);
		}
		
		private function successHandler(e:Event) : void
		{
			if(!loader) return;
			if(!mapTile) return;
			
			var bitmap:BitmapData = 
				new BitmapData(mapTile.size, mapTile.size);
			bitmap.draw(loader);
			mapTile.bitmapData = bitmap;

			mapTile.isBroken = false;
			mapTile.isLoading = false;
			
			reset();
			dispatchEvent(new MapTileLoaderEvent(MapTileLoaderEvent.MAPTILE_LOADED, this));
		}
		
		private function timeOut() : void
		{
			if(!mapTile) return;
			
			fail();
			dispatchEvent(new MapTileLoaderEvent(MapTileLoaderEvent.MAPTILE_LOAD_TIMED_OUT, this));			
		}
		
		private function fail() : void
		{
			mapTile.isBroken = true;
			mapTile.isLoading = false;

			if(loader)
			{
				loader.unload();
			}
			
			reset();

			mapTile.numRetriesForLoadingContent--;
		}
		
		private function reset() : void
		{
			loader = null;
			
			if(failToken > -1)
			{
				clearTimeout(failToken);
				failToken = -1;
			}
		}
	}
}