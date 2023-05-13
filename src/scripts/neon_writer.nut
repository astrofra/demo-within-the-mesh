/*
	File: scripts/laser_writer.nut
	Author: Astrofra
*/

Include("scripts/utils/utils.nut")
Include("scripts/base_animator.nut")
Include("scripts/ui.nut")

UILoadFont("ui/fonts/neon.ttf")


letter_table	<-	[
	[[0,0],[0,1],[1,1],[1,0],[0,0]],	//	A
	[[0,1],[0,0],[0,1],[1,1]]			//	B
]

/*!
	@short	LaserWriter
	@author	Astrofra
*/
class	NeonWriter	extends	BaseAnimator
{
/*<
	<Parameter =
		<text = <Name = "Text"> <Type = "String"> <Default = "type your text here">>
	>
>*/
	text						=	"test"
	
	letter_size					=	96

	position					=	0
	rotation					=	0

	w							=	0
	h							=	0

	global_fade					=	1.0

	rand_table					=	0
	rand_clock					=	0
	
	texture						=	0
	nmg_filename				=	"assets/writer_plane.nmg"
	plane_geometry				=	0

	rand_target					=	0.0
	current_rand				=	0.0

	poly_is_loaded				=	false

	//	How long does it take to draw a single segment
	vector_draw_duration		=	(1.0 / 60.0) * 0.5

	constructor()
	{
		rand_table = []
		local	n = 250
		while(n-- > 0)
			rand_table.append(Rand(0.0, 1.0))
	}

	function	OnSetup(item)
	{
		base.OnSetup(item)
		cam_min_dist			=	Mtr(40.0)
		cam_max_dist			=	Mtr(60.0)

		CreateNeonTexture()
		poly_is_loaded = DisplayWriterPoly(item)
	}
	
	function	CreateNeonTexture()
	{
		local	ui = SceneGetUI(scene)
		w = text.len() * letter_size
		h = letter_size
		local	neon_label = Label(ui, w, h, 0, 0, true, true)
		neon_label.label_color = 0x0fbbffff
		neon_label.font = "neon"
		neon_label.font_size = letter_size * 0.9
		neon_label.glow = true
//		neon_label.font_tracking = -1.0
//		neon_label.font_leading = -1.0
		neon_label.label = text
		neon_label.refresh()
		texture = neon_label.texture
		SpriteSetOpacity(neon_label.window, 0.0)
//		SpriteSetScale(neon_label.windows, 0.0, 0.0)
	}
	
	function	DisplayWriterPoly(item)
	{
		if (!FileExists(nmg_filename))
		{
			print("DisplayWriterPoly() : geometry '" + nmg_filename + "' cannot be found!")
			return	false
		}

		plane_geometry = ResourceFactoryLoadGeometryEx(g_factory, nmg_filename, true)
		ObjectSetGeometry(ItemCastToObject(item), plane_geometry)
		local mat = GeometryGetMaterialFromIndex(plane_geometry, 0)
		MaterialSetTexture(mat, 0, texture)
		ItemSetScale(item, ItemGetScale(item) * Vector(w.tofloat() / h.tofloat(), 1.0, 1.0))
		ItemSetRotation(item, ItemGetRotation(item) + Vector(0, PI, 0.0))
		MaterialSetAmbient(mat, Vector(w,h,0.0));

		return	true
	}

	function	OnUpdate(item)
	{

		if (!poly_is_loaded)
			return

		if (!ItemIsActive(item))
			return

		base.OnUpdate(item)

		rand_clock = g_clock

		global_fade = Clamp(RangeAdjust(grow_factor, cam_max_dist, cam_min_dist, 0.0, 1.0), 0.0, 1.0)

		if (grow_factor < cam_max_dist && !ItemIsBehindCamera(item))
		{
			local	_rand_seed = Mod(rand_clock, rand_table.len())
			rand_target = rand_table[_rand_seed]
			current_rand += ((rand_target - current_rand) * (g_dt_frame * 5.0))
			ItemSetDiffuseFloat(item, current_rand)
		}	

		ItemSetSelfIllumFloat(item, global_fade)
			
	}
}
