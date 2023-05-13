/*
	File: scripts/ui_demo.nut
	Author: Astrofra
*/

/*!
	@short	UIDemo
	@author	Astrofra
*/
class	UIDemo
{
	scene				=	0
	ui					=	0
	sprite_master		=	0
	sprite_vignette		=	0

	function	SwitchOff()
	{
		SpriteSetOpacity(sprite_master, 0.0)
	}

	constructor(_scene = -1)
	{
		if (_scene == -1)
			scene = g_scene
		else
			scene = _scene

		ui = SceneGetUI(scene)

		local	_screen_res = Vector(1280, 960, 0)

		sprite_master = UIAddWindow(ui, -1, _screen_res.x * 0.5, _screen_res.y * 0.5, 0, 0)
		{

			sprite_vignette = UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/vignette_alpha.tga"), 0 , 0, 256, 256)
			SpriteSetPivot(sprite_vignette, 128, 128)
			SpriteSetParent(sprite_vignette, sprite_master)
			SpriteSetScale(sprite_vignette, (_screen_res.x / 256.0) * 1.75, _screen_res.y / 256.0)

			sprite_vignette = UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/vignette_alpha.tga"), 0 , 0, 256, 256)
			SpriteSetPivot(sprite_vignette, 128, 128)
			SpriteSetParent(sprite_vignette, sprite_master)
			SpriteSetScale(sprite_vignette, (_screen_res.x / 256.0) * 1.75, _screen_res.y / 256.0)
			SpriteSetPosition(sprite_vignette, _screen_res.x * 1.75, 0)

			sprite_vignette = UIAddSprite(ui, -1, ResourceFactoryLoadTexture(g_factory, "ui/vignette_alpha.tga"), 0 , 0, 256, 256)
			SpriteSetPivot(sprite_vignette, 128, 128)
			SpriteSetParent(sprite_vignette, sprite_master)
			SpriteSetScale(sprite_vignette, (_screen_res.x / 256.0) * 1.75, _screen_res.y / 256.0)
			SpriteSetPosition(sprite_vignette, _screen_res.x * -1.75, 0)
			
		}

		local	_frame = (1.0 / 30.0).tostring()

		local	_cmd = ""
		_cmd += "loop;"
		_cmd += "toalpha " + _frame + ",0.75;"
		_cmd += "toalpha " + _frame + ",0.725;"
		_cmd += "toalpha " + _frame + ",0.75;"
		_cmd += "toalpha " + _frame + ",0.8;"
		_cmd += "toalpha " + _frame + ",0.75;"
		_cmd += "toalpha " + _frame + ",0.8;"
		_cmd += "toalpha " + _frame + ",0.725;"
		_cmd += "toalpha " + _frame + ",0.75;"
		_cmd += "toalpha " + _frame + ",0.8;"
		_cmd += "toalpha " + _frame + ",0.725;"
		_cmd += "toalpha " + _frame + ",0.8;"
		_cmd += "toalpha " + _frame + ",0.7;"
		_cmd += "toalpha " + _frame + ",0.75;"
		_cmd += "next;"

		SpriteSetCommandList(sprite_master, _cmd)
	}
}