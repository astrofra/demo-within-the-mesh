/*
	File: scripts/scene_ride.nut
	Author: Astrofra
*/

Include("scripts/base_scene.nut")
Include("scripts/utils/utils.nut")
Include("scripts/utils/block_activator.nut")
Include("scripts/intro_handler.nut")
Include("scripts/camera_ride.nut")

g_normalized_clock	<-	0.0

/*!
	@short	SceneRide
	@author	Astrofra
*/
class	SceneManager	extends	BaseScene
{
	camera_ride_handler		=	0
	holocam_handler			=	0
	activation_handler		=	0
	intro_handler			=	0

	ui_layer				=	0

	ride_item_list			=	0
	intro_item_list			=	0

	fog						=	0

	intro_filename			=	"scenes/space_view.nms"
	logo_filename			=	"scenes/mandarine_logo.nms"

	/*
		@short	OnSetup
		@desc	Stores the items of the main "ride" scene
				and loads the data of the introduction
	*/
	function	OnSetup(scene)
	{
		if ("OnSetup" in base)	base.OnSetup(scene)

		StoreFogSettings(scene)

		activation_handler = ItemActivation(scene)
		activation_handler.Load()

		camera_ride_handler = CameraRideHandler(scene)
		camera_ride_handler.Setup()

		intro_handler = IntroHandler(scene)
		intro_handler.Load(intro_filename)
		intro_handler.Load(logo_filename, "logo")
		intro_item_list = intro_handler.Setup()
	}

	/*
		@short	SetupHolographicRender
		@desc	Setup of the "render to texture" system
				used to render the holograms
	*/
	function	SetupHolographicRender(scene)
	{
		holocam_handler = HolographicCamera()
		holocam_handler.scene = scene
		holocam_handler.main_camera = SceneFindItem(scene, "render_camera")
		holocam_handler.holo_camera = SceneFindItem(scene, "rtt_camera")
		holocam_handler.holo_screen = SceneFindItem(scene, "rtt_screen")
	}

	/*
		@short	OnSetupDone
		@desc	Activated the "intro" items,
				disable the "ride" items.
	*/
	function	OnSetupDone(scene)
	{
		print("SceneManager::OnSetupDone(" + scene + ")")
		camera_ride_handler.SetupDone()

		ride_item_list = SceneGetItemList(scene)
		ItemListActivate(scene, ride_item_list, false)
		ItemListActivate(scene, intro_item_list, true)

		print("(SceneManager) dispatch = 'CheckDtFrameStability'")

		dispatch = CheckDtFrameStability
		dispatch_next = StartIntro
	}

	/*
		@short	OnUpdate
		@desc	Master update that will dispatch to specific "update" functions,
				according to the current part of the demo.
	*/
	function	OnUpdate(scene)
	{
		if ("OnUpdate" in base)	base.OnUpdate(scene)

		if (dispatch != 0)
			dispatch(scene)
	}

	function	StartIntro(scene)
	{
		UISetCommandList(SceneGetUI(scene), "globalfade 0,1;globalfade 0.25,0;")
		SceneSetAmbientColor(scene, Vector(73.0, 79.0, 105.0).Scale(1.0 / 255.0))
		SceneSetAmbientIntensity(scene, 0.75)
		intro_handler.init_clock_value = g_clock
		intro_handler.SetLogoCamera()
		dispatch = UpdateIntro
	}

	function	UpdateIntro(scene)
	{
		if (intro_handler != 0)
		{
			intro_handler.Update()
			if (intro_handler.IsDone())
				dispatch = SwitchToRide
		}
	}

	function	SwitchToRide(scene)
	{
		intro_handler.title_handler.TurnOffTitles()
		RestoreFogSettings(scene)
		activation_handler.Setup()
		ItemListActivate(scene, ride_item_list, true)
		ItemListActivate(scene, intro_item_list, false)
		intro_handler.DeleteLogo()
		SceneSetCurrentCamera(scene, ItemCastToCamera(SceneFindItem(scene, "render_camera")))

		SetupHolographicRender(scene)
		holocam_handler.Setup()

		camera_ride_handler.dispatch = camera_ride_handler.StartDemo

		ui_layer = UIDemo()
		UISetCommandList(SceneGetUI(scene), "globalfade 0,1;globalfade 0.5,0;")

		dispatch = UpdateDemo
	}

	function	UpdateDemo(scene)
	{
		camera_ride_handler.Update()

		if (activation_handler != 0)
			activation_handler.Update()

		if (holocam_handler != 0)
			holocam_handler.Update()
		else
			ApplyFogChange(scene)

		if (camera_ride_handler.IsDone())
			dispatch = SwitchToOutro
	}

	function	SwitchToOutro(scene)
	{
		if (holocam_handler != 0)
			holocam_handler.SwitchOff()

		if (ui_layer != 0)
			ui_layer.SwitchOff()

		ItemListActivate(scene, ride_item_list, false)
		ItemListActivate(scene, intro_item_list, true)
		SceneSetCurrentCamera(scene, ItemCastToCamera(SceneFindItem(scene, "intro_render_camera_outtro")))
		SceneSetFog(scene, false, Vector(0,0,0), 0, 0)
		local	planet_item = ItemSetSelfIllumFloat(SceneFindItem(scene, "planet"), 0.0)

		UISetCommandList(SceneGetUI(scene), "globalfade 0,1;globalfade 1.0,0;")

		dispatch = WaitTilOutroFadeInIsDone
	}

	function	WaitTilOutroFadeInIsDone(scene)
	{
		if (UIIsCommandListDone(SceneGetUI(scene)))
		{
			UISetCommandList(SceneGetUI(scene), "nop 4.0;globalfade 2.0,1;nop 0.5;")
			dispatch = UpdateOutro
		}
	}

	function	UpdateOutro(scene)
	{
		if (UIIsCommandListDone(SceneGetUI(scene)))
		{
			dispatch = 0
			ProjectEnd(g_project)
		}
	}

	//	-----------------------------
	//	Internals	-----------------
	//	-----------------------------
	function	ApplyFogChange(scene)
	{
		SceneSetFog(scene, true, fog.target_color, fog.target_near, fog.target_far)
	}

	function	ItemListActivate(scene, _list, _flag)
	{
		if (_list == 0)
			return

		foreach(_item in _list)
			if (ObjectIsValid(_item) && _item != NullItem)
				SceneItemActivateHierarchy(scene, _item, _flag)
	}

	function	StoreFogSettings(scene)
	{
		fog = {near = 0, far = 0, color = 0, target_near = 0, target_far = 0, target_color = 0}

		fog.near = SceneGetFogNear(scene)
		fog.far = SceneGetFogFar(scene)
		fog.color = SceneGetFogColor(scene)

		fog.target_near = 0.0
		fog.target_far = 0.0
		fog.target_color = Vector(0,0,0)

		SceneSetFog(scene, false, Vector(0,0,0), 0, 0)
	}

	function	RestoreFogSettings(scene)
	{
		fog.target_near = fog.near
		fog.target_far = fog.far
		fog.target_color = clone(fog.color)
	}
}
