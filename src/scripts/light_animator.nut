/*
	File: scripts/light_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")

/*!
	@short	LightAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	LightAnimator	extends BaseAnimator
{
	initial_pos					=	0
	initial_scale				=	0
	min_scale					=	0
	flare_script				=	0
	light_item					=	0
	light						=	0
	light_diffuse				=	0.0
	light_specular				=	0.0
	parent_distance_multiplier	=	1.0

	function	OnSetup(item)
	{
		base.OnSetup(item)
		initial_pos = ItemGetPosition(item)
		initial_scale = ItemGetScale(item)
		min_scale = initial_scale * Vector(0.01, 1.5, 0.1)

		flare_script = ItemGetScriptInstance(ItemGetChild(item, "flare"))
		light_item = ItemGetChild(item, "light")
		light = ItemCastToLight(light_item)
		light_diffuse = LightGetDiffuseIntensity(light)
		light_specular = LightGetSpecularIntensity(light)

		//	item_table.append({item = item})

		local	_tmp = ItemGetChildList(item)

		foreach(_item in _tmp)
			item_table.append({item = _item})

		ItemTableActivate(false)
		ItemSetScale(item, Vector(0,0,0))
		cam_min_dist			=	Mtr(10.0)
		cam_max_dist			=	Mtr(30.0)

		local	_parent = ItemGetParent(item)
		local	_name = ItemGetName(_parent)
		if (_name.find("_") != null)
			parent_distance_multiplier = (split(_name, "_")[1]).tofloat()

		cam_min_dist *= parent_distance_multiplier
		cam_max_dist *= parent_distance_multiplier

		LightSetDiffuseIntensity(light, 0.0)
		LightSetSpecularIntensity(light, 0.0)
	}

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		if (ItemIsBehindCamera(item) || grow_factor > cam_max_dist)
		{
			ItemTableActivate(false)
			SceneItemActivate(scene, light_item, false)
			LightSetDiffuseIntensity(light, 0.0)
			LightSetSpecularIntensity(light, 0.0)
		}
		else
		{
			ItemTableActivate(true)
			SceneItemActivate(scene, light_item, true)
			local	scale_factor = Pow(Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0), 0.0, 1.0), 0.25)
			local	rand_factor = Pow(Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_max_dist * 0.8 + cam_min_dist * 0.2, 1.0, 0.0), 0.0, 1.0), 4.0)
			scale_factor += (Rand(-1.0, 1.0) * 0.5 * rand_factor)
			ItemSetScale(item, initial_scale.Lerp(scale_factor, min_scale) + Vector(0,1.0,0).Scale(rand_factor))
			ItemSetPosition(item, initial_pos + Vector(0,1,0).Scale(Mtr(2.0) * rand_factor) + Vector(0,1,0).Scale(Mtr(1.0) * (1.0 - scale_factor)))
			LightSetDiffuseIntensity(light, light_diffuse * scale_factor)
			LightSetSpecularIntensity(light, light_specular * scale_factor)
		}

		flare_script.draw_flare = is_active
	}

}
