package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import openfl.display.BitmapData;
using flixel.util.FlxSpriteUtil;


class World extends FlxGroup
{

	
	private var COLS_SOLID:Array<FlxColor>;
	
	
	public static inline var PT_EMPTY:Int = 0;
	public static inline var PT_SOLID:Int = 1;
	
	public var width(default, null):Float = 0;
	public var height(default, null):Float = 0;
	
	public var ground(default, null):FlxSprite;
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
		
		ground = new FlxSprite(0, 0);
		ground.makeGraphic(Std.int(this.width), Std.int(this.height), 0x0);
		
		var tmpNoise:BitmapData = new BitmapData(Std.int(this.width), Std.int(this.height), false, 0xff000000);
		tmpNoise.perlinNoise(this.width/4, this.height/4, 8, FlxG.random.currentSeed, false, true, 7, true);
		var rndRow:Int = FlxG.random.int(0, Std.int(height));
		
		var surfaceStart:Int = FlxG.random.int(35, 50);
		var value:FlxColor;
		var _surface:Array<Int> = [];
		for (i in 0...Std.int(width))
		{
			value = tmpNoise.getPixel(i, rndRow);
			_surface.push(surfaceStart + Math.floor(  value.brightness * 30));
			
		}
		ground.pixels.lock();
		
		trace(COLS_SOLID);
		for (x in 0...Std.int(width))
		{
			data[x] = [];
			for (y in 0...Std.int(height))
			{
				if (y < _surface[x])
				{
					data[x][y] = PT_EMPTY;
				}
				else
				{
					value = tmpNoise.getPixel(x, y);
					data[x][y] = PT_SOLID;
					
					ground.pixels.setPixel32(x, y, COLS_SOLID[Std.int(value.brightness * 100)]);
					
					//ground.drawRect(x, y, 1, 1, COLS_SOLID[Std.int(value.brightness * 100)]);
				}
			}
			
		}
		ground.pixels.unlock();
		ground.dirty = true;
		
		add(ground);
	}
	
	private function defineColors():Void
	{
		COLS_SOLID = FlxGradient.createGradientArray(1, 100, [0xffc69c6d, 0xffa67c52, 0xff8c6239, 0xff754c24, 0xff603913],1,90,true);
	}
	
}