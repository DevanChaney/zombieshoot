package lib.shoot
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Particle extends MovieClip
	{
		public static const PURGE_EVENT:String = "PURGE";
		
		public var xVel:Number;
		public var yVel:Number;
		public var airResistance:Number;
		public var gravity:Number;
		
		public function Particle()
		{
			xVel = 0;
			yVel = 0;
			airResistance = 0.97;
			gravity = 0.75;
		}
		
		public function update():void
		{
			yVel += gravity;
			
			yVel *= airResistance;
			xVel *= airResistance;
			
			rotation = Math.atan2(yVel, xVel) * 180 / Math.PI;
			
			x += xVel;
			y += yVel;
			
			if (y > 650)
			{
				trace("Dispatching Particle Fell!");
				dispatchEvent(new Event(Particle.PURGE_EVENT, true, false));
			}
		}
	}
}