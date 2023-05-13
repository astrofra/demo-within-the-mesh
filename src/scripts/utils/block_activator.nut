/*
	File: scripts/situations/blocks_activator.nut
	Author: Movida Production
*/

g_block_autoactivation	<- true

/*!
	@short	SituationScript (block_activator)
	@author	Movida Production
*/

class	ItemActivation
{
	distance_threshold				= Mtr(250.0)
	distance_ahead					= Mtr(0.0)
	behind_cutoff					= Mtr(100.0)
	item_array						= 0
	current_camera					= 0
	current_scene					= 0
	prev_camera_pos					= 0

	lod_bias						= Mtr(0.0)

	cam_change_dist_threshold		=	Mtr(150.0)
	timeout_camera_change			= 0.0

	current_item_index				= 0
	item_per_pass					= 0

	prev_block_autoactivation		= false

	function	constructor(_scene)
	{	current_scene = _scene	}

	/*!
		@short	Load
		Called when the scene is about to be setup.
	*/
	function	Load()
	{
		prev_camera_pos = Vector()

		item_array = []
		local _item_count = 0

		/*
			Look into the scene's items list,
			Search for "Blocks" items
			Store them in an array, along with their "size" (square of the size) and "activation" attributes.
			If "Blocks" belongs to the "Highway", double the "size" attribute.
		*/
		local	_list = SceneGetItemList(g_scene)

		foreach(_root_item in _list)
		{
			local _root_item_name = ItemGetName(_root_item)
			if (_root_item_name != null && _root_item_name.find("Instance ") != null)
			{
				local _sublist = ItemGetChildList(_root_item)

				if (_sublist.len() > 0)
				{
					foreach(_item in _sublist)
					{
						if (_item != null && ItemGetName(_item) != null)
						{
							local	_bbox = ItemGetMinMax(_item)
							local	_item_scale = ItemGetScale(_item)
							//	Compute a "size" factor of the item, based on the square of the length() of the diagonal of its bounding box
							//	multiplied by the average scale applied to item
							local	_bbox_diagonal_size
							_bbox_diagonal_size = Max(_bbox.max.x - _bbox.min.x, _bbox.max.y - _bbox.min.y)
							_bbox_diagonal_size = Max(_bbox_diagonal_size, _bbox.max.z - _bbox.min.z)
							_bbox_diagonal_size *= (_item_scale.x + _item_scale.y + _item_scale.z) * 0.3333
							_bbox_diagonal_size = Pow(_bbox_diagonal_size, 2.0)
							_bbox_diagonal_size = Clamp(_bbox_diagonal_size, 0.0, Mtr(1000.0))
							_bbox_diagonal_size = 0.0

							local	_name = ItemGetName(_item).tolower()

							if (//(_bbox_diagonal_size > Mtr(0.0)) &&
								(_name.find("nolod") == null)
							)
							{
								_item_count++
								item_array.append({	item = _item, 
													active = true, 
													size = _bbox_diagonal_size,
													lod_factor = 1.0, 
													position = ItemGetWorldPosition(_item) * Vector(1.0,0,1.0),
													has_children = (ItemGetChildList(_item).len() > 0?true:false)
												})
							}
						}
					}
				}
			}
		}

		print("SituationScript::Setup() (block_activator), found " + _item_count + " items out of " + SceneGetItemList(g_scene).len() + " items total.")
	}

	/*!
		@short	Setup
		Called when the scene is about to be setup.
	*/
	function	Setup()
	{
		current_camera = SceneFindItem(current_scene, "render_camera")
		ActivateAllItems()

		item_per_pass = item_array.len() / 100
	}

	function	ActivateAllItems()
	{
		foreach(_item in item_array)
		{
			if (_item.has_children)
				SceneItemActivateHierarchy(current_scene, _item.item, true)
			else
				SceneItemActivate(current_scene, _item.item, true)
			_item.active = true
		}
	}

