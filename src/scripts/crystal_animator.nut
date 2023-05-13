/*
	File: scripts/crystal_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")

/*!
	@short	CrystalAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	CrystalAnimator	extends BaseAnimator
{
	initial_pos					=	0
	initial_scale				=	0
	min_pos						=	0
	min_scale					=	0

	scale_factor				=	0.0
	scale_factor_dt				=	0.0
	prev_scale_factor			=	0.0
	update_counter				=	0

	function	OnSetup(item)
	{
		base.OnSetup(item)
		cam_min_dist = Mtr(10.0)
		cam_max_dist = Mtr(50.0)

		initial_pos = ItemGetPosition(item)
		initial_scale = ItemGetScale(item)
		local	bbox = ItemGetMinMax(item)
		min_pos = initial_pos - ItemGetMatrix(item).GetUp().Normalize().Scale((bbox.max.y - bbox.min.y) * 0.25)
		min_scale = initial_scale * Vector(0.25, 0.025, 0.25)

		cam_min_dist += Rand(0.0, 5.0)
		cam_max_dist += Rand(0.0, 10.0)

		UpdateCrystalMotion(item, 0.0)
	}

	function	UpdateCrystalMotion(item, _factor)
	{
		_factor = Clamp(_factor, 0.0, 1.0)
		ItemSetPosition(item, initial_pos.Lerp(Clamp(RangeAdjust(_factor, 0.0, 0.25, 0.0, 1.0), 0.0, 1.0), min_pos))
		ItemSetScale(item, initial_scale.Lerp(_factor, min_scale))
		local	_opacity = Clamp(_factor, 0.0, 0.2) * 5.0
		ItemSetOpacityViaSelfIllum(item, _opacity)
	}

	function	OnUpdate(item)
	{
		local	cam_pos = ItemGetWorldPosition(item_current_camera)
		local	root_pos = ItemGetWorldPosition(item)

		root_pos.x = 0.0
		cam_pos.x = 0.0

		root_pos.y = 0.0
		cam_pos.y = 0.0

		grow_factor = root_pos.Dist(cam_pos)

		if (ItemIsBehindCamera(item) || grow_factor > cam_max_dist)
		{
			if (ItemIsBehindCamera(item))
				SceneItemActivateHierarchy(scene, item, false)
	
			return
		}

		update_counter++

		if (update_counter >= 1)
		{
			scale_factor = Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0), 0.0, 1.0)
			scale_factor = EaseInOutQuick(scale_factor)	//	Pow(scale_factor, RangeAdjust(scale_factor, 0.0, 1.0, 4.0, 1.0))
			update_counter = 0
		}
		else
			scale_factor += scale_factor_dt

		UpdateCrystalMotion(item, scale_factor)

		scale_factor_dt = scale_factor - prev_scale_factor
		prev_scale_factor = scale_factor
	}
}
