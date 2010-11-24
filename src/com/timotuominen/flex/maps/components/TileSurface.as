package com.timotuominen.flex.maps.components
{
	import com.timotuominen.flex.maps.events.TileSurfaceEvent;
	import com.timotuominen.flex.maps.model.MapTile;
	import com.timotuominen.flex.maps.model.LatLng;
	import com.timotuominen.flex.maps.utils.CoordinateUtils;
	import com.timotuominen.flex.maps.utils.MapTileLoaderManager;
	import com.timotuominen.flex.maps.utils.MapTileManager;
	
	import flash.errors.IllegalOperationError;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	import mx.validators.IValidatorListener;
	
	[Event(name="zoomLevelChanged", type="com.timotuominen.flex.maps.events.TileSurfaceEvent")]
	[Event(name="zoomPointChanged", type="com.timotuominen.flex.maps.events.TileSurfaceEvent")]
	public class TileSurface extends UIComponent
	{
		protected var tileLayers:Object = {};
		private var tileManager:MapTileManager;
		
		private var _viewBounds:Rectangle;
		private var _bufferedViewBounds:Rectangle;
		
		private var _zoomLevel:Number;
		private var zoomLevelInvalidated:Boolean = false;
		private var _zoomPoint:LatLng;
		private var zoomPointInvalidated:Boolean = false;
		
		private var debug_visibleLayer:String;
		
		public function TileSurface()
		{
			super();
			tileManager = new MapTileManager;
		}
		
		public function debug_setVisibleLayer(name:String) : void
		{
			debug_visibleLayer = name;
			zoomLevelInvalidated = true;
			invalidateProperties();
		}
		
		public function debug_getLayers() : Object
		{
			return tileLayers;
		}

		public function setZoomRange(min:Number, max:Number) : void
		{
			for(var i:Number = min; i <= max; i++)
			{
				createLayer(i);
			}
		}
		
		public function get viewBounds():Rectangle
		{
			return _viewBounds;
		}

		public function set viewBounds(value:Rectangle):void
		{
			_viewBounds = value;
			invalidateProperties();
		}
		
		public function get bufferedViewBounds():Rectangle
		{
			return _bufferedViewBounds;
		}
		
		public function set bufferedViewBounds(value:Rectangle):void
		{
			_bufferedViewBounds = value;
			invalidateProperties();
		}
		
		public function moveByPixels(offset:Point) : void
		{
			var currentZoomPixel:Point = fromLatLngToLocalPixel(zoomPoint);
			var newZoomPoint:LatLng = fromLocalPixelToLatLng(currentZoomPixel.subtract(offset));
			zoomPoint = newZoomPoint;
		}

		public function get zoomPoint():LatLng
		{
			return _zoomPoint;
		}
		
		public function set zoomPoint(value:LatLng):void
		{
			_zoomPoint = value;
			if(_zoomPoint)
			{
				zoomPointInvalidated = true;
				invalidateProperties();
			}
			else
			{
				throw new IllegalOperationError("zoomPoint was set to null");
			}
		}
		
		/**
		 * For now zoomLevel only supports integers. This is because
		 * otherwise the latlng - pixel transformations would be more
		 * difficult to calculate.
		 */
		public function get zoomLevel():int
		{
			return _zoomLevel;
		}
		
		public function set zoomLevel(value:int):void
		{
			_zoomLevel = value;
			zoomLevelInvalidated = true;
			invalidateProperties();
		}
		
		private function createLayer(zoomLevel:int) : void
		{
			if(!tileLayers.hasOwnProperty(zoomLevel))
			{
				tileLayers[zoomLevel] = new TileLayer(zoomLevel, tileManager.getTileSize());
				addChild(tileLayers[zoomLevel]);
			}
		}
		
		private function getPrimaryLayer() : TileLayer
		{
			return tileLayers[Math.ceil(zoomLevel)];
		}
		
		private function calculateLayerAlphas() : void
		{
			hideAllLayers();
			
			if(debug_visibleLayer)
			{
				tileLayers[debug_visibleLayer].alpha = 1.0;
				return;
			}
			
			var bottomLayer:int = Math.floor(zoomLevel);
			var topLayer:int = Math.ceil(zoomLevel);

			// Reveal all of the layers below this...
			// could be a small performance hit but makes
			// it sure the user sees at least something
			// if the proper tile hasn't loaded yet.
			for(var i:Number = 0; i <= bottomLayer; i++)
			{
				tileLayers[i].alpha = 1.0;				
			}
			
			if(bottomLayer != topLayer)
			{
				var ratio:Number = zoomLevel - bottomLayer;
				tileLayers[topLayer].alpha = Math.max(0, ratio * 4 - 2.0);
				MapTileLoaderManager.getInstance().priorityZoomLevels = [topLayer, bottomLayer];
			}
			else
			{
				MapTileLoaderManager.getInstance().priorityZoomLevels = [bottomLayer];				
			}
		}
		
		private function hideAllLayers() : void
		{
			for(var layerIndex:String in tileLayers)
			{
				tileLayers[layerIndex].alpha = 0.0;
			}			
		}

		private function resolveTileLayerTransformations() : void
		{
			for each(var tileLayer:TileLayer in tileLayers)
			{
				resolveTileLayerTransformation(tileLayer);
			}
		}
		
		private function resolveTileLayerTransformation(tileLayer:TileLayer) : void
		{
			var pos:Point = CoordinateUtils.getPixelCoordinates(zoomPoint, tileManager.getTileSize(), tileLayer.zoomLevel);
			var scale:Number = Math.pow(2, zoomLevel - tileLayer.zoomLevel);
			
			var m:Matrix = new Matrix;
			m.translate(-pos.x, -pos.y);
			m.scale(scale, scale);
			tileLayer.transform.matrix = m;
		}
		
		private function resolveAndLoadTilesInViewArea() : void
		{
			for each(var tileLayer:TileLayer in tileLayers)
			{
				if(tileLayer.visible && tileLayer.alpha > 0)
				{
					loadVisibleTilesForLayer(tileLayer, viewBounds);
				}
			}
		}
		
		private function bufferTilesForPrimaryLayer() : void
		{
			loadVisibleTilesForLayer(getPrimaryLayer(), bufferedViewBounds);
		}
		
		private function loadVisibleTilesForLayer(tileLayer:TileLayer, bounds:Rectangle) : void
		{			
			if(!bounds) return;
			var tileSize:int = tileManager.getTileSize();
			var leftMost:int = Math.floor((bounds.left - tileLayer.x) / (tileSize * tileLayer.scaleX));
			var topMost:int = Math.floor((bounds.top - tileLayer.y) / (tileSize * tileLayer.scaleY));
			var rightMost:int = Math.ceil((bounds.right - tileLayer.x) / (tileSize * tileLayer.scaleX));
			var bottomMost:int = Math.ceil((bounds.bottom - tileLayer.y) / (tileSize * tileLayer.scaleY));
			
			var visibleTiles:Array = [];
			for(var i:Number = leftMost; i < rightMost; i++)
			{
				for(var n:Number = topMost; n < bottomMost; n++)
				{
					var tile:MapTile = tileManager.requestTile(tileLayer.zoomLevel, i, n);
					if(tile)
						visibleTiles.push(tile);
				}
			}	
			tileLayer.setVisibleTiles(visibleTiles);
		}
		
		override protected function commitProperties():void
		{
			if(zoomLevelInvalidated || zoomPointInvalidated)
			{
				calculateLayerAlphas();
				resolveTileLayerTransformations();
			}
			
			super.commitProperties();
			resolveAndLoadTilesInViewArea();
			bufferTilesForPrimaryLayer();
			
			if(zoomLevelInvalidated)
			{
				dispatchEvent(new TileSurfaceEvent(TileSurfaceEvent.ZOOM_LEVEL_CHANGED));
				zoomLevelInvalidated = false;
			}

			if(zoomPointInvalidated)
			{
				dispatchEvent(new TileSurfaceEvent(TileSurfaceEvent.ZOOM_POINT_CHANGED));
				zoomPointInvalidated = false;
			}
		}
		
		/**
		 * Supports only zoomLevels of integer values. If the zoomLevel
		 * did not match a particular tile layer we couldn't use localToGlobal
		 * but instead we would have to calculate the point manually.
		 */
		public function fromLatLngToGlobalPixel(latlng:LatLng) : Point
		{
			var tileSurfacePoint:Point = fromLatLngToLocalPixel(latlng);
			var globalPoint:Point = getPrimaryLayer().localToGlobal(tileSurfacePoint);
			return globalPoint;
		}
		
		private function fromLatLngToLocalPixel(latlng:LatLng) : Point
		{
			return CoordinateUtils.getPixelCoordinates(latlng, tileManager.getTileSize(), zoomLevel);
		}

		/**
		 * Supports only zoomLevels of integer values. If the zoomLevel
		 * did not match a particular tile layer we couldn't use globalToLocal
		 * but instead we would have to calculate the point manually.
		 */
		public function fromGlobalPixelToLatLng(pixel:Point) : LatLng
		{
			var tileSurfacePoint:Point = globalToLocal(pixel);
			return fromLocalPixelToLatLng(tileSurfacePoint);
		}
		
		private function fromLocalPixelToLatLng(pixel:Point) : LatLng
		{
			return CoordinateUtils.getLatLngCoordinates(pixel, tileManager.getTileSize(), zoomLevel)			
		}
	}
}