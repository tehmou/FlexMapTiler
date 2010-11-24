package com.timotuominen.flex.maps.components
{
	import com.timotuominen.flex.maps.components.markers.IMarker;
	import com.timotuominen.flex.maps.events.TileSurfaceEvent;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
	import mx.events.MoveEvent;
	
	
	public class MarkerLayer extends UIComponent
	{
		private var _tileSurface:TileSurface;
		private var markers:Vector.<IMarker> = new Vector.<IMarker>;
		
		public function MarkerLayer()
		{
			super();
		}
		
		public function get tileSurface():TileSurface
		{
			return _tileSurface;
		}

		public function set tileSurface(value:TileSurface):void
		{
			if(_tileSurface)
			{
				_tileSurface.removeEventListener(TileSurfaceEvent.ZOOM_LEVEL_CHANGED, tileSurfaceChangeHandler);
				_tileSurface.removeEventListener(TileSurfaceEvent.ZOOM_POINT_CHANGED, tileSurfaceChangeHandler);
			}
			
			_tileSurface = value;
			
			_tileSurface.addEventListener(TileSurfaceEvent.ZOOM_LEVEL_CHANGED, tileSurfaceChangeHandler);
			_tileSurface.addEventListener(TileSurfaceEvent.ZOOM_POINT_CHANGED, tileSurfaceChangeHandler);
			invalidateProperties();
		}
		
		private function tileSurfaceChangeHandler(e:Event) : void
		{
			invalidateProperties();
		}

		public function addMarker(marker:IMarker) : void
		{
			markers.push(marker);
			marker.addEventListener("latlngChanged", markerLatLngChanged);
			addChild(marker as DisplayObject);
			invalidateProperties();
		}
		
		private function markerLatLngChanged(e:Event) : void
		{
			invalidateProperties();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if(!tileSurface) return;

			for each(var marker:IMarker in markers)
			{
				var globalPos:Point = tileSurface.fromLatLngToGlobalPixel(marker.latlng);
				var pos:Point = globalToLocal(globalPos);
				marker.x = pos.x;
				marker.y = pos.y;
			}
		}
	}
}