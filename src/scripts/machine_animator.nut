/*
	File: scripts/machine_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

/*!
	@short	MachineAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	MachineAnimator
{
	handlers			=	0
	hands				=	0
	angle				=	0.0

	function	OnSetup(item)
	{
		handlers = []
		hands = []

		local	_tmp = ItemGetChildList(item)

		foreach(_child in _tmp)
		{
			switch(ItemGetName(_child))
			{
				case "handler":
					handlers.append(_child)
					break

				case "hand":
					ItemSetParent(_child, NullItem)
					hands.append(_child)
					break
			}
		}
	}

	function	OnUpdate(item)
	{
		angle += g_dt_frame * Deg(-90.0)
		ItemSetRotation(item, Vector(angle, 0.0, 0.0))
		for(local n = 0; n < 4; n++)
			ItemSetPosition(hands[n], ItemGetWorldPosition(handlers[n]))
	}
}
