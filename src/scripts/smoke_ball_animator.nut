/*
	File: scripts/smoke_ball_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")

/*!
	@short	SmokeBallAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	SmokeBallAnimator	extends BaseAnimator
{

	base_scale					=	0
	max_scale_factor			=	2.5

	function	OnSetup(item)
	{
		base.OnSetup(item)

		cam_min_dist			=	Mtr(10.0)
		cam_max_dist			=	Mtr(40.0)
		cam_max_dist += Rand(-5.0,5.0)

		base_scale = ItemGetScale(item)
	}

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		local	_scale = RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0)
		_scale = Clamp(_scale, 0.0, 1.0)
		_scale *= _scale
		_scale = EaseInOutQuick(_scale)
		_scale = RangeAdjust(_scale, 0.0 ,1.0, 0.0001, max_scale_factor)
		ItemSetScale(item, (Vector(_scale, _scale, _scale) * base_scale).Scale(Rand(0.925, Rand(0.975,1.0))))
	}
	
}
