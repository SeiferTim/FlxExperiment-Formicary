package;

import cloner.Cloner;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
import openfl.geom.Point;
using flixel.util.FlxSpriteUtil;


class World extends FlxGroup
{
	
	private static inline var MIN_HOLES:Float = .6;
	private static inline var MAX_HOLES:Float = .2;
	private static inline var MIN_STONES:Float = .2;
	
	private static inline var STEPS:Int = 2;

	private var COLS_SOLID:Array<FlxColor>;
	private var COLS_GRASS:Array<FlxColor>;
	private var COLS_STONE:Array<FlxColor>;
	
	public static inline var PT_EMPTY:Int = 0;
	public static inline var PT_SOLID:Int = 1;
	public static inline var PT_STONE:Int = 2;
	public static inline var PT_FOOD:Int = 3;
	public static inline var PT_GRASS:Int = 4;
	
	public var width(default, null):Float = 0;
	public var height(default, null):Float = 0;
	
	public var sky(default, null):FlxSprite;
	public var ground(default, null):FlxSprite;
	public var antLayer(default, null):FlxSprite;
	
	public var ants(default, null):Array<Ant>;
	
	public var data(default, null):Array<Array<Int>>;
	
	
	public function new(width:Float=0, height:Float=0) 
	{
		super();
		
		defineColors();
		
		if (width == 0)
			width = FlxG.width;
		if (height == 0)
			height = FlxG.height;
			
		this.width = width;
		this.height = height;
		
		data = [];
		
		ground = new FlxSprite();
		ground.makeGraphic(Std.int(this.width), Std.int(this.height), 0x0);
		sky = new FlxSprite();
		sky.makeGraphic(Std.int(this.width), Std.int(this.height), 0x0);
		antLayer = new FlxSprite();
		antLayer.makeGraphic(Std.int(this.width), Std.int(this.height), 0x0);
		
		for (x in 0...Std.int(width))
		{
			data[x] = [];
			for (y in 0...Std.int(height))
			{
				data[x][y] = PT_SOLID;
			}
			
		}
		
		for (i in 0...STEPS)
		{
			doHoleStep();
			
		}
		
		for (i in 0...STEPS)
		{
			doStoneStep();
		}
		
		finishMap();
		
		add(sky);
		add(ground);
		add(antLayer);
		
		ants = new Array<Ant>();
		ants.push(new Ant(0,0, this));
	}
	
	public function countFoodAvailable():Int
	{
		var value:Int = 0;
		for (x in 0...Std.int(width))
		{
			for (y in 0...Std.int(height))
			{
				if (data[x][y] == PT_FOOD)
					value++;
			}
		}
		return value;
	}
	
	
	public function drawAnts():Void
	{
		antLayer.pixels.lock();
		antLayer.pixels = new BitmapData(Std.int(width), Std.int(height), true, 0x0);
		
		// draw ants!!!!!!
		for (a in ants)
		{
			if (a != null)
			{
				antLayer.pixels.setPixel32(a.x, a.y, 0xff9e005d);
			}
		}
		
		antLayer.pixels.unlock();
		antLayer.dirty = true;
	}
	
