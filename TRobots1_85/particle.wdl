// Template file v5.202 (02/20/02)
// TRobots particle script 1.62
// Jonathan Valvano 12/9/2006
////////////////////////////////////////////////////////////////////////
// File: particle.wdl
//		WDL prefabs for particle effects
////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////
//
/////////////////////////////////////////////////////////////////////////


// Some common definitions

// bitmap used for sparks
BMAP spark_map,<particleStar.pcx>;
// bitmap used for smoke
BMAP smoke_map, <blitz.pcx>;
BMAP darksmoke_map, <Blitzgrey.pcx>;

var scatter_color[3] = 250, 250, 250;
var scatter_range[3] = -100, -245, -245;
var scatter_lifetime	= 50;
var scatter_size = 250; 
var scatter_gravity = 0.25;
var scatter_spread = 6;
/////////////////////////////////////////////////////////////////////////
//SYNONYM scatter_map { TYPE BMAP; DEFAULT spark_map; }
bmap* scatter_map = spark_map;
var particle_pos[3];
var particle_speed[3];
var scatter_speed[3] = 0, 0, 0;

/////////////////////////////////////////////////////////////////////////
// The particle_fade action lets a particle fade away

var fade_lifetime	= 8;
var fade_color[3] = 255, 200, 0;
var fade_targetcolor[3] = 128, 128, 128;

function particle_fade()
{
	if(MY_AGE == 0)
	{	// just born?
		MY_SIZE = 100;
		MY_SPEED.X = RANDOM(2)-1;
		MY_SPEED.Y = RANDOM(2)-1;
		MY_SPEED.Z = RANDOM(2)-1;
		MY_COLOR.RED = fade_color.RED;
		MY_COLOR.GREEN = fade_color.GREEN;
		MY_COLOR.BLUE = fade_color.BLUE;
	}
	else
	{
		MY_COLOR.RED += (fade_targetcolor.RED - MY_COLOR.RED)*0.2;
		MY_COLOR.GREEN += (fade_targetcolor.GREEN - MY_COLOR.GREEN)*0.2;
		MY_COLOR.BLUE += (fade_targetcolor.BLUE - MY_COLOR.BLUE)*0.2;

		if(MY_AGE > fade_lifetime) { MY_ACTION = NULL; }
	}
}
/////////////////////////////////////////////////////////////////////////
// The particle_tumble action lets a particle tumble around
// for 0.5 seconds, then disappear.

var tumble_lifetime = 8;

function particle_tumble()
{
	if(MY_AGE == 0)
	{	// just born?
		MY_SPEED.X = RANDOM(0.3)-0.15;
		MY_SPEED.Y = RANDOM(0.3)-0.15;
		MY_SPEED.Z = RANDOM(0.3)-0.15;

		MY_SIZE = 30;
		MY_COLOR.RED = scatter_color.RED * 0.75;
		MY_COLOR.GREEN = scatter_color.GREEN * 0.3;
		MY_COLOR.BLUE = scatter_color.BLUE * 0.3;
	}
	if(MY_AGE > tumble_lifetime)
	{
		MY_ACTION = NULL;
	}
}

/////////////////////////////////////////////////////////////////////////
// The particle_scatter action will scatter particles in all directions,
// then let them fall to the ground.
//
function particle_scatter()
{
	// just born?
	if(MY_AGE == 0)
	{
		MY_SPEED.X = scatter_speed.X + RANDOM(scatter_spread) - (scatter_spread/2);
		MY_SPEED.Y = scatter_speed.Y + RANDOM(scatter_spread) - (scatter_spread/2);
		MY_SPEED.Z = scatter_speed.Z + RANDOM(scatter_spread) - (scatter_spread/2);

		MY_SIZE = scatter_size;
		MY_COLOR.RED = scatter_color.RED;
		MY_COLOR.GREEN = scatter_color.GREEN;
		MY_COLOR.BLUE = scatter_color.BLUE;
		MY_MAP = scatter_map;
		MY_FLARE = ON;
		return;
	}
	// Add gravity
	MY_SPEED.Z -= scatter_gravity;
	// Maybe add random term to age
	MY_AGE += RANDOM(0.05);

	if(MY_AGE >= scatter_lifetime)
	{
		MY_ACTION = NULL;
	}
}

