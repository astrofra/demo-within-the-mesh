/*
	File: scripts/temple_hat_animator.nut
	Author: Astrofra
*/

Include("scripts/base_animator.nut")

/*!
	@short	TempleHatAnimator
	@author	Astrofra
*/
class	TempleHatAnimator
{
	position	=	0
	rotation	=	0

	function	OnSetup(item)
	{
		position = ItemGetPosition(item)
	}

	function	OnUpdate(item)
	{
		local	_offset_pos = Vector()
		_offset_pos.y = Mtr(20.0) * sin(g_normalized_clock * 100.0 * Deg(45.0))
		ItemSetPosition(item, position + _offset_pos)
	}
}
