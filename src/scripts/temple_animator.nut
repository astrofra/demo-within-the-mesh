/*
	File: scripts/temple_animator.nut
	Author: Astrofra
*/

Include("scripts/base_animator.nut")

/*!
	@short	TempleAnimator
	@author	Astrofra
*/
class	TempleAnimator	extends BaseAnimator
{

	rotation		=	0

	function	OnSetup(item)
	{
		base.OnSetup(item)

		cam_min_dist = Mtr(20.0)
		cam_max_dist = Mtr(100.0)
		rotation = ItemGetRotation(item)
	}

	function	OnUpdate(item)
	{
		local	cam_pos = ItemGetWorldPosition(item_current_camera)
		local	root_pos = ItemGetWorldPosition(item)

		cam_pos.y = 0.0
		root_pos.y = 0.0

		grow_factor = root_pos.Dist(cam_pos)

		grow_factor = RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0)
		grow_factor = Pow(Clamp(grow_factor, 0.0, 1.0), 0.4)

		local	_rot_offset = Vector()
		_rot_offset.y = Deg(90.0) * grow_factor

		ItemSetRotation(item, rotation + _rot_offset)
	}
}