	function	AjustOptimizationParameters()
	{
		local	keyboard_handle_device = GetKeyboardDevice()

		//	shortcut to ajust the activation distance
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyUpArrow))
		{
			distance_threshold += Mtr(50)
			print("distance_threshold = " + distance_threshold)
		}
		else
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyDownArrow))
		{
			distance_threshold -= Mtr(50)
			print("distance_threshold = " + distance_threshold)
		}

		//	shortcut to ajust the LOD level
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyRightArrow))
		{
			lod_bias += Mtr(50)
			ObjectSetLODBias(lod_bias)
			print("lod_bias = " + lod_bias)

		}
		else
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyLeftArrow))
		{
			lod_bias -= Mtr(50)
			ObjectSetLODBias(lod_bias)
			print("lod_bias = " + lod_bias)
		}

		if (g_block_autoactivation != prev_block_autoactivation)
		{
			print("g_block_autoactivation = " + g_block_autoactivation)
			g_SituationManager.CallSituationFunction("notification_center", "Notify", {_str = ("Optimisation de l'affichage : " + (g_block_autoactivation?"activée":"désactivée")), _emitter_key = "notification_center"})

			if (!g_block_autoactivation)
				ActivateAllItems()
		}

		//	Shortcut to adjust distance_ahead		
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyK))
		{
			distance_ahead += Mtr(50)
			print("distance_ahead = " + distance_ahead)

		}
		else
		if(KeyboardCtrlShortcut(keyboard_handle_device, KeyJ))
		{
			distance_ahead -= Mtr(50)
			print("distance_ahead = " + distance_ahead)
		}
	}

	/*!
		@short	Update
		Called each frame.
	*/
	function	Update()
	{
		if( item_array.len() <= 0)  return

//		AjustOptimizationParameters()

		if (g_block_autoactivation != prev_block_autoactivation)
		{
			print("g_block_autoactivation = " + g_block_autoactivation)

			if (!g_block_autoactivation)
				ActivateAllItems()
		}

		prev_block_autoactivation = g_block_autoactivation 

		if (!g_block_autoactivation)
			return

		//	Based on camera speed
		local	_camera_pos = ItemGetWorldPosition(current_camera) + ItemGetMatrix(current_camera).GetFront().Normalize().Scale(distance_ahead)
		_camera_pos.y = 0.0

		local	_camera_velocity = prev_camera_pos.Dist(_camera_pos)
		prev_camera_pos = clone(_camera_pos)

//		if (_camera_velocity > cam_change_dist_threshold)
//		{
//			timeout_camera_change = Sec(1.0)
//			print("SituationScript::Update() Camera change detected!")
//		}

		if (EverySecond(Sec(0.15), this) || (timeout_camera_change <= 0.1))
		{
			local	n, _activated = 0, _deactivated = 0, _items_to_update
			_items_to_update = (timeout_camera_change > 0.0)?(item_per_pass * 100):item_per_pass

			for(n = 0; n < _items_to_update; n++)
			{
				current_item_index++
				if (current_item_index >= item_array.len())
					current_item_index = 0
				local	_item = item_array[current_item_index]
	
				//	If the item is within the "visibility range"
				if ((_camera_pos.z - behind_cutoff < _item.position.z) && (_item.position.Dist(_camera_pos) - _item.size < distance_threshold * _item.lod_factor))
				{
					//	Activate this item
					if (!_item.active)
					{
//						if (_item.has_children)
							SceneItemActivateHierarchy(current_scene, _item.item, true)
//						else
//							SceneItemActivate(current_scene, _item.item, true)

						ItemSleep(_item.item)
						_item.active = true
						_activated++
					}
				}
				else
				{
					//	Deactivate this item
					if (_item.active)
					{
//						if (_item.has_children)
							SceneItemActivateHierarchy(current_scene, _item.item, false)
//						else
//							SceneItemActivate(current_scene, _item.item, false)

						_item.active = false
						_deactivated++
					}
				}
			}
	
			timeout_camera_change = Max(timeout_camera_change - g_dt_frame, 0.0)
	
//			if (_deactivated > 1 || _activated > 1)
//				print("SituationScript::Update() (block_activator) _deactivated = " + _deactivated + ", _activated = " + _activated)

		}
	}
}
