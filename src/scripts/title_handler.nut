/*
	File: scripts/title_handler.nut
	Author: Polymorf-Astrofra-Alkama
*/

/*!
	@short	TitleHandler
	@author	Polymorf-Astrofra-Alkama
*/
class	TitleHandler
{
	scene					=	0
	ui						=	0

	tex_title_mandarine		=	0
	tex_title_credits		=	0
	tex_title_document		=	0
	tex_title_main			=	0
	tex_black_block			=	0

	spr_title_mandarine		=	0
	spr_title_credits		=	0
	spr_title_document		=	0
	spr_title_main			=	0
	spr_black_screen		=	0

	item_title_main			=	0

	constructor(_scene)
	{
		scene = _scene
		print("TitleHandler::constructor(" + scene + ")")
	}

	function	Setup()
	{
		print("TitleHandler::Setup()")

		ui = SceneGetUI(scene)
		item_title_main = SceneFindItem(scene, "intro_blur_screen")

		Creates2DLayers()

		SetTitleSpriteOpacity("title_mandarine", 0.0)
		SetTitleSpriteOpacity("title_credits", 0.0)
		SetTitleSpriteOpacity("title_document", 0.0)
		SetTitleSpriteOpacity("title_main", 0.0)
		SetTitleSpriteOpacity("black_screen", 1.0)
		SetTitleItemOpacity("title_main", 1.0)
	}

	function	TurnOffTitles()
	{
		SetTitleSpriteOpacity("title_mandarine", 0.0)
		SetTitleSpriteOpacity("title_credits", 0.0)
		SetTitleSpriteOpacity("title_document", 0.0)
		SetTitleSpriteOpacity("title_main", 0.0)
		SetTitleSpriteOpacity("black_screen", 0.0)
		SetTitleItemOpacity("title_main", 0.0)
	}

	function	Creates2DLayers()
	{
		tex_title_mandarine = ResourceFactoryLoadTexture(g_factory, "ui/title_credits_mndrn.tga")
		tex_title_credits = ResourceFactoryLoadTexture(g_factory, "ui/title_credits.tga")
		tex_title_document = ResourceFactoryLoadTexture(g_factory, "ui/title_document.tga")
		tex_title_main = ResourceFactoryLoadTexture(g_factory, "ui/title_main.tga")
		tex_black_block	= ResourceFactoryLoadTexture(g_factory, "ui/black_block.png")

		local	spr = UIAddSprite(ui, -1, tex_black_block, 1280.0 * 0.5, 960.0 * 0.5, 380, 380)
		SpriteSetPivot(spr, 380 * 0.5, 380 * 0.5)
		SpriteSetScale(spr, 10.0, 5.0)
		spr_black_screen = spr

		spr_title_main = UIAddWindow(ui, -1, 0, 0, 0, 0)

		local	w = TextureGetWidth(tex_title_main),
				h = TextureGetHeight(tex_title_main)
		local	spr = UIAddSprite(ui, -1, tex_title_main, (1280.0 - w) * 0.5, (960.0 - h) * 0.5, w, h)
		SpriteSetParent(spr, spr_title_main)

		local	spr = UIAddSprite(ui, -1, tex_black_block, (1280.0 - w) * 0.5 - 380, (960.0 - h) * 0.5, 380, 380)
		SpriteSetParent(spr, spr_title_main)
		local	spr = UIAddSprite(ui, -1, tex_black_block, (1280.0 + w) * 0.5, (960.0 - h) * 0.5, 380, 380)
		SpriteSetParent(spr, spr_title_main)

		local	sx = (w + (380 * 2.0)) / 380.0
		local	spr = UIAddSprite(ui, -1, tex_black_block, (1280.0 - (sx * 380.0)) * 0.5, (960.0 - h) * 0.5 - 380, 380, 380)
		SpriteSetScale(spr, sx, 1.0)
		SpriteSetParent(spr, spr_title_main)
		
		local	spr = UIAddSprite(ui, -1, tex_black_block, (1280.0 - (sx * 380.0)) * 0.5, (960.0 - h) * 0.5 + 380, 380, 380)
		SpriteSetScale(spr, sx, 1.0)
		SpriteSetParent(spr, spr_title_main)

		sx = 960.0 / 380.0

		local	spr = UIAddSprite(ui, -1, tex_black_block, 1280.0 + 380, 0, 380, 380)
		SpriteSetScale(spr, sx, sx)
		SpriteSetParent(spr, spr_title_main)

		local	spr = UIAddSprite(ui, -1, tex_black_block, -1280.0 - 60.0, 0, 380, 380)
		SpriteSetScale(spr, sx, sx)
		SpriteSetParent(spr, spr_title_main)

		local	w = TextureGetWidth(tex_title_document),
				h = TextureGetHeight(tex_title_document)
		local	spr = UIAddSprite(ui, -1, tex_title_document, (1280.0 - w) * 0.5, (960.0 - h) * 0.75, w, h)
		spr_title_document = spr
		//	SpriteSetOpacity(spr, 1.0)

		local	w = TextureGetWidth(tex_title_mandarine),
				h = TextureGetHeight(tex_title_mandarine)
		local	spr = UIAddSprite(ui, -1, tex_title_mandarine, (1280.0 - w) * 0.5, (960.0 - h) * 0.5, w, h)
		spr_title_mandarine = spr

		local	w = TextureGetWidth(tex_title_credits),
				h = TextureGetHeight(tex_title_credits)
		local	spr = UIAddSprite(ui, -1, tex_title_credits, (1280.0 - w) * 0.5, (960.0 - h) * 0.5, w, h)
		spr_title_credits = spr
	}

	function	SetTitleSpriteOpacity(_key = "black_screen", _opacity = 1.0)
	{
		local	_spr_key = "spr_" + _key
		if (_spr_key in this)
			SpriteSetOpacity(this[_spr_key], Clamp(_opacity, 0.0, 1.0))
	}

	function	SetTitleItemOpacity(_key = "title_main", _opacity = 1.0)
	{
		local	_item_key = "item_" + _key
		if (_item_key in this)
		{
			ItemSetOpacityViaSelfIllum(this[_item_key], Clamp(_opacity, 0.0, 1.0))
			if (_opacity == 0.0)
				SceneItemActivateHierarchy(scene, this[_item_key], false)
			else
				SceneItemActivateHierarchy(scene, this[_item_key], true)
		}
	}
}
