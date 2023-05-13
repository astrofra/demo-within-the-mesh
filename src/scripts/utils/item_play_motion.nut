class	ItemPlayMotion
{
	scene			=	0
	motion			=	"Walk"
	loop_start		=	0.0
	loop_end		=	80.0

	function	OnSetupDone(item)
	{
return
		scene	= ItemGetScene(item)
		local	source = 0

		source = SceneSetMotion(scene, motion, 0.0)
//		source = GroupSetMotion(ItemGetSkinBoneItemsGroup(item), motion, 0.0)
		AnimationSourceGroupSetLoopMode(source, AnimationRepeat)
		AnimationSourceGroupSetClockScale(source, 0.75)
//		AnimationSourceGroupSetLoop(source, loop_start, loop_end)
	}
}
