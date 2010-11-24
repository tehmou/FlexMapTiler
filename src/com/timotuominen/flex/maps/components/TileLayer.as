package com.timotuominen.flex.maps.components
{
	import com.timotuominen.flex.maps.model.MapTile;
	import com.timotuominen.flex.maps.model.LatLng;
	import com.timotuominen.flex.maps.utils.CoordinateUtils;
	
	import flash.errors.IllegalOperationError;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	public class TileLayer extends UIComponent
	{
		private var _zoomLevel:int;
		private var _tileSize:int;
		private var visibleVisualTiles:ArrayCollection = new ArrayCollection;
		private var visualTiles:Object = {};

		public function TileLayer(zoomLevel:int, tileSize:int)
		{
			super();
			_zoomLevel = zoomLevel;
			_tileSize = tileSize;
		}
		
		public function get zoomLevel() : int
		{
			return _zoomLevel;
		}
		
		public function get tileSize() : int
		{
			return _tileSize;
		}
		
		public function getNumVisibleTiles() : Number
		{
			return visibleVisualTiles.length;
		}
		
		public function setVisibleTiles(value:Array) : void
		{
			hideInvisibleTiles(value);
			showVisibleTiles(value);
		}
		
		private function hideInvisibleTiles(newVisibleTiles:Array) : void
		{
			for each(var visualTile:VisualMapTile in this.visibleVisualTiles)
			{
				var tileFound:Boolean = false;
				for each(var tile:MapTile in newVisibleTiles)
				{
					if(visualTile.sourceTile == tile)
					{
						tileFound = true;
						break;
					}
				}
				if(!tileFound)
				{
					hideTile(visualTile);
				}
			}			
		}
		
		private function showVisibleTiles(newVisibleTiles:Array) : void
		{
			for each(var tile:MapTile in newVisibleTiles)
			{
				var tileFound:Boolean = false;
				for each(var visualTile:VisualMapTile in this.visibleVisualTiles)
				{
					if(visualTile.sourceTile == tile)
					{
						tileFound = true;
						break;
					}
				}
				if(!tileFound)
				{
					showTile(tile);
				}
			}			
		}
		
		private function showTile(tile:MapTile) : void
		{
			var visualTile:VisualMapTile = getVisualTile(tile);
			visibleVisualTiles.addItem(visualTile);
			addChild(visualTile);
			visualTile.sourceTile.isVisible = true;
		}
		
		private function hideTile(visualTile:VisualMapTile) : void
		{
			visibleVisualTiles.removeItemAt(visibleVisualTiles.getItemIndex(visualTile));
			removeChild(visualTile);
			visualTile.sourceTile.isVisible = false;
		}
		
		private function getVisualTile(tile:MapTile) : VisualMapTile
		{
			if(tile.size != tileSize)
			{
				throw new IllegalOperationError("The tile size " + tile.size + " did not match the tile size of the surface (" + tileSize + ")");
			}
			
			if (visualTiles.hasOwnProperty(tile.x))
			{
				if(visualTiles[tile.x].hasOwnProperty(tile.y))
				{
					return visualTiles[tile.x][tile.y];
				}
			}
			else
			{
				visualTiles[tile.x] = {};
			}
			
			var visualTile:VisualMapTile = new VisualMapTile;
			visualTile.width = tileSize;
			visualTile.height = tileSize;
			visualTile.sourceTile = tile;
			visualTile.x = tile.x * tileSize;
			visualTile.y = tile.y * tileSize;
			visualTiles[tile.x][tile.y] = visualTile;
			return visualTile;
		}
	}
}