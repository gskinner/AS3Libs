package {
	
	
	import com.gskinner.motion.Wander;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	[SWF(frameRate="30", backgroundColor="#FFFFFF")]
	public class WanderFollow extends Sprite {
		
		protected var w:Number;
		protected var h:Number;
		
		public function WanderFollow() {
			stage.scaleMode = "noScale";
			stage.align = "tl";
			init();
		}
		
		protected function init():void {
			
			w = stage.stageWidth;
			h = stage.stageHeight;
			
			var superDude:Sprite = getDude(0xFF0000);
			superDude.scaleX = superDude.scaleY = 2;
			new Wander(superDude,{speed:9,outerRadius:h,innerRadius:h*0.5,targetY:h*0.5,targetX:w*0.5,varyRotation:0.5});
			
			var oldDude:Sprite = superDude;
			for (var i:uint=0; i<200; i++) {
				
				var dude:Sprite = getDude(0x000000);
				new Wander(dude,{speed:8+i*0.02,strength:Math.random()*0.1,outerRadius:Math.random()*400+200,innerRadius:20,varyRotation:0.05,targetObject:superDude,rotationLimit:Math.random()*5+5});
			}
		}
		
		protected function getDude(color:uint):Sprite {
			var dude:Sprite = new Sprite();
			dude.graphics.beginFill(color,1);
			dude.graphics.moveTo(-3,-1);
			dude.graphics.lineTo(-3,1);
			dude.graphics.lineTo(3,0);
			
			dude.x = -100;
			dude.y = -100;
			
			addChild(dude);
			
			return dude;
		}
		
	}
}