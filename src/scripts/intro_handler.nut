/*
	File: scripts/intro_handler.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/title_handler.nut")
Include("scripts/subtitles_handler.nut")

//	title_credits		:	----------
//	title_document		:	                    ----------
//	title_main			:             ---------------
//	black_screen		:	----------

g_subs			<-	[	" ",
						"In March 18th of Earth Time",
						"in the Erycian Plain of the planet Venus", 
						"a crystal prospector was reported lost" + "\n" + "in a walled labyrinth.",
						"  ",
						"This is the last video-feed", 
						"he was able to broadcast to the command center."
					]

g_intro_fades	<-	[	{cam_key	= "logo_render_camera",			fade_in = 0.0,	fade_out = 3.5		},
						{cam_key	= "intro_render_camera",		fade_in = 3.5,	fade_out = 25.0 + 2.0		},
						{script_key	= "mandarine_logo_handler",		fade_in = 0.0,	fade_out = 3.5		},
						{script_key	= "ambient_fix_handler",		fade_in = 3.5,	fade_out = 4.0		},

						{script_key	= "voice_over_hander",			fade_in = 16.0,	fade_out = 30.0		},

						{group_key	= "logo_group",					fade_in = 0.0,	fade_out = 3.5		},
						{group_key	= "planet_group",				fade_in = 3.5,	fade_out = 25.0 + 2.0		},

						{sfx_key	= "sfx/intro_buzzing_sound_long.ogg", volume = 0.25, fade_in = 3.0, fade_out = 28.0	},

						{global_fade_key	= null,					fade_in = 29.0, fade_out = 30.0	},

						{spr_key	= "black_screen",				fade_in = 2.0, fade_out = 8.0 + 1.0		},
						{spr_key	= "title_credits",				fade_in = 3.5,	fade_out = 5.0 + 3.0		},
						{spr_key	= "title_document",				fade_in = 8.0 + 2.0,	fade_out = 13.0 + 1.0		},
						{spr_key	= "title_main",					fade_in = 8.0,	fade_out = 12.0 + 2.0		},

						{item_key	= "title_main",					fade_in = -1.0, fade_out = 15.0		},

						{eos		= null,							fade_in = -1.0, fade_out = 30.0		}	//	End of sequence
				]

class	AmbientFix
{
	scene			=	0

	constructor(_scene)
	{	scene = _scene	}

	function	SetNormalizedClock(_c)
	{
		SceneSetAmbientColor(scene, Vector(73.0, 79.0, 105.0).Scale(1.0 / 255.0).Scale(_c))
		SceneSetAmbientIntensity(scene, 0.75 * _c)
	}
}

/*!
	@short	IntroHandler
	@author	Polymorf-Astrofra-Alkama
*/
class	IntroHandler
{
	scene					=	0
	intro_render_camera		=	0
	logo_render_camera		=	0
	intro_blur_screen		=	0

	logo_render_camera		=	0

	fade_duration			=	Sec(1.0)
	clock_start				=	Sec(1.0)
	clock_end				=	Sec(25.0 + 10.0) 

	normalized_clock		=	0
	init_clock_value		=	0

	title_handler			=	0
	mandarine_logo_handler	=	0
	voice_over_hander		=	0
	ambient_fix_handler		=	0

	current_group			=	""
	planet_group			=	0
	logo_group				=	0

	sfx_table				=	0

	/*
		Normalize the clock, from a custom range
		to a [0.0, 1.0] range.
	*/
	function	NormalizeClock()
	{
		//	Get the "local" clock (starting from 0)
		normalized_clock = g_clock - init_clock_value

		//	Convert it to seconds
		normalized_clock = TickToSec(normalized_clock)

		//	Ajust the clock to the local "user range"
		normalized_clock = RangeAdjust(normalized_clock, clock_start, clock_end, 0.0, 1.0)
		normalized_clock = Clamp(normalized_clock, 0.0, 1.0)
	}

	function	IsDone()
	{
		return (normalized_clock == 1.0?true:false)
	}

