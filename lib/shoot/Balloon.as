package lib.shoot
{
	import flash.display.MovieClip;
	import lib.shoot.Particle;
	import flash.events.Event;	
	
	public class Balloon extends Particle
	{
		public var sinMeter:Number;
		public var bobValue:Number;
		public var status:String;
		
		public function Balloon()
		{
			status = "OK";
			bobValue = 0.1;
			sinMeter = 0;
			xVel = 0;
			yVel = 0;
			airResistance = 1;
			gravity = 0;
			gotoAndStop(1);
		}
		
		public function destroy():void
		{
			gotoAndStop(2);
			gravity = 0.75;
			status = "Dead";
		}
		
		public override function update():void
		{
			if (status != "Dead")
			{
				yVel = Math.sin(sinMeter) * bobValue;
			}
			
			sinMeter += 0.1;
			super.update();
			
			if (x < 0)
			{
				trace("Dispatching Balloon Escaped!");
				dispatchEvent(new Event(Particle.PURGE_EVENT, true, false));
			}
		}
	}
}