	private function finishMap():Void
	{
		var tmpGrad:BitmapData = FlxGradient.createGradientBitmapData(Std.int(this.width), Std.int(this.height), [0xff8affff, 0xff67bfbf, 0xff67bfbf]);
		var tmpNoise:BitmapData = new BitmapData(Std.int(width), Std.int(height), false, 0xff000000);
		tmpNoise.perlinNoise(width/4, height/4, 8, FlxG.random.currentSeed, false, true, 7, true);
		var surfaceStart:Int = FlxG.random.int(35, 50);
		var _surface:Array<Int> = [];
		var rndRow:Int = FlxG.random.int(0, Std.int(height));
		var value:FlxColor;
		for (i in 0...Std.int(width))
		{
			value = tmpNoise.getPixel(i, rndRow);
			_surface.push(surfaceStart + Math.floor(  value.brightness * 30));
			
		}
		sky.pixels.lock();
		ground.pixels.lock();
		
		var y:Int = 0;
		var foundTop:Bool = false;
		for (x in 0...Std.int(width))
		{
			y = 0;
			foundTop = false;
			while (y < Std.int(height) && !foundTop)
			{
				if (y >= _surface[x] && data[x][y] != PT_EMPTY)
				{
					foundTop = true;
					_surface[x] = y;
				}
				y++;
			}
		}
		
		for (x in 0...Std.int(width))
		{
			
			for (y in 0...Std.int(height))
			{
				if (y < _surface[x])
				{
					sky.pixels.setPixel32(x, y, tmpGrad.getPixel32(x, y));
					if (y + 1 == _surface[x] && data[x][y+1] == PT_SOLID)
					{
						addGrass(x, y);
					}
					else
					{
						data[x][y] = PT_EMPTY;
						
					}
				}
				else
				{
					value = tmpNoise.getPixel(x, y);
					sky.pixels.setPixel32(x, y, COLS_SOLID[Std.int(value.brightness * 100)].getDarkened(.4));
					if (data[x][y] == PT_SOLID)
					{
						
						addGround(x, y, value.brightness);
					}
					else if (data[x][y] == PT_STONE)
					{
						value = tmpNoise.getPixel(Std.int(width - x), Std.int(height - y));
						addStone(x, y, value.brightness);
					}
				}
			}
		}
		sky.pixels.unlock();
		ground.pixels.unlock();
		ground.dirty = true;
		sky.dirty = true;
		
	}
	
	
	private function doStoneStep():Void
	{
		var tmpNoise:BitmapData = new BitmapData(Std.int(width), Std.int(height), false, 0xff000000);
		tmpNoise.perlinNoise(width / 12, height / 12, 4, FlxG.random.int() , true, true, 7, true);
		var tmpGrad:BitmapData = FlxGradient.createGradientBitmapData(Std.int(width), Std.int(height), [  0x0, 0x0,0x0,0x0,0x0,0x0, 0xcc000000]);
		var tmpSolid:BitmapData = FlxGradient.createGradientBitmapData(Std.int(width), Std.int(height), [0xff000000,0xff000000]);
		tmpNoise.copyPixels(tmpSolid, tmpSolid.rect, new Point(), tmpGrad, new Point(), false);
		
		var value:FlxColor;
		for (r in 0...Std.int(width))
		{
			for (c in 0...Std.int(height))
			{
				value = tmpNoise.getPixel32(r, c);
				if (value.brightness < MIN_STONES)
				{
					data[r][c] = PT_STONE;
				}
			}
		}
		
	}
	
	
	private function doHoleStep():Void
	{
		var tmpNoise:BitmapData = new BitmapData(Std.int(width), Std.int(height), false, 0xff000000);
		tmpNoise.perlinNoise(width /6, height /6, 16, FlxG.random.int() , true, true, 7, true);
		var value:FlxColor;
		for (r in 0...Std.int(width))
		{
			for (c in 0...Std.int(height))
			{
				value = tmpNoise.getPixel32(r, c);
				//trace(value.getColorInfo());
				if (data[r][c] == PT_EMPTY)
				{
					if (value.brightness > .4)
					{
						data[r][c] = PT_SOLID;
					}
					
				}
				else if (value.brightness < .3)
				{
					data[r][c] = PT_EMPTY;
				}
			}
		}
		
	}
	
	private function addStone(x:Int, y:Int, value:Float):Void
	{
		ground.pixels.setPixel32(x, y, COLS_STONE[Std.int(value * 100)]);
		
	}
	private function addGround(x:Int, y:Int, value:Float):Void
	{
		var color:FlxColor = COLS_SOLID[Std.int(value * 100)];
		ground.pixels.setPixel32(x, y, color);
		
		
	}
	
	private function addGrass(x:Int, y:Int):Void
	{
		
		var grassLen:Int = 0;
		var grassColorStart:Int = 0;
		var darkness:Float = 0 ;
		if (FlxG.random.bool(98))
		{
			grassLen = FlxG.random.int( 8, 32);
		}
		if (grassLen <= 0)
		{
			data[x][y] = PT_EMPTY;
		}
		else
		{
			grassColorStart = FlxG.random.int(0, 100);
			darkness = 0;
			for (tmpY in y-grassLen...y+1)
			{
				if (tmpY >= 0)
				{
					data[x][tmpY] = PT_GRASS;
					ground.pixels.setPixel32(x, tmpY, COLS_GRASS[grassColorStart].getDarkened(darkness));
					darkness += (.4 / grassLen);
				}
			}
		}
	}
	
	private function defineColors():Void
	{
		COLS_SOLID = FlxGradient.createGradientArray(1, 100, [0xffc69c6d, 0xffa67c52, 0xff8c6239, 0xff754c24, 0xff603913], 1, 90, true);
		COLS_GRASS = FlxGradient.createGradientArray(1, 100, [0xff194D00, 0xff55FF00], 1, 90, true);
		COLS_STONE = FlxGradient.createGradientArray(1, 100, [0xffc7b299, 0xff959595, 0xff8b956d, 0xffebebeb, 0xff464646, 0xffc6c6c6, 0xff736357], 1, 90, true);
	}
	
	override public function draw():Void 
	{
		drawAnts();
		super.draw();
		
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		for (a in ants)
		{
			if (a != null)
			{
				a.update(elapsed);
			}
		}
	}
	
}