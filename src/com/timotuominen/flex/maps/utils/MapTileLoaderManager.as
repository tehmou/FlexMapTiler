package com.timotuominen.flex.maps.utils
{
	import com.timotuominen.flex.maps.events.MapTileLoaderEvent;
	
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;

	public class MapTileLoaderManager
	{
		static public const MAX_SIMULTANEOUS:Number = 5;
		
		public var loadAlreadyInvisibleTiles:Boolean = false;
		
		public var loaderQueue:ArrayCollection = new ArrayCollection;
		public var activeLoaders:ArrayCollection = new ArrayCollection;
		public var priorityZoomLevels:Array;

		private static var instance:MapTileLoaderManager;
		
		public function MapTileLoaderManager(singletonEnforcer:SingletonEnforcer)
		{
			if(singletonEnforcer == null)
			{
				throw new IllegalOperationError("Singleton!");
			}
		}
		
		static public function getInstance() : MapTileLoaderManager
		{
			if(!instance) instance = new MapTileLoaderManager(new SingletonEnforcer);
			return instance;
		}
		
		public function addToStack(tileLoader:MapTileLoader) : void
		{
			loaderQueue.addItemAt(tileLoader, 0);
			processQueue();
		}
		
		public function addToBottomOfStack(tileLoader:MapTileLoader) : void
		{
			loaderQueue.addItemAt(tileLoader, loaderQueue.length);
			processQueue();			
		}
		
		private function tileLoadedHandler(e:MapTileLoaderEvent) : void
		{
			activeLoaders.removeItemAt(activeLoaders.getItemIndex(e.mapTileLoader));
			processQueue();
		}
		
		private function tileLoadFailedHandler(e:MapTileLoaderEvent) : void
		{
			activeLoaders.removeItemAt(activeLoaders.getItemIndex(e.mapTileLoader));
			processQueue();
		}
		
		private function tileLoadTimedOutHandler(e:MapTileLoaderEvent) : void
		{
			activeLoaders.removeItemAt(activeLoaders.getItemIndex(e.mapTileLoader));
			addToBottomOfStack(e.mapTileLoader);
			processQueue();
		}

		private function processQueue() : void
		{
			if(loaderQueue.length == 0) return;
			
			if(activeLoaders.length < MAX_SIMULTANEOUS)
			{
				
				// See if some tiles are more important than others.
				if(priorityZoomLevels)
				{
					for each(var priorityZoomLevel:int in priorityZoomLevels)
					{
						for each(var loader:MapTileLoader in loaderQueue)
						{
							if(loader.mapTile.zoomLevel == priorityZoomLevel)
							{
								if(startLoad(loader))
									return;
							}
						}
					}
				}
				
				// Just take the first one in the queue.
				while(loaderQueue.length > 0 && !startLoad(loaderQueue.getItemAt(0) as MapTileLoader)) { }
			}
		}
		
		private function startLoad(tileLoader:MapTileLoader) : Boolean
		{
			loaderQueue.removeItemAt(loaderQueue.getItemIndex(tileLoader));

			if(!loadAlreadyInvisibleTiles && !tileLoader.mapTile.isVisible)
			{
				return false;
			}
			
			activeLoaders.addItem(tileLoader);
			tileLoader.addEventListener(MapTileLoaderEvent.MAPTILE_LOADED, tileLoadedHandler);
			tileLoader.addEventListener(MapTileLoaderEvent.MAPTILE_LOAD_FAILED, tileLoadFailedHandler);
			tileLoader.addEventListener(MapTileLoaderEvent.MAPTILE_LOAD_TIMED_OUT, tileLoadTimedOutHandler);
			tileLoader.load();
			return true;
		}
	}
}

class SingletonEnforcer { }