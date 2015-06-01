package;
import flixel.addons.util.FlxFSM;
import flixel.addons.util.FlxFSM.FlxFSMState;

class Ant
{
	
	public var fullness:Float = 1;
	public var health:Float = 1;
	
	public var fsm:FlxFSM<Ant>;
	
	public var world(default, null):World;
	
	public var x:Int;
	public var y:Int;
	
	public function new(x:Int = 0, y:Int = 0, world:World)
	{
		this.x = x;
		this.y = y;
		this.world = world;
		
		fsm = new FlxFSM<Ant>(this);
		
		var idle = new Idle();
		//var seekFood:Class<flixel.addons.util.FlxFSMState<Ant>> = new SeekFood();
		//var collectFood:Class<flixel.addons.util.FlxFSMState<Ant>> = new CollectFood();
		//fsm.transitions.start(new Idle());
			//.add(idle, seekFood, Conditions.isHungryAndfoodAvailable)
			//.add(idle, collectFood, Conditions.isHungryAndNotfoodAvailable)
		fsm.transitions.start(idle);
		
	}
	
	public function update(elapsed:Float=0):Void
	{
		fsm.update(elapsed);
	}
	
	public function destroy():Void
	{
		fsm.destroy();
		fsm = null;
	}
	
}

class Conditions
{
	
	public static function isHungryAndfoodAvailable(Owner:Ant)
	{
		return (Owner.fullness <= .2 && Owner.world.countFoodAvailable() > 0);
	}
	public static function isHungryAndNotfoodAvailable(Owner:Ant)
	{
		return (Owner.fullness <= .2 && Owner.world.countFoodAvailable() <= 0);
	}
	
}

class Idle extends FlxFSMState<Ant>
{
	override public function enter(Owner:Ant, FSM:FlxFSM<Ant>)
	{
		//
	}
	
	override public function update(elapsed:Float, Owner:Ant, FSM:FlxFSM<Ant>)
	{
		//
	}
}


class SeekFood extends flixel.addons.util.FlxFSMState<Ant>
{
	override public function enter(Owner:Ant, FSM:FlxFSM<Ant>)
	{
		// target a nearby food item
	}
	
	override public function update(elapsed:Float, Owner:Ant, FSM:FlxFSM<Ant>)
	{
		// move towards that food
	}
}

class CollectFood extends flixel.addons.util.FlxFSMState<Ant>
{
	override public function enter(Owner:Ant, FSM:FlxFSM<Ant>)
	{
		// target some grass
	}
	
	override public function update(elapsed:Float, Owner:Ant, FSM:FlxFSM<Ant>)
	{
		// move towards grass, then cut it down, and carry it back to home
		
	}
	
}
