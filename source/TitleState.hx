package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TitleState extends FlxState
{
	private var titleText:FlxText;
	private var menuText:FlxText;
	private var selectedMode:String = "cpu";

	override public function create()
	{
		super.create();

		titleText = new FlxText(0, FlxG.height / 2 - 100, FlxG.width, "Eraser Drop Game", 48);
		titleText.alignment = CENTER;
		titleText.color = FlxColor.WHITE;
		add(titleText);

		menuText = new FlxText(0, FlxG.height / 2 - 20, FlxG.width, "1: CPU Battle\n2: 100 Matches\nPress 1 or 2 to select, SPACE to start", 24);
		menuText.alignment = CENTER;
		menuText.color = FlxColor.YELLOW;
		add(menuText);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE)
		{
			selectedMode = "cpu";
			menuText.text = "Selected: CPU Battle\nPress SPACE to start";
		}
		else if (FlxG.keys.justPressed.TWO)
		{
			selectedMode = "100matches";
			menuText.text = "Selected: 100 Matches\nPress SPACE to start";
		}

		if (FlxG.keys.justPressed.SPACE)
		{
			FlxG.switchState(new PlayState(selectedMode));
		}
	}
}