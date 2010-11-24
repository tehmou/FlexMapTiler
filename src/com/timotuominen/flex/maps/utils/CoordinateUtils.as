package com.timotuominen.flex.maps.utils
{
	import com.timotuominen.flex.maps.model.LatLng;
	
	import flash.geom.Point;

	public class CoordinateUtils
	{
		public function CoordinateUtils()
		{
		}

		/**
		 * Calculates the pixel coordinates from the given
		 * latitude and longitude.
		 */
		static public function getPixelCoordinates(latlng:LatLng, tileSize:Number, zoom:int) : Point
		{
			var tilesPerAxis:Number = Math.pow(2, zoom);
			var pixelsPerAxis:Number = tilesPerAxis * tileSize;
			var xCoord:Number = (latlng.lng / 360) + 0.5;
			var yCoord:Number = Math.min(1, Math.max(0, 0.5 - (Math.log(Math.tan((Math.PI / 4) + (((Math.PI / 2) * latlng.lat) / 180))) / Math.PI) / 2));
			
			return new Point(xCoord * pixelsPerAxis, yCoord * pixelsPerAxis);		
		}
		
		static public function getLatLngCoordinates(pixel:Point, tileSize:Number, zoom:int) : LatLng
		{
			// TODO: FIXME
			// Does not take it very well if lng goes under -90

			var tilesPerAxis:Number = Math.pow(2, zoom);
			var pixelsPerAxis:Number = tilesPerAxis * tileSize;
			var xCoord:Number = pixel.x / pixelsPerAxis;
			var yCoord:Number = pixel.y / pixelsPerAxis;
			
			var lat:Number = 90 * (4 * Math.atan(Math.exp(2 * Math.PI * (0.5 - yCoord))) / Math.PI - 1)
			var lng:Number = Math.max(-90, Math.min(90, ((xCoord - 0.5) * 360)))

			return new LatLng(lat, lng);
		}
	}
}