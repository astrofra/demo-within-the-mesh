/*
	File: scripts/gate_iris_animator.nut
	Author: Astrofra
*/

Include("scripts/base_animator.nut")

/*!
	@short	GateIrisAnimator
	@author	Astrofra
*/
class	GateIrisAnimator		extends BaseAnimator
{
	function	OnSetup(item)
	{
		base.OnSetup(item)

		print("GateIrisAnimator::OnSetup()")

		ExploreHierarchyAndReturnTable(item)

		cam_min_dist = Mtr(5.0)
		cam_max_dist = Mtr(15.0)
	}

	function	ExploreHierarchyAndReturnTable(_item)
	{
		local	_child_list = ItemGetChildList(_item)
		foreach(_child in _child_list)
			if(ItemGetName(_child) == "gate_iris_plate")
				item_table.append({item = _child, position = ItemGetPosition(_child), rotation = ItemGetRotation(_child), scale = ItemGetScale(_child)})
	}

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		if (grow_factor < cam_max_dist)
		{
			grow_factor = RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0)
			grow_factor = Clamp(grow_factor, 0.0, 1.0)

			if (grow_factor > 0.0)
			{
				grow_factor = EaseInOutByPow(grow_factor, 1.5)
				local	_angle = grow_factor * Deg(-60.0)
				foreach(_item in item_table)
					ItemSetRotation(_item.item, _item.rotation + Vector(0, 0, _angle))
			}
		}
	}
}
