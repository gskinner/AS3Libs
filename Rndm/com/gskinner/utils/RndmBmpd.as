/**
* Rndm by Grant Skinner. Jan 15, 2008
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
*
* Copyright (c) 2008 Grant Skinner
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
*/

package com.gskinner.utils {

	import flash.display.BitmapData;
	
	// Provides common random functions using a seeded random system. Can be used through static interface or via instantiation.
	
	public class Rndm {
	// static interface:
		// NOTE: for usage information, look at the instance methods below.
	
		protected static var _instance:Rndm;
		public static function get instance():Rndm {
			if (_instance == null) { _instance = new Rndm(); }
			return _instance;
		}
		
		public static function get seed():uint {
			return instance.seed;
		}
		public static function set seed(value:uint):void {
			instance.seed = value;
		}
		
		public static function get pointer():uint {
			return instance.pointer;
		}
		public static function set pointer(value:uint):void {
			instance.pointer = value;
		}
		
		public static function random():Number {
			return instance.random();
		}
		
		public static function float(min:Number,max:Number=NaN):Number {
			return instance.float(min,max);
		}
		
		public static function boolean(chance:Number=0.5):Boolean {
			return instance.boolean(chance);
		}
		
		public static function sign(chance:Number=0.5):int {
			return instance.sign(chance);
		}
		
		public static function bit(chance:Number=0.5):int {
			return instance.bit(chance);
		}
		
		public static function integer(min:Number,max:Number=NaN):int {
			return instance.integer(min,max);
		}
		
		public static function shuffle(array:Array):Array {
			return instance.shuffle(array);
		}
		
		public static function item(array:Array):* {
			return instance.item(array);
		}
		
		public static function reset():void {
			instance.reset();
		}
		
		
	// constants:
	// private properties:
		protected var _seed:uint=0;
		protected var _pointer:uint=0;
		protected var bmpd:BitmapData;
		protected var seedInvalid:Boolean=true;
	
	// public properties:
		
	// constructor:
		public function Rndm(seed:uint=0) {
			_seed = seed;
			bmpd = new BitmapData(1000,200);
		}
		
	// public getter/setters:
	
		// seed = Math.random()*0xFFFFFF; // sets a random seed
		// seed = 50; // sets a static seed
		public function get seed():uint {
			return _seed;
		}
		public function set seed(value:uint):void {
			if (value != _seed) { seedInvalid = true; _pointer=0; }
			_seed = value;
		}
		
		// trace(Rndm.pointer); // traces the current position in the number series
		// Rndm.pointer = 50; // moves the pointer to the 50th number in the series
		public function get pointer():uint {
			return _pointer;
		}
		public function set pointer(value:uint):void {
			_pointer = value;
		}
	
	// public methods:
		// random(); // returns a number between 0-1 exclusive.
		public function random():Number {
			
			_seed = (_seed * 16807) % 2147483647
			return _seed/0x7FFFFFFF*0.999999999999998+0.000000000000001;
			
			/*
			if (seedInvalid) {
				bmpd.noise(_seed,0,255,1|2|4|8);
				seedInvalid = false;
			}
			_pointer++;
			// Flash's numeric precision appears to run to 0.9999999999999999, but we'll drop one digit to be safe:
			return (bmpd.getPixel32(_pointer%1000,_pointer/1000>>0%200)*0.999999999999998+0.000000000000001)/0xFFFFFFFF;
			
			*/
		}
		
		// float(50); // returns a number between 0-50 exclusive
		// float(20,50); // returns a number between 20-50 exclusive
		public function float(min:Number,max:Number=NaN):Number {
			if (isNaN(max)) { max = min; min=0; }
			return random()*(max-min)+min;
		}
		
		// boolean(); // returns true or false (50% chance of true)
		// boolean(0.8); // returns true or false (80% chance of true)
		public function boolean(chance:Number=0.5):Boolean {
			return (random() < chance);
		}
		
		// sign(); // returns 1 or -1 (50% chance of 1)
		// sign(0.8); // returns 1 or -1 (80% chance of 1)
		public function sign(chance:Number=0.5):int {
			return (random() < chance) ? 1 : -1;
		}
		
		// bit(); // returns 1 or 0 (50% chance of 1)
		// bit(0.8); // returns 1 or 0 (80% chance of 1)
		public function bit(chance:Number=0.5):int {
			return (random() < chance) ? 1 : 0;
		}
		
		// integer(50); // returns an integer between 0-49 inclusive
		// integer(20,50); // returns an integer between 20-49 inclusive
		public function integer(min:Number,max:Number=NaN):int {
			if (isNaN(max)) { max = min; min=0; }
			// Need to use floor instead of bit shift to work properly with negative values:
			return Math.floor(float(min,max));
		}
		
		// shuffle(arr); // shuffles the items in the specified array. Modifies the original array.
		// arr2 = shuffle(arr1.slice()); // to get a new shuffled array w/o modifying original.
		// no allocations or array resizing.
		public function shuffle(array:Array):Array {
			var l = array.length;
			for (var i:uint=0; i<l; i++) {
				var j:uint = l*random()|0;
				if (j==i) { continue; }
				var item:* = array[j];
				array[j] = array[i];
				array[i] = item;
			}
			return array;
		}
		
		// item([1,3,5]); // returns a random item from the array. Does not modify the original array.
		public function item(array:Array):* {
			return array[array.length*random()|0];
		}
		
		// reset(); // resets the number series, retaining the same seed
		public function reset():void {
			_pointer = 0;
		}
		
	// private methods:
	}
}
