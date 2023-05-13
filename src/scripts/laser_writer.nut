/*
	File: scripts/laser_writer.nut
	Author: Astrofra
*/

Include("scripts/utils/utils.nut")
Include("assets/scripts/letters.nut")
Include("scripts/base_animator.nut")

letter_table	<-	[
	[[0,0],[0,1],[1,1],[1,0],[0,0]],	//	A
	[[0,1],[0,0],[0,1],[1,1]]			//	B
]

/*!
	@short	LaserWriter
	@author	Astrofra
*/
class	LaserWriter	extends	BaseAnimator
{
/*<
	<Parameter =
		<text = <Name = "Text"> <Type = "String"> <Default = "type your text here">>
	>
>*/
	text						=	"test"

	position					=	0
	rotation					=	0

	vector_list					=	0
	current_vector_index		=	0
	current_fading_vector_index	=	0

	global_fade					=	1.0

	rand_table					=	0
	rand_clock					=	0

	//	How long does it take to draw a single segment
	vector_draw_duration		=	(1.0 / 60.0) * 0.5

	constructor()
	{
		vector_list = []

		rand_table = []
		local	n = 2500
		while(n-- > 0)
			rand_table.append(Rand(-1.0, 1.0))
	}

	function	OnSetup(item)
	{
		base.OnSetup(item)
		cam_min_dist			=	Mtr(20.0)
		cam_max_dist			=	Mtr(50.0)
		ConvertTextToVectors()
	}

	function	ConvertTextToVectors()
	{
		local	i,n, base_pos = Vector()

		for(i = 0; i < text.len(); i++)
		{
			local 	_l = "", _letter, c = text.slice(i,i+1).toupper()
			foreach(_letter in letter_vectors)
				if(c == _letter.letter_name)
				{
					_l = _letter
					break
				}

			if (_l != "")
			{
				local	m
				foreach(_segment in _l.segments)
				{
					local	_prev_p = _segment[0]
					for(m = 1; m < _segment.len(); m++)
					{
						local	_p = _segment[m]
						vector_list.append({position_a = base_pos + _prev_p, position_b = base_pos + _p, intensity = 0.0})
						_prev_p = clone(_p)
					}
				}
			}

			if (_l != "" || c == " ")
				base_pos.x += Mtr(0.75)
		}

		//	Center the word
		foreach(_vec in vector_list)
		{
			_vec.position_a.x -= (base_pos.x * 0.45)
			_vec.position_b.x -= (base_pos.x * 0.45)
		}

		vector_draw_duration = 1.0 / (vector_list.len() + 1.0)
	}

	function	OnRenderUser(item)
	{
return
		if (!ItemIsActive(item))
			return

		if (vector_list == 0)
			return

		if (grow_factor < cam_max_dist && !ItemIsBehindCamera(item))
		{	
			RendererSetIdentityWorldMatrix(g_render)

			local	_origin = ItemGetWorldPosition(item)
			local	_scale = ItemGetScale(item)

			foreach(_vector in vector_list)
			{
				local	_a, _b, _i
				_a = _origin + _vector.position_a * _scale
				_b = _origin + _vector.position_b * _scale

//				if (_vector.intensity > 0.0)
//				{
//					local	_color =  Vector(0.2, 0.7, 1.0).Scale(RangeAdjustClamped(Pow(_vector.intensity, 2.0) * global_fade, 0.0, 1.0, 1.0, 2.0))
					local	_color =  Vector(0.2, 0.7, 1.0, 0.8)
					_color.w = /* _vector.intensity * */ global_fade
					if (Rand(0,100) < 2)
						_color *= 1.25
					if (Rand(0,100) < 10)
						_color *= 2.0
					if (Rand(0,100) < 20)
						_color *= 1.1
					DrawLaserVector(_a, _b, _color, _scale)
//				}
			}
		}
	}

	function	DrawLaserVector(_va, _vb, _vcolor, _scale)
	{
		local	n = 0

		local	_a = clone(_va)
		local	_b = clone(_vb)
		local	_color = clone(_vcolor)

		_a = RandomizeLaser(_a, n + rand_clock)
		_b = RandomizeLaser(_b, n + rand_clock)

		DrawQuadBasedLineInXYPlane(_a, _b, Mtr(0.04), _color)
		_color.w *= 1.5
		DrawQuadInXYPlane(_a, Mtr(0.025) * _scale.x, _color)
//		DrawQuadInXYPlane(_a, Mtr(0.025 * 0.5) * _scale.x, _color)

	}

	function	RandomizeLaser(_v, n)
	{
		local	e = 0.025
		local	_o = PointCoordinateToRandomOffset(_v, n)
		_v += _o.Scale(e)
		return _v
	}

	function	PointCoordinateToRandomOffset(_pos, n)
	{
		local	_v = Vector()
		_v.x = rand_table[Mod(n + Abs(_pos.x * 1000.0).tointeger(), rand_table.len() - 1)]
		_v.y = rand_table[Mod(n + Abs(_pos.y * 1000.0).tointeger(), rand_table.len() - 1)]
		_v.z = rand_table[Mod(n + Abs(_pos.z * 1000.0).tointeger(), rand_table.len() - 1)]
		return _v
	}

	function	OnUpdate(item)
	{
return
		if (!ItemIsActive(item))
			return

		if (vector_list == 0)
			return

		base.OnUpdate(item)

		rand_clock = g_clock

		global_fade = Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0), 0.0, 1.0)

/*
		if (grow_factor < cam_max_dist && !ItemIsBehindCamera(item))
		{
			local	_amount_of_fading_vectors = 0.0

			while(_amount_of_fading_vectors < 0.01 * 60.0)
			{
				vector_list[current_fading_vector_index].intensity = Max(0.0, vector_list[current_fading_vector_index].intensity - (g_dt_frame * 12.0))

				_amount_of_fading_vectors += 0.1

				current_fading_vector_index++
				if (current_fading_vector_index >= vector_list.len())
					current_fading_vector_index = 0

			}
				
			local	_amount_of_redrawn_vectors = 0.0

			while(_amount_of_redrawn_vectors < 0.01 * 0.1 * 60.0)
			{
				vector_list[current_vector_index].intensity = 1.0

				_amount_of_redrawn_vectors += 0.1

				current_vector_index++
				if (current_vector_index >= vector_list.len())
					current_vector_index = 0
			}

		}
*/
		
	}
}
