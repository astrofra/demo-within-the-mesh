/*
	File: scripts/camera_ride.nut
	Author: Astrofra
*/

Include("scripts/synchro-track_beeps.nut")
Include("scripts/holographic_camera.nut")
Include("scripts/ui_demo.nut")
Include("scripts/music.nut")

/*!
	@short	CameraBasicRaide
	@author	Astrofra
*/
class	CameraRideHandler
{

	scene					=	0
	item					=	0
	item_table				=	0
	rotation_offset			=	0
	camera_current_pos		=	0

	item_scaphander			=	0
	scaphander_pos			=	0
	scaphander_rot			=	0

	video_screen			=	0

	clock_start				=	Sec(0.0)
	clock_end				=	Sec(104.0)

	video_fx_clock_start	=	Sec(0.5)
	video_fx_clock_end		=	Sec(6.0)

	video_fx_end_clock_start	=	Sec(104.0 - 8.0)
	video_fx_end_clock_end		=	Sec(104.0)
	
	normalized_clock		=	0
	prev_normalized_clock	=	0
	normalized_dt			=	0.0
	init_clock_value		=	0
	clock_offset			=	0.0
	target_clock_offset		=	0.0

	audio_channel_music		=	0
	signal_noise_sfx_played = false

	mouse_device			=	0
	mx						=	0
	my						=	0
	prev_mx					=	0
	prev_my					=	0

	dispatch				=	0

//	dt_history				=	0

	synchro_handler_beep	=	0

	constructor(_scene)
	{	
		scene = _scene
		item = SceneFindItem(scene, "render_camera")
		camera_current_pos = Vector(0,0,0)	
	}

	/*
		Main script setup.
	*/
	function	Setup()
	{
		print("CameraBasicRide::OnSetup()")

		scene = ItemGetScene(item)

		rotation_offset = Vector(0,0,0)
		item_scaphander = SceneFindItem(scene, "Scaphander")
		scaphander_pos = ItemGetPosition(item_scaphander)
		scaphander_rot = ItemGetRotation(item_scaphander)

		//	Mouse Input
		mouse_device = GetInputDevice("mouse")
		mx = DeviceInputValue(mouse_device, DeviceAxisX)
		my = DeviceInputValue(mouse_device, DeviceAxisY)
		prev_my = mx
		prev_my = my

//		dt_history = []

		//	Camera keyframes data
		item_table = CollectKeys()

		InterpolateKeyTables()

		camera_current_pos = item_table[0].position

		SceneSetCurrentCamera(scene, ItemCastToCamera(item))

		SceneGetScriptInstance(scene).render_user_callback.append(this)

		//	Music Synchronization data
		synchro_handler_beep = MusicSynchro("g_synchro_track_beeps")

		video_screen = SceneFindItem(scene, "video_screen")

//		dispatch = CheckDtFrameStability
	}

	/*
		Main script setup.
	*/
	function	SetupDone()
	{
		ItemSetPosition(item, GetInterpolatedPosition(0.0).position)
//		UISetCommandList(SceneGetUI(scene), "globalfade 0,1;")
	}

	/*
	*/
	function	RenderUser(scene)
	{
		return

		if (item_table.len() > 0)
		{
			local	_prev_pos = -1, _pos, _color = false
			foreach(_key in item_table)
			{
				_pos = (_key) - Vector(0,0.1,0)

				if (_prev_pos != -1)
					RendererDrawLineColored(g_render, _prev_pos, _pos, _color?Vector(1,0,0,1):Vector(1,1,1,1))

				_color = !_color
				_prev_pos = clone(_pos)
			}
		}
	}

	/*
		Interpolate 2 keys (linearly).
	*/
	function	AddSubkey(_table, _idx, _lerp_value)
	{
		local	_pos = (_table[_idx].position).Lerp(_lerp_value, (_table[_idx + 1].position))
		local	_rot = (_table[_idx].rotation).Lerp(_lerp_value, (_table[_idx + 1].rotation))
		return { position = _pos, rotation = _rot	}
	}

