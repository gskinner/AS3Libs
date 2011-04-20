/**
 * ProximityManager by Grant Skinner. Nov 17, 2009
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

package com.gskinner.utils {
	
	import flash.display.DisplayObject;
	import flash.filters.DisplacementMapFilter;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import __AS3__.vec.Vector; // for ASDoc
	
	/**
	 * <b>ProximityManager ©2009 Grant Skinner, gskinner.com. Visit www.gskinner.com/blog/ for documentation, updates and more free code. Licensed under the MIT license - see the source file header for more information.</b>
	 * <hr/>
	 * Uses grid based proximity to quickly return coarse neighbors of a display object in systems with large numbers of items. It has a linear growth pattern for processing time,
	 * versus an exponential growth pattern for simpler compare all to all approaches. For example, in a system with 5000 items, it would require nearly 12.5 million iterations to
	 * compare each item's distance directly. With this library it only requires 5000 iterations. While the cost per iteration is higher with grid based proximity, that cost is quickly 
	 * made insignificant as you add more items.
	 * <br/><br/>
	 * This class also offers optional item list management methods. These are significant in that they support the removal and addition of items between updates. An item removed with removeItem() after update() was called
	 * will not be returned in subsequent getNeighbor calls.
	 **/
	public class ProximityManager {
		
	// Public properties:
		/** 
		 * If true, items will be included in getNeighbor calls immediately when they are added.
		 * If false, they will not be included until the next time update() is called.
		 **/
		public var addItemsImmediately:Boolean=false;
		
	// Protected properties:
		/** @private **/
		protected var _items:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		/** @private **/
		protected var grid:Vector.<Vector.<DisplayObject>>;
		/** @private **/
		protected var deadItems:Dictionary = new Dictionary(true);
		/** @private **/
		protected var checkDead:Boolean=false;
		/** @private **/
		protected var liveItems:Dictionary = new Dictionary(true);
		/** @private **/
		protected var gridSize:Number;
		/** @private **/
		protected var bounds:Rectangle;
		/** @private **/
		protected var w:uint;
		/** @private **/
		protected var h:uint;
		/** @private **/
		protected var offX:Number=0;
		/** @private **/
		protected var offY:Number=0;
		/** @private **/
		protected var length:uint;
		/** @private **/
		protected var lengths:Vector.<uint>;
		/** @private **/
		protected var m:Number;
		
		
	// Constructor:
		/** Constructs a new ProximityManager instance **/
		public function ProximityManager(gridSize:Number,bounds:Rectangle) {
			this.gridSize = gridSize;
			this.bounds = bounds;
			init();
		}
		
	// Public getter / setters:
		/**
		 * The list of items currently being tracked in the system. You can use this to quickly pass in a list of
		 * existing items, or retrieve the current list. It is recommended to use the addItem and removeItem methods
		 * for minor modifications to the list.
		 **/
		public function get items():Vector.<DisplayObject> {
			return _items;
		}
		public function set items(value:Vector.<DisplayObject>):void {
			_items = value;
			for (var o:Object in deadItems) { delete(deadItems[o]); }
			var l:uint = _items.length;
			for (var i:uint=0; i<l; i++) {
				liveItems[_items[i]] = true;
			}
		}
		
	// Public methods:
		/**
		 * Adds an item to track. If addItemsImmediately is true, it will immediately
		 * be inserted into the active grid, if not, it will be inserted the next time update() is called.
		 * <b>Note that removing and adding an item within the same update with addItemsImmediately can cause problems with duplicate returns.</b>
		 **/
		public function addItem(item:DisplayObject):void {
			if (!(liveItems[item] || deadItems[item])) {
				_items.push(item);
			}
			liveItems[item] = true;
			delete(deadItems[item]);
			
			if (addItemsImmediately) {
				var pos:uint = ((item.x+offX)*m|0)*h+(item.y+offY)*m;
				grid[pos][lengths[pos]++] = item;
			}
		}
		
		/**
		 * Removes an item from the system. It will not be returned in any subsequent getNeighbors() calls.
		 **/
		public function removeItem(item:DisplayObject):void {
			if (!liveItems[item]) { return; }
			deadItems[item] = true;
			delete(liveItems[item]);
			checkDead = true;
		}
		
		/**
		 * Updates the positions of all items on the grid. Call this when items have moved, but not after *each* item moves.
		 * For example, if you have a number of sprites moving around on screen each frame, move them all, then call update() once per frame.
		 **/
		public function update():void {
			// clear grid:
			lengths.length = 0;
			lengths.length = length;
			for (var i:int=0; i<length; ++i) {
				grid[i].length = 0;
			}
			
			// populate grid:
			var l:uint = _items.length;
			for (i=l; i-->0; ) {
				var item:DisplayObject = _items[i];
				if (checkDead && deadItems[item]) {
					_items.splice(i,1);
					delete(deadItems[item]);
					continue;
				}
				var pos:uint = ((item.x+offX)*m|0)*h+(item.y+offY)*m;
				grid[pos][lengths[pos]++] = item;
			}
			checkDead = false;
		}
		
		/**
		 * Returns the list of neighbors for the specified item. Neighbours are items in grid positions within radius positions away from the item.
		 * For example, a radius of 0 returns only items in the same position. A radius of 1 returns 9 positions (the center, + the 8 positions 1 position away).
		 * A radius of 2 returns 25 positions. It is generally recommended to only use a radius of 1, but there are occasional use cases that may benefit from using
		 * a radius of 2.
		 * <br/><br/>
		 * It is important to note that this is a coarse set of neighbors. Their distance from the target item varies depending on their location within their grid position.
		 * This is allows you to exclude items that are too far away, then use more accurate comparisions (like pythagoram distance calculations or hit tests) on the
		 * smaller set of items.
		 * <br/><br/>
		 * You can specify a resultVector to avoid the need for ProximityManager to instantiate a new Vector each time you call getNeighbors. Results will be appended
		 * to the end of the vector. You may want to clear the vector with myVector.length = 0 before reusing it.
		 **/
		public function getNeighbors(item:DisplayObject,radius:uint=1,resultVector:Vector.<DisplayObject>=null):Vector.<DisplayObject> {
			
			var itemX:uint = (item.x+offX)/gridSize|0;
			var itemY:uint = (item.y+offY)/gridSize|0;
			
			var minX:int = itemX-radius;
			if (minX < 0) { minX = 0; }
			
			var minY:int = itemY-radius;
			if (minY < 0) { minY = 0; }
			
			var maxX:uint = itemX+radius;
			if (maxX > w) { maxX = w; }
			
			var maxY:uint = itemY+radius;
			if (maxY > h) { maxY = h; }
			
			var results:Vector.<DisplayObject> = resultVector ? resultVector : new Vector.<DisplayObject>();
			var count:uint= resultVector ? resultVector.length : 0;
			for (var x:uint=minX; x<=maxX; x++) {
				var adjX:uint = x*h;
				for (var y:uint=minY; y<=maxY; y++) {
					var itemList:Vector.<DisplayObject> = grid[adjX+y];
					var l:uint = itemList.length;
					for (var i:uint=0; i<l; i++) {
						var item:DisplayObject = itemList[i];
						if (!checkDead || !deadItems[item]) { results[count++] = itemList[i]; }
					}
				}
			}
			return results;
		}
		
		
	// Protected methods:
		/** @private **/
		protected function init():void {
			w = Math.ceil(bounds.width/gridSize)+1;
			h = Math.ceil(bounds.height/gridSize)+1;
			length = w*h;
			offX = -bounds.x;
			offY = -bounds.y;
			m = 1/gridSize;
			
			lengths = new Vector.<uint>();
			grid = new Vector.<Vector.<DisplayObject>>(length,true);
			for (var i:uint=0; i<length; i++) {
				grid[i] = new Vector.<DisplayObject>();
			}
		}
		
		
	}
}