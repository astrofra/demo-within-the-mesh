/*
	File: scripts/preloader.nut
	Author: Astrofra
*/

/*!
	@short	Preload
	@author	Astrofra
*/
class	Preload
{
	
	object_list = [

// --- textures list

"cyclopean_pillar_01/normal_pillar_01.jpg",
"cyclopean_pillar_01/occ_pillar_01.png",

"cyclopean_pillar_02/normal_pillar_02.jpg",
"cyclopean_pillar_02/occ_pillar_02.png",

"ruins_temple/normal_ruins_temple.png",
"ruins_temple/occ_ruins_temple.png",

"planet/occ_planet.jpg",
"planet/planet_latlong_diffuse.png",        
"planet/planet_latlong_mask.png",
"planet/planet_latlong_normal.png",
"planet/planet_latlong_specular.png",

"spaceship/diffus_spaceship.png",
"spaceship/normal_spaceship.jpg",
"spaceship/spaceshipe_mask.png",
"spaceship/spec_spaceship.png",

"assets/brushed_metal_normal.jpg",
"assets/grey_mix_cement_normal.jpg",
"assets/grey_strong_cement_normal.jpg",
"assets/grid-6-X-6-colored.jpg",
"assets/metal_dirt.jpg",
"assets/wall_basic_10m_baking_color.jpg",
"assets/bare_metal.png",
"assets/bare_metal_spec.png",
"assets/bare_metal_worn.png",
"assets/brushed_metal.png",
"assets/color_nerv_net.png",
"assets/cristal_bakingNormalsMap.png",
"assets/envmap_atmosphere.png",
"assets/fallof_map_0.png",
"assets/hologram_diffuse.png",
"assets/hologram_mask.png",
"assets/iris_gate_concrete_ambiant_MR_.png",
"assets/kitchen_latlong_envmap.png",
"assets/kitchen_latlong_envmap_blurred.png",
"assets/monitor_crt_mask.png",
"assets/monitor_crt_scanline.png",
"assets/occ_electron.png",
"assets/occ_light.png",
"assets/paper_color.png",
"assets/paper_normal.png",
"assets/planet_envmap_1.png",
"assets/planet_envmap_2.png",
"assets/planet_envmap_3.png",
"assets/skybox_flat.jpg",
"assets/starfield.png",
"assets/wall_basic_10m_bakingAmbient Occlusion _MR_.png",
"assets/wall_basic_10m_bakingDiffuseMap.png",
"assets/wall_basic_10m_bakingNormalsMap.png",
"assets/wall_flat_10m_bakingAmbient.png",

"assets/alpha_linear_gradient.tga",
"assets/alpha_radial.tga",
"assets/dirt_shadow_alpha.tga",
"assets/dist_particle_alpha.tga",
"assets/dist_particle_sharp_alpha.tga",
"assets/dry_grass_color.tga",
"assets/noise.tga",
"assets/noise_alpha.tga",

"ui/title_credits_mndrn.tga",
"ui/title_credits.tga",
"ui/title_document.tga",
"ui/title_main.tga",
"ui/vignette_alpha.tga",
"ui/black_block.png",

// --- geo list

"assets/mandarine_logo_neon.nmg",
"assets/wall_logo.nmg",

"wall_dome/wall_dome.nmg",

"walls_mix/walls_mix_simple.nmg",
"walls_mix/walls_mix_brick.nmg",

"planet/planet.nmg",

"rubbles/ruins_temple_rubble.nmg",

"cyclopean_pillar_01/cyclopean_pillar_01.nmg",

"cyclopean_pillar_02/cyclopean_pillar_02.nmg",

"ruins_temple/ruins_temple.nmg",
"ruins_temple/ruins_temple_hat.nmg",
"ruins_temple/ruins_temple_projection/ruins_temple_hat_projection.nmg",
"ruins_temple/ruins_temple_projection/ruins_temple_projection.nmg",

"spaceship/spaceship.nmg",
"spaceship/spaceshipe_lightmesh.nmg",

"Libraries/Astrofra - Ancient World Kit/greece_column.nmg",
"Libraries/Astrofra - Ancient World Kit/greece_column_broken_0.nmg",

"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_bar_0.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_bar_1.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_bar_2.nmg",

"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_broken_2m_03.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_broken_2m_01.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_1m_01.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_1m_02.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_1m_03.nmg",
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_broken_1m_01.nmg"
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_broken_1m_02.nmg"
"Libraries/Astrofra - Urban Ruins Kit/Meshes/post_nuke_cube_broken_1m_03.nmg"

"assets/arrow.nmg",                              
"assets/blur_screen.nmg",                        
"assets/creature_ringlet.nmg",                   
"assets/cristal_transparent_large.nmg",          
"assets/cristal_transparent_med.nmg",            
"assets/cristal_transparent_small.nmg",          
"assets/dummy.nmg",                              
"assets/dust_particle.nmg",                      
"assets/dust_particle_sharp.nmg",                
"assets/electron.nmg",                           
"assets/eryx_hand.nmg",                          
"assets/eryx_hand_projector.nmg",                
"assets/eryx_machine.nmg",                       
"assets/eryx_machine_projector.nmg",             
"assets/gate_iris_00.nmg",                       
"assets/gate_iris_01.nmg",                       
"assets/gate_iris_02.nmg",                       
"assets/gate_iris_03.nmg",                       
"assets/gate_iris_04.nmg",                       
"assets/gate_iris_05.nmg",                       
"assets/gate_iris_06.nmg",                       
"assets/gate_iris_07.nmg",                       
"assets/gate_iris_concrete.nmg",                 
"assets/gate_linear_gradient.nmg",               
"assets/light.nmg",                              
"assets/mainframe.nmg",                          
"assets/nerv_net.nmg",                           
"assets/particle_merge.nmg",                     
"assets/particle_sharp_merge.nmg",               
"assets/plant_branch_chrome.nmg",                
"assets/plant_branch_chrome_lod.nmg",            
"assets/plant_branch_chrome_long.nmg",           
"assets/plant_branch_chrome_long_lod.nmg",       
"assets/plant_branch_original.nmg",              
"assets/plant_branch_short_chrome.nmg",          
"assets/plant_branch_short_chrome_lod.nmg",      
"assets/plant_branch_smoke.nmg",                 
"assets/plant_branch_wood.nmg",                  
"assets/plant_branch_wood_faceted.nmg",          
"assets/plant_branch_wood_lod.nmg",              
"assets/plant_branch_wood_lod2.nmg",             
"assets/rtt_screen.nmg",                         
"assets/scaphander_calf_L.nmg",                  
"assets/scaphander_calf_R.nmg",                  
"assets/scaphander_forearm_L.nmg",               
"assets/scaphander_forearm_R.nmg",               
"assets/scaphander_head.nmg",                    
"assets/scaphander_pelvis.nmg",                  
"assets/scaphander_thigh_L.nmg",                 
"assets/scaphander_thigh_R.nmg",                 
"assets/scaphander_torso.nmg",                   
"assets/scaphander_upperarm_L.nmg",              
"assets/scaphander_upperarm_R.nmg",              
"assets/smoke_plane.nmg",                        
"assets/strangelet_creature_01_body.nmg",        
"assets/strangelet_creature_01_flagellum.nmg",   
"assets/strangelet_creature_01_head.nmg",        
"assets/vignette.nmg",                           
"assets/wall_basic_10m.nmg",                     
"assets/wall_basic_10m_lod1.nmg",                
"assets/wall_basic_10m_lod2.nmg",                
"assets/wall_flat_10m.nmg",                      
"assets/wall_shadow_caster_only.nmg",            
	]

