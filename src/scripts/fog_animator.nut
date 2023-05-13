/*
	File: scripts/fog_animator.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")

/*!
	@short	FogAnimator
	@author	Polymorf-Astrofra-Alkama
*/
class	FogAnimator	extends	BaseAnimator
{

	scale_factor			=	0.0
	scene_script			=	0

	function	OnSetup(item)
	{
		cam_min_dist = Mtr(20.0)
		cam_max_dist = Mtr(70.0)
		base.OnSetup(item)
		scene_script = SceneGetScriptInstance(scene)
		
	}

	function	OnUpdate(item)
	{
		base.OnUpdate(item)

		if (grow_factor > cam_max_dist)
			return

		local	_color
		local	_near
		local	_far

		if (ItemIsBehindCamera(item))
		{
			_color = Vector(0.01,0.01,0.01,1)
			_near = Mtr(1.0)
			_far = Mtr(10.0)
		}
		else
		{
			scale_factor = RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0)
			scale_factor = Clamp(scale_factor, 0.0, 1.0)
			scale_factor = EaseInOutQuick(scale_factor)
			_color = scene_script.fog.color.Lerp(1.0 - scale_factor, Vector(0.01,0.01,0.01,1))
			_near = Lerp(scale_factor, scene_script.fog.near, Mtr(1.0))
			_far = Lerp(scale_factor, scene_script.fog.far, Mtr(10.0))
		}

		//	SceneSetFog(scene, true, _color, _near, _far)
		local	fog = SceneGetScriptInstance(scene).fog
		fog.target_near = _near
		fog.target_far = _far
		fog.target_color = clone(_color)
	}
}
