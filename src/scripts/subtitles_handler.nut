/*
	File: scripts/subtitles_tracker.nut
	Author: Astrofra
*/

Include("scripts/ui.nut")

UILoadFont("ui/fonts/OpenSans-CondLight.ttf")

/*!
	@short	VoiceOverHander
	@author	Astrofra
*/
class	VoiceOverHandler
{

	scene				=	0
	voice_sfx			=	0
	sound_played		=	false

	normalized_clock	=	0.0
	sub_clock			=	0.0
	all_done			=	false

	sub_table			=	0

	current_sub			=	0
	current_sub_index	=	0

	ui					=	0
	subtitle_label		=	0

	constructor(_scene)
	{
		scene = _scene
		voice_sfx = ResourceFactoryLoadSound(g_factory, "sfx/intro_voice_over.ogg")
		local	voice_len = Sec(15.0) //	SoundGetDuration(voice_sfx)
		print("VoiceOverHander::constructor(" + _scene + ")")
		print("voice_len = " + voice_len)

		sub_table = []
		local	_total_len = 0

		foreach(_sub in g_subs)
		{
			sub_table.append({text = _sub, length = _sub.len(), sprite = 0, fade_in = 0.0, fade_out = 0.0})
			_total_len += _sub.len()
		}

		//	Normalize sub duration
		local	fade_in = 0.0, fade_out = 0.0
		foreach(_sub in sub_table)
		{
			local	_len = SecToTick(_sub.length * voice_len.tofloat() / (_total_len.tofloat()))

			_sub.length = _len

			fade_out += _len
			_sub.fade_out = fade_out

			_sub.fade_in = fade_in
			fade_in += _len
		}

		CreateSubtitleLabel()
	}

	function	SetNormalizedClock(_c)
	{
		normalized_clock = _c
		Update()
	}

	function	Update()
	{
		if (!sound_played && normalized_clock > 0.0001)
		{
			local	_chan = MixerPlaySound(g_mixer, voice_sfx)
			MixerChannelSetGain(g_mixer, _chan, 1.0)
			MixerChannelSetLoopMode(g_mixer, _chan, LoopNone)
			sub_clock = g_clock
			GetNextSub()
			sound_played = true
		}

		if (sound_played)
			UpdateSubtitles()
	}

	function	UpdateSubtitles()
	{
		local	_clock = g_clock - sub_clock
		if (all_done)
			return

		if (_clock > current_sub.fade_out)
			GetNextSub()
	}

	function	GetNextSub()
	{
		print("VoiceOverHandler::GetNextSub()")
		if (current_sub_index < sub_table.len())
		{
			current_sub = sub_table[current_sub_index]
			DisplaySub(current_sub.text)

			current_sub_index++
		}
		else
		{
			subtitle_label.label = ""
			subtitle_label.refresh()
			all_done = true
		}
	}

	function	CreateSubtitleLabel()
	{
		ui = SceneGetUI(scene)
		subtitle_label = Label(ui, 1280, 256, 1280 * 0.5, 960 - (256 * 0.75), true, true)
		subtitle_label.label_color = 0xffff00ff
		subtitle_label.font = "OpenSans-CondLight"
		subtitle_label.font_size = 80
		subtitle_label.drop_shadow = true
		subtitle_label.font_tracking = -1.0
		subtitle_label.font_leading = -1.0
		subtitle_label.label = ""
		subtitle_label.refresh()
	}

	function	DisplaySub(str)
	{
		print("VoiceOverHandler::DisplaySub(" + str + ")")
		subtitle_label.label = str
		subtitle_label.refresh()
	}

}