	/*
		Subdivides a table of keyframes,
		linearly, and then smooth them.
	*/
	function	InterpolateKeyTables()
	{
		local	sub_level = 8
		//	Subdivide the key table
		for(local n = 0; n < sub_level; n++)
		{
			local	_new_key_table = []
			foreach(_idx, _key in item_table)
			{
				_new_key_table.append(_key)

				if (_idx < (item_table.len() - 1))
					if (_key.position.Dist(item_table[_idx + 1].position) > Mtr(1.0))
						_new_key_table.append(AddSubkey(item_table, _idx, 0.5))
			}

			item_table = _new_key_table
		}

		//	Smooth the key table
		local	_blur_level = sub_level * 2
		local	_new_key_table = []
		foreach(_idx, _key in item_table)
		{
			local n, _pos_sum = Vector(), _rot_sum = Vector()
			for(n = 0; n < _blur_level; n++)
			{
				local	_i = Clamp(_idx - n + (_blur_level / 2), 0, item_table.len() - 1).tointeger()
				_pos_sum += item_table[_i].position
				_rot_sum += item_table[_i].rotation
			}

			_pos_sum = _pos_sum.Scale( 1.0 / _blur_level.tofloat())
			_rot_sum = _rot_sum.Scale( 1.0 / _blur_level.tofloat())
			_new_key_table.append({position = _pos_sum, rotation = _rot_sum})
		}

		item_table = _new_key_table

	}

	/*
		Search for a list of item named "key" in the main scene,
		and sort/order them by Z.
	*/
	function	CollectKeys()
	{
		//	Find key, store their position
		local	_tmp = []
		foreach(_item in SceneGetItemList(g_scene))
			if (ItemGetName(_item) == "key")
			{
				_tmp.append({position = ItemGetWorldPosition(_item), rotation = ItemGetRotation(_item)})
				ObjectSetGeometry(ItemCastToObject(_item), NullGeometry)
//				SceneItemActivate(g_scene, _item, false)
//				ItemSetInvisible(_item, true)
			}

		//	Sort the keys by Z order
		local	_tmp_sort = [], _min_z_idx, i, l
		l = _tmp.len()

		for(i = 0; i < l; i++)
		{
			_min_z_idx = 0
			foreach(_idx, _key in _tmp)
			{
				if (_key.position.z < _tmp[_min_z_idx].position.z)
					_min_z_idx = _idx
			}
			_tmp_sort.append(_tmp[_min_z_idx])
			_tmp.remove(_min_z_idx)
		}
		
		return _tmp_sort
	}

	/*
		Get an interpolated keyframe,
		based a time variable [0.0, 1.0]
	*/
	function	GetInterpolatedPosition(_clock)
	{
		//	Total length
		local	_pos, _rot, _laggy_rot, idx
		local	total_length = 0.0,
				segment_length

		for(idx = 0; idx < item_table.len() - 1; idx++)
		{
			segment_length = (item_table[idx].position).Dist((item_table[idx + 1].position))
			total_length += segment_length
		}

		//	Search for the correct segment
		local	segment_length_sum = 0.0
		for(idx = 0; idx < item_table.len() - 1; idx++)
		{
			segment_length = (item_table[idx].position).Dist((item_table[idx + 1].position))
			if ((_clock >= (segment_length_sum / total_length)) && (_clock < ((segment_length_sum + segment_length) / total_length)))
				break

			segment_length_sum += segment_length
		}

		local	_current_key_idx = idx

		if (idx < (item_table.len() - 1))
		{
			local	_inter_key_clock = (_clock - (segment_length_sum / total_length)) * total_length / segment_length
			_pos = (item_table[idx].position).Lerp(1.0 - _inter_key_clock, (item_table[idx + 1].position))
			_rot = (item_table[idx].rotation).Lerp(1.0 - _inter_key_clock, (item_table[idx + 1].rotation))
		}
		else
		{
			_pos = (item_table[item_table.len() - 1].position)
			_rot = (item_table[item_table.len() - 1].rotation)
		}

		return { position = _pos, rotation = _rot}
	}

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
		normalized_clock = Clamp(normalized_clock, 0.0, 1.0) + clock_offset

