package;

import Random;
import haxe.Exception;
import flixel.FlxG;

enum SimonButtons {
	Green;
	Purple;
	Red;
	Yellow;
}

class SimonGameplay {
	public var computerPattern:Array<SimonButtons>;

	public function new() {
		computerPattern = new Array<SimonButtons>();
	}

	public function ResetPattern() {
		computerPattern.resize(0);
	}

	public function GeneratePattern(length:Int):Array<SimonButtons> {
		while(computerPattern.length < length) {
			var newButton = Random.fromArray([SimonButtons.Green, SimonButtons.Purple, SimonButtons.Red, SimonButtons.Yellow]);
			computerPattern.insert(computerPattern.length, newButton);
		}

		return(computerPattern.copy());
	}

	public function ComparePattern(pattern:Array<SimonButtons>):Bool {
		if(computerPattern.length != pattern.length) {
			throw new Exception('Invalid pattern length.');
		}

		for(i => b in pattern) {
			if(computerPattern[i] != pattern[i]) {
				return(false);
			}
		}

		return(true);
	}

	public function LogPattern() {
		var pattern = "";
		for(b in computerPattern) {
			switch b {
				case SimonButtons.Green: pattern += "G";
				case SimonButtons.Red: pattern += "R";
				case SimonButtons.Yellow: pattern += "Y";
				case SimonButtons.Purple: pattern += "P";
			}
		}

		FlxG.log.notice(pattern);
	}
}