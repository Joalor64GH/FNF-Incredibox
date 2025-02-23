package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import Character;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var angulodDeCam:Float = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var shakeCam:Bool = false;
	private var tirarVida:Bool = false;
	private var batidao:Bool = false;
	private var batidaoRoda:Bool = false;
	private var hasTriggered:Bool = false;
	private var hasTriggeredRoda:Bool = false;
	private var ehBaixo:Bool = false;
	private var v4aparecer:Bool = false;
	private var inverterControls:Bool = false;
	private var trocarDeLados:Bool = false;
	private var pretoSaindo:Bool = false;
	private var hideV8:Bool = false;
	private var OBoyTaComManto:Bool = false;
	private var piramideTaAqui:Bool = false;
	//var totalDamageTaken:Float = 0;
	//var shouldBeDead:Bool = false;
	//var interupt:Bool = false;
	var grabbed:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var fundoV8:FlxSprite;
	var povoAtrasV8:FlxSprite;
	var povoDanceV8:FlxSprite;
	var chaoV8:FlxSprite;
	var piramide:FlxSprite;

	var bagadov2:FlxSprite;
	var negociodov4:FlxSprite;
	//var bagadov2Passo:FlxSound;
	var bgFinal:FlxSprite;
	var bgAlive:FlxSprite;
	var bgBrazil:FlxSprite;
	var bgDystopia:FlxSprite;
	var bgLM:FlxSprite;
	var bgLove:FlxSprite;
	var bgflash:FlxSprite;
	var bgpreto:FlxSprite;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dadbattle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			//pq cacetas o dialogo n ta indo????

				/*case 'alpha':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('alpha/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('alpha/dialogue'));
				case 'little-miss':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('little-miss/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('little-miss/dialogue'));
				case 'sunrise':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('sunrise/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('sunrise/dialogue'));
				case 'the-love':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('the-love/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('the-love/dialogue'));
				case 'brazil':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('brazil/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('brazil/dialogue'));
				case 'alive':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('alive/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('alive/dialogue'));
				case 'jeevan':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('jeevan/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('jeevan/dialogue'));
				case 'dystopia':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('dystopia/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('dystopia/dialogue'));
				case 'synthwave-little-miss':
					if(FlxG.save.data.traduzido == true)
						dialogue = CoolUtil.coolTextFile(Paths.txt('synthwave-little-miss/dialogo'));
					if(FlxG.save.data.traduzido == false)
						dialogue = CoolUtil.coolTextFile(Paths.txt('synthwave-little-miss/dialogue'));*/
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }

				  case 'sunrise':
				{
					curStage = 'v3';

					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-365, -423);
					bg.loadGraphic(Paths.image('Incredibox/v3/v3_bg'));
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);
				}

				 case 'the-love':
				 {
					 curStage = 'v4';

					 var bg:FlxSprite = new FlxSprite(-205, -38);
					 bg.loadGraphic(Paths.image('Incredibox/v4/ceuiluminati'));
					 bg.scrollFactor.set(0.2, 0.6);
					 bg.antialiasing = true;
					 bg.active = false;
					 bg.updateHitbox();
					 add(bg);

					 var bgFundo:FlxSprite = new FlxSprite(-138, -60);
					 bgFundo.loadGraphic(Paths.image('Incredibox/v4/fundo'));
					 bgFundo.scrollFactor.set(0.5, 0.8);
					 bgFundo.antialiasing = true;
					 bgFundo.active = false;
					 bgFundo.updateHitbox();
					 add(bgFundo);

					 var bgChaoV4:FlxSprite = new FlxSprite(-304, -180);
					 bgChaoV4.loadGraphic(Paths.image('Incredibox/v4/chao'));
					 bgChaoV4.antialiasing = true;
					 bgChaoV4.active = false;
					 bgChaoV4.updateHitbox();
					 add(bgChaoV4);

					 negociodov4 = new FlxSprite(-13, -4);
					 negociodov4.loadGraphic(Paths.image('Incredibox/v4/coisanatela'));
					 negociodov4.scrollFactor.set(0, 0);
					 negociodov4.antialiasing = true;
					 negociodov4.updateHitbox();

				 }

				case 'brazil':
				{
					curStage = 'v5';
					
					var bg:FlxSprite = new FlxSprite(-158, -253);
					bg.loadGraphic(Paths.image('Incredibox/v5/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);

					var bgCasas:FlxSprite = new FlxSprite(-181, -182);
					bgCasas.loadGraphic(Paths.image('Incredibox/v5/casas'));
					bgCasas.scrollFactor.set(0.5, 0.5);
					bgCasas.antialiasing = true;
					bgCasas.active = false;
					bgCasas.updateHitbox();
					add(bgCasas);

					var bgPipas:FlxSprite = new FlxSprite(-9, -93);
					bgPipas.frames = Paths.getSparrowAtlas('Incredibox/v5/Pipas');
					bgPipas.animation.addByPrefix('idle', 'Pipas', 24);
					bgPipas.antialiasing = true;
					bgPipas.updateHitbox();
					bgPipas.animation.play('idle');
					bgPipas.scrollFactor.set(0.4, 0.4);
					add(bgPipas);

					var bgBrilho:FlxSprite = new FlxSprite(-148, -193);
					bgBrilho.loadGraphic(Paths.image('Incredibox/v5/brilho'));
					bgBrilho.scrollFactor.set(0.3, 0.3);
					bgBrilho.antialiasing = true;
					bgBrilho.active = false;
					bgBrilho.updateHitbox();
					add(bgBrilho);

					var bgChao:FlxSprite = new FlxSprite(-244, -321);
					bgChao.loadGraphic(Paths.image('Incredibox/v5/chao'));
					bgChao.antialiasing = true;
					bgChao.active = false;
					bgChao.updateHitbox();
					add(bgChao);
				}

				case 'alive':
				{
				    curStage = 'v6';

					defaultCamZoom = 1.001;

					//kk o numero do demonio
					var bg:FlxSprite = new FlxSprite(-54, -152);
					bg.loadGraphic(Paths.image('Incredibox/v6/fundo'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);
					  
					var bgLuz:FlxSprite = new FlxSprite(305, -211);
					bgLuz.frames = Paths.getSparrowAtlas('Incredibox/v6/Luzes_assets');
					bgLuz.animation.addByPrefix('idle', 'Luz 1', 24);
					bgLuz.antialiasing = true;
					bgLuz.updateHitbox();
					bgLuz.animation.play('idle');
					bgLuz.scrollFactor.set(0.5, 0.3);
					add(bgLuz);

					var bgPredios:FlxSprite = new FlxSprite(-129.15, -233.6);
					bgPredios.loadGraphic(Paths.image('Incredibox/v6/prediosLonge'));
					bgPredios.scrollFactor.set(0.5, 0.3);
					bgPredios.antialiasing = true;
					bgPredios.active = false;
					bgPredios.updateHitbox();
					add(bgPredios);

					var bgPredPerto:FlxSprite = new FlxSprite(-139.2, -324);
					bgPredPerto.loadGraphic(Paths.image('Incredibox/v6/prediosPerto'));
					bgPredPerto.scrollFactor.set(0.65, 0.6);
					bgPredPerto.antialiasing = true;
					bgPredPerto.active = false;
					bgPredPerto.updateHitbox();
					add(bgPredPerto);

					var bgChaoV6:FlxSprite = new FlxSprite(-194.75, -418);
					bgChaoV6.loadGraphic(Paths.image('Incredibox/v6/chao'));
					bgChaoV6.scrollFactor.set(0, 1);
					bgChaoV6.antialiasing = true;
					bgChaoV6.active = false;
					bgChaoV6.updateHitbox();
					add(bgChaoV6);
				  }

				  case 'jeevan':
				{
					curStage = 'v7';

					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-344, -624);
					bg.loadGraphic(Paths.image('Incredibox/v7/bg'));
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);
				}

				  case 'dystopia':
				{
					curStage = 'v8';

					fundoV8 = new FlxSprite(-154, -208);
					fundoV8.loadGraphic(Paths.image('Incredibox/v8/Fundo'));
					fundoV8.scrollFactor.set(0.6, 0.8);
					fundoV8.antialiasing = true;
					fundoV8.active = false;
					fundoV8.updateHitbox();
					add(fundoV8);

					povoAtrasV8 = new FlxSprite(-139, -243);
					povoAtrasV8.loadGraphic(Paths.image('Incredibox/v8/povoAtras'));
					povoAtrasV8.scrollFactor.set(0.7, 0.9);
					povoAtrasV8.antialiasing = true;
					povoAtrasV8.active = false;
					povoAtrasV8.updateHitbox();
					add(povoAtrasV8);

					povoDanceV8 = new FlxSprite(-200, -235);
					povoDanceV8.frames = Paths.getSparrowAtlas('Incredibox/v8/PovoDanca');
					povoDanceV8.animation.addByPrefix('idle', 'PovoDanca bg instância ', 14);
					povoDanceV8.animation.play('idle');
					povoDanceV8.antialiasing = true;
					povoDanceV8.updateHitbox();
					add(povoDanceV8);

					chaoV8 = new FlxSprite(-255, -201);
					chaoV8.loadGraphic(Paths.image('Incredibox/v8/chao'));
					chaoV8.antialiasing = true;
					chaoV8.active = false;
					chaoV8.updateHitbox();
					add(chaoV8);

					piramide = new FlxSprite(-582, -58);
					piramide.frames = Paths.getSparrowAtlas('Incredibox/v8/piramidoRotato_assets');
					piramide.animation.addByPrefix('normal', 'piramidoRotato', 42, false, false, false);
					piramide.animation.addByPrefix('lento', 'piramidoRotatoDemorado', 32, false, false, false);
					piramide.animation.addByPrefix('lolz', 'lol', 24, false);
					piramide.antialiasing = true;
					piramide.updateHitbox();
				}

				  case 'little-miss':
				{
					curStage = 'v2';

					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-123, -85);
					bg.loadGraphic(Paths.image('Incredibox/v2/ceu'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);

					var bgMontanhas:FlxSprite = new FlxSprite(-362, -179);
					bgMontanhas.loadGraphic(Paths.image('Incredibox/v2/montanha'));
					bgMontanhas.scrollFactor.set(0.2, 0.2);
					bgMontanhas.antialiasing = true;
					bgMontanhas.active = false;
					bgMontanhas.updateHitbox();
					add(bgMontanhas);

					var bgFundo2:FlxSprite = new FlxSprite(-2913, -106);
					bgFundo2.frames = Paths.getSparrowAtlas('Incredibox/v2/fundo2');
					bgFundo2.animation.addByPrefix('idle', 'bg fundo2', 28);
					bgFundo2.antialiasing = true;
					bgFundo2.updateHitbox();
					bgFundo2.animation.play('idle');
					bgFundo2.scrollFactor.set(0.4, 0.5);
					add(bgFundo2);

					var bgFundo1:FlxSprite = new FlxSprite(-3203, -124);
					bgFundo1.frames = Paths.getSparrowAtlas('Incredibox/v2/fundo1');
					bgFundo1.animation.addByPrefix('idle', 'bg fundo', 28);
					bgFundo1.antialiasing = true;
					bgFundo1.updateHitbox();
					bgFundo1.animation.play('idle');
					bgFundo1.scrollFactor.set(0.6, 0.9);
					add(bgFundo1);

					var bgChaoV2:FlxSprite = new FlxSprite(-352, -172);
					bgChaoV2.loadGraphic(Paths.image('Incredibox/v2/chao'));
					bgChaoV2.antialiasing = true;
					bgChaoV2.active = false;
					bgChaoV2.updateHitbox();
					add(bgChaoV2);

					bagadov2 = new FlxSprite(1280, 150);
					bagadov2.loadGraphic(Paths.image('Incredibox/v2/sapoxa q mata'));
					bagadov2.antialiasing = true;
					bagadov2.updateHitbox();

					//bagadov2Passo = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				}

				  case 'alpha':
				{
					curStage = 'v1';

					defaultCamZoom = 0.9;

					var bg:FlxSprite = new FlxSprite(-294, -167);
					bg.loadGraphic(Paths.image('Incredibox/v1/fundo'));
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);
				}

				  case 'synthwave-little-miss':
				{
					curStage = 'vfinal';

					defaultCamZoom = 0.9;

					bgFinal = new FlxSprite(-527, -264);
					bgFinal.loadGraphic(Paths.image('Incredibox/vFinal/fundoNormal'));
					bgFinal.antialiasing = true;
					bgFinal.active = false;
					bgFinal.updateHitbox();
					add(bgFinal);
					bgFinal.alpha = 0;

					bgAlive = new FlxSprite(-528, -359);
					bgAlive.loadGraphic(Paths.image('Incredibox/vFinal/fundoAlive'));
					bgAlive.antialiasing = true;
					bgAlive.active = false;
					bgAlive.updateHitbox();
					add(bgAlive);
					bgAlive.alpha = 0;

					bgBrazil = new FlxSprite(-535, -422);
					bgBrazil.loadGraphic(Paths.image('Incredibox/vFinal/fundoBrazil'));
					bgBrazil.antialiasing = true;
					bgBrazil.active = false;
					bgBrazil.updateHitbox();
					add(bgBrazil);
					bgBrazil.alpha = 0;

					bgDystopia = new FlxSprite(-531, -323);
					bgDystopia.loadGraphic(Paths.image('Incredibox/vFinal/fundoDystopia'));
					bgDystopia.antialiasing = true;
					bgDystopia.active = false;
					bgDystopia.updateHitbox();
					add(bgDystopia);
					bgDystopia.alpha = 0;

					bgLM = new FlxSprite(-509, -241);
					bgLM.loadGraphic(Paths.image('Incredibox/vFinal/fundoLittleMiss'));
					bgLM.antialiasing = true;
					bgLM.active = false;
					bgLM.updateHitbox();
					add(bgLM);
					bgLM.alpha = 0;

					bgLove = new FlxSprite(-528, -310);
					bgLove.loadGraphic(Paths.image('Incredibox/vFinal/fundoTheLove'));
					bgLove.antialiasing = true;
					bgLove.active = false;
					bgLove.updateHitbox();
					add(bgLove);
					bgLove.alpha = 0;

					bgflash = new FlxSprite(-31, -13);
					bgflash.loadGraphic(Paths.image('Incredibox/vFinal/flashbranco'));
					bgflash.antialiasing = true;
					bgflash.active = false;
					bgflash.updateHitbox();
					bgflash.scrollFactor.set(0, 0);
					bgflash.alpha = 0;

					bgpreto = new FlxSprite(-159, -115);
					bgpreto.loadGraphic(Paths.image('Incredibox/vFinal/telapreta'));
					bgpreto.antialiasing = true;
					bgpreto.active = false;
					bgpreto.updateHitbox();
					bgpreto.scrollFactor.set(0, 0);
					bgpreto.alpha = 0;
				}
				  case 'expurgation':
				  {
					curStage = 'auditorHell';

					defaultCamZoom = 1.0;

					var bg:FlxSprite = new FlxSprite(-294, -167);
					bg.loadGraphic(Paths.image('Incredibox/v1/fundo'));
					bg.antialiasing = true;
					bg.active = false;
					bg.updateHitbox();
					add(bg);
				  }

		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }
		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			//case 'v2':
				//gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Sunrise_polo':
				dad.x = -52;
				dad.y = 127;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Brazil_polo':
				dad.x = 77;
				dad.y = 56;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Thelove_polo':
				dad.x = 55;
				dad.y = 95;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Alive-Polo':
				dad.x = 59;
				dad.y = 131;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Jeevan-Polo':
				dad.x = 133;
				dad.y = 116;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Dystopia-Polo':
				dad.x = 7;
				dad.y = 132;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'LittleMiss-Polo':
				dad.x = -19;
				dad.y = 46;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Alpha-Polo':
				dad.x = 113;
				dad.y = 122;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'Ultra-Polo':
				dad.x = -288;
				dad.y = 35;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'exTricky':
				dad.x = 59;
				dad.y = 131;
				//dad.visible = false;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'v3':
				boyfriend.x = 837;
				boyfriend.y = 257;
				gf.x = 334;
				gf.y = -56;
			case 'v4':
				boyfriend.x = 758;
				boyfriend.y = 302;
				gf.x = 296; 
				gf.y = -38;
			case 'v5':
				boyfriend.x = 685;
				boyfriend.y = 269;
				gf.x = 283;
				gf.y = -70;
			case 'v6':
				boyfriend.x = 771;
				boyfriend.y = 288;
				gf.x = 310;
				gf.y = -42;
			case 'v7':
				boyfriend.x = 802;
				boyfriend.y = 263;
				gf.x = 279;
				gf.y = -55;
			case 'v8':
				boyfriend.x = 750;
				boyfriend.y = 296;
				gf.x = 280;
				gf.y = -39;
				gf.alpha = 0;
			case 'v2':
				boyfriend.x = 727;
				boyfriend.y = 252;
				gf.x = 224;
				gf.y = -45;
			case 'v1':
				boyfriend.x = 744;
				boyfriend.y = 295;
				gf.x = 264;
				gf.y = -56;
			case 'vfinal':
				boyfriend.x = 816;
				boyfriend.y = 378;
				gf.x = 268;
				gf.y = -13;
				boyfriend.alpha = 0;
				gf.alpha = 0;
				dad.alpha = 0;
			case 'auditorHell':
				boyfriend.x = 771;
				boyfriend.y = 288;
				gf.x = 310;
				gf.y = -42;
				gf.alpha = 0;
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (curStage == 'vfinal')
			add(bgpreto);
			add(bgflash);

		add(dad);
		add(boyfriend);

		add(bagadov2);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		if(curSong == 'The-Love')
		{
		add(negociodov4);
		negociodov4.alpha = 0;
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		if(curSong == 'The-Love')
		{
		negociodov4.cameras = [camHUD];
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				/*case 'alpha':
					schoolIntro(doof);
				case 'little-miss':
					schoolIntro(doof);
				case 'sunrise':
					schoolIntro(doof);
				case 'the-love':
					schoolIntro(doof);
				case 'brazil':
					schoolIntro(doof);
				case 'alive':
					schoolIntro(doof);
				case 'jeevan':
					schoolIntro(doof);
				case 'dystopia':
					schoolIntro(doof);
				case 'synthwave-little-miss':
					schoolIntro(doof);*/
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function doStopSign(sign:Int = 0, fuck:Bool = false)
	{
		trace('sign ' + sign);
		var daSign:FlxSprite = new FlxSprite(0,0);
		// CachedFrames.cachedInstance.get('sign')

		daSign.frames = Paths.getSparrowAtlas('Incredibox/exp/Sign_Post_Mechanic');

		daSign.setGraphicSize(Std.int(daSign.width * 0.67));

		daSign.cameras = [camHUD];

		switch(sign)
		{
			case 0:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 1',24, false);
				daSign.x = FlxG.width - 650;
				daSign.angle = -90;
				daSign.y = -300;
			case 1:
				/*daSign.animation.addByPrefix('sign','Signature Stop Sign 2',20, false);
				daSign.x = FlxG.width - 670;
				daSign.angle = -90;*/ // this one just doesn't work???
			case 2:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 3',24, false);
				daSign.x = FlxG.width - 780;
				daSign.angle = -90;
				if (FlxG.save.data.downscroll)
					daSign.y = -395;
				else
					daSign.y = -980;
			case 3:
				daSign.animation.addByPrefix('sign','Signature Stop Sign 4',24, false);
				daSign.x = FlxG.width - 1070;
				daSign.angle = -90;
				daSign.y = -145;
		}
		add(daSign);
		daSign.flipX = fuck;
		daSign.animation.play('sign');
		daSign.animation.finishCallback = function(pog:String)
			{
				trace('ended sign');
				remove(daSign);
			}
	}

	var totalDamageTaken:Float = 0;

	var shouldBeDead:Bool = false;

	var interupt = false;

	function doGremlin(hpToTake:Int, duration:Int,persist:Bool = false)
	{
		interupt = false;

		grabbed = true;
		
		totalDamageTaken = 0;

		var gramlan:FlxSprite = new FlxSprite(0,0);

		gramlan.frames = Paths.getSparrowAtlas('Incredibox/exp/hp/HP GREMLIN');

		gramlan.setGraphicSize(Std.int(gramlan.width * 0.76));

		gramlan.cameras = [camHUD];

		gramlan.x = iconP1.x;
		gramlan.y = healthBarBG.y - 325;

		gramlan.animation.addByIndices('come','HP Gremlin ANIMATION',[0,1], "", 24, false);
		gramlan.animation.addByIndices('grab','HP Gremlin ANIMATION',[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24], "", 24, false);
		gramlan.animation.addByIndices('hold','HP Gremlin ANIMATION',[25,26,27,28],"",24);
		gramlan.animation.addByIndices('release','HP Gremlin ANIMATION',[29,30,31,32,33],"",24,false);

		gramlan.antialiasing = true;

		add(gramlan);

		//if(FlxG.save.data.downscroll){
			//gramlan.flipY = true;
			//gramlan.y -= 150;
		//}
		
		// over use of flxtween :)

		var startHealth = health;
		var toHealth = (hpToTake / 100) * startHealth; // simple math, convert it to a percentage then get the percentage of the health

		var perct = toHealth / 2 * 100;

		trace('start: $startHealth\nto: $toHealth\nwhich is prect: $perct');

		var onc:Bool = false;

		//FlxG.sound.play(Paths.sound('fourth/GremlinWoosh','clown'));

		gramlan.animation.play('come');
		new FlxTimer().start(0.14, function(tmr:FlxTimer) {
			gramlan.animation.play('grab');
			FlxTween.tween(gramlan,{x: iconP1.x - 140},1,{ease: FlxEase.elasticIn, onComplete: function(tween:FlxTween) {
				trace('I got em');
				gramlan.animation.play('hold');
				FlxTween.tween(gramlan,{
					x: (healthBar.x + 
					(healthBar.width * (FlxMath.remapToRange(perct, 0, 100, 100, 0) * 0.01) 
					- 26)) - 75}, duration,
				{
					onUpdate: function(tween:FlxTween) { 
						// lerp the health so it looks pog
						if (interupt && !onc && !persist)
						{
							onc = true;
							trace('oh shit');
							gramlan.animation.play('release');
							gramlan.animation.finishCallback = function(pog:String) { gramlan.alpha = 0;}
						}
						else if (!interupt || persist)
						{
							var pp = FlxMath.lerp(startHealth,toHealth, tween.percent);
							if (pp <= 0)
								pp = 0.1;
							health = pp;
						}

						if (shouldBeDead)
							health = 0;
					},
					onComplete: function(tween:FlxTween)
					{
						if (interupt && !persist)
						{
							remove(gramlan);
							grabbed = false;
						}
						else
						{
							trace('oh shit');
							gramlan.animation.play('release');
							if (persist && totalDamageTaken >= 0.7)
								health -= totalDamageTaken; // just a simple if you take a lot of damage wtih this, you'll loose probably.
							gramlan.animation.finishCallback = function(pog:String) { remove(gramlan);}
							grabbed = false;
						}
					}
				});
			}});
		});
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		
		if (SONG.song.toLowerCase() == 'expurgation') // start the grem time
		{
			new FlxTimer().start(25, function(tmr:FlxTimer) {
				if (curStep < 2400)
				{
					if (canPause && !paused && health >= 1.5 && !grabbed)
						doGremlin(40,3);
					trace('checka ' + health);
					tmr.reset(25);
				}
			});
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		if(shakeCam)
		{
			FlxG.camera.shake(0.02, 0.02);
		}
		if(tirarVida)
		{
			if(storyDifficulty == 1)
			{
			health -= 0.002;
			}

			if(storyDifficulty == 2)
			{
			health -= 0.0035;
			}
		}
		if(batidao)
		{
			if(curSong == 'Sunrise')
			{
				if (curStep % 4 == 0)
				{
					if(!hasTriggered)
					{
						FlxG.camera.zoom = 1.15;
						hasTriggered = true;
					}
				}else hasTriggered = false;
			}
			if(curSong == 'Brazil')
			{
				FlxG.camera.angle = angulodDeCam;
				if(angulodDeCam > 0)
				{
					angulodDeCam -= angulodDeCam / 2;
				}
				if(angulodDeCam < 0)
				{
					angulodDeCam += angulodDeCam / 2;
				}
				if (curStep % 4 == 0)
				{
					if(!hasTriggered)
					{
						FlxG.camera.zoom = 1.3;
						hasTriggered = true;
					}
				}else hasTriggered = false;

				if(batidaoRoda)
				{
					if (curStep % 4 == 0)
					{
						if(!hasTriggeredRoda)
						{
							ehBaixo != ehBaixo;
							if(ehBaixo == false)
							{
								angulodDeCam = 6;
							}
							if(ehBaixo == true)
							{
								angulodDeCam = -6;
							}
							hasTriggeredRoda = true;
						}
					}else hasTriggeredRoda = false;
				}
			}
			if(curSong == 'Expurgation')
			{
				if (curBeat % 2 == 0)
				{
					if(!hasTriggered)
					{
						FlxG.camera.zoom = 1.6;
						hasTriggered = true;
					}
				}else hasTriggered = false;
			}
		}
		if(curSong == 'The-Love')
		{
			if(v4aparecer)
			{	
				if(negociodov4.alpha <= 0.95)
				{
				negociodov4.alpha += 0.0035;
				}
			}else{
				negociodov4.alpha -= 0.0035;
			}
		}
		if(curSong == 'Alive')
		{
			if(trocarDeLados == false)
			{
				boyfriend.x = 771;
				boyfriend.flipX = false;
				dad.x = 64;
				dad.flipX = false;
			}else{
				boyfriend.x = 114;
				boyfriend.flipX = true;
				dad.x = 711;
				dad.flipX = true;
			}
		}
		
		if(curSong == 'Dystopia')
		{
			if(hideV8)
			{
					if(OBoyTaComManto == false)
					{
					remove(boyfriend);
					boyfriend = new Boyfriend(750, 296, 'bf-Com-Manto');
					add(boyfriend);
					OBoyTaComManto = true;
					}
				defaultCamZoom = 1.4;
				//camFollow.setPosition(boyfriend.getMidpoint().x + 150, boyfriend.getMidpoint().y - 100);
				camHUD.alpha -= 0.003;
				dad.alpha = 0.2;
				fundoV8.alpha = 0;
				povoAtrasV8.alpha = 0;
				povoDanceV8.alpha = 0;
				chaoV8.alpha = 0.2;
			}else{
					if(OBoyTaComManto == true)
					{
					remove(boyfriend);
					boyfriend = new Boyfriend(750, 296, 'bf');
					add(boyfriend);
					OBoyTaComManto = false;
					}
				defaultCamZoom = 1;
				camHUD.alpha += 0.0033;
				dad.alpha = 1;
				fundoV8.alpha = 1;
				povoAtrasV8.alpha = 1;
				povoDanceV8.alpha = 1;
				chaoV8.alpha = 1;
			}
		}

		if(curSong == 'Synthwave-Little-Miss')
		{
			if(pretoSaindo)
			{
				bgpreto.alpha -= 0.005;
			}
		}
		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		if(FlxG.save.data.traduzido)
		{
		scoreTxt.text = "Pontuação:" + songScore;
		}else{
		scoreTxt.text = "Score:" + songScore;
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (curSong == 'Little-Miss')
		{
			bagadov2.x += 100;
			if(FlxG.keys.justPressed.SPACE && boyfriend.animation.curAnim.name != 'dodge')
			{
				boyfriend.playAnim('dodge', true);
			}
			if(boyfriend.animation.curAnim.name == 'dodge' && boyfriend.animation.finished)
			{
				boyfriend.playAnim('idle');
			}
			if(FlxG.overlap(bagadov2, boyfriend) && boyfriend.animation.curAnim.name != 'dodge' && storyDifficulty != 0)
			{
				health = 0;
			}
			if(FlxG.overlap(bagadov2, boyfriend) && boyfriend.animation.curAnim.name != 'dodge' && storyDifficulty == 0)
			{
				health = 0.01;
			}
		}

		if(curSong == 'Dystopia')
		{
			if(FlxG.keys.pressed.SPACE)
			{
				hideV8 = true;
			}else{
				hideV8 = false;
			}
			if(piramideTaAqui)
			{
				if(piramide.animation.curAnim.name == 'normal' && hideV8 == false)
				{
					health -= 0.02;
				}
				if(piramide.animation.curAnim.name == 'normal' && piramide.animation.finished)
				{
					remove(piramide);
					piramideTaAqui = false;
				}
				if(piramide.animation.curAnim.name == 'lento' && hideV8 == false)
				{
					health -= 0.02;
				}
				if(piramide.animation.curAnim.name == 'lento' && piramide.animation.finished)
				{
					remove(piramide);
					piramideTaAqui = false;
				}
			}
		}

		if(curSong == 'Synthwave-Little-Miss')
		{
			bgflash.alpha -= 0.05;
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (!(curBeat >= 531 && curBeat <= 536  && curSong.toLowerCase() == "expurgation")){
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
						}
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						vocals.volume = 0;
					}			

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if(FlxG.keys.justPressed.L)
		{
			health = 1;
		}
		#end

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up;
		var right;
		var down;
		var left;

		var upP;
		var rightP;
		var downP;
		var leftP;

		var upR;
		var rightR;
		var downR;
		var leftR;
		if(inverterControls == false)
		{
		// HOLDING
		up = controls.UP;
		right = controls.RIGHT;
		down = controls.DOWN;
		left = controls.LEFT;

		upP = controls.UP_P;
		rightP = controls.RIGHT_P;
		downP = controls.DOWN_P;
		leftP = controls.LEFT_P;

		upR = controls.UP_R;
		rightR = controls.RIGHT_R;
		downR = controls.DOWN_R;
		leftR = controls.LEFT_R;
		}else{
		up = controls.UP;
		right = controls.LEFT;
		down = controls.DOWN;
		left = controls.RIGHT;

		upP = controls.UP_P;
		rightP = controls.LEFT_P;
		downP = controls.DOWN_P;
		leftP = controls.RIGHT_P;

		upR = controls.UP_R;
		rightR = controls.LEFT_R;
		downR = controls.DOWN_R;
		leftR = controls.RIGHT_R;
		}

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') || boyfriend.animation.curAnim.name.endsWith('dodge'))
			{
				boyfriend.playAnim('idle');
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.01;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP;
		var rightP;
		var downP;
		var leftP;
		if(inverterControls == false)
		{
		upP = controls.UP_P;
		rightP = controls.RIGHT_P;
		downP = controls.DOWN_P;
		leftP = controls.LEFT_P;
		}else{
		upP = controls.UP_P;
		rightP = controls.LEFT_P;
		downP = controls.DOWN_P;
		leftP = controls.RIGHT_P;
		}

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var stepOfLast = 0;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		
		if (curStage == 'auditorHell' && curStep != stepOfLast)
		{
			switch(curStep)
			{
				case 322:
					doStopSign(0);
				case 384:
					doStopSign(0);
				case 511:
					doStopSign(2);
					doStopSign(0);
				case 610:
					doStopSign(3);
				case 720:
					doStopSign(2);
				case 991:
					doStopSign(3);
				case 1184:
					doStopSign(2);
				case 1218:
					doStopSign(0);
				case 1235:
					doStopSign(0, true);
				case 1200:
					doStopSign(3);
				case 1328:
					doStopSign(0, true);
					doStopSign(2);
				case 1439:
					doStopSign(3, true);
				case 1567:
					doStopSign(0);
				case 1584:
					doStopSign(0, true);
				case 1600:
					doStopSign(2);
				case 1706:
					doStopSign(3);
				case 1917:
					doStopSign(0);
				case 1923:
					doStopSign(0, true);
				case 1927:
					doStopSign(0);
				case 1932:
					doStopSign(0, true);
				case 2032:
					doStopSign(2);
					doStopSign(0);
				case 2036:
					doStopSign(0, true);
				case 2162:
					doStopSign(2);
					doStopSign(3);
				case 2193:
					doStopSign(0);
				case 2202:
					doStopSign(0,true);
				case 2239:
					doStopSign(2,true);
				case 2258:
					doStopSign(0, true);
				case 2304:
					doStopSign(0, true);
					doStopSign(0);	
				case 2326:
					doStopSign(0, true);
				case 2336:
					doStopSign(3);
				case 2447:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);	
				case 2480:
					doStopSign(0, true);
					doStopSign(0);	
				case 2512:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
				case 2544:
					doStopSign(0, true);
					doStopSign(0);	
				case 2575:
					doStopSign(2);
					doStopSign(0, true);
					doStopSign(0);
				case 2608:
					doStopSign(0, true);
					doStopSign(0);	
				case 2604:
					doStopSign(0, true);
				case 2655:
					doGremlin(20,13,true);
			}
			stepOfLast = curStep;
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();
		if(curSong == 'Alpha')
		{
			switch (curBeat)
			{
				case 64:
				defaultCamZoom = 1.5;

				case 80:
				defaultCamZoom = 0.9;

				case 144:
				defaultCamZoom = 1.5;

				case 160:
				defaultCamZoom = 0.9;
			}
		}
		if (curSong == 'Little-Miss')
		{
				if(curBeat == 52)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 53)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 54)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 55)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 68)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 69)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 70)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 71)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 93)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 94)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 95)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 96)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 125)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 126)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 127)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 128)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 140)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 141)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 142)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 143)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 157)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 158)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 159)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 160)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 164)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 165)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 166)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 167)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 172)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 173)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 174)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 175)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 189)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 190)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 191)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 192)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 196)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 197)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 198)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 199)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 204)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 205)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 206)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 207)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 225)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 226)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 227)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 228)
				{
				bagadov2.x = -430;
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 229)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 230)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 231)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 233)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 234)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 235)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 236)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 257)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 258)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 259)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 260)
				{
				bagadov2.x = -430;
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 261)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 262)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 263)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 265)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 266)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 267)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 268)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 285)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 286)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 287)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 288)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 292)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 293)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 294)
				{
				FlxG.sound.play(Paths.sound('bagadov2Passo'));
				}
				if(curBeat == 295)
				{
				bagadov2.x = -430;
				}

				if(curBeat == 296)
				{
					defaultCamZoom = 1.2;
				}
		}

		if(curSong == 'Sunrise')
		{
			if(curBeat == 64)
			{
				batidao = true;
			}

			if(curBeat == 188)
			{
				batidao = false;
			}

			if(curBeat == 192)
			{
				defaultCamZoom = 1.2;
			}

			if(curBeat == 220)
			{
				defaultCamZoom = 0.9;
			}

			if(curBeat == 224)
			{
				batidao = true;
			}

			if(curBeat == 320)
			{
				batidao = false;
			}
		}

		if(curSong == 'The-Love')
		{
			if(curBeat == 84)
			{
				v4aparecer = true;
			}

			if(curBeat == 124)
			{
				v4aparecer = false;
			}
			
			if(curBeat == 173)
			{
				v4aparecer = true;
			}
			if(curBeat == 284)
			{
				v4aparecer = false;
			}
		}

		if(curSong == 'Brazil')
		{
			if(curBeat == 32)
			{
				batidao = true;
				batidaoRoda = true;
			}
			if(curBeat == 64)
			{
				batidaoRoda = false;
			}
			if(curBeat == 128)
			{
				batidaoRoda = true;
			}
			if(curBeat == 160)
			{
				batidao = false;
				batidaoRoda = false;
			}
			if(curBeat == 192)
			{
				batidao = true;
			}
			if(curBeat == 272)
			{
				batidaoRoda = true;
			}
			if(curBeat == 320)
			{
				batidaoRoda = false;
			}
			if(curBeat == 336)
			{
				batidao = false;
			}
		}

		if(curSong == 'Alive')
		{
			if(curBeat == 244)
			{
				defaultCamZoom = 1.3;
				dad.playAnim('butao');
			}
			if(curBeat == 255)
			{
				dad.playAnim('butaoAperta');
			}
			if(storyDifficulty == 1 || storyDifficulty == 2)
			{
				if(curBeat == 256)
				{
					inverterControls = true;
					trocarDeLados = true;
				}
			}
			if(storyDifficulty == 0)
			{
				if(curBeat == 256)
				{
					trocarDeLados = true;
				}
			}
			if(curBeat == 352)
			{
				inverterControls = false;
				trocarDeLados = false;
				defaultCamZoom = 1;
			}
		}

		if (curSong == 'Dystopia')
		{
			if(curBeat == 84)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 116)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 172)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}

			if(curBeat == 194)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 224)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 253)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}

			if(curBeat == 288)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 312)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}

			if(curBeat == 343)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}

			if(curBeat == 373)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}

			if(curBeat == 384)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 408)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('normal');
			}

			if(curBeat == 432)
			{
				add(piramide);
				piramideTaAqui = true;
				piramide.animation.play('lento');
			}
		}

		if (curSong == 'Synthwave-Little-Miss')
		{
				if(curBeat == 13)
				{
				defaultCamZoom = 1.3;
				}

				if (curBeat == 15)
				{
				gf.alpha = 100;
				boyfriend.alpha = 100;
				dad.alpha = 100;
				bgFinal.alpha = 100;
				}

				if(curBeat == 16)
				{
				defaultCamZoom = 0.95;
				}

				if(curBeat == 64)
				{
				defaultCamZoom = 1.1;
				}

				if(curBeat == 80)
				{
				defaultCamZoom = 0.9;
				}

				if(curBeat == 96)
				{
				defaultCamZoom = 1.4;
				gf.alpha = 0;
				bgFinal.alpha = 0;
				shakeCam = true;
				}

				if(curBeat == 124)
				{
				shakeCam = false;
				defaultCamZoom = 0.9;
				bgAlive.alpha = 100;
				}

				if(curBeat == 132)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 136)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 140)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 144)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 148)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 152)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 156)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 160)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 164)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 168)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 172)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 176)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 180)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 184)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 188)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 192)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 224)
				{
				//defaultCamZoom = 1.2;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 228)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 232)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 236)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 240)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 244)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 248)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 252)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 256)
				{
				defaultCamZoom = 1.4;
				bgDystopia.alpha = 0;
				shakeCam = true;
				}

				if(curBeat == 284)
				{
				defaultCamZoom = 0.9;
				bgBrazil.alpha = 100;
				shakeCam = false;
				}

				if(curBeat == 288)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				shakeCam = true;
				tirarVida = true;
				}

				if(curBeat == 290)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 292)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 294)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 296)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 298)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 300)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 302)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 304)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 306)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 308)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 310)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 312)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLove.alpha = 0;
				bgAlive.alpha = 100;
				}

				if(curBeat == 314)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgAlive.alpha = 0;
				bgLM.alpha = 100;
				}

				if(curBeat == 316)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgLM.alpha = 0;
				bgBrazil.alpha = 100;
				}

				if(curBeat == 318)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgBrazil.alpha = 0;
				bgDystopia.alpha = 100;
				}

				if(curBeat == 318)
				{
				FlxG.camera.zoom = 1.4;
				bgflash.alpha = 1;
				bgDystopia.alpha = 0;
				bgLove.alpha = 100;
				}

				if(curBeat == 320)
				{
				FlxG.camera.zoom = 1.4;
				defaultCamZoom = 1.4;
				tirarVida = false;
				bgLove.alpha = 0;
				}

				if(curBeat == 325)
				{
					remove(dad);
					dad = new Character(255, 370, 'Final-Polo');
					add(dad);
					bgpreto.alpha = 1;
					gf.alpha = 1;
					bgFinal.alpha = 1;
				}

				if(curBeat == 336)
				{
					//FlxG.camera.zoom = 1.9;
					defaultCamZoom = 0.9;
					//gf.alpha = 100;
					//bgFinal.alpha = 100;
					shakeCam = false;
					pretoSaindo = true;
				}
		}

		if(curSong == 'Expurgation')
		{
			if(curBeat == 600)
			{
				batidao = true;
			}
			if(curBeat == 660)
			{
				batidao = false;
			}
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		
		//if (curStage == 'auditorHell')
		//{
			//if (curBeat % 8 == 4 && beatOfFuck != curBeat)
			//{
				//beatOfFuck = curBeat;
				//doClone(FlxG.random.int(0,1));
			//}
		//}

		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.startsWith("dodge"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat == 531 && curSong.toLowerCase() == "expurgation")
		{
			dad.playAnim('Hank', true);
		}

		if (curBeat == 532 && curSong.toLowerCase() == "expurgation" && dad.animation.curAnim.name != 'Hank')
		{
			dad.playAnim('Hank', true);
		}

		if (curBeat == 536 && curSong.toLowerCase() == "expurgation")
		{
			dad.playAnim('idle', true);
			trace('OH SHIT!!!');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					//curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					//phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	//var curLight:Int = 0;
	}
}
