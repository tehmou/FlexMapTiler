package com.timotuominen.flex.maps.utils
{
	import com.timotuominen.flex.maps.model.MapTile;
	import com.timotuominen.flex.maps.model.LatLng;
	
	import flash.display.Loader;
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;

	public class MapTileManager
	{
		static private const DEFAULT_TILE_SIZE:int = 256;
		
		private var zoomGrids:Object = {};
		
		private var tileSize:int;
		private var startedLoadingTiles:Boolean = false;
		
		public function MapTileManager(tileSize:int=DEFAULT_TILE_SIZE)
		{
			this.tileSize = tileSize;
		}
		
		public function setTileSize(size:int) : void
		{
			if(!startedLoadingTiles)
			{
				tileSize = size;
			}
			else
			{
				throw new IllegalOperationError("Cannot change tile size after tiles have started loading.");
			}
		}
		
		public function getTileSize() : int
		{
			return tileSize;
		}
		
		public function requestTile(zoomLevel:int, x:int, y:int) : MapTile
		{
			var max:Number = Math.pow(2, zoomLevel);

			if(x < 0 || x >= max || y < 0 || y >= max)
				return null;
				
			var tile:MapTile = getTile(zoomLevel, x, y);
			
			if(tile)
				return tile;
			
			tile = createTile(zoomLevel, x, y);
			var tileLoader:MapTileLoader = new MapTileLoader(tile);
			MapTileLoaderManager.getInstance().addToStack(tileLoader);
			
			return tile;
		}
		
		private function getTile(zoomLevel:int, x:int, y:int) : MapTile
		{
			if( zoomGrids.hasOwnProperty(zoomLevel) &&
				zoomGrids[zoomLevel].hasOwnProperty(x) &&
				zoomGrids[zoomLevel][x].hasOwnProperty(y))
			{
				return zoomGrids[zoomLevel][x][y];
			}
			return null;
		}
		
		private function createTile(zoomLevel:int, x:int, y:int) : MapTile
		{
			var tile:MapTile = new MapTile(zoomLevel, x, y, tileSize);
			if(!zoomGrids.hasOwnProperty(zoomLevel))
			{
				zoomGrids[zoomLevel] = {};
			}
			if(!zoomGrids[zoomLevel].hasOwnProperty(x))
			{
				zoomGrids[zoomLevel][x] = {};
			}
			zoomGrids[zoomLevel][x][y] = tile;
			return tile;
		}
		
	}
}