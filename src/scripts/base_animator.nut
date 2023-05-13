/*
	File: scripts/base_animator.nut
	Author: Astrofra
*/

/*!
	@short	BaseAnimator
	@author	Astrofra
*/
class	BaseAnimator
{
	item_table				=	0

	grow_factor				=	0.0
	cam_min_dist			=	Mtr(10.0)
	cam_max_dist			=	Mtr(30.0)

	scene					=	0
	item_current_camera		=	0

	is_active				=	true
	set_static				=	false

	constructor()
	{
		item_table = []
	}

	function	OnSetup(item)
	{
		scene = ItemGetScene(item)
		item_current_camera = SceneFindItem(scene, "render_camera") //CameraGetItem(SceneGetCurrentCamera(scene))
		is_active = true
	}

	function	ItemIsBehindCamera(item, _bias = Mtr(15.0))
	{
		local	cam_pos = ItemGetWorldPosition(item_current_camera)
		local	root_pos = ItemGetWorldPosition(item)

		if (root_pos.z + _bias < cam_pos.z)
			return true
		else
			return false
	}

	function	OnUpdate(item)
	{
		local	cam_pos = ItemGetWorldPosition(item_current_camera)
		local	root_pos = ItemGetWorldPosition(item)

		grow_factor = root_pos.Dist(cam_pos)
	}

	function	ItemTableActivate(_flag)
	{
		if (_flag != is_active)
		{
			is_active = _flag
			foreach(_item in item_table)
				SceneItemActivateHierarchy(scene, _item.item, _flag)
		}
	}
}
