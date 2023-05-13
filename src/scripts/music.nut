/*
	File: scripts/music.nut
	Author: Astrofra
*/

/*!
	@short	MusicSynchro
	@author	Astrofra
*/
class	MusicSynchro
{

	table_reference		=	0
	table_length		=	0

	constructor(table_name)
	{
		table_reference = getroottable()[table_name]
		table_length = table_reference.len()
	}

	function	GetSynchroValueFromTime(_normalized_clock = 0.0)
	{
		local	_idx = Clamp((_normalized_clock * table_length), 0.0, table_length - 1.0).tointeger()
		return table_reference[_idx]
	}

}