	/*
		@short	constructor
	*/
	constructor(_scene)
	{		
		scene = _scene
		print("IntroHandler::constructor(" + _scene + ")")

		title_handler = TitleHandler(scene)
		ambient_fix_handler = AmbientFix(_scene)
		sfx_table = {}
	}

	/*
		@short	Load
	*/
	function	Load(_path, type = "intro")
	{
		local	tmp_group = SceneLoadAndStoreGroup(scene, _path, ImportFlagAll & ~ImportFlagGlobals)
		GroupRenderSetup(tmp_group, g_factory)
		GroupSetup(tmp_group)

		print("IntroHandler::loaded '" + type + "'.")

		switch(type)
		{
			case "intro":
				planet_group = tmp_group
				break
			case "logo":
				logo_group = tmp_group
				break
		}
	}

	/*
		@short	Setup
	*/
	function	Setup()
	{
		local	_list = GroupGetItemList(planet_group)
		if (logo_group != 0)
		{
			_list.extend(GroupGetItemList(logo_group))
			mandarine_logo_handler = ItemGetScriptInstance(GroupFindItem(logo_group, "mandarine_logo_handler"))
		}

		voice_over_hander = VoiceOverHandler(scene)

		//	Get some item handles
		logo_render_camera = ItemCastToCamera(SceneFindItem(scene, "logo_render_camera"))
		intro_render_camera = ItemCastToCamera(SceneFindItem(scene, "intro_render_camera"))
		intro_blur_screen = SceneFindItem(scene, "intro_blur_screen")

		title_handler.Setup()

		//	Normalize fade timings
		local	_max_time = 0.0
		foreach(_fade in g_intro_fades)
			if (Max(_fade.fade_in, _fade.fade_out + fade_duration) > _max_time)
				_max_time = Max(_fade.fade_in, _fade.fade_out + fade_duration)

		print("IntroHandler::Setup() _max_time = " + _max_time)

		if (_max_time > 0.0)
		{
			foreach(_fade in g_intro_fades)
			{
				_fade.fade_in /= _max_time
				_fade.fade_out /= _max_time
			}

			fade_duration /= _max_time
		}

		print("IntroHandler::Setup() fade_duration = " + fade_duration)

		//	returns the list of this scene's items for the main demo manager		
		return	_list
	}

