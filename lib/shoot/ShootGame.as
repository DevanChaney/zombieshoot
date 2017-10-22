package lib.shoot
{
	import flash.display.MovieClip
	import lib.shoot.Particle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	public class ShootGame extends MovieClip
	{
		private var Background:Sprite;
		private var BowArm:Sprite;
		private var Body:Sprite;
		private var arrows:Array;
		private var balloons:Array;
		public var bowLocation:Point;
		private var bowAngle:Number;
		
		private var arrowsLayer:Sprite;
		private var balloonsLayer:Sprite;
		private var touchLayer:Sprite;
		
		private var balloonSpawnDelay:Number;
		private var balloonSpawnCounter:Number;
		
		private var difficulty:Number;
		private var difficultyRate:Number;
		
		private var barrageCount:Number;
		private var barrageSpacing:Number;
		
		public function ShootGame()
		{
			barrageCount = 7;
			barrageSpacing = 5;
			
			difficultyRate = 0.3;
			difficulty = 1;
			balloonSpawnDelay = balloonSpawnCounter = 100;
			
			arrows = new Array();
			balloons = new Array();
			
			Background = new background();
			BowArm = new Arm();
			Body = new body();
			
			bowLocation = new Point(150, 450);
			bowAngle = 0;
			
			BowArm.x = bowLocation.x;
			BowArm.y = bowLocation.y;
			
			Body.x = bowLocation.x - 89.55;
			Body.y = bowLocation.y - 109.1;
			
			BowArm.rotation  = bowAngle;
			
			addChild(Background);
			addChild(Body);
			addChild(BowArm);
			
			addEventListener(Event.ENTER_FRAME, update);
			
			arrowsLayer = new Sprite();
			balloonsLayer = new Sprite();
			touchLayer = new Sprite();
			
			addChild(arrowsLayer);
			addChild(balloonsLayer);
			addChild(touchLayer);
			addEventListener(Event.ADDED_TO_STAGE, setupTouchLayer);
			touchLayer.addEventListener(MouseEvent.CLICK, shootArrow);
		}
		
		private function setupTouchLayer(evt:Event):void
		{
			touchLayer.graphics.beginFill(0x000000, 0);
			touchLayer.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			touchLayer.graphics.endFill();
			stage.addEventListener(KeyboardEvent.KEY_DOWN, shootArrowBarrage);
		}
		
		private function shootArrow(evt:MouseEvent):void
		{
			makeArrow(bowAngle);
		}
		
		private function shootArrowBarrage(evt:KeyboardEvent):void
		{
			if (evt.keyCode == Keyboard.SPACE)
			{
				var i:int;
				for (i = 0; i < barrageCount; i++)
				{
					makeArrow(bowAngle - ((barrageCount - i - (barrageCount / 2)) * barrageSpacing));
				}
			}
			//ASK FOR HELP, W KEY AND S KEY
			if (evt.keyCode == 87){
				bowLocation.y = bowLocation.y - 5;
			}
			
			if (evt.keyCode == 83){
				bowLocation.y = bowLocation.y + 5;
			}
		}
		
		private function makeArrow(angle:Number):void
		{
			var newArrow:Particle = new Arrow();
			
			newArrow.x = bowLocation.x;
			newArrow.y = bowLocation.y;
			newArrow.rotation = angle;
			
			var xDiff:Number = bowLocation.x - touchLayer.mouseX;
			var yDiff:Number = bowLocation.y - touchLayer.mouseY;
			
			var distance:Number = Math.sqrt(Math.pow(xDiff, 2) + Math.pow(yDiff, 2));
			
			var power:Number = distance / 15;
			
			newArrow.xVel = power * Math.cos(newArrow.rotation / 180 * Math.PI);
			newArrow.yVel = power * Math.sin(newArrow.rotation / 180 * Math.PI);
			
			newArrow.addEventListener(Particle.PURGE_EVENT, purgeArrowHandler);
			
			arrowsLayer.addChild(newArrow);
			arrows.push(newArrow);
		}
		
		private function makeBalloons():void
		{
			balloonSpawnCounter++;
			
			if (balloonSpawnCounter > balloonSpawnDelay)
			{
				balloonSpawnCounter = 0;
				balloonSpawnDelay -= difficultyRate;
				difficulty += difficultyRate;
				makeBalloon();
			}
		}
		
		private function makeBalloon():void
		{
			var i:int;
			for (i = 0; i < Math.floor(difficulty); i++)
			{
				var newBalloon:Balloon = new MouseBalloon();
				
				newBalloon.x = 1050;
				newBalloon.y = Math.random() * 300 + 150;
				
				newBalloon.xVel = (-Math.random() * difficulty) - 5;
				newBalloon.sinMeter = Math.random() * 10;
				newBalloon.bobValue = Math.random() * difficulty;
				
				newBalloon.addEventListener(Particle.PURGE_EVENT, purgeBalloonHandler);
				
				balloonsLayer.addChild(newBalloon);
				balloons.push(newBalloon);
			}
		}
		
		private function purgeArrowHandler(evt:Event):void
		{
			var targetArrow:Particle = Particle(evt.target);
			purgeArrow(targetArrow);
		}
		private function purgeBalloonHandler(evt:Event):void
		{
			var targetBalloon:Particle = Particle(evt.target);
			purgeBalloon(targetBalloon);
		}
		
		private function purgeBalloon(targetBalloon:Particle):void
		{
			targetBalloon.removeEventListener(Particle.PURGE_EVENT, purgeBalloonHandler);
			try
			{
				var i:int;
				for (i = 0; i < balloons.length; i++)
				{
					if (balloons[i].name == targetBalloon.name)
					{
						balloons.splice(i, 1);
						balloonsLayer.removeChild(targetBalloon);
						i = balloons.length;
					}
				}
			}
			catch(e:Error)
			{
				trace("Failed to delete balloon!", e);
			}
		}
		
		private function purgeArrow(targetArrow:Particle):void
		{
			targetArrow.removeEventListener(Particle.PURGE_EVENT, purgeArrowHandler);
			try
			{
				var i:int;
				for (i = 0; i < arrows.length; i++)
				{
					if (arrows[i].name == targetArrow.name)
					{
						arrows.splice(i, 1);
						arrowsLayer.removeChild(targetArrow);
						i = arrows.length;
					}
				}
			}
			catch(e:Error)
			{
				trace("Failed to delete arrow!", e);
			}
		}
		
		private function hitTest(arrow:Particle):void
		{
			for each (var balloon:Balloon in balloons)
			{
				if (balloon.status != "Dead" && balloon.hitTestPoint(arrow.x, arrow.y))
				{
					balloon.destroy();
					purgeArrow(arrow);
				}
			}
		}
		
		private function update(evt:Event):void
		{
			
			BowArm.x = bowLocation.x;
			BowArm.y = bowLocation.y;
			
			Body.x = bowLocation.x - 89.55;
			Body.y = bowLocation.y - 109.1;
			
			
			var target:Point = new Point(stage.mouseX, stage.mouseY);
			
			var angleRad:Number = Math.atan2(target.y - bowLocation.y, target.x - bowLocation.x);
			
			bowAngle = angleRad * 180 / Math.PI;
			
			BowArm.rotation = bowAngle;
			
			trace(balloons.length, arrows.length);
			
			for each (var balloon:Particle in balloons)
			{
				balloon.update();
			}
			
			for each (var arrow:Particle in arrows)
			{
				arrow.update();
				hitTest(arrow);
			}
			
			makeBalloons();
		}
	}
}