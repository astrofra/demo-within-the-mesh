/*
	File: scripts/mesh_cycler.nut
	Author: Polymorf-Astrofra-Alkama
*/

Include("scripts/base_animator.nut")
Include("scripts/utils/utils.nut")

if (!("g_mesh_cycle" in getroottable))
	g_mesh_cycle		<-		[]

/*!
	@short	MeshCycler
	@author	Polymorf-Astrofra-Alkama
*/
class	MeshCycler	extends	BaseAnimator
{
	base_framerate		=	12.0
	base_speed			=	Mtrs(15.0)
	initial_frame		=	0.0
	object				=	0

	walk_steps			=	0

	base_scale			=	3.0
	scale_variation		=	0.05

	local_pos			=	0
	initial_pos			=	0
	pos_z_offset		=	0.0
	z_speed				=	Mtr(0.15)
	z_offset			=	Mtr(-50.0)

	rand_table			=	0

	local_clock			=	0.0

	last_ground_hit		=	0
	racyast_dir			=	0

	prev_mesh_idx		=	-1
	prev_pos_y			=	0.0

	opacity				=	0.0

	
	function	OnSetup(item)
	{
		base.OnSetup(item)

		cam_max_dist = Mtr(75.0)

		object = ItemCastToObject(item)

		if (g_mesh_cycle.len() == 0)
			LoadGeometries()

		InitWalkSteps()

		rand_table = []
		for(local n = 0; n < 100; n++)
			rand_table.append(Rand(0.0, 100.0))

		local	pos = ItemGetWorldPosition(item)
		local	rdmize = Mod(Abs((pos.x + pos.y + pos.z).tointeger()), g_mesh_cycle.len())

		z_offset += ((z_offset * 0.25) * rand_table[rdmize] / 100.0)

		initial_frame += rand_table[rdmize] * g_mesh_cycle.len() / 100.0

		base_framerate += (base_framerate * (rand_table[rdmize] - 50.0) / 500.0)
		z_speed += (z_speed * (rand_table[rdmize] - 50.0) / 500.0)

		local	scale = base_scale + (base_scale * ((rand_table[rdmize] * 2.0) - 100.0) * scale_variation / 100.0)
		ItemSetScale(item, Vector(scale,scale,scale))

		initial_pos = ItemGetPosition(item)
		local_pos = clone(initial_pos)
		last_ground_hit = clone(initial_pos)

		racyast_dir = Vector(0,-1,0)
	}

	function	InitWalkSteps()
	{
		walk_steps = []
		for(local n = 0; n < g_mesh_cycle.len(); n++)
		{
			local	_beta = (n * 4.0 * PI / g_mesh_cycle.len()) + (0.45 * PI)
			local	_offset = cos(_beta)
			_offset = Clamp(_offset, 0.0, 1.0)
			_offset *= 0.5
			walk_steps.append(_offset)
		}
	}

	function	OnUpdate(item)	
	{
		ItemSetOpacity(item, opacity)

		local	normalized_dt = SceneGetScriptInstance(scene).camera_ride_handler.normalized_dt

		local	cam_pos = ItemGetWorldPosition(item_current_camera)
		local	root_pos = ItemGetWorldPosition(item)
		local_pos = ItemGetPosition(item)

		local	dist_trigger = Max((cam_pos.z - initial_pos.z + cam_max_dist), 0.0)		

		if (dist_trigger > 0.0)
		{
			local_clock += normalized_dt * Sec(100.0)	//	100.0 == roughly the length of the whole ride sequence.
//			opacity = Clamp(opacity + local_clock * 0.25, 0.0, 1.0)
			opacity = Clamp(RangeAdjust(dist_trigger, Mtr(15.0), Mtr(35.0), 0.0, 1.0), 0.0, 1.0)
			//	Stick To The Ground

			if (EverySecond(Sec(0.025), this))
			{
				local	hit = SceneCollisionRaytrace(scene, local_pos + Vector(0,25.0,base_scale), racyast_dir, -1, CollisionTraceAll, Mtr(50.0))
				if (hit.hit)
					last_ground_hit = hit.p.Lerp(0.1, last_ground_hit)
			}
		}

		UpdateFrame(item)
	}

	function	UpdateFrame(item)
	{
		local	current_frame = initial_frame + (local_clock * base_framerate)

		current_frame = Mod(current_frame, g_mesh_cycle.len().tofloat())

		local	_mesh_idx = current_frame.tointeger()
		if (_mesh_idx != prev_mesh_idx)
			ObjectSetGeometry(object, g_mesh_cycle[_mesh_idx])

		local	_pos = clone(initial_pos)
		_pos.z += (z_speed * local_clock * base_speed * base_scale) 
		_pos.z += walk_steps[_mesh_idx] * base_scale
		_pos.z += z_offset
		_pos.y = prev_pos_y

		if (_mesh_idx != prev_mesh_idx)
			prev_pos_y = last_ground_hit.y

		ItemSetPosition(item, _pos)

		prev_mesh_idx = _mesh_idx
	}

	function	LoadGeometries()
	{
		local	n
		for(n = 1; n < 51; n++)
		{
			local	_mesh_name = "colossus_walk_frozen/colossus"

			if (n < 10)
				_mesh_name += "0"
			if (n < 100)
				_mesh_name += "0"

			_mesh_name += n.tostring()
			_mesh_name += ".nmg"

			if (FileExists(_mesh_name))
			{
				local	_new_geo = ResourceFactoryLoadGeometry(g_factory, _mesh_name)
				g_mesh_cycle.append(_new_geo)
					print("MeshCycler::LoadGeometries() loaded : '" + _mesh_name + "'.")
			}
		}
	}
}
