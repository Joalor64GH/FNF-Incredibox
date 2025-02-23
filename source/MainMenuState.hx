package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	//private var tex = 'FNF_main_menu_assets';
	private var menuItem:FlxSprite;
	private var menuItemBr:FlxSprite;
	private var souLegal:FlxText;
	private var fnfBy:FlxText;
	private var sofarsogood:FlxText;
	private var modBy:FlxText;
	private var pressP:FlxText;
	private var LingAtual:FlxText;

	var menuItems:FlxTypedGroup<FlxSprite>;
	//var menuItemsBr:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		//menuItemsBr = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		//add(menuItemsBr);

		var tex = 'FNF_main_menu_assets';
		var tex2 = 'FNF_menu_principal_assets';

		for (i in 0...optionShit.length)
		{
			menuItem = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = Paths.getSparrowAtlas(tex);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			
			//menuItemBr = new FlxSprite(0, 60 + (i * 160));
			//menuItemBr.frames = Paths.getSparrowAtlas(tex2);
			//menuItemBr.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			//menuItemBr.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			//menuItemBr.animation.play('idle');
			//menuItemBr.ID = i;
			//menuItemBr.screenCenter(X);
			//menuItems.add(menuItemBr);
			//menuItemBr.scrollFactor.set();
			//menuItemBr.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		souLegal = new FlxText(5, FlxG.height - 80, 0, "jogo tá em PT-BR :)", 12);
		souLegal.scrollFactor.set();
		souLegal.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(souLegal);

		fnfBy = new FlxText(5, FlxG.height - 66, 0, "FNF por Ninjamuffim99, PhantomArcade, etc", 12);
		fnfBy.scrollFactor.set();
		fnfBy.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfBy);

		sofarsogood = new FlxText(5, FlxG.height - 52, 0, "Incredibox por SofarSoGood", 12);
		sofarsogood.scrollFactor.set();
		sofarsogood.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sofarsogood);

		modBy = new FlxText(5, FlxG.height - 38, 0, "Mod por Luiz Phellipe (SeuPaiGordo)", 12);
		modBy.scrollFactor.set();
		modBy.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(modBy);

		pressP = new FlxText(5, 10, 0, "APERTE 'P' PARA MUDAR O IDIOMA", 12);
		pressP.scrollFactor.set();
		pressP.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(pressP);

		LingAtual = new FlxText(5, 30, 0, "Idioma Atual:", 12);
		LingAtual.scrollFactor.set();
		LingAtual.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(LingAtual);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		
		
		//menuItem.frames = Paths.getSparrowAtlas(tex);

		if(FlxG.keys.justPressed.P)
		{
			FlxG.save.data.traduzido =! FlxG.save.data.traduzido;
		}

		if(FlxG.save.data.traduzido)
		{
			souLegal.visible = true;
			fnfBy.text = 'FNF por Ninjamuffim99, PhantomArcade, etc...';
			sofarsogood.text = 'Incredibox por SofarSoGood';
			modBy.text = 'Mod por Luiz Phellipe (SeuPaiGordo)';
			pressP.text = "APERTE 'P' PARA MUDAR O IDIOMA";
			LingAtual.text = 'Idioma atual: PT-BR';
		}else{
			souLegal.visible = false;
			fnfBy.text = 'FNF by Ninjamuffim99, PhantomArcade, etc...';
			sofarsogood.text = 'Incredibox by SofarSoGood';
			modBy.text = 'Mod by Luiz Phellipe (SeuPaiGordo)';
			pressP.text = "PRESS 'P' TO CHANGE LANGUAGE";
			LingAtual.text = 'Current Language: EN-US';
		}

		if(FlxG.keys.justPressed.B)
		{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://www.youtube.com/watch?v=BEjCeMrdlAU", "&"]);
					#else
					FlxG.openURL('https://www.youtube.com/watch?v=BEjCeMrdlAU');
					#end
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										FlxG.switchState(new OptionsMenu());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
