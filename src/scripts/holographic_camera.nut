/*
	File: scripts/holographic_camera.nut
	Author: Astrofra
*/

/*!
	@short	HolographicCamera
	@author	Astrofra
*/
class	HolographicCamera
{
	scene					=	0
	main_camera				=	0
	holo_camera				=	0
	holo_screen				=	0
	holo_material			=	0
	holo_triggers			=	0

	render_diff_texture		=	0
	render_mask_texture		=	0

	/*
		constructor()
	*/
	constructor()
	{
		print("HolographicCamera::constructor()")
		holo_triggers = []
	}

	function	Setup()
	{
		print("HolographicCamera::Setup()")

		local	screen_geo = ItemGetGeometry(holo_screen)
		holo_material = GeometryGetMaterialFromIndex(screen_geo, 0)
	//	holo_material = ResourceFactoryLoadMaterial(g_factory, "assets/rtt_screen.nmg")
		render_diff_texture = 	NewTexture()
		local	_res = RendererGetOutputDimensions(g_render)

		/*
			Patch when the demo is running inside GSedit.
			RendererGetOutputDimensions() returns (64, 64).
		*/
		if (_res.x < 128.0)	_res.x = 1280.0
		if (_res.y < 128.0)	_res.y = 720.0

		local	pic = NewPicture(_res.x, _res.y)
		TextureUpdate(render_diff_texture, pic)
		render_mask_texture = 	NewTexture()
		local	pic = NewPicture(_res.x, _res.y)
		TextureUpdate(render_mask_texture, pic)

		if (!ObjectIsValid(render_diff_texture))
			print("HolographicCamera::Setup() texture 'render_diff_texture' is not a valid object!")
		if (!ObjectIsValid(render_mask_texture))
			print("HolographicCamera::Setup() texture 'render_mask_texture' is not a valid object!")

		foreach(_item in SceneGetItemList(scene))
			if (ItemGetName(_item) != null && ItemGetName(_item).tolower().find("trigger_") != null)
				holo_triggers.append(ItemCastToTrigger(_item))

		HideScreen()

		SceneSetRenderless(scene, true)
	}

	function	SwitchOff()
	{
		SceneSetRenderless(scene, false)
	}

	function	HideScreen()
	{	
		//	SceneItemActivate(scene, holo_screen, false)	
	}

	function	ShowScreen()
	{	
		//	SceneItemActivate(scene, holo_screen, true)	
	}

	/*
		Update()
	*/
	function	Update()
	{
		if ((main_camera == 0) || (holo_camera == 0))
			return

		local	_enable_holo = false
		foreach(_trigger_item in holo_triggers)
			if (TriggerTestItem(_trigger_item, main_camera))
				_enable_holo = true

		if (_enable_holo)
			ShowScreen()
		else
			HideScreen()

		//	Set the position of the holographic camera
		local	_pos = ItemGetPosition(main_camera)
		local	_rot = ItemGetRotation(main_camera)

		ItemSetPosition(holo_camera, _pos + Vector(0, Mtr(-1500.0), 0))
		ItemSetRotation(holo_camera, _rot)

		//	Render to texture
		SceneRegisterAsPropertyCallback(scene, g_render)

		SceneSetFog(scene, false, Vector(0,0,0,1), 0, 0)

		// Switch to output texture and render.
		SceneSetCurrentCamera(scene, ItemCastToCamera(holo_camera))
		RendererSetViewItemAndApplyView(g_render, holo_camera)
		CameraSetClipping(ItemCastToCamera(holo_camera), Mtr(0.1), Mtr(100.0))
		
		ScenePushRenderable(scene, g_render)
	
		if (_enable_holo)
		{	
			//	Render the hologram diffuse
			RendererClearFrame(g_render, 0, 0, 0)
			
			local viewport = RendererGetOutputDimensions(g_render)
			RendererSetViewport(g_render, 0.0, 0.0, TextureGetWidth(render_diff_texture).tofloat()/viewport.x.tofloat(), TextureGetHeight(render_diff_texture).tofloat()/viewport.y.tofloat())
			RendererRenderQueue(g_render)
			
			RendererGrabDisplayToTexture(g_render, render_diff_texture)
			MaterialSetTexture(holo_material, 1, render_diff_texture)
			
			RendererClearClippingPlane(g_render)
			RendererClearFrame(g_render, 0, 0, 0)

/*	
			//	Render the mask
			SceneSetFog(scene, true, Vector(1,1,1,1), 0.1, 0.2)
	
			RendererClearFrame(g_render, 0, 0, 0)
			
			local viewport = RendererGetOutputDimensions(g_render)
			RendererSetViewport(g_render, 0.0, 0.0, TextureGetWidth(render_mask_texture).tofloat()/viewport.x.tofloat(), TextureGetHeight(render_mask_texture).tofloat()/viewport.y.tofloat())
			
			RendererRenderQueue(g_render)
			
			RendererGrabDisplayToTexture(g_render, render_mask_texture)
			MaterialSetTexture(holo_material, 2, render_mask_texture)
*/
		}

		RendererClearClippingPlane(g_render)
		RendererClearFrame(g_render, 0, 0, 0)

		
		// Restore camera, output buffer and viewport.
		SceneGetScriptInstance(scene).ApplyFogChange(scene)
		SceneSetCurrentCamera(scene, ItemCastToCamera(main_camera))
		RendererSetViewItemAndApplyView(g_render, main_camera)
		
		RendererSetViewport(g_render, 0.0, 0.0, 1.0, 1.0)
		
		RendererRenderQueue(g_render)
		RendererRenderQueueReset(g_render)
	}
}