	/*
		@short	Update
	*/
	function	Update()
	{
		NormalizeClock()

		foreach(_fade in g_intro_fades)
		{
			if ("sfx_key" in _fade)
			{
				if (!(SHA1(_fade.sfx_key) in sfx_table))
				{
					local	_chan = MixerStartStream(g_mixer, _fade.sfx_key)
					MixerChannelSetLoopMode(g_mixer, _chan, LoopRepeat)
					MixerChannelSetGain(g_mixer, _chan, 0.0)
					sfx_table.rawset(SHA1(_fade.sfx_key), _chan)
				}

				local	_chan = sfx_table[SHA1(_fade.sfx_key)],
						_sfx_fade_duration_in = fade_duration * 5.0,
						_sfx_fade_duration_out = fade_duration * 3.0,
						_vol = _fade.volume

				if (normalized_clock < _fade.fade_in)
					MixerChannelSetGain(g_mixer, _chan, 0.0)
				else
				if (normalized_clock >= _fade.fade_in && normalized_clock <= _fade.fade_in + _sfx_fade_duration_in)
					MixerChannelSetGain(g_mixer, _chan, RangeAdjust(normalized_clock, _fade.fade_in, _fade.fade_in + _sfx_fade_duration_in, 0.0, 1.0) * _vol)
				else
				if (normalized_clock >= _fade.fade_out && normalized_clock <= _fade.fade_out + _sfx_fade_duration_out)
					MixerChannelSetGain(g_mixer, _chan, RangeAdjust(normalized_clock, _fade.fade_out, _fade.fade_out + _sfx_fade_duration_out, 1.0, 0.0) * _vol)
				else
				if (normalized_clock > _fade.fade_out + _sfx_fade_duration_out)
					MixerChannelSetGain(g_mixer, _chan, 0.0)
			}
			if ("script_key" in _fade)
			{
				if (this[_fade.script_key] != 0)
				{
					local	_script_time = RangeAdjust(normalized_clock, _fade.fade_in, _fade.fade_in + fade_duration, 0.0, 1.0)
					_script_time = Clamp(_script_time, 0.0, 1.0)
					this[_fade.script_key].SetNormalizedClock(_script_time)
				}
			}
			else
			if ("group_key" in _fade)
			{
				if (normalized_clock >= _fade.fade_in && normalized_clock < _fade.fade_out)
					if (current_group != _fade.group_key)
					{
						SceneGroupActivate(scene, planet_group, false)
						SceneGroupActivate(scene, logo_group, false)
						SceneGroupActivate(scene, this[_fade.group_key], true)
						current_group = _fade.group_key
					}
			}
			else
			if ("cam_key" in _fade)
			{
				local	_current_camera_name = ItemGetName(CameraGetItem(SceneGetCurrentCamera(scene)))
				if (normalized_clock >= _fade.fade_in && normalized_clock < _fade.fade_out)
					if (_current_camera_name != _fade.cam_key)
						SceneSetCurrentCamera(scene, ItemCastToCamera(SceneFindItem(scene, _fade.cam_key)))
			}
			else
			if ("spr_key" in _fade)
			{
				if (normalized_clock < _fade.fade_in)
					title_handler.SetTitleSpriteOpacity(_fade.spr_key, 0.0)
				else
				if (normalized_clock >= _fade.fade_in && normalized_clock <= _fade.fade_in + fade_duration)
					title_handler.SetTitleSpriteOpacity(_fade.spr_key, RangeAdjust(normalized_clock, _fade.fade_in, _fade.fade_in + fade_duration, 0.0, 1.0))
				else
				if (normalized_clock >= _fade.fade_out && normalized_clock <= _fade.fade_out + fade_duration)
					title_handler.SetTitleSpriteOpacity(_fade.spr_key, RangeAdjust(normalized_clock, _fade.fade_out, _fade.fade_out + fade_duration, 1.0, 0.0))
				else
				if (normalized_clock > _fade.fade_out + fade_duration)
					title_handler.SetTitleSpriteOpacity(_fade.spr_key, 0.0)
			}
			else
			if ("item_key" in _fade)
			{
				if (normalized_clock >= _fade.fade_in && normalized_clock <= _fade.fade_in + (fade_duration * 3.0))
					title_handler.SetTitleItemOpacity(_fade.item_key, RangeAdjust(normalized_clock, _fade.fade_in, _fade.fade_in + (fade_duration * 3.0), 0.0, 1.0))
				else
				if (normalized_clock >= _fade.fade_out && normalized_clock <= _fade.fade_out + (fade_duration * 3.0))
					title_handler.SetTitleItemOpacity(_fade.item_key, RangeAdjust(normalized_clock, _fade.fade_out, _fade.fade_out + (fade_duration * 3.0), 1.0, 0.0))
			}
			else
			if ("global_fade_key" in _fade)
			{
				local	_ui = SceneGetUI(scene),
						_ui_fade = 0.0

				if (normalized_clock >= _fade.fade_in && normalized_clock <= _fade.fade_out)
				{
					_ui_fade = RangeAdjust(normalized_clock, _fade.fade_in, _fade.fade_out, 0.0, 1.0)
					_ui_fade = Clamp(_ui_fade, 0.0, 1.0)
					_ui_fade = EaseInOutQuick(_ui_fade)
				}
				else
				if (normalized_clock > _fade.fade_out)
					_ui_fade = 1.0
				

				UISetGlobalFadeEffect(_ui, _ui_fade)
			}
		}
	}

	function	DeleteLogo()
	{
		local	_list = GroupGetItemList(logo_group)
		foreach(_item in _list)
			SceneDeleteItem(scene, _item)

		SceneFlushDeletionQueue(scene)
	}

	function	SetMainCamera()
	{		SceneSetCurrentCamera(scene, intro_render_camera)	}

	function	SetLogoCamera()
	{		SceneSetCurrentCamera(scene, logo_render_camera)	}
}