// The same, but with a particle trace behind
function particle_traces()
{
	particle_scatter();
	// A particle itself may emit further particles
	emit(1,MY_POS,particle_tumble);
}

// The same, but with a color range
function particle_range()
{
	particle_scatter();

	if(MY_AGE > 0)
	{
		MY_COLOR.RED += scatter_range.RED*MY_AGE/scatter_lifetime;
		MY_COLOR.GREEN += scatter_range.GREEN*MY_AGE/scatter_lifetime;
		MY_COLOR.BLUE += scatter_range.BLUE*MY_AGE/scatter_lifetime;
	}
}

// The same, but emits a sphere, with color range
function particle_sphere()
{
	particle_scatter();
	if(MY_AGE == 0)
	{
		vec_normalize(MY_SPEED,scatter_spread);
	}
	else
	{
		MY_COLOR.RED += scatter_range.RED*MY_AGE/scatter_lifetime;
		MY_COLOR.GREEN += scatter_range.GREEN*MY_AGE/scatter_lifetime;
		MY_COLOR.BLUE += scatter_range.BLUE*MY_AGE/scatter_lifetime;
	}
}

// This action may be called to initalize the scattering
//
function scatter_init()
{
	vec_set(particle_pos,MY.X);
	vec_set(scatter_speed,NULLVECTOR); // no offset here!
}


/////////////////////////////////////////////////////////////////////////
// The particle_shot action lets a particle fly in shot_speed
// direction for 2 seconds, then disappear.

var shot_lifetime	= 32;
var shot_speed;

function particle_shot()
{
	if(MY_AGE == 0)
	{	// just born?
		MY_SPEED.X = shot_speed.X;
		MY_SPEED.Y = shot_speed.Y;
		MY_SPEED.Z = shot_speed.Z;
		MY_SIZE = 100;
		MY_COLOR.RED = 255;
		MY_COLOR.GREEN = 0;
		MY_COLOR.BLUE = 200;
	}
	if(MY_AGE > shot_lifetime)
	{
		MY_ACTION = NULL;
	}
}

/////////////////////////////////////////////////////////////////
var rain_mode = 0;
var rain_pos;
var rain_rate = 20;	// snowflakes per second
var rain_counter;

// start snowfall around the player
// original idea by Harald Schmidt
function snowfall()
{
	if(player == NULL) { return; }

	rain_mode = 1;
	while(rain_mode > 0)
	{
		// all snowflakes will start 50 quants above the player
		rain_pos.Z = player.Z + player.MAX_Z + 50;

		//	depending on the frame rate, create several snow flakes at the same time
		rain_counter = rain_rate * TIME;
		while(rain_counter > 0)
		{
			// place snowflake somewhere near the player
			rain_pos.X = player.X + RANDOM(500) - 250;
			rain_pos.Y = player.Y + RANDOM(500) - 250;
			// now create one flake (emit 1) at this position
			emit(1,rain_pos,particle_rain);
			rain_counter -= 1;
		}
		wait(1);
	}
}

function particle_rain()
{
// just born?
	if(MY_AGE == 0)
	{  // this simple snow should do nothing more than fall to earth
		MY_SPEED.X = 0;
		MY_SPEED.Y = 0;
		MY_SPEED.Z = -2; // experiment with this value

// Set the size and colour you want (or maybe a bitmap)
		MY_SIZE = 100;
		MY_COLOR.RED = 255;
		MY_COLOR.GREEN = 255;
		MY_COLOR.BLUE = 255;

//		my_map = spark_map;
//		my_transparent = on;
		return;
	}

// remove flake if below player's feet
 	if((player == NULL) || (MY_POS.Z < player.Z - 100))
	{
		MY_ACTION = NULL;
	}
}


