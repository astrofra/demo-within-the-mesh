/*
	File: scripts/floating_wall_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")

/*!
	@short	FloatingWallAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	FloatingWallAnimator	extends BaseAnimator
{
	initial_pos					=	0
	min_pos						=	0
	
	scale_factor				=	0.0
	scale_factor_dt				=	0.0
	prev_scale_factor			=	0.0
	update_counter				=	0

	function	OnSetup(item)
	{
		base.OnSetup(item)
		cam_min_dist = Mtr(25.0)
		cam_max_dist = Mtr(75.0)

		initial_pos = ItemGetPosition(item)
		min_pos = initial_pos - ItemGetMatrix(item).GetUp().Normalize().Scale(10.0)

		UpdateWallMotion(item, 0.0)
	}

	function	UpdateWallMotion(item, _factor)
	{
		ItemSetPosition(item, initial_pos.Lerp(_factor, min_pos))
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
			return

		update_counter++

		if (update_counter >= 1)
		{
			scale_factor = Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0), 0.0, 1.0)
			update_counter = 0
		}
		else
			scale_factor += scale_factor_dt

		scale_factor = EaseInOutQuick(scale_factor)
		UpdateWallMotion(item, scale_factor)
		
		scale_factor_dt = scale_factor - prev_scale_factor
		prev_scale_factor = scale_factor
	}	
}
