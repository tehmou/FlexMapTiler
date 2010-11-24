package com.timotuominen.flex.maps.model
{
	public class LatLng
	{
		public var lat:Number;
		public var lng:Number;
		
		public function LatLng(lat:Number=NaN, lng:Number=NaN)
		{
			this.lat = lat;
			this.lng = lng;
		}
		
		public function toString() : String
		{
			return "NLatLng(" + lat + ", " + lng + ")";
		}
	}
}