		normalized_dt = normalized_clock + clock_offset - prev_normalized_clock
		prev_normalized_clock = normalized_clock + clock_offset
	}

	/*
	*/
	function	Update()
	{
		if (!ItemIsActive(item))
			return

		g_normalized_clock = normalized_clock

		if (dispatch != 0)
			dispatch()
	}

	function	IsDone()
	{	
		if (normalized_clock == 1.0)
			return true

		if (camera_current_pos.Dist2(item_table.top().position) < Mtr(0.1))
			return true
	}

	function	UpdateInput()
	{
		//	Time offset
		local	mouse_wheel = DeviceInputValue(mouse_device, DeviceAxisRotY)
		if (fabs(mouse_wheel) > 0.0)
			target_clock_offset += (g_dt_frame * mouse_wheel * 0.1)

//		MixerChannelSetPitch(g_mixer, audio_channel_music, 1.0 + mouse_wheel)

		if (fabs(target_clock_offset - clock_offset) > 0.001)
		{
			local _dt = target_clock_offset - clock_offset
			clock_offset += (_dt * g_dt_frame * 10.0)
		}

		//	Camera rotation offset based on the mouse motion.
		//	(might be useful for the Oculus Rift, hint hint)
		local	max_angle = Deg(25.0)

		mx = DeviceInputValue(mouse_device, DeviceAxisX)
		my = DeviceInputValue(mouse_device, DeviceAxisY)

		if (DeviceIsKeyDown(mouse_device, KeyButton0))
		{
			local	dx,dy
			dx = Clamp(mx - prev_mx,-1.0,1.0)
			dy = Clamp(my - prev_my,-1.0,1.0)

			rotation_offset.x += dy
			rotation_offset.y += dx

			rotation_offset.x = Clamp(rotation_offset.x, -max_angle, max_angle)
			rotation_offset.y = Clamp(rotation_offset.y, -max_angle, max_angle)
			rotation_offset.z = Clamp(rotation_offset.z, -max_angle, max_angle)
		}

		if (!DeviceIsKeyDown(mouse_device, KeyButton0))
			rotation_offset = rotation_offset * Vector(0.95,0.95,0.95)

		prev_mx = mx
		prev_my = my
	}

	/*
	*/
	function	StartDemo()
	{
		print("CameraRideHandler::StartDemo()")

		audio_channel_music = MixerStartStream(g_mixer, "sfx/alkama_etrange-monde.ogg")
		MixerChannelSetGain(g_mixer, audio_channel_music, 1.0)
		MixerChannelSetPitch(g_mixer, audio_channel_music, 1.0)
		MixerChannelSetLoopMode(g_mixer, audio_channel_music, LoopNone)

		SceneItemActivate(scene, video_screen, true)

		//	Init clock!
		init_clock_value = g_clock

		dispatch = CameraUpdate
	}

	function	UpdateSignalNoiseSFX()
	{
		if (signal_noise_sfx_played)
			return

		local	noise_len = Sec(21.5)
		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)

		if (_clock > clock_end - noise_len)
		{
			local signal_noise_sfx = MixerStartStream(g_mixer, "sfx/signal_noise_in.ogg")
			MixerChannelSetGain(g_mixer, signal_noise_sfx, 1.0)
			MixerChannelSetPitch(g_mixer, signal_noise_sfx, 1.0)
			MixerChannelSetLoopMode(g_mixer, signal_noise_sfx, LoopNone)
			signal_noise_sfx_played = true
		}
	}

	function	UpdateVideoFX()
	{
		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)
		local	_fx

		if (_clock <= video_fx_clock_end)
			_fx = Clamp(RangeAdjust(_clock, video_fx_clock_start, video_fx_clock_end, 0.0, 1.0), 0.0, 1.0)
		else
		if (_clock >= video_fx_end_clock_start)
			_fx = Clamp(RangeAdjust(_clock, video_fx_end_clock_start, video_fx_end_clock_end, 1.0, 0.0), 0.0, 1.0)
		else
			_fx = 1.0

		_fx = EaseInOutQuick(_fx)
		
		if (_fx < 1.0)
		{
			ItemSetSelfIllumFloat(video_screen, _fx)
			ItemRegistrySetKey(item, "PostProcess:SSAO:Strength", _fx * 5.0)
			ItemRegistrySetKey(item, "PostProcess:ChromDisp:Width", RangeAdjust(_fx, 0.0, 1.0, 10.0, 1.0))
			SceneItemActivate(scene, video_screen, true)
		}
		else
		{
			SceneItemActivate(scene, video_screen, false)
		}
	}

	function	ChromaDispersionUpdate()
	{
		local	disp_amount	= 0.0

		//	Chroma dispersion based
		if (normalized_clock < 0.5)
		{
			local	_light_intensity = synchro_handler_beep.GetSynchroValueFromTime(normalized_clock)
			_light_intensity = Clamp(_light_intensity, 0.0, 1.0) * 3.0
			disp_amount = RangeAdjust(_light_intensity, 0.0, 1.0, 1.0, 5.0)
		}
		else
			disp_amount = 1.0

		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)
		local	_fx = 1.0
		if (_clock >= video_fx_end_clock_start * 0.915)
		{
			_fx = Clamp(RangeAdjust(_clock, video_fx_end_clock_start * 0.915, video_fx_end_clock_end, 0.0, 1.0), 0.0, 1.0)
			_fx = EaseInOutQuick(_fx) 
			_fx = _fx * 5.0 + Rand(0, _fx * 3.5) + Rand(0, _fx * 2.5)
		}

		disp_amount	= Max(disp_amount, _fx)

		ItemRegistrySetKey(item, "PostProcess:ChromDisp:Width", disp_amount)
	}

	function	VideoNoiseUpdate()
	{
		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)
		local	_fx

		if (_clock <= video_fx_clock_end * 1.15)
			_fx = Clamp(RangeAdjust(_clock, video_fx_clock_start, video_fx_clock_end * 1.15, 1.0, 0.0), 0.0, 1.0)
		else
		if (_clock >= video_fx_end_clock_start * 1.025)
			_fx = Clamp(RangeAdjust(_clock, video_fx_end_clock_start * 1.025, video_fx_end_clock_end, 0.0, 1.0), 0.0, 1.0)
		else
			_fx = 0.0

		_fx = EaseInOutQuick(_fx)

		local noise_amount = RangeAdjust(_fx, 0.0, 1.0, 0.35, 0.85)
		noise_amount += noise_amount * Rand(0, 0.1)

		ItemRegistrySetKey(item, "PostProcess:Noise:Strength", noise_amount)
	}

	function	RadialBlurUpdate()
	{
		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)
		local	_fx

		if (_clock >= video_fx_end_clock_start * 0.98)
			_fx = Clamp(RangeAdjust(_clock, video_fx_end_clock_start * 0.98, video_fx_end_clock_end, 0.0, 1.0), 0.0, 1.0)
		else
			_fx = 0.0

		_fx *= _fx // EaseInOutQuick(_fx)

		local blur_amount = RangeAdjust(_fx, 0.0, 1.0, 0.0, 0.5)

		ItemRegistrySetKey(item, "PostProcess:RadialBlur:Strength", blur_amount)
	}
	

	/*
	*/
	function	CameraUpdate()
	{
		NormalizeClock()
		UpdateInput()

		UpdateVideoFX()
		ChromaDispersionUpdate()
		VideoNoiseUpdate()
		UpdateSignalNoiseSFX()
		RadialBlurUpdate()
		
		//	Synchro issue ugly patch.
		// if (normalized_clock < 0.5)
		// 	ItemRegistrySetKey(item, "PostProcess:ChromDisp:Width", RangeAdjust(_light_intensity, 0.0, 1.0, 1.0, 5.0))
		// else
		// 	ItemRegistrySetKey(item, "PostProcess:ChromDisp:Width", 1.0)		
/*
		local	_light = ItemCastToLight(SceneFindItem(scene, "beep_light"))
		LightSetDiffuseIntensity(_light, _light_intensity)
		LightSetSpecularIntensity(_light, _light_intensity)
*/

		local	_interpolated_key = GetInterpolatedPosition(normalized_clock)

		local 	_cam_matrix = ItemGetMatrix(item)
		local	_front_vec = _cam_matrix.GetUp()

		local	_clock = RangeAdjust(normalized_clock, 0.0, 1.0, clock_start, clock_end)
		local	_fx = 0.0
		if (_clock >= video_fx_end_clock_start * 0.95)
		{
			_fx = Clamp(RangeAdjust(_clock, video_fx_end_clock_start * 0.95, video_fx_end_clock_end, 0.0, 1.0), 0.0, 1.0)
			_fx = EaseInOutQuick(_fx)
			_fx = _fx * 0.25 /* + Rand(_fx * -0.25, _fx * 0.25)*/  + Rand(_fx * -0.125, _fx * 0.125) + Rand(_fx * -0.05, _fx * 0.05)
			_fx *= Clamp(RangeAdjust(_clock, video_fx_end_clock_start * 0.95, video_fx_end_clock_end, 0.5, 1.0), 0.5, 1.0)

			if (Rand(0.0, 100.0) > 40.0)
				_fx *= 0.5
			if (Rand(0.0, 100.0) > 60.0)
				_fx *= 0.5
			if (Rand(0.0, 100.0) > 20.0)
				_fx *= 0.95
			if (Rand(0.0, 100.0) > 10.0)
				_fx *= 0.25
			if (Rand(0.0, 100.0) > 80.0)
				_fx *= 0.1
			if (Rand(0.0, 100.0) > 5.0)
				_fx *= 0.1		
		}

		camera_current_pos = _interpolated_key.position
		ItemSetPosition(item, camera_current_pos + _front_vec.Scale(_fx))
		ItemSetRotation(item, _interpolated_key.rotation + rotation_offset)

		// local cam_fov = Clamp(RangeAdjust(_clock, video_fx_end_clock_start, video_fx_end_clock_end, 50.0, 60.0), 50.0, 60.0)
		// CameraSetFov(ItemCastToCamera(item), DegreeToRadian(cam_fov))
	}

}