	current_object		=	0
	progress			=	0
	preloading			=	true
	ui					=	0
	bar					=	0

	toggle				=	false

//object_list = []

	function	OnSetup(scene)
	{
		print("Preload::OnSetup()")
		current_object	=	0
		ui	=	SceneGetUI(scene)
		
		local	_preloader_back_texture, _preloader_bar_texture, _w, _h
//		_preloader_back_texture = EngineLoadTexture(g_engine, "ui/loader_back.png")
		_preloader_bar_texture = EngineLoadTexture(g_engine, "ui/loader_bar.png")

		_w = 480
		_h = 4

		local	_back = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5, _w, _h)
		SpriteSetScale(_back, 1.0, 1.0)
		SpriteSetOpacity(_back, 0.45)

		bar = UIAddSprite(ui, -1, _preloader_bar_texture, (1280 - _w) * 0.5, (960 - _h) * 0.5, _w, _h)
		SpriteSetScale(bar, 1.0, 0.5)

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

			object_list.append(_mesh_name)
		}
	}

	function	OnUpdate(scene)
	{
		if (object_list.len() > 0)
			progress	=	(((object_list.len() - current_object) * 100.0) / object_list.len()).tointeger()

		progress = Clamp(100 - progress, 0.0, 100)
		//progress = (Pow(progress / 100.0, 2.0) * 100.0).tointeger()

		WindowSetScale(bar, Clamp((progress / 100.0), 0.01, 1.0), 1.0)

		print("Preload::OnUpdate() progress = " + progress)

		toggle != toggle

		if (toggle)
			return

		if (preloading && UIIsCommandListDone(ui))
		{
			if (current_object < object_list.len())
			{
				if (FileExists(object_list[current_object]))
				{
					if (object_list[current_object].find(".nmg") != null)
						ResourceFactoryLoadGeometry(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".png") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".jpg") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
					else
					if (object_list[current_object].find(".tga") != null)
						ResourceFactoryLoadTexture(g_factory, object_list[current_object])
				}
			}
			else
			{
				ProjectGetScriptInstance(g_project).LoadDemo()
//				UISetCommandList(SceneGetUI(scene), "globalfade 0,1;")
				preloading = false
			}

			current_object++
		}
	}

}
