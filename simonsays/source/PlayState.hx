package;

import flixel.FlxState;
import SimonGameplay;
import flixel.FlxG;
import flixel.system.FlxSound;
import haxe.Timer;
import flixel.FlxSprite;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var gameplayObj:SimonGameplay;
	var playerPattern:Array<SimonButtons>;
	var currentLevel:Int;
	var highestScore:Int;
	var gs:flixel.system.FlxSound;
	var ps:flixel.system.FlxSound;
	var rs:flixel.system.FlxSound;
	var ys:flixel.system.FlxSound;
	var playbackPattern:Array<SimonButtons>;
	var playbackTimer:Timer;
	var nextLevelTimer:Timer;
	var initialized:Bool;
	var lossCounter:Int;

	//Delcaring vars for the images of the 
	private var background:FlxSprite;
	private var G_Buttonlit:FlxSprite;
	private var G_Button:FlxSprite;
	private var P_Buttonlit:FlxSprite;
	private var P_Button:FlxSprite;
	private var R_Buttonlit:FlxSprite;
	private var R_Button:FlxSprite;
	private var Y_Buttonlit:FlxSprite;
	private var Y_Button:FlxSprite;
	private var GameBoard:FlxSprite;

	var highScore:FlxText;
	var currentScore:FlxText;
	var instructions:FlxText;

	override public function create()
	{
		super.create();

		// Create a gameplay object to track computer generated patterns
		gameplayObj = new SimonGameplay();

		// Create an array to store user input
		playerPattern = new Array<SimonButtons>();

		// Set current level
		currentLevel = 1;
		highestScore = 0;

		background = new flixel.FlxSprite();
		background.loadGraphic("assets/images/background.png");
		background.screenCenter();
		background.scale.set(0.3, 0.3);
		add(background);

		GameBoard = new flixel.FlxSprite();
		GameBoard.loadGraphic("assets/images/gameboard.png");
		GameBoard.screenCenter();
		GameBoard.scale.set(0.5, 0.5);
		add(GameBoard);

		highScore = new FlxText(0,0,0, "High Score: " + highestScore, 20);
		highScore.size = 15;
		highScore.x = 400;
		highScore.y = 20;
		add(highScore); // removed for now

		currentScore = new FlxText(0,0,0, "Current Level: " + currentLevel, 20);
		currentScore.size = 15;
		currentScore.x = 30;
		currentScore.y = 20;
		add(currentScore);

		instructions = new FlxText(0, 0, 0, "Listen and watch!", 20);
		instructions.size = 15;
		instructions.screenCenter();
		instructions.y = 430;
		add(instructions);

		G_Button = new flixel.FlxSprite();
		G_Button.loadGraphic("assets/images/button_green.png");
		G_Button.scale.set(0.5, 0.5);
		G_Button.updateHitbox();
		G_Button.screenCenter();
		G_Button.y = 85;
		add(G_Button);

		G_Buttonlit = new flixel.FlxSprite();
		G_Buttonlit.loadGraphic("assets/images/button_green_lit.png");
		G_Buttonlit.scale.set(0.5, 0.5);
		G_Buttonlit.updateHitbox();
		G_Buttonlit.screenCenter();
		G_Buttonlit.y = 85;
		G_Buttonlit.alpha = 0.0;
		add(G_Buttonlit);

		P_Button = new flixel.FlxSprite();
		P_Button.loadGraphic("assets/images/button_purple.png");
		P_Button.scale.set(0.5, 0.5);
		P_Button.updateHitbox();
		P_Button.screenCenter();
		P_Button.y = 285;
		add(P_Button);

		P_Buttonlit = new flixel.FlxSprite();
		P_Buttonlit.loadGraphic("assets/images/button_purple_lit.png");
		P_Buttonlit.scale.set(0.5, 0.5);
		P_Buttonlit.updateHitbox();
		P_Buttonlit.screenCenter();
		P_Buttonlit.y = 285;
		P_Buttonlit.alpha = 0.0;
		add(P_Buttonlit);

		R_Button = new flixel.FlxSprite();
		R_Button.loadGraphic("assets/images/button_red.png");
		R_Button.scale.set(0.5, 0.5);
		R_Button.updateHitbox();
		R_Button.screenCenter();
		R_Button.x = 360;
		add(R_Button);

		R_Buttonlit = new flixel.FlxSprite();
		R_Buttonlit.loadGraphic("assets/images/button_red_lit.png");
		R_Buttonlit.scale.set(0.5, 0.5);
		R_Buttonlit.updateHitbox();
		R_Buttonlit.screenCenter();
		R_Buttonlit.x = 360;
		R_Buttonlit.alpha = 0.0;
		add(R_Buttonlit);

		Y_Button = new flixel.FlxSprite();
		Y_Button.loadGraphic("assets/images/button_yellow.png");
		Y_Button.scale.set(0.5, 0.5);
		Y_Button.updateHitbox();
		Y_Button.screenCenter();
		Y_Button.x = 165;
		add(Y_Button);

		Y_Buttonlit = new flixel.FlxSprite();
		Y_Buttonlit.loadGraphic("assets/images/button_yellow_lit.png");
		Y_Buttonlit.scale.set(0.5, 0.5);
		Y_Buttonlit.updateHitbox();
		Y_Buttonlit.screenCenter();
		Y_Buttonlit.x = 165;
		Y_Buttonlit.alpha = 0.0;
		add(Y_Buttonlit);

		if (FlxG.sound.music == null) // don't restart the music if it's already playing
 		{
     		FlxG.sound.playMusic(AssetPaths.bg__ogg, 0.20);
 		}

 		// Load sound assets
	 	gs = FlxG.sound.load(AssetPaths.button_green__wav);
	 	ps = FlxG.sound.load(AssetPaths.button_purple__wav);
	 	rs = FlxG.sound.load(AssetPaths.button_red__wav);
	 	ys = FlxG.sound.load(AssetPaths.button_yellow__wav);

	 	// Start level
	 	startLevel();

	 	// Set loss counter; after 3 losses, reset game
	 	lossCounter = 0;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if(initialized == false) {
			return;
		}

		// Process key releases
		if(FlxG.keys.enabled) {
			// Separately, check for button releases to disable lit states
			if(FlxG.keys.anyJustReleased([UP,W])) {
				G_Buttonlit.alpha = 0.0;
			}
			if(FlxG.keys.anyJustReleased([DOWN,S])) {
				P_Buttonlit.alpha = 0.0;
			}
			if(FlxG.keys.anyJustReleased([LEFT,A])) {
				Y_Buttonlit.alpha = 0.0;
			}
			if(FlxG.keys.anyJustReleased([RIGHT,D])) {
				R_Buttonlit.alpha = 0.0;
			}
		}

		if(playbackPattern.length > 0) {
			// Don't process any player input while the computer playback is player
			return;
		}		

		// Check player input
		if(FlxG.keys.enabled){
			if(FlxG.keys.anyJustPressed([UP,W])) {
				G_Buttonlit.alpha = 1.0;

				gs.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Green);
			}
			if(FlxG.keys.anyJustPressed([DOWN,S])) {
				P_Buttonlit.alpha = 1.0;

				ps.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Purple);
			}
			if(FlxG.keys.anyJustPressed([LEFT,A])) {
				Y_Buttonlit.alpha = 1.0;

				ys.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Yellow);
			}
			if(FlxG.keys.anyJustPressed([RIGHT,D])) {
				R_Buttonlit.alpha = 1.0;

				rs.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Red);
			}
		}
		
		if(FlxG.mouse.overlaps(G_Button)){
			if(FlxG.mouse.justPressed){
				G_Buttonlit.alpha = 1.0;

				gs.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Green);
			}
		}
		if(FlxG.mouse.overlaps(P_Button)){
			if(FlxG.mouse.justPressed){
				P_Buttonlit.alpha = 1.0;

				ps.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Purple);
			}
		}
		if(FlxG.mouse.overlaps(Y_Button)){
			if(FlxG.mouse.justPressed){
				Y_Buttonlit.alpha = 1.0;

				ys.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Yellow);
			}
		}
		if(FlxG.mouse.overlaps(R_Button)){
			if(FlxG.mouse.justPressed){
				R_Buttonlit.alpha = 1.0;

				rs.play(true);
				playerPattern.insert(playerPattern.length, SimonButtons.Red);
			}
		}

		// On completion of the user pattern, call gameplayObj.ComparePattern to see if it is correct
		if(playerPattern.length == currentLevel) {
			if(gameplayObj.ComparePattern(playerPattern)) {
				// Player wins level
				instructions.text = "Great work!";
				instructions.screenCenter();
				instructions.y = 430;

				currentLevel++;
			}
			else {
				lossCounter++;

				if(lossCounter < 3) {
					// Player loses level, try again
					instructions.text = "Try again!";
					instructions.screenCenter();
					instructions.y = 430;
				}
				else {
					// Player loses, reset game
					instructions.text = "Game over! Resetting...";
					instructions.screenCenter();
					instructions.y = 430;

					if(highestScore < currentLevel) {
						highestScore = currentLevel;
						highScore.text = "High Score: " + highestScore;
					}

					gameplayObj.ResetPattern();
					currentLevel = 1;
					lossCounter = 0;
				}
			}

			startLevel();
			playerPattern.resize(0);
		}
	}

	public function startLevel() {
		// Generate a pattern of the right length
		playbackPattern = gameplayObj.GeneratePattern(currentLevel);
		//gameplayObj.LogPattern();

		// Create a timer to play computer sounds
	 	playbackTimer = new haxe.Timer(600);
	 	playbackTimer.run = runTimer;

		currentScore.text = "Current Level: " + currentLevel;
	}

	public function runTimer() {
		// Turn off all button "lights"
		G_Buttonlit.alpha = 0.0;
		Y_Buttonlit.alpha = 0.0;
		R_Buttonlit.alpha = 0.0;
		P_Buttonlit.alpha = 0.0;

		instructions.text = "Listen and watch!";
		instructions.screenCenter();
		instructions.y = 430;

	 		// If we don't have any elements, stop the timer
	 		if(playbackPattern.length == 0) {
	 			instructions.text = "Your turn!";
				instructions.screenCenter();
				instructions.y = 430;

	 			playbackTimer.stop();
	 			return;
	 		}

	 		// If we do have elements, grab the next one (shift left) and "play" it
	 		var nextButton = playbackPattern.shift();
	 		switch nextButton {
	 			case SimonButtons.Green:
	 				// Light up green button
	 				G_Buttonlit.alpha = 1.0;
	 				gs.play(true);
	 			case SimonButtons.Red:
	 				// Light up red button
	 				R_Buttonlit.alpha = 1.0;
	 				rs.play(true);
	 			case SimonButtons.Yellow:
	 				// Light up yellow button
	 				Y_Buttonlit.alpha = 1.0;
	 				ys.play(true);
	 			case SimonButtons.Purple:
	 				// Light up purple button
	 				P_Buttonlit.alpha = 1.0;
	 				ps.play(true);
	 		}
	}
}
