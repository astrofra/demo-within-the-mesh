/*
	File: scripts/plant_animator.nut
	Author: Astrofra
*/

Include("scripts/base_animator.nut")

/*!
	@short	PlantAnimator
	@author	Astrofra
*/
class	PlantAnimator	extends BaseAnimator
{
	phase					=	0.0

	function	OnSetup(item)
	{
		base.OnSetup(item)

		ExploreHierarchyAndReturnTable(item)
		local	_tmp = []
		for(local n = 1; n <= item_table.len(); n++)
			_tmp.append(item_table[item_table.len() - n])

		item_table = _tmp
		ItemTableActivate(false)
	}

	function	OnSetupDone(item)
	{
		GrowAndWave()
	}

	function	ExploreHierarchyAndReturnTable(_item, _search_for_name = "cube")
	{
		local	_child_list = ItemGetChildList(_item)
		foreach(_child in _child_list)
			ExploreHierarchyAndReturnTable(_child)

		if (ItemGetName(_item) == _search_for_name)
			item_table.append({item = _item, position = ItemGetPosition(_item), rotation = ItemGetRotation(_item), scale = ItemGetScale(_item)})
	}

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		if (grow_factor < cam_max_dist && !ItemIsBehindCamera(item))
		{
			ItemTableActivate(true)

			grow_factor = RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0)
			grow_factor = Pow(Clamp(grow_factor, 0.0, 1.0), 0.4)

			if (grow_factor > 0.0)
				GrowAndWave()

			phase += Deg(120.0) * g_dt_frame
		}
		else
			ItemTableActivate(false)
	}

	function	GrowAndWave()
	{
		local	_node_phase = phase,
				_wav_amplitude = Deg(2.0),
				_axis = true

		foreach(_node in item_table)
		{
			_node_phase += Deg(60.0)
			ItemSetScale(_node.item, _node.scale.Scale(grow_factor))

			local	_wav_offset
			if (_axis)
				_wav_offset = Vector(_wav_amplitude * sin(_node_phase), _wav_amplitude * cos(_node_phase), _wav_amplitude * cos(_node_phase + 0.5 * PI))
			else
				_wav_offset = Vector(_wav_amplitude * sin(-_node_phase), _wav_amplitude * cos(_node_phase + 0.5 * PI), _wav_amplitude * cos(-_node_phase))

			ItemSetRotation(_node.item, _node.rotation + _wav_offset)
			_wav_amplitude += Deg(0.5)
			_axis = !_axis
		}
	}
}
