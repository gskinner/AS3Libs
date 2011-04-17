/*
Note that much of the CPU cost of this demo is generating the perlin noise.
*/

package {
	import com.gskinner.effects.Kaleidoscope;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	
	[SWF(frameRate="20", backgroundColor="#000000")]
	public class KaleidoscopeTest extends Sprite {
		
		protected var ks:Kaleidoscope;
		protected var src:BitmapData;
		protected var count:uint=0;
		
		public function KaleidoscopeTest() {
			stage.scaleMode = "noScale";
			stage.align = "tl";
			
			src = new BitmapData(400,100,false,0);
			
			ks = new Kaleidoscope(src,200,10,true);
			ks.onChange = update;
			ks.x = stage.stageWidth>>1;
			ks.y = stage.stageHeight>>1;
			ks.offsetX = -src.width/2;
			ks.offsetY = -src.height/2;
			ks.rotation = 18;
			addChild(ks);
			
			ks.filters = [new GlowFilter(0xFFFFFF, 1, 8, 8, 32, 1)];
		}
		
		protected function update(ks:Kaleidoscope):void {
			count++;
			src.perlinNoise(150,50,2,0,false,false,7,false,[new Point(count,count),new Point(count*1.7,-count*2.7),new Point(-count*4.1,count*8.1)]);
			ks.offsetRotation = -count%360;
		}
		
		
	}
}