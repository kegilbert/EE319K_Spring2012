// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: lflare.wdl
//		WDL code for lens flare and lighting effects
////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////

var flare_trace_mode; // used to trace to the sun

var qLensFlare = -1;	// -1 == not created
	 				    	// 0 == off
	 						// 1 == on
	  						// otherwise == turning off


string	str_skytex = "sky";	// if the first part of the texture scanned matches this, it is sky

// use the skill1 parameter to store a number in a sprite entity
// The pivot distance is the percent distance between the screen center
//(where pivot_dist = 0) and the sun (pivot_dist = 1).
define pivot_dist,skill1;

// this is the sun itself
entity flareSun_ent
{
	type = <flare2.pcx>; // uses a sprite
	view = CAMERA; 		// same camera parameters as the default view
	layer = -6; 			// displayed beneath other entity layers
	pivot_dist = 1;		// distance factor from 'pivot point', must be 1 for sun
	scale_x = 2;			// sun is two times as large as the flares
	scale_y = 2;
}

// The 8 lens flare entities
entity flare0_ent
{
	type = <flare0.pcx>;
	view = CAMERA;
	layer = -6;
	pivot_dist = 0.75;	// at distance 0 is the pivot point - the screen center
}
entity flare1_ent
{	// 7 lens reflections
	type = <flare1.pcx>;
	view = CAMERA;
	layer = -6;
	pivot_dist = 0.55;
}
entity flare2_ent
{
	type = <flare2.pcx>;
	view = CAMERA;
	layer = -6;
	pivot_dist = 0.35;
}

entity flare3_ent
{
	type = <flare3.pcx>;
	layer = -6;
	view = CAMERA;
	pivot_dist = 0.15;
	scale_x = 1.5;
	scale_y = 1.5;
}

entity flare4_ent
{
	type = <flare0.pcx>;
	layer = -6;
	view = CAMERA;
	pivot_dist = -0.25;
}

entity flare5_ent
{
	type = <flare1.pcx>;
	layer = -6;
	view = CAMERA;
	pivot_dist = -0.45;
}

entity flare6_ent
{
	type = <flare2.pcx>;
	layer = -6;
	view = CAMERA;
	pivot_dist = -0.65;
}

entity flare7_ent
{
	type = <flare3.pcx>;
	layer = -6;
	view = CAMERA;
	pivot_dist = -0.85;
	scale_x = 1.5;
	scale_y = 1.5;
}


// Desc: this function takes an entity as parameter.
function flare_init(flare_ent)
{
	my = flare_ent;	// necessary because function parameters have no type
	my.visible = off;	// start with flares off
	if (video_depth > 8) 	// D3D mode?
	{
		ent_alphaset(0,10);	// create an alpha channel (won't work with standard edition)
		my.bright = on;
		my.flare = on;
	}
	else
	{
		my.transparent = on;	// looks lousy in 8 bit, though
	}
}


// Desc: places a flare at temp.x/temp.y deviations from screen center
function flare_place(flare_ent)
{
	my = flare_ent;
	my.visible = on;

	// multiply the pixel deviation with the pivot factor,
	// and add the screen center
	my.x = temp.x*my.pivot_dist + 0.5*screen_size.x;
	my.y = temp.y*my.pivot_dist + 0.5*screen_size.y;
	my.z = 750;	// screen distance, determines the size of the flare
	rel_for_screen(my.x,camera);
}


// Desc: this function turns all the flareN_ent (and flareSun_ent) on or
// 	off depending on the value pass in 'on_off'.
//
function flare_visible(on_off)
{
	flareSun_ent.visible = on_off;

	flare0_ent.visible = on_off;
	flare1_ent.visible = on_off;
	flare2_ent.visible = on_off;
	flare3_ent.visible = on_off;
	flare4_ent.visible = on_off;
	flare5_ent.visible = on_off;
	flare6_ent.visible = on_off;
	flare7_ent.visible = on_off;
}



// Desc: setup the lens flare effect
function lensflare_create()
{
	// set alpha values for each entity
	flare_init(flare0_ent);
	flare_init(flare1_ent);
	flare_init(flare2_ent);
	flare_init(flare3_ent);
	flare_init(flare4_ent);
	flare_init(flare5_ent);
	flare_init(flare6_ent);
	flare_init(flare7_ent);

	flare_init(flareSun_ent);	// <<the sun flare

//  set the trace mode to be used to trace to the sun
	flare_trace_mode = IGNORE_PASSABLE + IGNORE_MODELS; //IGNORE_PASSABLE needed for tracing through the sky box)

	qLensFlare = 0;	// start 'off'
}


// Desc: start and animate a lens flare effect as long as qLensFlare == 1
//
function	lensflare_start()
{

	if(qLensFlare == -1) // create the lens flares
	{
		lensflare_create();
	}

	if(qLensFlare == 1)  // lens flare already started
	{
		return;
	}

	// allow for setup time for "lensflare_create"
	//(if it was called right before this function)
	wait(1);
	qLensFlare = 1;	// mark lens flare as on

	// place lens flares
	while(qLensFlare == 1)
	{
		wait(1);	// animate each cycle
		// Animate lens flare
		vec_set(temp,sun_pos);
		if(vec_to_screen(temp,camera) == 0)
		{
		// Outside of View cone... remove lens flares
			flare_visible(off);
		}
		else     // check for trace to sun
		{
		// trace to the 'sun'
			trace_mode = flare_trace_mode + scan_texture;   // ++ added scan_texture
		// check if line to sun is blocked
			if (trace(camera.x,sun_pos) != 0)
			{
				if( str_cmpni(tex_name,str_skytex) == 0) // object blocking us is not sky
				{
				// Something is blocking us.. hide lens flare
					flare_visible(off);
					continue;	// continue loop
				}
			}


			// temp now contains the sun XY screen position
			// subtract the screen center, needed for flare_place()
			temp.x -= 0.5 * screen_size.x;
			temp.y -= 0.5 * screen_size.y;
			flare_place(flareSun_ent);

			// place all flares according to deviation and their pivot distance
			flare_place(flare0_ent);
			flare_place(flare1_ent);
			flare_place(flare2_ent);
			flare_place(flare3_ent);
			flare_place(flare4_ent);
			flare_place(flare5_ent);
			flare_place(flare6_ent);
			flare_place(flare7_ent);
		}
	}

	// Remove lens flares
	flare_visible(off);
	qLensFlare = 0;     // mark lens flare as off
}

// Desc: stop the lens flare effect
function lensflare_stop()
{
	qLensFlare = .5;	// signal to stop
}