// Desc: smoke particle
//      slowly raise (+Z) and drifts (+/- X & Y) while increasing size
//    	6/14/00 Doug Poston
//
function particle_smoke()
{
	// just born?
	if(MY_AGE == 0)
	{
		MY_SPEED.X = random(1)-0.5;	// -0.5 to +0.5
		MY_SPEED.Y = random(2)-1;     // -1 to +1
		MY_SPEED.Z = random(1)+1;     // +1 to +2

		MY_SIZE = random(25)+25; // 25 to 50 in size

		MY_MAP = smoke_map;
		MY_FLARE = ON;
		MY_COLOR.RED = 245;
		MY_COLOR.GREEN = 200;
		MY_COLOR.BLUE = 80;

		return;
	}

	// increase the size of the smoke particle (up to max)
	if(MY_SIZE < 800)
	{
 		MY_SIZE += (1000 - MY_SIZE)*0.1*TIME;
	}

	// Remove old particles
	if(MY_AGE >= 35)
	{
  		MY_ACTION = NULL;
	}
}
// Desc: smoke particle
//      slowly raise (+Z) and drifts (+/- X & Y) while increasing size
//    	6/14/00 Doug Poston
// 12/9/06 -JWV
function particle_darksmoke()
{
	// just born?
	if(MY_AGE == 0)
	{
		MY_SPEED.X = random(2)-1;	// -0.5 to +0.5
		MY_SPEED.Y = random(2)-1;     // -1 to +1
		MY_SPEED.Z = random(1)+1;     // +1 to +2

		MY_SIZE = random(10)+15; // 15 to 25 in size

		MY_MAP = darksmoke_map;
		MY_FLARE = ON;
		MY_COLOR.RED = 200;
		MY_COLOR.GREEN = 200;
		MY_COLOR.BLUE = 200;

		return;
	}


	// increase the size of the smoke particle (up to max)
	if(MY_SIZE < 1200)
	{
 		MY_SIZE += (2000 - MY_SIZE)*0.1*TIME;
	}

	// Remove old particles
	if(MY_AGE >= 25)
	{
  		MY_ACTION = NULL;
	}
}

////////////////////////////////////////////////////////////////////////

// Desc: particles that become transparent about halfway into their life
function particle_fadeout()
{
	if(MY_AGE == 0)
	{
		MY_SPEED.x = random(0.3)-0.15;  // -0.15 - +0.15
		MY_SPEED.y = random(0.3)-0.15;  // -0.15 - +0.15
		MY_SPEED.z = random(0.3)-0.15;  // -0.15 - +0.15

		MY_SIZE = 150;
		MY_COLOR.red = 150;
		MY_COLOR.green = 150;
		MY_COLOR.blue = 150;

		return;
	}

	MY_SIZE += 30 * TIME;
	if(MY_AGE > 2 + random(2)) { MY_TRANSPARENT = ON; }
	if(MY_AGE > 4 + random(2)) { MY_ACTION = NULL; }
}

var p2[3];	// array used in particle_line

// Desc: produce a vapor trail from p to p2; p and p2 are changed
function particle_line()
{
	vec_sub(p2,p);
	temp = vec_length(p2);
	p2.x = (p2.x * 16) / temp;
	p2.y = (p2.y * 16) / temp;
	p2.z = (p2.z * 16) / temp;

	while(temp > 0)
	{
		emit(1,p,particle_fadeout);
		vec_add(p,p2);
		temp -= 16;
	}
}


BMAP	gbrass_map, <gbrass.pcx>;    // gun 'brass'


// Desc: gun brass particle (ejected shell)
//			arc from gun
//
function particle_gunBrass()
{
	// just born?
	if(MY_AGE == 0)
	{
		MY_SPEED.X = random(6)-6;	// -3 to 3
		MY_SPEED.Y = random(6)-6;  // -3 to 3
		MY_SPEED.Z = random(3)+8;  // 8 to 11

		MY_SIZE = 150;
 		MY_MAP = gbrass_map;
 		MY_COLOR.RED = 245;
		MY_COLOR.GREEN = 200;
		MY_COLOR.BLUE = 80;

		return;
	}

	if(MY_SPEED.Z > -16)
	{
		MY_SPEED.Z -= 2 * TIME;
	}

	// Remove old particles
	if(MY_AGE >= 35)
	{
  		MY_ACTION = NULL;
	}
}