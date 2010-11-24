package com.timotuominen.flex.maps.components
{
	import com.timotuominen.flex.maps.components.markers.IMarker;
	import com.timotuominen.flex.maps.model.MapTile;
	import com.timotuominen.flex.maps.model.LatLng;
	import com.timotuominen.flex.maps.utils.MapTileManager;
	
	import flash.errors.IllegalOperationError;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	[Bindable]
	public class FlexMapTilerCore extends UIComponent
	{
		static public const SCREEN_BUFFER_PIXEL_SIZE:Number = 50;
		
		static public var debug:Boolean = true;
		private var debugLabel:Label;
		
		protected var markerLayer:MarkerLayer = new MarkerLayer;
		protected var tileSurface:TileSurface;
		protected var controlLayer:UIComponent = new UIComponent;
		
		private var myMask:UIComponent;
		
		public function FlexMapTilerCore() { }
		
		[Bindable(event="zoomLevelChanged")]
		public function get zoomLevel():Number
		{
			return tileSurface.zoomLevel;
		}

		public function set zoomLevel(value:Number):void
		{
			tileSurface.zoomLevel = value;
		}

		[Bindable(event="zoomPointChanged")]
		public function get zoomPoint():LatLng
		{
			return tileSurface.zoomPoint;
		}
		
		public function set zoomPoint(value:LatLng):void
		{
			tileSurface.zoomPoint = value;
		}

		public function zoomToLatLng(latlng:LatLng, zoomLevel:int) : void
		{
			tileSurface.zoomPoint = latlng;
			tileSurface.zoomLevel = zoomLevel;
		}
		
		public function zoomToLatLngWithPixelOffset(latlng:LatLng, zoomLevel:int, offset:Point) : void
		{
			zoomToLatLng(latlng, zoomLevel);
			tileSurface.moveByPixels(offset);
		}

		public function fromLatLngToGlobalPixel(latlng:LatLng) : Point
		{
			return tileSurface.fromLatLngToGlobalPixel(latlng);
		}
		
		public function fromGlobalPixelToLatLng(pixel:Point) : LatLng
		{
			return tileSurface.fromGlobalPixelToLatLng(pixel);
		}
		
		override protected function createChildren():void
		{
			super.createChildren();

			myMask = new UIComponent;
			addChild(myMask);
			mask = myMask;
			
			tileSurface = new TileSurface();
			tileSurface.zoomLevel = 4;
			tileSurface.zoomPoint = new LatLng(52.522377, 13.408813);
			addChild(tileSurface);
			tileSurface.setZoomRange(0, 18);

			markerLayer.tileSurface = tileSurface;
			addChild(markerLayer);
			
			addChild(controlLayer);
			
			debugLabel = new Label;
			debugLabel.y = 10;
			debugLabel.x = 10;
			debugLabel.setStyle("color", 0xffffff);
			addChild(debugLabel);
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			graphics.clear();
			graphics.beginFill(0xfbf9ef);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			
			tileSurface.viewBounds = new Rectangle(-unscaledWidth/2, -unscaledHeight/2, unscaledWidth, unscaledHeight);
			tileSurface.bufferedViewBounds = new Rectangle(
				-(width/2 + SCREEN_BUFFER_PIXEL_SIZE),
				-(height/2 + SCREEN_BUFFER_PIXEL_SIZE), 
				width + SCREEN_BUFFER_PIXEL_SIZE*2,
				height + SCREEN_BUFFER_PIXEL_SIZE*2);
			
			tileSurface.x = width / 2;
			tileSurface.y = height / 2;

			if(debug)
			{
				debugLabel.text = "Existing map layers:";
				var layers:Object = tileSurface.debug_getLayers();
				for(var layer:String in layers)
				{
					debugLabel.text += "\na: " + layers[layer].alpha + " v: " + layers[layer].visible + " n: " + layers[layer].getNumVisibleTiles() + " id:" + layer;
				}
			}
			debugLabel.filters = [new DropShadowFilter(0.5)];
			
			myMask.graphics.clear();
			myMask.graphics.beginFill(0);
			myMask.graphics.drawRect(0, 0, width, height);
			myMask.graphics.endFill();
		}
	}
}