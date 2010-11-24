package com.timotuominen.flex.maps.components
{
	import com.timotuominen.flex.maps.events.MapTileEvent;
	import com.timotuominen.flex.maps.model.MapTile;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.core.UIComponent;
	
	[Bindable]
	public class VisualMapTile extends UIComponent
	{
		static public var debug:Boolean = false;
		
		private var _sourceTile:MapTile;
		private var bitmapImage:Image;
		private var debugLabel:Label;
		
		public function VisualMapTile()
		{
			super();
		}
		
		
		public function get sourceTile():MapTile
		{
			return _sourceTile;
		}
		
		public function set sourceTile(value:MapTile):void
		{
			if(value.assigned)
			{
				throw new IllegalOperationError("The tile was already assigned!");
			}
			value.assigned = true;
			
			_sourceTile = value;
			_sourceTile.addEventListener(MapTileEvent.TILE_BITMAPDATA_LOADED, sourceTileBitmapDataChangedHandler);
			/*BindingUtils.bindSetter(isBrokenSetter, _sourceTile, "isBroken");
			BindingUtils.bindSetter(isBrokenSetter, _sourceTile, "isLoading");
			BindingUtils.bindSetter(isBrokenSetter, _sourceTile, "bytesLoaded");
			BindingUtils.bindSetter(isBrokenSetter, _sourceTile, "bytesTotal");*/
			invalidateProperties();
		}
		
		/*private function isBrokenSetter(e:*) : void
		{
		invalidateProperties();
		}*/
		
		private function sourceTileBitmapDataChangedHandler(e:Event) : void
		{
			invalidateProperties();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			if(!bitmapImage)
			{
				bitmapImage = new Image;
				//bitmapImage.smooth = true;
				addChild(bitmapImage);
			}
			
			if(!debugLabel)
			{
				debugLabel = new Label;
				addChild(debugLabel);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if(!sourceTile) return;
			
			if(sourceTile.bitmapData)
			{
				var bitmap:Bitmap = new Bitmap(sourceTile.bitmapData);
				bitmapImage.source = bitmap;
				bitmapImage.width = bitmap.width;
				bitmapImage.height = bitmap.height;				
			}
			
			if(debug)
			{
				debugLabel.x = 10;
				debugLabel.y = 10;
				debugLabel.height = 50;
				debugLabel.text = sourceTile.isLoading + ", " + sourceTile.bytesLoaded + "/" + sourceTile.bytesTotal
					+ "\n" + sourceTile.zoomLevel + ", " + sourceTile.x + ", " + sourceTile.y + ", " + sourceTile.size
					+ "\nretries: " + sourceTile.numRetriesForLoadingContent;
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{	
			graphics.clear();
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(debug)
			{
				graphics.lineStyle(0, 0, 0.2);
				graphics.beginFill(0, 0);
				graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
				
				if(!sourceTile.bitmapData && sourceTile.isBroken)
				{
					var l:Number = 20;
					graphics.lineStyle(10, 0x000000, 0.2);
					graphics.moveTo(l, l);
					graphics.lineTo(unscaledWidth - l, unscaledHeight - l);
					graphics.moveTo(unscaledWidth - l, l);
					graphics.lineTo(l, unscaledHeight - l);
				}				
			}
		}
	}
}