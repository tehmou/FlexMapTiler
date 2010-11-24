package com.timotuominen.flex.maps.components.markers
{
	import com.timotuominen.flex.maps.model.LatLng;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IDataRenderer;
	import mx.core.IUIComponent;
	
	public interface IMarker extends IUIComponent, IEventDispatcher
	{
		function set latlng(value:LatLng) : void;
		function get latlng() : LatLng;
	}
}