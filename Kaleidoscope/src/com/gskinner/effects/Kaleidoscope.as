/**
 * Kaleidoscope by Grant Skinner. Nov 16, 2009
 * Visit www.gskinner.com/blog for documentation, updates and more free code.
 *
 *
 * Copyright (c) 2009 Grant Skinner
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

package com.gskinner.effects {
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.IBitmapDrawable;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import __AS3__.vec.Vector; // for ASDoc
	
	[SWF(frameRate="100", backgroundColor="#FFFFFF")]
	/**
	 * <b>Kaleidoscope ©2009 Grant Skinner, gskinner.com. Visit www.gskinner.com/blog/ for documentation, updates and more free code. Licensed under the MIT license - see the source file header for more information.</b>
	 * <hr/>
	 * Draws a kaleidoscope effect based on a specified source image. <br/>
	 * <b>Fast Mode: </b> Note that Kaleidoscope will use a faster drawing mode if the source is a BitmapData instance, and all offset values are set to 0.
	**/
	public class Kaleidoscope extends Sprite {
		
	// Public properties:
		/** The image source. For example, a DisplayObject or BitmapData instance. Note that Kaleidoscope will use a faster drawing mode if the source is a BitmapData instance, and all offset values are set to 0. **/
		public var source:IBitmapDrawable;
		/** X offset to use when drawing the image source into the kaleidoscope. **/
		public var offsetX:Number=0;
		/** Y offset to use when drawing the image source into the kaleidoscope. **/
		public var offsetY:Number=0;
		/** Rotation offset to use when drawing the image source into the kaleidoscope. For example, this can be used to create the effect of twisting the kaleidoscope.  **/
		public var offsetRotation:Number=0;
		/** Callback that is called *before* the kaleidoscope updates. Useful for making updates to the source immediately before the kaleidoscope updates. **/
		public var onChange:Function;
		/** Callback that is called after the kaleidoscope updates. Useful for reacting to changes. **/
		public var onChanged:Function;
		
	// Protected properties:
		protected var _maskSlices:Boolean=true;
		protected var _slices:uint;
		protected var _reflect:Boolean;
		protected var _autoUpdate:Boolean;
		protected var _radius:Number;
		protected var sliceMask:BitmapData;
		protected var bmpd:BitmapData;
		protected var bmpList:Vector.<Bitmap>;
		protected var sliceList:Vector.<Sprite>;
		protected var mtx:Matrix;
		protected var pt:Point;
		
	// Constructor:
		/** Creates a new kaleidoscope instance. **/
		public function Kaleidoscope(source:IBitmapDrawable=null, radius:uint=200, slices:uint=8, reflect:Boolean=true) {
			bmpList = new Vector.<Bitmap>();
			sliceList = new Vector.<Sprite>();
			pt = new Point();
			this.source = source;
			_radius = radius;
			_slices = slices;
			_reflect = reflect;
			if (_slices&1 && _reflect) { _slices++; }
			init();
			autoUpdate = true;
		}
		
	// Getter / setters:
		/** If true, the kaleidoscope will update every frame. If false, you must call update() when you want it to update. **/
		public function get autoUpdate():Boolean {
			return _autoUpdate;
		}
		public function set autoUpdate(value:Boolean):void {
			_autoUpdate = value;
			if (value) {
				addEventListener(Event.ENTER_FRAME,tick);
			} else {
				removeEventListener(Event.ENTER_FRAME,tick);
			}
		}
		
		/** If true, each slice of the kaleidoscope will be masked. If false, they will be able to overlap. **/
		public function get maskSlices():Boolean {
			return _maskSlices;
		}
		public function set maskSlices(value:Boolean):void {
			if (value == _maskSlices) { return; }
			_maskSlices = value;
			updateMask();
		}
		
		/** Sets the number of slices in the kaleidoscope. Must be 1 or greater. If reflect is true, this must be an even number. **/
		public function get slices():uint {
			return _slices;
		}
		public function set slices(value:uint):void {
			value = Math.max(1,value);
			if (_reflect && value&1) { value++; }
			if (_slices == value) { return; }
			_slices = value;
			init();
		}
		
		/** Indicates whether alternating slices should be flipped to reflect each other. If you set this to true with an odd number of slices, the number of slices will be increased by one to make it even. **/
		public function get reflect():Boolean {
			return _reflect;
		}
		public function set reflect(value:Boolean):void {
			if (_reflect == value) { return; }
			if (_reflect && _slices&1) { _slices++; }
			_reflect = value;
			init();
		}
		
		/** Sets the radius for the kaleidoscope. **/
		public function get radius():Number {
			return _radius;
		}
		public function set radius(value:Number):void {
			if (_radius == value) { return; }
			_radius = value;
			init();
		}
		
		/** Draws the latest source image to the kaleidoscope and calls the onChange and onChanged callbacks. Called every frame automatically if autoUpdate is true. **/
		public function update():void {
			if (onChange != null) { onChange(this); }
			bmpd.fillRect(bmpd.rect,0);
			if (source == null) { return; }
			if (source is BitmapData && offsetRotation == 0 && offsetX == 0 && offsetY == 0) {
				// fast mode, skip transform and draw:
				bmpd.copyPixels(source as BitmapData,bmpd.rect,pt,sliceMask,pt,false);
			} else {
				var mtx:Matrix = this.mtx.clone();
				mtx.translate(offsetX,offsetY);
				mtx.rotate(offsetRotation/180*Math.PI);
				bmpd.draw(source,mtx);
				if (_maskSlices) {
					bmpd.copyPixels(bmpd,bmpd.rect,pt,sliceMask,pt,false);
				}
			}
			if (onChanged != null) { onChanged(this); }
		}
		
		
	// Protected methods:
		protected function init():void {
			var a:Number = 360/_slices;
			
			// clean up old slices:
			while (numChildren > 0) { removeChildAt(0); }
			
			while (bmpList.length < _slices) {
				var bmp:Bitmap = new Bitmap();
				bmpList.push(bmp);
				var slice:Sprite = new Sprite();
				slice.addChild(bmp);
				sliceList.push(slice);
			}
			
			// get rid of extras if we had more slices before:
			bmpList.length = _slices; 
			sliceList.length = _slices;
			
			// Calculate the size of the slice bmpd:
			var bmpdW:Number = _slices>3&&_maskSlices?_radius:_radius*2;
			var bmpdH:Number = _slices>1&&_maskSlices?_radius:_radius*2;
			
			// only rebuild bmpd if dimensions have changed:
			if (bmpd == null || bmpd.width != bmpdW || bmpd.height != bmpdH) {
				if (bmpd) {
					bmpd.dispose();
					bmpd = null;
				}
				bmpd = new BitmapData( bmpdW , bmpdH ,true,0);
			}
			
			// set up the slices:
			for (var i:uint=0; i<bmpList.length; i++) {
				slice = sliceList[i];
				slice.rotation = a*i;
				if (_reflect && i%2) {
					slice.scaleX = -1;
					if (_slices/2%2==0) { slice.rotation+=a; }
				}
				bmp = bmpList[i];
				bmp.bitmapData = bmpd;
				bmp.smoothing = true;
				bmp.x = bmpd.width>_radius?-_radius:0;
				bmp.y = bmpd.height>_radius?-_radius:0;
				addChild(slice);
			}
			
			updateMask();
			
			// set up the base matrix (we add the offsets later):
			mtx = new Matrix(1,0,0,1,bmpd.width-_radius,bmpd.height-_radius);
		}
		
		protected function updateMask():void {
			// if maskSlices is false, we don't need to keep the sliceMask in memory:
			if (!_maskSlices) {
				if (sliceMask) {
					sliceMask.dispose();
					sliceMask = null;
				}
				return;
			}
			
			// only create a new sliceMask bitmapdata if the dimensions have changed:
			if (sliceMask == null || sliceMask.width != bmpd.width || sliceMask.height != bmpd.height) {
				if (sliceMask) {
					sliceMask.dispose();
					sliceMask = null;
				}
				sliceMask = new BitmapData(bmpd.width,bmpd.height,true,0);
			}
			
			// draw the slice:
			var sliceShape:Shape = new Shape();
			sliceShape.graphics.lineStyle(1,0,1);
			sliceShape.graphics.beginFill(0,1);
			drawSlice(sliceShape.graphics,bmpd.width>_radius?_radius:0,bmpd.height>_radius?_radius:0,_radius,360/_slices);
			
			// draw it into our alpha mask:
			sliceMask.draw(sliceShape);
		}
		
		protected function tick(evt:Event):void {
			update();
		}
		
		
		// drawSlice method adapted from drawWedge by Lee Brimelow:
		protected function drawSlice(g:Graphics, sx:Number, sy:Number, radius:Number, arc:Number, startAngle:Number=0):void {
			var segAngle:Number;
			var angle:Number;
			var angleMid:Number;
			var numOfSegs:Number;
			var ax:Number;
			var ay:Number;
			var bx:Number;
			var by:Number;
			var cx:Number;
			var cy:Number;
			
			// Move the pen
			g.moveTo(sx, sy);
			
			// No need to draw more than 360
			if (Math.abs(arc) > 360) {
				arc = 360;
			}
			
			numOfSegs = Math.ceil(Math.abs(arc) / 45);
			segAngle = arc / numOfSegs;
			segAngle = (segAngle / 180) * Math.PI;
			angle = (startAngle / 180) * Math.PI;
			
			// Calculate the start point
			ax = sx + Math.cos(angle) * radius;
			ay = sy + Math.sin(-angle) * radius;
			
			// Draw the first line
			g.lineTo(ax, ay);
			
			for (var i:int=0; i<numOfSegs; i++) {
				angle += segAngle;
				angleMid = angle - (segAngle / 2);
				bx = sx + Math.cos(angle) * radius;
				by = sy + Math.sin(angle) * radius;
				cx = sx + Math.cos(angleMid) * (radius / Math.cos(segAngle / 2));
				cy = sy + Math.sin(angleMid) * (radius / Math.cos(segAngle / 2));
				g.curveTo(cx, cy, bx, by);
			}
			
			// Close the wedge
			g.lineTo(sx, sy);
		}
		
		
	}
}