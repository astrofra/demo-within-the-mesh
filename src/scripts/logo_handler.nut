/*
	File: scripts/logo_handler.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/utils/utils.nut")

/*!
	@short	MandaLogoHandler
	@author	Polymorf-Astrofra-Alkama
*/
class	MandaLogoHandler
{
	scene				=	0

	light				=	0
	light_diffuse_int	=	0.0
	light_specular_int	=	0.0
	neon				=	0
	neon_material		=	0
	neon_base_color		=	0
	normalized_clock	=	0.0
	ambient_color		=	0.0

	neon_bounce_response	=	0.0

	sound_played		=	false

	mid_clock_bias		=	0.25
	
	all_done			=	false

	function	OnSetup(item)
	{
		normalized_clock	=	0.0

		scene = ItemGetScene(item)

		light = ItemCastToLight(ItemGetChild(item, "logo_main_spotlight"))
		light_diffuse_int = LightGetDiffuseIntensity(light)
		light_specular_int = LightGetSpecularIntensity(light)

		neon = ItemGetChild(item, "mandarine_logo_neon")
		neon_material = GeometryGetMaterialFromIndex(ObjectGetGeometry(ItemCastToObject(neon)), 0)
		neon_base_color = MaterialGetDiffuse(neon_material)

		ambient_color = Vector(66.0 , 70.0, 72.0).Scale(1.0 / 255.0)
	}

	function	SetNormalizedClock(_c)
	{	normalized_clock	=	_c	}

	function	OnUpdate(item)
	{
//		normalized_clock += (g_dt_frame * 0.75)
//		normalized_clock = Clamp(normalized_clock, 0.0, 1.0)

		if (all_done)
			return

		local	_time = MakeTriangleWave(normalized_clock)
		_time = Clamp(RangeAdjust(_time, 0.0, 0.9, 0.0, 1.0), 0.0, 1.0)
		local	_eased_time = EaseInOutByPow(_time, 2.0)

		local	_biased_time = (normalized_clock < 0.5 + mid_clock_bias)?RangeAdjust(normalized_clock, 0.0, 0.5 + mid_clock_bias, 0.0, 0.5):RangeAdjust(normalized_clock, 0.5 + mid_clock_bias, 1.0, 0.5, 1.0)
		_biased_time = MakeTriangleWave(_biased_time)

		local	_global_bias = Clamp(RangeAdjust(normalized_clock, 0.35, 1.0, 0.0, 0.2), 0.0, 0.2)
		_global_bias *= EaseInOutByPow(Clamp(RangeAdjust(normalized_clock, 0.5, 1.0, 1.0, 0.0), 1.0, 0.0), 2.0)

		//	Additionnal flashes
		local	_neon_flashes = fabs(sin(normalized_clock * 2.0 * PI * 5.0))
		local	_in_glitches = Clamp(RangeAdjust(_neon_flashes, 0.4, 0.95, 0.0, 1.0), 0.0, 1.0)
		local	_out_glitches = Clamp(RangeAdjust(_neon_flashes, 0.0, 0.75, 0.0, 1.0), 0.0, 1.0)
		_neon_flashes = _in_glitches * (1.0 - normalized_clock) + _out_glitches * normalized_clock
		_neon_flashes = Pow(_neon_flashes, 0.5)
		_neon_flashes *= 0.5
		_neon_flashes *= _biased_time

		local	_neon_bounce = Clamp(RangeAdjust(normalized_clock, 0.9, 1.0, 0.0, 1.0), 0.0, 1.0)
		_neon_bounce = MakeTriangleWave(_neon_bounce)
		_neon_bounce *= _neon_bounce
		neon_bounce_response = Max(neon_bounce_response, _neon_bounce)
		neon_bounce_response = Clamp(neon_bounce_response - (g_dt_frame * 0.75), 0.0, 1.0)

		_neon_flashes = Max(_neon_flashes, neon_bounce_response * neon_bounce_response)

		MaterialSetSelf(neon_material, Vector(1,1,1).Scale(Max(_global_bias * 0.25, _neon_flashes)))

		//	Short fade in and out of the reflexions
		local	_time_refl = Clamp(RangeAdjust(_time, 0.0, 0.2, 0.0, 1.0), 0.0, 1.0)
		_time_refl = EaseInOutByPow(_time_refl, 2.0) 
		MaterialSetAmbient(neon_material, Vector(1,1,1).Scale(Max(_global_bias * 0.5, Max(_time_refl, neon_bounce_response))))

		//	Global light control (fades in and out on the whole sequence)
		LightSetDiffuseIntensity(light, Max(_global_bias * 2.0, Max(light_diffuse_int * _eased_time, neon_bounce_response * 0.5)))
		LightSetSpecularIntensity(light, Max(_global_bias * 2.0, Max(light_specular_int * _eased_time, neon_bounce_response * 0.25)))

		if (normalized_clock < 1.0)
		{
			SceneSetAmbientColor(scene, ambient_color)
			SceneSetAmbientIntensity(scene, Max(_global_bias * 0.25, Max(_eased_time, neon_bounce_response * 0.25)))
		}

		if (!sound_played && _neon_flashes > 0.01)
			PlayNeonSfx()
	}

	function	PlayNeonSfx()
	{
		MixerStartStreamFast(g_mixer, "sfx/neon.ogg")
		sound_played = true
	}
}
