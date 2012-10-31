///////////////////////////////////////////////////////////////////////////////////
// TRobots main script 1.85
// Jonathan Valvano 4/24/2011
////////////////////////////////////////////////////////////////////////////
// Files to over-ride:
// * logodark.bmp - the engine logo, include your game title
// * horizon.pcx - A horizon map displayed over the sky and cloud maps
////////////////////////////////////////////////////////////////////////////
// The PATH keyword gives directories where game files can be found,
// relative to the level directory
path "C:\\Program Files\\GStudio6\\template";	// Path to WDL templates subdirectory

// Version 1.82, added 100 point bonus for fatal shot
//               added 100 point bonus for being alive at end of round
// Version 1.83 moved lifepacks
// Version 1.84 sort by score
// Version 1.85 sensor moves with Port P, not turret

////////////////////////////////////////////////////////////////////////////
// The INCLUDE keyword can be used to include further WDL files,
// like those in the TEMPLATE subdirectory, with prefabricated actions
include <movement.wdl>;
include <camera.wdl>;	// handle camera movement
//include <input.wdl>;    // handle user input (mouse, keyboard, joystick, ..)
include <messages.wdl>;
include <menu.wdl>;		// must be inserted before doors and weapons
include <particle.wdl>; // remove when you need no particles
//include <doors.wdl>;		// remove when you need no doors
//include <actors.wdl>;   // remove when you need no actors
//include <weapons.wdl>;  // remove when you need no weapons
//include <war.wdl>;      // remove when you need no fighting
//include <venture.wdl>;	// include when doing an adventure
include <lflare.wdl>;   // remove when you need no lens flares

////////////////////////////////////////////////////////////////////////////
// The engine starts in the resolution given by the follwing vars.
//var video_mode = 6;	 // screen size 640x480
//var video_mode = 7;	 // screen size 800x600
var video_mode = 8;	 // screen size 1024x768
var video_depth = 16; // 16-bit color D3D mode
//var video_screen = 2; // startsettings for window mode
var video_screen = 1; // startsettings for Fullscreen
/////////////////////////////////////////////////////////////////
// Strings and filenames
// change this string to your own starting mission message.
string mission_str = "Trobots v1.85 by Jonathan Valvano";
string level_str = <TRobots.WMB>; // give file names in angular brackets
sound wham = <wham.wav>;   // tank-tank collision
sound ahh = <ahh.wav>;     // tank-wall collision
define MAX_TANK=200;       // memory allocated for this many
define MAX_NUM=50;         // limited by scoreboard, you have to also check the ScoreBoard
var TheActive[MAX_TANK];   // true if this tank exists, false if it doesn't exist
var TheScore[MAX_TANK];    // tank score
var TheTurret[MAX_TANK];   // turret angle in degrees
var TheSensor[MAX_TANK];   // sensor angle in degrees
var StartX[MAX_TANK];      // starting X position
var StartY[MAX_TANK];      // starting Y position
var ExplicitStart[MAX_TANK];     // 1 for explicit start location, set by ini file, 0 means random start
var ExplicitStartX[MAX_TANK];    // Explicit starting X position, ADC units 0 to 1023
var ExplicitStartY[MAX_TANK];    // Explicit starting Y position, ADC units 0 to 1023
var ExplicitStartDir[MAX_TANK];  // Explicit starting direction, ADC units 0 to 1023
var ExplicitStartTurret[MAX_TANK];  // Explicit starting turret angle, ADC units 0 to 1023
var Last_X[MAX_TANK];      // used to back up after a collision
var Last_Y[MAX_TANK];      // used to back up after a collision
var Backward[MAX_TANK];    // 1 for backward, 0 for forward
var CenterPack[MAX_TANK];  // 0 for tank has captured this lifepack, 1 still available
var NWPack[MAX_TANK];      // 0 for tank has captured this lifepack, 1 still available
var NEPack[MAX_TANK];      // 0 for tank has captured this lifepack, 1 still available
var SWPack[MAX_TANK];      // 0 for tank has captured this lifepack, 1 still available
var SEPack[MAX_TANK];      // 0 for tank has captured this lifepack, 1 still available
//**************used to sort winners*************************
var TheScoreSorted[MAX_TANK];    // tank score
var TheTankSorted[MAX_TANK];     // the tank at that score
//***********************************************************
define PACK_SIZE 25;       // in ADC units, length of a half of a side of lifepack 
//define LIFE_PACK 707;      // map units position of 4 packs in a square around the center
define LifeupNWx 1500;     // map units position of NW pack, copy from the Properties in level editor 
define LifeupNWy 200;      // map units position of NW pack
define LifeupSWx -300;     // map units position of SW pack
define LifeupSWy -300;     // map units position of SW pack
define LifeupNEx -1600;    // map units position of NE pack
define LifeupNEy 1300;     // map units position of NE pack
define LifeupSEx 750;      // map units position of SE pack
define LifeupSEy -1300;    // map units position of SE pack

var NWPackX;               // X position of lifepack, in ADC units (0 to 1023)
var NWPackY;               // Y position of lifepack, in ADC units (0 to 1023)
var NEPackX;               // X position of lifepack, in ADC units (0 to 1023)
var NEPackY;               // Y position of lifepack, in ADC units (0 to 1023)
var SWPackX;               // X position of lifepack, in ADC units (0 to 1023)
var SWPackY;               // Y position of lifepack, in ADC units (0 to 1023)
var SEPackX;               // X position of lifepack, in ADC units (0 to 1023)
var SEPackY;               // Y position of lifepack, in ADC units (0 to 1023)
var bGameOver;             // true, then entities remove themselves
var TimeLimit;             // 6812 can run until this limit
var TheTime;					// game running time in ms, counts down
var NumberOfBattles;       // competition has multiple runs
var KillBonus;             // bonus points for killing an opponent
var LiveBonus;             // bonus points for staying alive for the entire battle
define TIME_STEP,40;       // 40us step
define MS_STEP,0.04;       // 0.04ms step
var BattleTime;            // length of a battle in ms
var NumberOfTanks;         // how many created
var RunNum;
var bLogFile;       			// true if results saved in logFile.txt file
var_nsave filehandle;
var MissileSpeed;          // 10 in original versions up to 1.4
var TheMinStepTime = 0;    // Smallest time in bus cycles allowed between stepper outputs
var TheBaudRate = 9600;    // default baud rate
var bWallBounce=1;       	// true if tanks bounce off wall
savedir "\\S19"; 
// ********from Trobot simulation to 6812 simulation
var Alive[MAX_TANK];       // true if alive
var Waiting[MAX_TANK];     // true if stalled on 
var TheX[MAX_TANK];        // ADC channel 0, X position
var TheY[MAX_TANK];        // ADC channel 1, Y position
var ThePan[MAX_TANK];      // ADC channel 2, tank orientation
var TheTurretV[MAX_TANK];  // ADC channel 3, turret angle in volts 0 to 1023
var TheLeft[MAX_TANK];     // ADC channel 4, range to closest tank on the left 
var TheFront[MAX_TANK];    // ADC channel 5, range to closest tank in center 
var TheRight[MAX_TANK];    // ADC channel 6, range to closest tank on the right 
var TheHealth[MAX_TANK];   // ADC channel 7, tank health 0 to 1023
//*******from 6812 simulation to Trobot simulation ***************
var TheResolution[MAX_TANK];    // PTM5-4, scanner resolution 0,1,2,3 
var TheTurretStepper[MAX_TANK]; // PTM3-0, stepper command for turret. E.g. -2,-1,0,1,2
var TheLeftStepper[MAX_TANK];   // PTT7-4, stepper command for left track. E.g. -2,-1,0,1,2
var TheRightStepper[MAX_TANK];  // PTT3-0, stepper command for right track. E.g. -2,-1,0,1,2
var TheDistance[MAX_TANK];      // SCI serial output, 0 to 255
var ThePC[MAX_TANK];            // 6812 program counter
var TheRegX[MAX_TANK];          // 6812 X register
var TheRegY[MAX_TANK];          // 6812 Y register
var TheRAM[MAX_TANK];           // 6812 16-bit contents of location $3800
var TheRAM2[MAX_TANK];          // 6812 16-bit contents of location $3802
var TheRAM3[MAX_TANK];          // 6812 16-bit contents of location $3804
var TheRAM4[MAX_TANK];          // 6812 16-bit contents of location $3806
var TheSensorAngle[MAX_TANK];   // sensor angle command from Port P, 0 to 255
var TheMotorSpeed[MAX_TANK];    // 1=fast mode, set by PM7

define USE_GRAVITY,1; // activate falling
define gravity,0.02;   // force of gravity
define shooter,skill38;
define tanknumber,skill39;  // starts with number 1000
// *********bounding box for camera**********
define FIELD_MINX,-1852;  // values taken from Level editor
define FIELD_MAXX,1852;   // assume the tower is at map (93,-93) (-93,-93) (-93,93) (93,93)
define FIELD_MINY,-1845;  
define FIELD_MAXY,1845;   
define FIELD_MINZ,30;       // -112;   
define FIELD_MAXZ,3000;     // made this number up
define UTTOWER_SIZE,160;    // used to prevent tanks from spawning inside tower
define MIN_START_DIST,300;  // how close can two tanks start from each other
// objects in the map
// UT tower map=(0,0)        ADC=(512,512)   all building about 50 ADC units square
// building map=(-1000,0)    ADC=(234,512)
// building map=(1000,0)     ADC=(789,512)
// building map=(0,1000)     ADC=(512,789)
// building map=(0,-1000)    ADC=(512,234)
// lifepack map=(-707,-707)  ADC=(315,315)  50 ADC units square or +/- 25
// lifepack map=(707,-707)   ADC=(706,315)
// lifepack map=(-707,707)   ADC=(315,706)
// lifepack map=(707,707)    ADC=(706,706)
// ******************************************
//define SCANNER_RANGE,2318;
define SCANNER_RANGE,920;      // 0 to 256 meters
define MAX_HEALTH,1023;        // full health
define HEALTH_50PERCENT,512;   // gain when capturing lifepack
define HEALTH_25PERCENT,256;   // gain when capturing lifepack
define HEALTH_10PERCENT,102;   // cost of software bug
define HEALTH_5PERCENT,51;     // cost of taking a near hit, direct cannon hit, or collision
// resolution= 0 is narrow resolution of 10 degrees
// ***********ScoreBoard configuration**********
var bTheX=1;       // true if ScoreBoard shows ADC channel 0, X position
var bTheY=1;       // true if ScoreBoard shows ADC channel 1, Y position
var bThePan=1;     // true if ScoreBoard shows ADC channel 2, tank orientation
var bTheTurretV=1; // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
var bTheLeft=1;    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
var bTheFront=1;   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
var bTheRight=1;   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
var bTheHealth=1;  // true if ScoreBoard shows ADC channel 7, tank health
var bThePC=1;      // true if ScoreBoard shows 6812 Program Counter
var bTheRegX=1;    // true if ScoreBoard shows 6812 Register X
var bTheRegY=1;    // true if ScoreBoard shows 6812 Register Y
var bTheRAM=1;     // true if ScoreBoard shows 6812 RAM location $3800
var bTheRAM2=1;    // true if ScoreBoard shows 6812 RAM location $3800
var bTheRAM3=1;    // true if ScoreBoard shows 6812 RAM location $3800
var bTheRAM4=1;    // true if ScoreBoard shows 6812 RAM location $3800
var bTheScore=1;   // true if ScoreBoard shows TheScore
var bBigFont=1;    // true if larger font, 0 if smaller font
var bPauseBetweenGames=1; // pause for input between games
var bStopWillPause=0;     // executing stop will pause for the PlayerTank
// *************camera parameters**************************
var PlayerTank = 0;   // tanknum to follow
var PanoramicCameraSpeed = 0.02;
var PanoramicCameraHeight = 2000;
var PanoramicCameraDirection = 1;
var PanoramicCameraPan = 0;
var PanoramicCameraDistance = 2000;
function UpdatePanorama();
// person_3rd camera function
//   5        automatic panoramic
//   4        disconnected from player, manual motion
//   2        orbit player
//   0        1st

// **************6812 simulation from DLL******************
// called first to initialize simulator
// establish pointer links to above [MAX_TANK] arrays
// returns zero if error
dllfunction Init6812();     

// Hardware reset of particular 6812
// returns zero if error
dllfunction Reset6812(tank);     

// Program ROM of particular 6812 at address with specified data
// returns zero if error
dllfunction ProgramMem6812(address,data,tank);

// Execute 6812 code until a particular event occurs
// returns the event causing execution to halt
dllfunction Run6812(tank,timelimit);     
// num  event
// >0   timelimit reached, returns
// -1    change tracks, TheLeftStepper, TheRightStepper changed
// -2    change turret, TheTurretStepper, TheResolution changed
// -3    fire rocket, TheDistance changed
// -4    breakpoint (if tank is ThePlayer)
// -10 and above are  6812 program error

// Specify the minimum time in us allowed between track stepper outputs
// 0 means you can move as fast as you want
// tank will throw a 43 error if the 6812 program tries to output faster
// returns zero if error
dllfunction SetMinStepTime(minTime);

// Sets the baud rate
// tank will throw a 41 error if the 6812 program tries to output at the incorrect rate
// returns zero if error
dllfunction SetBaudRate(baudrate);


// ***************Sky textures *******************************
// skycubes - by thomas oppl (thomas.oppl@inode.at)

define clip_distance,25000;

sky clouds
{
	type=<clouds.tga>;
	layer=1;
	scale_x=1;
	speed_u=8;
	speed_v=16;
	material=mat_sky;
	flags=dome,visible;
}

sky cube
{ 
	type=<skycube1.mdl>;
	layer=2;
	scale_x=clip_distance;
	scale_y=clip_distance;
	scale_z=clip_distance;
	material=mat_sky;
	flags=scene,visible;
}

DEFINE SCROLL_LINES,8;	// maximum 8;

TEXT scroll
{
	POS_X 800;
	POS_Y 4;
	FONT	msg_font;
	STRINGS 9;
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	STRING "                                                           ";
	INDEX SCROLL_LINES;
}

//string* scroll_string;

// Desc: scroll message upwards while adding a line
// Mod Date: 14/03/01 JCL - str parameter added
function scroll_message(str)
{
	if (str) {
		str_cpy(scroll.STRING[SCROLL_LINES],str);
	}
	if(bLogFile)
	{
		filehandle = file_open_append ("logFile.txt"); // opens the file logFile.txt to read 
		file_str_write (filehandle,str);
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_close (filehandle); 
	}
	snd_play(msg_sound,66,0);
	scroll.VISIBLE = ON;
	temp = 1;
	while(temp <= SCROLL_LINES)
	{
	// scroll upwards by copying each string to the previous one
		str_cpy(scroll.STRING[temp-1],scroll.STRING[temp]);
		temp += 1;
	}
	// clear the last string
	str_cpy(scroll.STRING[SCROLL_LINES],empty_str);
}


/////////////////////////////////////////////////////////////////
// define a splash screen with the required A4/A5 logo
bmap splashmap = <logodark.pcx>; // the default logo in templates
panel splashscreen {
	bmap = splashmap;
	flags = refresh,d3d;
}
var range = 0;
var damage = 0;
var fire_mode = 0;
var light_flash[3]  = 200, 150,  50;// { RED 200; GREEN 150; BLUE 50; }
SOUND explo_wham,<explo.wav>;
DEFINE hit_wham,explo_wham;
DEFINE _OFFS_X,SKILL1;
DEFINE _OFFS_Y,SKILL2;
DEFINE _OFFS_Z,SKILL3;
DEFINE _AMMOTYPE,SKILL4;
DEFINE _BULLETSPEED,SKILL5;
DEFINE _WEAPONNUMBER,SKILL6;
DEFINE _FIRETIME,SKILL7;
//SKILL8 = _FIREMODE from movement.wdl

DEFINE _GUN_SOURCE_X,SKILL11;
DEFINE _GUN_SOURCE_Y,SKILL12;
DEFINE _GUN_SOURCE_Z,SKILL13;


DEFINE _OFFS_FLASH,SKILL14;
DEFINE _RECOIL,SKILL15;
DEFINE _DAMAGE,SKILL16;
DEFINE _DISPLACEMENT,SKILL17;
DEFINE _FIRE,SKILL18;
//@ Input Defines
DEFINE _HANDLE,1;		// SCAN via space key
DEFINE _EXPLODE,2;	// SCAN by an explosion
DEFINE _GUNFIRE,3;	// SHOOT fired by a gun
DEFINE _WATCH,4;		// looking for an enemy
DEFINE _DETECTED,5;	// detected by an enemy
DEFINE _SHOOT1,6;		// shoot key pressed (not used yet)


//@ Input Vars
var indicator = 0;

////////////////////////////////////////////////////////////////////////////
// The following script controls the sky
//sky horizon_sky {
	//	// A backdrop texture's horizontal size must be a power of 2;
	//	// the vertical size does not matter
	//	scale_x = 0.2; // gives a field of 72 degrees (360 * 0.2 = 72)
	//	type = <horizon1.pcx>;
	//	tilt = -10;
	//	flags = scene,overlay,visible;
	//	layer = 3;
//}

// Desc: event attached to rocket
//			Explode the rocket.
//
//]- Mod Date: 6/13/00 Doug Poston
//]-				Created
//
// Mod Date: 6/07/02 DCP
//		Added wait before scan to avoid "dangerous instruction in event"
function _rocket_event()
{
	proc_kill(1);	//EXCLUSIVE_ENTITY;	// terminate other functions started by 'my' to stop moving
	MY.EVENT = NULL;
	MY.SKILL9 = -1;   // stop movement


	wait(1);	// to avoid dangerous instruction in event warning
	// Apply damage
	range = MY._DAMAGE * 6;
	damage = MY._DAMAGE;
 	temp.PAN = 360;
	temp.TILT = 360;
	temp.Z = range;	
		
	if(EVENT_TYPE== EVENT_ENTITY){
      indicator = _GUNFIRE;	// direct hit
	   c_scan(MY.POS,MY_ANGLE,temp,IGNORE_ME|SCAN_ENTS);
	}
	if(EVENT_TYPE== EVENT_BLOCK){
	   indicator = _EXPLODE;	// possible near hit
	   c_scan(MY.POS,MY_ANGLE,temp,IGNORE_ME|SCAN_ENTS);
	}

  	// Explode
	ent_morph (me,"explo+7.pcx");   //**morph**
	MY.AMBIENT = 100;
	MY.FACING = ON;
	MY.NEAR = ON;
  	MY.FLARE = ON;

	MY.PASSABLE =  ON;
	MY.AMBIENT = 100;
	MY.LIGHTRED = light_flash.RED;
	MY.LIGHTGREEN = light_flash.GREEN;
	MY.LIGHTBLUE = light_flash.BLUE;
	MY.LIGHTRANGE = 64;
	wait(1);

	ent_playsound ( ME,hit_wham,300);
	while(MY.CYCLE <= 7)
	{
		MY.CYCLE += TIME;
		waitt(1);
	}

	ent_remove(ME);
}
// Desc: event attached to rocket
//			Explode the rocket.
//
//]- Mod Date: 6/13/00 Doug Poston
//]-				Created
//
// Mod Date: 6/07/02 DCP
//		Added wait before scan to avoid "dangerous instruction in event"
// This function is called when a rocket hits an object, either a tank, the ground or a wall
function _TankRocket_event()
{
	proc_kill(1);	//EXCLUSIVE_ENTITY;	// terminate other functions started by 'my' to stop moving
	MY.EVENT = NULL;
	MY.SKILL9 = -1;   // stop movement


	wait(1);	// to avoid dangerous instruction in event warning
	// Apply damage
	range = MY._DAMAGE * 6;
	damage = MY._DAMAGE;
	temp.PAN = 360;

	temp.TILT = 360;
	temp.Z = range;	
	//	if(EVENT_TYPE == EVENT_ENTITY)
	//	{
		indicator = _GUNFIRE;	// direct hit
		c_scan(MY.POS,MY_ANGLE,temp,IGNORE_ME|SCAN_ENTS);
	//	}
	//	if(EVENT_TYPE == EVENT_BLOCK)
	//	{
		//		indicator = _EXPLODE;	// possible near hit
		//		scan(MY.POS,MY_ANGLE,temp);
	//	}

	// Explode
	ent_morph (me, "expl2+16.pcx");
	//	ent_morph (me, "explo+7.pcx");
	MY.AMBIENT = 100;
	MY.FACING = ON;
	MY.NEAR = ON;
	MY.FLARE = ON;

	MY.PASSABLE =  ON;
	MY.AMBIENT = 100;
	MY.LIGHTRED = light_flash.RED;
	MY.LIGHTGREEN = light_flash.GREEN;
	MY.LIGHTBLUE = light_flash.BLUE;
	MY.LIGHTRANGE = 64;
	wait(1);

	ent_playsound ( ME,hit_wham,300);
	while(MY.CYCLE <= 16)
	{
		MY.CYCLE += TIME;
		waitt(1);
	}

	ent_remove(ME);
}

// Desc: launch a tank rocket (models)
//
//]- Mod Date: 6/13/00 Doug Poston
//]-				Created
//]- Mod Date: 8/31/00 DCP
//]-				Scale rocket movement by movement_scale
//]-				Scale rocket size by actor_scale
//]-
//]- Mod:  04/18/01 DCP
//]-    	Use 'vec_to_angle' and shot_speed to determine rocket orientation
//
// Mod:  06/08/01 DCP
//			Replaced move() with ent_move()
function tank_launch()
{ 
	vec_scale(MY.SCALE_X,0.4);	// make a small fireball

	MY.ENABLE_BLOCK = ON;      // collision with map surface
	MY.ENABLE_ENTITY = ON;     // collision with entity
	MY.ENABLE_STUCK = ON;
	MY.ENABLE_IMPACT = ON;
	MY.ENABLE_PUSH = ON;
	MY.EVENT = _rocket_event;  // function to execute when rocket hits something

	MY.AMBIENT = 100;  // bright
	MY.LIGHTRANGE = 150;
	MY.LIGHTRED = 220;
	MY.LIGHTGREEN = 80;
	MY.LIGHTBLUE = 80;

	//- 	MY.PAN = YOUR.PAN; // the rocket start in the same direction than this 'emitter'
	//- 	MY.TILT = YOUR.TILT;
	//- 	MY.ROLL = YOUR.ROLL;
	vec_to_angle(MY.PAN, shot_speed);

	MY.SKILL2 = shot_speed.x;
	MY.SKILL3 = shot_speed.y;
	MY.SKILL4 = shot_speed.z;
	//	MY._DAMAGE = damage;
	MY._DAMAGE = 10;
	MY._FIREMODE = fire_mode;

	MY.SKILL9 = 2500; // 'burn time'  (fuel)
	while(MY.SKILL9 > 0)
	{
		if(bGameOver)
		{
			ent_remove(ME);
			return;

		}

		temp.X = MY.SKILL2 * TIME;
		temp.Y = MY.SKILL3 * TIME;
		temp.Z = MY.SKILL4 * TIME;
		MY.SKILL4 -= MissileSpeed*gravity*time;   // v(n)=v(n-1)-g*dt
		vec_scale(temp,movement_scale);	// scale distance by movement_scale
		//--		move(ME,NULLSKILL,temp);
		move_mode = ignore_you + ignore_passable + activate_trigger;
		result = ent_move(nullskill,temp);

		emit(3,MY.POS,particle_smoke);	// emit( smoke
		MY.SKILL9 -= TIME;  // burn fuel
		wait(1);     // update position once per tick
	}
	_TankRocket_event();   // explode when out of fuel
}

//************tankFire**************
// launch a fireball from my tank
// from the end of the turret in the direction of the cannon
// thedistance determines the firing range
function tankFire(){
	var shotStart[3];
	var tankNum;
	tankNum = my.tanknumber-1000;
	TheScore[tankNum] -= 1;  // cost of shooting
	shot_speed.X = MissileSpeed;       // rocket velocity
	shot_speed.Y = 0;
	shot_speed.Z = TheDistance[tankNum]/50;
	//	my_angle.PAN = my.PAN+TheTurret[tankNum]+180;
	my_angle.PAN = my.PAN+TheTurret[tankNum];
	vec_rotate(shot_speed,my_angle);
	damage = 10;
	fire_mode = 303.2; // orange fireball, with smoke
	shotStart.x = my.x+60*shot_speed.x/MissileSpeed; // start at end of gun barrel
	shotStart.y = my.y+60*shot_speed.y/MissileSpeed;
	shotStart.z = my.z+16;
	you = ent_CREATE("blitz.pcx",shotStart.x,tank_launch); //bullet_shot);
	you.shooter = tankNum+1000;
}
string subjectStr="Tank ";
string wallStr=" runs into the wall";
string killStr=" kills tank ";
string hitStr=" hits tank ";
string nearhitStr=" nearly hits tank ";
string crashStr=" crashes into tank ";
string dieStr=" watches from the side";
string captureStr=" captures a lifepack ";
string themsg="#50";
string Tank_str="#50";
string TankNum_str="#50";
// theTank goes from  0    1    2         103
// TankNum_str is   "A0" "B0" "C0", up to "Z3"
function SetTankStr(theTank){
	var num; 
	var letter;
	str_cpy(Tank_str," ");
	letter = 65+theTank%26; // A to Z
	str_for_asc(Tank_str,letter); // "A" to "Z"
	num = 0; 
	while((num+1)*26<=theTank)
	{
		num += 1;
	}
	str_for_num(TankNum_str,num);   // then do the number part
	str_cat(Tank_str,TankNum_str);  // "A0" "B0" "C0" etc
}
function tankfight_event() 
{ var who;
	var i;
	var tankNum;
	var previousHealth;
	tankNum = my.tanknumber-1000;

	//	if ((EVENT_TYPE == EVENT_SCAN) && (indicator == _EXPLODE))
	//	{
		//		my._HEALTH -= HEALTH_5PERCENT; 
		//		TheScore[tankNum] -=3;    // cost of explosion
		//		who = you.shooter-1000;
		//		if(who != tankNum)
		//		{
			//			TheScore[who] +=6;           // value of hitting another tank
		//		}
		//		TheHealth[tankNum]=max(0,my._HEALTH);    // life points
		//		SetTankStr(who);                  // which tank fired the missile
		//		str_cpy(themsg,subjectStr);       // "Tank "
		//		str_cat(themsg,Tank_str);         // "Tank you"
		//		str_cat(themsg,nearhitStr);       // "Tank you nearly hits tank "
		//		SetTankStr(tankNum);              // which tank did the missile hit
		//		str_cat(themsg,Tank_str);         // "Tank you nearly hits tank me"
		//		scroll_message(themsg);
		//
	//	}
	if ((EVENT_TYPE == EVENT_SCAN) && (indicator == _GUNFIRE))
	{
		previousHealth = my._HEALTH; // did this tank just die?
		my._HEALTH -= HEALTH_5PERCENT; 
		TheScore[tankNum] -=5;    // cost of explosion
		who = you.shooter-1000;
//		if(who == tankNum){
//		 breakpoint;	//
//		}
		if(who != tankNum)
		{
			TheScore[who] += 20;        // value of hitting another tank
		}
		TheHealth[tankNum]=max(0,my._HEALTH);  // life points
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(who);                // which tank fired the missile
		str_cat(themsg,Tank_str);       // "Tank you"
		if((previousHealth>0)&&(TheHealth[tankNum]==0)){
			str_cat(themsg,killStr);     // "Tank you kills tank "
			if(who != tankNum)
			{
				TheScore[who] += KillBonus;  // value of killing another tank
			}
		}
		else{
			str_cat(themsg,hitStr);      // "Tank you hits tank "
		}
		SetTankStr(tankNum);            // which tank did the missile hit
		str_cat(themsg,Tank_str);       // "Tank you hits tank me"
		scroll_message(themsg);

	}
	//  if ((EVENT_TYPE == EVENT_SHOOT) && (indicator == _GUNFIRE))
	//  {
		//  	breakpoint;
		//     my._HEALTH -= damage; 
	//  }
	if (EVENT_TYPE == EVENT_ENTITY) // collision with entity
	{
		who = you.tanknumber-1000;
		if((who != tankNum)&&(who>=0)&&(who<MAX_TANK)){
			ENT_playSOUND(MY,wham,50);
			//	breakpoint;
			my.x = Last_X[tankNum];
			my.y = Last_Y[tankNum];
			vec_to_angle (my.pan, bounce); // bounce direction
			if(Backward[tanknum])
			{
				my.pan += 180;                 // move away from bounce (old tank)
			}

			my._HEALTH -= HEALTH_5PERCENT;  // the one who bumps loses health
			TheScore[tankNum] -=5;          // cost running into another tank
			//	TheScore[who] -=5;              // both tanks lose 5 points
			SetMyTankStats();
			str_cpy(themsg,subjectStr);    // "Tank "
			SetTankStr(tankNum);           // which tank did the colliding
			str_cat(themsg,Tank_str);      // "Tank me"
			str_cat(themsg,crashStr);      // "Tank me crashes into tank "
			SetTankStr(who);               // tank into which this tank collided
			str_cat(themsg,Tank_str);      // "Tank me crashes into tank you"
			scroll_message(themsg);
		}

	}
	if (EVENT_TYPE == EVENT_BLOCK) // collision with wall
	{
		ENT_playSOUND(MY,ahh,50);
		//	breakpoint;
		my.x = Last_X[tankNum];   // move back away from wall
		my.y = Last_Y[tankNum];
// ************added a parameter to select bounce or no bounce off wall 8/3/08 
		if(bWallBounce){
			vec_to_angle (my.pan, bounce); // bounce direction
			if(Backward[tanknum])
			{
				my.pan += 180;              // move away from bounce (old tank)
			}
		}
//********************************************************************************
		my._HEALTH -= HEALTH_5PERCENT; 
		TheScore[tankNum] -=5;         // cost hitting the wall
		SetMyTankStats();
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(tankNum);            // which tank did the colliding
		str_cat(themsg,Tank_str);       // "Tank me"
		str_cat(themsg,wallStr);        // "Tank me runs into the wall"
		scroll_message(themsg);
	}
}
function tankstate_die() 
{
	str_cpy(themsg,subjectStr);     // "Tank "
	SetTankStr(my.tanknumber-1000); // which tank did the dieing
	str_cat(themsg,Tank_str);       // "Tank me"
	str_cat(themsg,dieStr);         // "Tank me watches from the side"
	scroll_message(themsg);
	my._ANIMDIST = 0; // reset entities' animation time to zero
	while (my._ANIMDIST < 100)
	{
		// ent_FRAME("death",my._ANIMDIST); // set the frame from the percentage
		my._ANIMDIST += 5.0 * TIME; // calculate next percentage for death in ~1.25 seconds
		wait(1);
	}
	my.enable_scan = OFF; // become insensible
	my.enable_shoot = OFF;
	my.event = NULL; // and don't react anymore
}
var from[10];
// ************parameters displayed on screen and sent to 6812 simulation************
function SetMyTankStats()
{
	var tankNum;
	tankNum = my.tanknumber-1000;
	TheX[tankNum] = 1023*((my.X-FIELD_MINX)/(FIELD_MAXX-FIELD_MINX));  // X position, in ADC units
	TheY[tankNum] = 1023*((my.Y-FIELD_MINY)/(FIELD_MAXY-FIELD_MINY));  // Y position, in ADC units
	//	TheX[tankNum] = my.X;  // X position, in map units
	//	TheY[tankNum] = my.Y;  // Y position, in map units
	if((TheX[tankNum]>(NEPackX-PACK_SIZE))&&(TheY[tankNum]>NEPackY-PACK_SIZE)&&
	   (TheX[tankNum]<(NEPackX+PACK_SIZE))&&(TheY[tankNum]<NEPackY+PACK_SIZE)&&NEPack[tankNum])
	{
		NEPack[tankNum] = 0; // used
		my._HEALTH = my._HEALTH+HEALTH_50PERCENT;
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(tankNum);            // which tank 
		str_cat(themsg,Tank_str);       // "Tank me"
		str_cat(themsg,captureStr);     // "Tank me captures lifepack"
		scroll_message(themsg);
	}
	if((TheX[tankNum]>(SWPackX-PACK_SIZE))&&(TheY[tankNum]>SWPackY-PACK_SIZE)&&
	   (TheX[tankNum]<(SWPackX+PACK_SIZE))&&(TheY[tankNum]<SWPackY+PACK_SIZE)&&SWPack[tankNum])
	{
		SWPack[tankNum] = 0; // used
		my._HEALTH = my._HEALTH+HEALTH_50PERCENT;
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(tankNum);            // which tank 
		str_cat(themsg,Tank_str);       // "Tank me"
		str_cat(themsg,captureStr);     // "Tank me captures lifepack"
		scroll_message(themsg);
	}
	if((TheX[tankNum]>(NWPackX-PACK_SIZE))&&(TheY[tankNum]>NWPackY-PACK_SIZE)&&
	   (TheX[tankNum]<(NWPackX+PACK_SIZE))&&(TheY[tankNum]<NWPackY+PACK_SIZE)&&NWPack[tankNum])
	{
		NWPack[tankNum] = 0; // used
		my._HEALTH = my._HEALTH+HEALTH_50PERCENT;
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(tankNum);            // which tank 
		str_cat(themsg,Tank_str);       // "Tank me"
		str_cat(themsg,captureStr);     // "Tank me captures lifepack"
		scroll_message(themsg);
	}
	if((TheX[tankNum]>(SEPackX-PACK_SIZE))&&(TheY[tankNum]>SEPackY-PACK_SIZE)&&
	   (TheX[tankNum]<(SEPackX+PACK_SIZE))&&(TheY[tankNum]<SEPackY+PACK_SIZE)&&SEPack[tankNum])
	{
		SEPack[tankNum] = 0; // used
		my._HEALTH = my._HEALTH+HEALTH_50PERCENT;
		str_cpy(themsg,subjectStr);     // "Tank "
		SetTankStr(tankNum);            // which tank 
		str_cat(themsg,Tank_str);       // "Tank me"
		str_cat(themsg,captureStr);     // "Tank me captures lifepack"
		scroll_message(themsg);
	}
	if(my._HEALTH>MAX_HEALTH){  // cap health to 100%
		my._HEALTH = MAX_HEALTH;
	}
	ThePan[tankNum] = int((1024*(my.PAN%360)+180)/360);      // tank orientation, in ADC units
	if(ThePan[tankNum]>1023)
	{
		ThePan[tankNum] = 0;
	}
	TheHealth[tankNum] = max(0,my._HEALTH);         // life points, in ADC units
	TheHealth[tankNum] = min(1023,my._HEALTH);      // show as 1023
	TheTurretV[tankNum] = int((1024*TheTurret[tankNum]+180)/360);  // in ADC units
	if(TheTurretV[tankNum]>1023)
	{
		TheTurretV[tankNum] = 0;
	}
	// resolution= 0 is narrow resolution of 5 degrees
	indicator = NULL;
	from.x = my.x;  // first three are the start location of the scan
	from.y = my.y;
	from.z = my.z;
	if(TheResolution[tankNum]==0)   // PTM5,4 = 0,0
	{
		from[3] = my.PAN+TheSensor[tankNum];  // look in the direction of the sensor
		from[4] = 0;    // tilt search angle
		temp.pan = 5;   // 5 deg resolution
		temp.tilt = 10; // tilt resolution
		temp.z = SCANNER_RANGE;   // range
		TheFront[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]+5; // look left from the direction of the sensor
		TheLeft[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]-5; // look right from the direction of the sensor
		TheRight[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		if(TheFront[tankNum]<=0)
		{
			TheFront[tankNum] = 1023; // none
		}
		if(TheLeft[tankNum]<=0)
		{
			TheLeft[tankNum] = 1023; // none
		}
		if(TheRight[tankNum]<=0)
		{
			TheRight[tankNum] = 1023; // none
		}
		return;
	}
	if(TheResolution[tankNum]==1)   // PTM5,4 = 0,1
	{
		from[3] = my.PAN+TheSensor[tankNum];  // look in the direction of the sensor
		from[4] = 0;    // tilt search angle
		temp.pan = 10;  // 10 deg resolution
		temp.tilt = 10; // tilt resolution
		temp.z = SCANNER_RANGE;   // range
		TheFront[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]+10; // look left from the direction of the sensor
		TheLeft[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]-10; // look right from the direction of the sensor
		TheRight[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		if(TheFront[tankNum]<=0)
		{
			TheFront[tankNum] = 1023; // none
		}
		if(TheLeft[tankNum]<=0)
		{
			TheLeft[tankNum] = 1023; // none
		}
		if(TheRight[tankNum]<=0)
		{
			TheRight[tankNum] = 1023; // none
		}
		return;
	}
	if(TheResolution[tankNum]==2)   // PTM5,4 = 1,0
	{
		from[3] = my.PAN+TheSensor[tankNum];  // look in the direction of the sensor
		from[4] = 0;    // tilt search angle
		temp.pan = 30;  // 30 deg resolution
		temp.tilt = 10; // tilt resolution
		temp.z = SCANNER_RANGE;   // range
		TheFront[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]+30; // look left from the direction of the sensor
		TheLeft[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		from[3] = my.PAN+TheSensor[tankNum]-30; // look right from the direction of the sensor
		TheRight[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
		if(TheFront[tankNum]<=0)
		{
			TheFront[tankNum] = 1023; // none
		}
		if(TheLeft[tankNum]<=0)
		{
			TheLeft[tankNum] = 1023; // none
		}
		if(TheRight[tankNum]<=0)
		{
			TheRight[tankNum] = 1023; // none
		}
		return;
	}                                 // PTM5,4 = 1,1
	from[3] = my.PAN+TheSensor[tankNum];      // look in the direction of the sensor
	from[4] = 0;     // tilt search angle
	temp.pan = 120;  // 120 deg resolution
	temp.tilt = 10;  // tilt resolution
	temp.z = SCANNER_RANGE;   // range
	TheFront[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
	from[3] = my.PAN+TheSensor[tankNum]+120; // look left from the direction of the sensor
	TheLeft[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
	from[3] = my.PAN+TheSensor[tankNum]-120; // look right from the direction of the sensor
	TheRight[tankNum] = min(1023,(1023*scan_entity(from,temp))/SCANNER_RANGE);
	if(TheFront[tankNum]<=0)
	{
		TheFront[tankNum] = 1023; // none
	}
	if(TheLeft[tankNum]<=0)
	{
		TheLeft[tankNum] = 1023; // none
	}
	if(TheRight[tankNum]<=0)
	{
		TheRight[tankNum] = 1023; // none
	}
}
var Distance[3];
var TheTankNumber = 1000;

// the following are CCW heading changes if
define StepAngleH0,1.5;  // one motor half-steps
define StepAngleFf,6;    // full-step on one, full-step other way on second
define StepAngleF0,3;    // one motor full-steps
define StepAngleHh,3;    // half-step on one, half-step other way on second
define StepAngleFhh,4.5; // Full-step on one, half-step other way on second
define StepAngleFH,1.5;  // Full-step on one, half-step the same way on second

// the following are forward distance changes if (changed distances 7/27/08)
// -1852 to +1852 map units
// 0 to 1023 meters
// step is 1.80859375 map unit
// distance of one step is 1.80859375*1024/3704 = 0.5meters
define StepDistFF,1.80859375;     //          full-step on one, full-step the same way on second
define StepDistH0,0.4521484375;   // 0.25*FF  one motor half-steps
define StepDistF0,0.904296875;    // 0.5*FF   one motor full-steps
define StepDistHH,0.904296875;    // 0.5*FF   half-step on one, half-step other way on second
define StepDistFhh,0.4521484375;  // 0.25*FF  Full-step on one, half-step other way on second
define StepDistFH,1.1755859375;   // 0.650*FF Full-step on one, half-step the same way on second

// bleft is  -2=f, -1=h, 0=0, 1=H, and 2=F
// bRight is -2=f, -1=h, 0=0, 1=H, and 2=F
function MoveTank(bLeft,bRight,speed){ // speed is 1 or 2
	// *************implement falling to hit the floor *******************   	
	my.enable_block = OFF;     // no penalty for falling
	vec_set(temp,my.x);
	temp.z -= 1000; // calculate a position 1000 quants below the player
	// set a trace mode for using the player's hull, and detecting map entities and level surfaces only 
	trace_mode = ignore_me+ignore_sprites+IGNORE_MODELS+USE_BOX;
	result = trace(my.x,temp); // subtract vertical distance to ground
	if((result>0.5)||(result<-0.5)) // changed to make it closer to the ground
	{
		Distance.X = 0 ;
		Distance.Y = 0 ;
		Distance.Z = -result;
		ent_MOVE(Distance, nullvector);
	}
	my.enable_block = ON;     // restore penalty for hitting wall    
	// *************end falling to hit the floor *******************   	
   
	// Heading change are in degrees
	// Distance changes are in meters
	
	if((bLeft==0)&&(bRight==0)){ 
		return(0); // no changes
	}
	Distance.Y = 0; // motion in direction of current heading
	Distance.Z = 0; // distance down
	// there are 24 cases involving motion
	if((bLeft==2)&&(bRight==2))
	{ // left full forward, right full forward
		// no rotation
		Distance.X = speed*StepDistFF;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-2)&&(bRight==-2))
	{ // left full backward, right full backward
		// no rotation
		Distance.X = -speed*StepDistFF;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==2)&&(bRight==-2))
	{ // left full forward, right full backward
		my.PAN += -StepAngleFf;  // CW
		// no translation
		return(0);
	}
	if((bLeft==-2)&&(bRight==2))
	{ // left full backward, right full forward
		my.PAN += StepAngleFf;   // CCW		
		// no translation
		return(0);
	}
	if((bLeft==2)&&(bRight==0))
	{ // left full forward, right stop
		my.PAN += -speed*StepAngleF0;  // CW
		Distance.X = speed*StepDistF0;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==0)&&(bRight==2))
	{ // left stop, right full forward
		my.PAN += speed*StepAngleF0;   // CCW
		Distance.X = speed*StepDistF0;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-2)&&(bRight==0))
	{ // left full backward, right stop
		my.PAN += speed*StepAngleF0;   // CCW
		Distance.X = -speed*StepDistF0;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==0)&&(bRight==-2))
	{ // left stop, right full backward
		my.PAN += -speed*StepAngleF0;   // CW
		Distance.X = -speed*StepDistF0;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==1)&&(bRight==1))
	{      // left half forward, right half forward
		// no rotation
		Distance.X = speed*StepDistHH;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==1)&&(bRight==-1))
	{ // left half forward, right half backward
		my.PAN += -StepAngleHh;  // CW
		// no translation   
		return(0);
	}
	if((bLeft==-1)&&(bRight==-1))
	{ // left half backward, right half backward
		// no rotation
		Distance.X = -speed*StepDistHH;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==-1)&&(bRight==1))
	{ // left half backward, right half forward
		my.PAN += StepAngleHh;  // CCW
		// no translation
		return(0);
	}
	if((bLeft==1)&&(bRight==0))
	{ // left half forward, right stop
		my.PAN += -speed*StepAngleH0; // CW
		Distance.X = speed*StepDistH0;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==0)&&(bRight==1))
	{ // left stop, right half forward
		my.PAN += speed*StepAngleH0;  // CCW
		Distance.X = speed*StepDistH0;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-1)&&(bRight==0))
	{ // left half backward, right stop
		my.PAN += speed*StepAngleH0; // CCW
		Distance.X = -speed*StepDistH0;				
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==0)&&(bRight==-1))
	{ // left stop, right half backward
		my.PAN += -speed*StepAngleH0; // CW
		Distance.X = -speed*StepDistH0;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==2)&&(bRight==1))
	{ // left full forward, right half forward
		my.PAN += -StepAngleFH;  // CW
		Distance.X = speed*StepDistFH;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==1)&&(bRight==2))
	{ // left half forward, right full forward
		my.PAN += StepAngleFH;   // CCW
		Distance.X = speed*StepDistFH;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-2)&&(bRight==-1))
	{ // left full backward, right half backward
		my.PAN += StepAngleFH;   // CCW
		Distance.X = -speed*StepDistFH;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==-1)&&(bRight==-2))
	{ // left half backward, right full backward
		my.PAN += -StepAngleFH;  // CW
		Distance.X = -speed*StepDistFH;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==2)&&(bRight==-1))
	{ // left full forward, right half backward
		my.PAN += -StepAngleFhh;   // CW
		Distance.X = speed*StepDistFhh;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-1)&&(bRight==2))
	{ // left half backward, right full forward
		my.PAN += StepAngleFhh;   // CCW
		Distance.X = speed*StepDistFhh;
		ent_MOVE(Distance, nullvector);
		return(0);
	}
	if((bLeft==-2)&&(bRight==1))
	{ // left full backward, right half forward
		my.PAN += StepAngleFhh;  // CCW
		Distance.X = -speed*StepDistFhh;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
	if((bLeft==1)&&(bRight==-2))
	{ // left half forward, right full backward
		my.PAN += -StepAngleFhh;    // CW
		Distance.X = -speed*StepDistFhh;
		ent_MOVE(Distance, nullvector);
		return(1);
	}
}

// bStep is -2=f, -1=h, 0=0, 1=H, and 2=F
// add 10, 5, 0, -5, -10 to turret angle
// rotates the turret, and effects the global TheTurret
function MoveTurret(bStep)
{
	var tankNum;
	if(bStep==0)
	{ 
		return; // no changes
	}
	tankNum = my.tanknumber-1000;
	TheTurret[tankNum] = (TheTurret[tankNum]+(5*bStep))%360;       
	// turret angles are in degrees

	my.frame = 1+(TheTurret[tankNum]/10)%36;  // goes from 1,2,3,...36 
	//	my.frame = 1+(16-((TheTurret[tankNum]*2)/45))%16;  // goes from 1,2,3,...16 
}
define ASCII_0,48;
define ASCII_1,49;
define ASCII_9,57;
define ASCII_A,65;
define ASCII_S,83;
define ASCII_question,63;
string HexString="#50";
// input is 0 to 15
// output is ASCII 0-9,A-F
function HexDigit(digit)
{
	if(digit<10)
	{
		return(ASCII_0+digit);  // 0-9
	}
	if(digit<16)
	{
		return(ASCII_A+digit-10); // A-F
	}
	return(ASCII_question);
}
string hexLetterStr="#50";
function str_for_hex3(n)
{
	var MsDigit;
	var MiddleDigit;
	var LsDigit;
	var rest;
	rest = n&4095;  // 12-bits 0x0FFF
	LsDigit = HexDigit(rest%16);
	rest = rest/16;
	MiddleDigit = HexDigit(rest%16);
	MsDigit = HexDigit(rest/16);
	str_cpy(HexString," ");
	str_for_asc(HexString,MsDigit);
	str_cpy(hexLetterStr," ");
	str_for_asc(hexLetterStr,MiddleDigit);
	str_cat(HexString,hexLetterStr);
	str_cpy(hexLetterStr," ");
	str_for_asc(hexLetterStr,LsDigit);
	str_cat(HexString,hexLetterStr);
	str_cat(HexString," ");
}
function str_for_hex4(n)
{
	var MsDigit;
	var ThreeDigit;
	var TwoDigit;
	var LsDigit;
	var rest;
	rest = n&65535;  // 16-bits 0xFFFF
	LsDigit = HexDigit(rest%16);
	rest = rest/16;
	TwoDigit = HexDigit(rest%16);
	rest = rest/16;
	ThreeDigit = HexDigit(rest%16);
	MsDigit = HexDigit(rest/16);
	str_cpy(HexString," ");
	str_for_asc(HexString,MsDigit);
	str_cpy(hexLetterStr," ");
	str_for_asc(hexLetterStr,ThreeDigit);
	str_cat(HexString,hexLetterStr);
	str_cpy(hexLetterStr," ");
	str_for_asc(hexLetterStr,TwoDigit);
	str_cat(HexString,hexLetterStr);
	str_cpy(hexLetterStr," ");
	str_for_asc(hexLetterStr,LsDigit);
	str_cat(HexString,hexLetterStr);
	str_cat(HexString," ");
}

action move_me 
{ var i; 
	var myDamageLoc[3];
	var bDamage;        // initially false, true when first damaged
	var mySevereDamageLoc[3];
	var bSevereDamage; // initially false, true when first severely damaged
	var myLoc[3];
	var myNumber;
	var theangle;
	my._HEALTH = 1023;
	bDamage = 0;     		// not damaged
	bSevereDamage = 0;	// not severely damaged
	my.scale_x = 0.3;
	my.scale_y = 0.5;
	my.scale_z = 0.5;
	my.enable_scan = ON;      // sensible of explosions
	my.enable_block = ON;     // make Entity sensitive for block (wall)collision
	my.enable_shoot = ON;     // sensible of gunshots
	my.enable_entity = ON;    // sensible for entity collision
	my.event = tankfight_event; // handle hits, collisions
	//	my.metal = ON;
	my.albedo = 50;
	myNumber = TheTankNumber-1000;  // 0,1,2,...
	my.tanknumber = TheTankNumber;  // 1000,1001,1002,...
	my.skin = (myNumber%26)+1;
	if(ExplicitStart[myNumber])
	{ // Explicit starting direction and turret in ADC units 0 to 1023
		TheTurret[myNumber] = int((360*ExplicitStartTurret[myNumber]+512)/1024); // 0-359
		if(TheTurret[myNumber]>359)
		{
			TheTurret[myNumber]=0;
		} 
		my.PAN = int((360*ExplicitStartDir[myNumber]+512)/1024);                 // 0-359
		if(my.PAN>359)
		{
			my.PAN=0;
		} 
	} else{
		TheTurret[myNumber] = 10*int(random(36)); // 0,10,...,350
		my.PAN = 12*int(random(30));              // 0,12,...,348
	}
	Alive[myNumber] = 1;      // alive
	Waiting[myNumber] = 0;    // not waiting

	//	my.frame = 1+(16-((TheTurret[myNumber]*2)/45))%16;  // goes from 1,2,3,...16 
	my.frame = 1+(TheTurret[myNumber]/10)%36;  // goes from 1,2,3,...36 

	//************the commands received from the 6812 simulation***************
	TheResolution[myNumber] = 0;    // PTM5-4, scanner resolution 0,1,2,3 
	TheTurretStepper[myNumber] = 0; // PTM3-0, stepper command for turret. E.g. -2,-1,0,1,2
	TheLeftStepper[myNumber] = 0;   // PTT7-4, stepper command for left track. E.g. -2,-1,0,1,2
	TheRightStepper[myNumber] = 0;  // PTT3-0, stepper command for right track. E.g. -2,-1,0,1,2
	TheDistance[myNumber] = 0;      // SCI serial output, 0 to 255
	TheSensorAngle[myNumber] = 0;   // Port P output, 0 to 255, sensor angle
	TheMotorSpeed[myNumber] = 0;    // PM7, slow mode
	
	//*************************************************************************
   CenterPack[myNumber] = 1;  // 0 for tank has captured this lifepack, 1 still available
   NWPack[myNumber] = 1;      // 0 for tank has captured this lifepack, 1 still available
   NEPack[myNumber] = 1;      // 0 for tank has captured this lifepack, 1 still available
   SWPack[myNumber] = 1;      // 0 for tank has captured this lifepack, 1 still available
   SEPack[myNumber] = 1;      // 0 for tank has captured this lifepack, 1 still available
	//*************************************************************************

	move_mode = ignore_passable;
	MoveTank(0,0,1);
	wait(3);
	while (1)
	{
// person_3rd camera function
//   5        automatic panoramic
//   4        disconnected from player, manual motion
//   2        orbit PlayerTank
//   0        1st
		if((myNumber==PlayerTank)&&(person_3rd<3)){
			player = my;  // sets which tank is the player
			move_view();  // active player for 1st camera, 3rd person camera
		}
		if(bGameOver)
		{
			ent_remove(ME);
			return;
		}
		//    move_mode = ignore_passable + glide;
		if (my._HEALTH <= 0) 
		{ 
			tankstate_die(); 
			Alive[myNumber] = 0;    // dead
			Waiting[myNumber] = 0;  // not waiting on timelimit
			ent_remove(ME);
			return; 
		} 
		if ((my._HEALTH <= HEALTH_50PERCENT)&&(bDamage==0)) {
			myDamageLoc.x = random(70)-35;	// -35 to +35
			myDamageLoc.y = random(70)-35;	// -35 to +35
			myDamageLoc.z = random(10)+10;	// 10 to 20
			bDamage = 1;   // damaged
		}
		if ((my._HEALTH <= HEALTH_25PERCENT)&&(bSevereDamage==0)) {
			mySevereDamageLoc.x = random(70)-35;	// -35 to +35
			mySevereDamageLoc.y = random(70)-35;	// -35 to +35
			mySevereDamageLoc.z = random(10)+10;	// 10 to 20
			bSevereDamage = 1;   // damaged
		}
		if (my._HEALTH <= HEALTH_50PERCENT) {
			myLoc.x=MY.x + myDamageLoc.x;
			myLoc.y=MY.y + myDamageLoc.y;
			myLoc.z=MY.z + myDamageLoc.z;
			emit(3,myLoc,particle_darksmoke);	// emit( smoke
		}
		if (my._HEALTH <= HEALTH_25PERCENT) {
			myLoc.x=MY.x + mySevereDamageLoc.x;
			myLoc.y=MY.y + mySevereDamageLoc.y;
			myLoc.z=MY.z + mySevereDamageLoc.z;
			emit(10,myLoc,particle_scatter);	// emit second smoke
		}

		SetMyTankStats();
		
		result = Run6812(myNumber,TimeLimit);
		if(result>0)  
		{
	      MoveTank(0,0,1);
			Last_X[myNumber] = my.x;
			Last_Y[myNumber] = my.y;
			Waiting[myNumber] = 1;  // waiting on timelimit
			wait(1);

		}
		else
		{
			Waiting[myNumber] = 0;  // not waiting on timelimit
			if(result==-1)          // -1    change tracks, TheLeftStepper, TheRightStepper changed
			{
				Backward[myNumber] = MoveTank(TheLeftStepper[myNumber],TheRightStepper[myNumber],TheMotorSpeed[myNumber]);
				// **check for lifeup**
				//wait(1);
			} 
			else
			{
				if(result==-2) // -2    change turret, TheTurretStepper, TheResolution changed
				{
					MoveTurret(TheTurretStepper[myNumber]);
				} 
				else
				{
					if(result==-3) // -3    fire rocket, TheDistance changed
					{
						Last_X[myNumber] = my.x;
						Last_Y[myNumber] = my.y;
						tankFire();
						wait(1);    // give rocket a chance to fly
					} 
					else{
						if(result==-4) // -4    break point
						{
							if((myNumber==PlayerTank)&&(bStopWillPause)){	
								str_cpy(themsg,"Stopped, hit SPACE to continue");
							   scroll_message(themsg);
								PauseGame();   // pause if player
							}
						} 
						else  // -10 and beyond   6812 program error
						{
							if(result == -5) // -5 write Port P, sensor angle
							{
								TheSensor[myNumber] = (360*TheSensorAngle[myNumber])/256;
							}
							else
							{
								str_cpy(themsg,"Tank ");
								SetTankStr(myNumber);   // Tank_str becomes "A0", "A1', etc.
								str_cat(themsg,Tank_str);
								str_cat(themsg," bug= ");
								str_for_num(TankNum_str,-result);   // then do the number part
								str_cat(themsg,TankNum_str);
								str_cat(themsg,", PC= ");
								str_for_hex4(ThePC[myNumber]);
								str_cat(themsg,HexString);
								scroll_message(themsg);
								my._HEALTH -= HEALTH_10PERCENT;
								TheHealth[myNumber]=max(0,my._HEALTH);  // life points
							}

						}
					}
				}
			}
		}
		//SetMyTankStats();

	}
}
FONT green_font,<msgfont13.bmp>,12,13;	// new font
//FONT green_font,<msgfont2.bmp>,12,14;	// new font
//FONT green_font,<msgfont.bmp>,12,16;	// ScoreBoard font
//font green_font = "Courier New",1,14; // truetype font 

text ScoreBoard
{
	layer = 1;
	pos_x = 15;
	pos_y = 15;
	//	size_y = 100;
	//	offset_y = 0;
	alpha = 200;
	flags = visible,outline;
	font = green_font;
	//font = standard_font;
	strings = 56;  // make this a couple more than MAX_NUM
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";
	string "                                                                                             ";


	INDEX 56;

}
function SortScores(){
  var tank;
  var indx1;
  var indx2;
  var score1;
  var score2;
  var tank1;
  var tank2;
  var flipped;
  tank = 0;
  while(tank<MAX_TANK)
  {
	 TheScoreSorted[tank] = TheScore[tank];  // copy tank score
    TheTankSorted[tank] = tank;             // the tank at that score
    tank = tank+1;
  }
    /* bubble sort */
  indx1 = 1; 
  flipped = 1;
  while ((indx1 < MAX_TANK) && flipped)
  {
    flipped = 0;
    indx2 = MAX_TANK - 1;
    while (indx2 >= indx1)
    {
      score1 = TheScoreSorted[indx2];
      score2 = TheScoreSorted[indx2 - 1];
      tank1 = TheTankSorted[indx2];
      tank2 = TheTankSorted[indx2 - 1];
      if (score2 < score1)
      {
        TheScoreSorted[indx2 - 1] = score1;
        TheScoreSorted[indx2] = score2;
        TheTankSorted[indx2]= tank2;
        TheTankSorted[indx2 - 1] = tank1;
        flipped = 1;
      }
      indx2=indx2-1;
    }
    indx1 = indx1+1;
  }
}
string ScoreStr="#200";                                                     
function UpdateScoreBoard()
{
	var tank;
	var indx;
	var scoreBoardLine;
	str_cpy(ScoreStr,"Battle = ");
	str_for_num(TankNum_str,RunNum);   // then do the number part
	str_cat(ScoreStr,TankNum_str);
	str_cat(ScoreStr,"  Time = ");
	str_for_num(TankNum_str,TheTime);   // then do the number part
	str_cat(ScoreStr,TankNum_str);
	str_cpy(ScoreBoard.string[0],ScoreStr);

	str_cpy(ScoreStr,"   ");
	if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
	{
		str_cat(ScoreStr,"X   ");
	}
	if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
	{
		str_cat(ScoreStr,"Y   ");
	}
	if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
	{
		str_cat(ScoreStr,"Dir ");
	}
	if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
	{
		str_cat(ScoreStr,"Tur ");
	}
	if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
	{
		str_cat(ScoreStr,"Lft ");
	}
	if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
	{
		str_cat(ScoreStr,"Ctr ");
	}
	if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
	{
		str_cat(ScoreStr,"Rgt ");
	}
	if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
	{
		str_cat(ScoreStr,"Hlt ");
	}
	if(bThePC)     // true if ScoreBoard shows 6812 PC
	{
		str_cat(ScoreStr,"PC   ");
	}
	if(bTheRegX)     // true if ScoreBoard shows 6812 RegX
	{
		str_cat(ScoreStr,"RegX ");
	}
	if(bTheRegY)     // true if ScoreBoard shows 6812 RegY
	{
		str_cat(ScoreStr,"RegY ");
	}
	if(bTheRAM)     // true if ScoreBoard shows 6812 RAM location $3800
	{
		str_cat(ScoreStr,"3800 ");
	}
	if(bTheRAM2)     // true if ScoreBoard shows 6812 RAM location $3802
	{
		str_cat(ScoreStr,"3802 ");
	}
	if(bTheRAM3)     // true if ScoreBoard shows 6812 RAM location $3804
	{
		str_cat(ScoreStr,"3804 ");
	}
	if(bTheRAM4)     // true if ScoreBoard shows 6812 RAM location $3806
	{
		str_cat(ScoreStr,"3806 ");
	}
	if(bTheScore)   // true if ScoreBoard shows TheScore
	{
		str_cat(ScoreStr,"Score");
	}
	str_cpy(ScoreBoard.string[1],ScoreStr);
	indx = 0;
	scoreBoardLine = 2;  // which line to draw into
	SortScores();
	while(indx<MAX_TANK)
	{
		tank = TheTankSorted[indx];
		if(TheActive[tank])  // only draw active tanks
		{
			SetTankStr(tank);
			str_cpy(ScoreStr,Tank_str);
			str_cat(ScoreStr," ");
			if(TheHealth[tank]<=0)
			{
				if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
				{
					str_cat(ScoreStr,"    ");
				}
				if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
				{
					str_cat(ScoreStr,"    ");
				}
				if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
				{
					str_cat(ScoreStr,"dead");
				}
				if(bThePC)  // true if ScoreBoard shows 6812 PC
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRegX)  // true if ScoreBoard shows 6812 RegX
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRegY)  // true if ScoreBoard shows 6812 RegY
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM)  // true if ScoreBoard shows 6812 RAM location $3800
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM2)  // true if ScoreBoard shows 6812 RAM location $3802
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM3)  // true if ScoreBoard shows 6812 RAM location $3804
				{
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM4)  // true if ScoreBoard shows 6812 RAM location $3806
				{
					str_cat(ScoreStr,"     ");
				}
			}
			else
			{
				if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
				{
					str_for_hex3(TheX[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
				{
					str_for_hex3(TheY[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
				{
					str_for_hex3(ThePan[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
				{
					str_for_hex3(TheTurretV[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
				{
					str_for_hex3(TheLeft[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
				{
					str_for_hex3(TheFront[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
				{
					str_for_hex3(TheRight[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
				{
					str_for_hex3(TheHealth[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bThePC)  // true if ScoreBoard shows 6812 PC
				{
					str_for_hex4(ThePC[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRegX)  // true if ScoreBoard shows 6812 RegX
				{
					str_for_hex4(TheRegX[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRegY)  // true if ScoreBoard shows 6812 RegY
				{
					str_for_hex4(TheRegY[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM)  // true if ScoreBoard shows 6812 RAM location $3800
				{
					str_for_hex4(TheRAM[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM2)  // true if ScoreBoard shows 6812 RAM location $3802
				{
					str_for_hex4(TheRAM2[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM3)  // true if ScoreBoard shows 6812 RAM location $3804
				{
					str_for_hex4(TheRAM3[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM4)  // true if ScoreBoard shows 6812 RAM location $3806
				{
					str_for_hex4(TheRAM4[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
			}

			if(bTheScore)   // true if ScoreBoard shows TheScore
			{
				str_for_num(TankNum_str,TheScore[tank]);   // then do the number part
				str_cat(ScoreStr,TankNum_str);
			}	
			str_cpy(ScoreBoard.string[scoreBoardLine],ScoreStr);
			scoreBoardLine += 1;
		}
		indx += 1;
	}
}
string TabStr=" ";

function LogScoreBoard()
{
	var tank;
	var indx;
	if(bLogFile==0)
	{
		return;
	}
	str_for_asc(TabStr,9); // now tab string
	filehandle = file_open_append ("logFile.txt"); // opens the file logFile.txt to read 
	str_cpy(ScoreStr,"Battle = ");
	str_for_num(TankNum_str,RunNum);   // then do the number part
	str_cat(ScoreStr,TankNum_str);
	str_cat(ScoreStr,"  Time = ");
	str_for_num(TankNum_str,TheTime);   // then do the number part
	str_cat(ScoreStr,TankNum_str);
	file_str_write (filehandle,ScoreStr);
	file_asc_write(filehandle,13); // CR is added to the end of the file
	file_asc_write(filehandle,10); // LF is added to the end of the file

	str_cpy(ScoreStr,"   "); 
	str_cat(ScoreStr,TabStr);
	if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
	{
		str_cat(ScoreStr,"X   "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
	{
		str_cat(ScoreStr,"Y   "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
	{
		str_cat(ScoreStr,"Dir "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
	{
		str_cat(ScoreStr,"Tur "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
	{
		str_cat(ScoreStr,"Lft "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
	{
		str_cat(ScoreStr,"Ctr "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
	{
		str_cat(ScoreStr,"Rgt "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
	{
		str_cat(ScoreStr,"Hlt "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bThePC)     // true if ScoreBoard shows 6812 PC
	{
		str_cat(ScoreStr,"PC   "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRegX)     // true if ScoreBoard shows 6812 RegX
	{
		str_cat(ScoreStr,"RegX "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRegY)     // true if ScoreBoard shows 6812 RegY
	{
		str_cat(ScoreStr,"RegY "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRAM)     // true if ScoreBoard shows 6812 RAM location $3800
	{
		str_cat(ScoreStr,"3800 "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRAM2)     // true if ScoreBoard shows 6812 RAM location $3802
	{
		str_cat(ScoreStr,"3802 "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRAM3)     // true if ScoreBoard shows 6812 RAM location $3804
	{
		str_cat(ScoreStr,"3804 "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheRAM4)     // true if ScoreBoard shows 6812 RAM location $3806
	{
		str_cat(ScoreStr,"3806 "); 
		str_cat(ScoreStr,TabStr);
	}
	if(bTheScore)   // true if ScoreBoard shows TheScore
	{
		str_cat(ScoreStr,"Score");
	}
	file_str_write (filehandle,ScoreStr);
	file_asc_write(filehandle,13); // CR is added to the end of the file
	file_asc_write(filehandle,10); // LF is added to the end of the file
	indx = 0;
	SortScores();
	while(indx<MAX_TANK)
	{
		tank = TheTankSorted[indx];
		if(TheActive[tank])
		{
			SetTankStr(tank);
			str_cpy(ScoreStr,Tank_str);
			str_cat(ScoreStr," ");
			if(TheHealth[tank]<=0)
			{
				if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"    ");
				}
				if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"dead");
				}
				if(bThePC)  // true if ScoreBoard shows 6812 PC
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRegX)  // true if ScoreBoard shows 6812 RegX
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRegY)  // true if ScoreBoard shows 6812 RegY
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM)  // true if ScoreBoard shows 6812 RAM location $3800
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM2)  // true if ScoreBoard shows 6812 RAM location $3802
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM3)  // true if ScoreBoard shows 6812 RAM location $3804
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
				if(bTheRAM4)  // true if ScoreBoard shows 6812 RAM location $3806
				{
					str_cat(ScoreStr,TabStr); 
					str_cat(ScoreStr,"     ");
				}
			}
			else
			{
				if(bTheX)       // true if ScoreBoard shows ADC channel 0, X position
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheX[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheY)       // true if ScoreBoard shows ADC channel 1, Y position
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheY[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bThePan)     // true if ScoreBoard shows ADC channel 2, tank orientation
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(ThePan[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheTurretV) // true if ScoreBoard shows ADC channel 3, turret angle in volts 0 to 1023
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheTurretV[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheLeft)    // true if ScoreBoard shows ADC channel 4, range to closest tank on the left 
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheLeft[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheFront)   // true if ScoreBoard shows ADC channel 5, range to closest tank in center 
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheFront[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRight)   // true if ScoreBoard shows ADC channel 6, range to closest tank on the right 
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheRight[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheHealth)  // true if ScoreBoard shows ADC channel 7, tank health
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex3(TheHealth[tank]);   // then do the number part in 3 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bThePC)  // true if ScoreBoard shows 6812 PC
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(ThePC[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRegX)  // true if ScoreBoard shows 6812 RegX
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRegX[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRegY)  // true if ScoreBoard shows 6812 RegY
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRegY[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM)  // true if ScoreBoard shows 6812 RAM location $3800
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRAM[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM2)  // true if ScoreBoard shows 6812 RAM location $3802
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRAM2[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM3)  // true if ScoreBoard shows 6812 RAM location $3804
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRAM3[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
				if(bTheRAM4)  // true if ScoreBoard shows 6812 RAM location $3806
				{
					str_cat(ScoreStr,TabStr); 
					str_for_hex4(TheRAM4[tank]);   // then do the number part in 4 digit Hexadecimal
					str_cat(ScoreStr,HexString);
				}
			}

			if(bTheScore)   // true if ScoreBoard shows TheScore
			{
				str_cat(ScoreStr,TabStr); 
				str_for_num(TankNum_str,TheScore[tank]);   // then do the number part
				str_cat(ScoreStr,TankNum_str);
			}		
			file_str_write (filehandle,ScoreStr);
			file_asc_write(filehandle,13); // CR is added to the end of the file
			file_asc_write(filehandle,10); // LF is added to the end of the file
		}
		indx += 1;

	}
	file_close (filehandle); 
}
// Camera motion functions
function MoveCameraCloser()
{
	var letter;
	var CameraSpeed;
	var CameraChange[3];
	var newPos[3];
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraChange.X = 1;
	CameraChange.Y = 0;
	CameraChange.Z = 0;
	vec_rotate(CameraChange,camera.pan);
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // up arrow
		CameraSpeed = min(50,CameraSpeed+time);
		newPos.x = camera.x + CameraSpeed*CameraChange.X;	    // accelerate motion while key is held
		newPos.y = camera.y + CameraSpeed*CameraChange.Y;	    
		newPos.z = camera.z + CameraSpeed*CameraChange.Z;	    
		newPos.x = max(newPos.x, FIELD_MINX); 
		newPos.x = min(newPos.x, FIELD_MAXX); 
		newPos.y = max(newPos.y, FIELD_MINY); 
		newPos.y = min(newPos.y, FIELD_MAXY); 
		newPos.z = max(newPos.z, FIELD_MINZ); 
		newPos.z = min(newPos.z, FIELD_MAXZ); 

		vec_set(camera.x,newPos.x);  // update only if valid
		wait(1);   	
	}
}
function MoveCameraAway()
{
	var letter;
	var CameraSpeed;
	var CameraChange[3];
	var newPos[3];
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraChange.X = 1;
	CameraChange.Y = 0;
	CameraChange.Z = 0;
	vec_rotate(CameraChange,camera.pan);
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // down arrow
		CameraSpeed = min(50,CameraSpeed+time);
		newPos.x = camera.x - CameraSpeed*CameraChange.X;	    // accelerate motion while key is held
		newPos.y = camera.y - CameraSpeed*CameraChange.Y;	    
		newPos.z = camera.z - CameraSpeed*CameraChange.Z;	    
		newPos.x = max(newPos.x, FIELD_MINX); 
		newPos.x = min(newPos.x, FIELD_MAXX); 
		newPos.y = max(newPos.y, FIELD_MINY); 
		newPos.y = min(newPos.y, FIELD_MAXY); 
		newPos.z = max(newPos.z, FIELD_MINZ); 
		newPos.z = min(newPos.z, FIELD_MAXZ); 

		vec_set(camera.x,newPos.x);  // update only if valid
		wait(1);   
	}
}
function RotateCameraLeft(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // left arrow
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		camera.pan += CameraSpeed;	    // accelerate motion while key is held
		wait(1);   
	}
}
function RotateCameraRight(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // right arrow
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		camera.pan -= CameraSpeed;	    // accelerate motion while key is held	
		wait(1);   
	}
}

function RotateCameraUp(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // Page up
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		camera.tilt += CameraSpeed;	    // accelerate motion while key is held
		wait(1);   
		if(camera.tilt >= 90)
		{
			return;  // don't let camera flip over
		}
	}
}
function RotateCameraDown(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // Page down
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		camera.tilt -= CameraSpeed;	    // accelerate motion while key is held
		wait(1);   
		if(camera.tilt <= -90)
		{
			return;  // don't let camera flip over
		}
	}
}
function RotateHeadUp(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // Page up
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		head_angle.TILT += CameraSpeed;	    // accelerate motion while key is held
		wait(1);   
		if(head_angle.TILT >= 75)
		{
			return;  // don't let camera flip over
		}
	}
}
function RotateHeadDown(){
	var letter;
	var CameraSpeed;
	CAMERA.DIAMETER = 0;		// make the camera passable
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // Page up
		CameraSpeed = min(5,CameraSpeed+0.5*time);
		head_angle.TILT -= CameraSpeed;	    // accelerate motion while key is held
		wait(1);   
		if(head_angle.TILT <= -75)
		{
			return;  // don't let camera flip over
		}
	}
}
function OrbitLeftArrow(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // left arrow
	
		inc_orbit_camera_pan();	    // while key is held
		wait(1);   
	}
}
function OrbitRightArrow(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // right arrow
		dec_orbit_camera_pan();	    // while key is held
		wait(1);   
	}
}
function OrbitUpArrow(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // up arrow
		dec_orbit_camera_dist();	    // while key is held
		wait(1);   
	}
}
function OrbitDownArrow(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // down arrow
		inc_orbit_camera_dist();	    // while key is held
		wait(1);   
	}
}
function OrbitPageUp(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // PageUp
		inc_orbit_camera_zOff();	    // while key is held
		wait(1);   
	}
}
function OrbitPageDown(){
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // page down 
		dec_orbit_camera_zOff();	    // while key is held
		wait(1);   
	}
}
function PanoramicLeftArrow()
{
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // left arrow
		if(PanoramicCameraSpeed>-0.25)
		{
			PanoramicCameraSpeed -= 0.01;	    	
		}
		wait(1);   
	}	
}
function PanoramicRightArrow()
{
	var letter;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // right arrow
		if(PanoramicCameraSpeed<0.25)
		{
			PanoramicCameraSpeed += 0.01;	    	
		}
		wait(1);   
	}
	
}
function PanoramicDownArrow()
{
	var letter;
	var CameraSpeed;
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // down arrow key
		CameraSpeed = min(50,CameraSpeed+0.5*time);
		if(PanoramicCameraDistance<5000){
			PanoramicCameraDistance += CameraSpeed;	    // accelerate motion while key is held	
		}
		if(PanoramicCameraDistance>5000){
			PanoramicCameraDistance = 5000;	
		}
		wait(1);   
	}
}
function PanoramicUpArrow()
{
	var letter;
	var CameraSpeed;
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // up arrow
		CameraSpeed = min(50,CameraSpeed+0.5*time);
		if(PanoramicCameraDistance>100)
		{
			PanoramicCameraDistance -= CameraSpeed;	    // accelerate motion while key is held	
		}
		if(PanoramicCameraDistance<100)
		{
			PanoramicCameraDistance = 100;
		}
		wait(1);   
	}
}
function PanoramicPageUp(){
	var letter;
	var CameraSpeed;
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // page up key
		CameraSpeed = min(50,CameraSpeed+0.5*time);
		if(PanoramicCameraHeight<5000){
			PanoramicCameraHeight += CameraSpeed;	    // accelerate motion while key is held	
		}
		if(PanoramicCameraHeight>5000){
			PanoramicCameraHeight = 5000;	
		}
		wait(1);   
	}
}
function PanoramicPageDown(){
	var letter;
	var CameraSpeed;
	CameraSpeed = 0;
	letter = key_lastpressed;
	while(key_pressed(letter) == ON)
	{ // page down key
		CameraSpeed = min(50,CameraSpeed+0.5*time);
		if(PanoramicCameraHeight>50)
		{
			PanoramicCameraHeight -= CameraSpeed;	    // accelerate motion while key is held	
		}
		if(PanoramicCameraHeight<50)
		{
			PanoramicCameraHeight = 50;
		}
		wait(1);   
	}
}
// point at center 0,0,0
function UpdatePanorama()
{
	PanoramicCameraPan = PanoramicCameraPan+PanoramicCameraSpeed*PanoramicCameraDirection;
	if(PanoramicCameraPan>360)
	{
		PanoramicCameraPan = PanoramicCameraPan-360;
	}
	if(PanoramicCameraPan<0)
	{
		PanoramicCameraPan = PanoramicCameraPan+360;
	}
	CAMERA.X = PanoramicCameraDistance * COS(PanoramicCameraPan);
	CAMERA.Y = PanoramicCameraDistance * SIN(PanoramicCameraPan);
 	CAMERA.Z = PanoramicCameraHeight;
 	// face the center 0,0,0
 	temp.X = 0 - camera.X;
   temp.Y = 0 - camera.Y;
   temp.Z = 0 - camera.Z;
 	vec_to_angle(temp,temp);
 	camera.PAN = temp.PAN;
 	camera.TILT = temp.TILT;
}
 
function PauseGame()
{
	if(freeze_mode)
	{
		freeze_mode = 0;  // running so stop
	}
	else
	{
		freeze_mode = 1;  // stopped so run
	}	
}
STRING abortmessage="This run aborted by F11";
function AbortGame()
{
	scroll_message(abortmessage);
	TheTime=0; // cause this game to end	
}
STRING abort_yesno="  Abort?";

function AbortGame_yesno() // invoked by F11
{
	yesno_txt.STRING = abort_yesno;
	yesno_do = AbortGame;
	yesno_show();
}
STRING playerstr=" is now the player";
function NextPlayer() // invoked by F8
{
	PlayerTank = PlayerTank+1;
	if(PlayerTank>=MAX_TANK){
		PlayerTank = 0;
	}
	while(Alive[PlayerTank]==0){  // must be alive
		PlayerTank = PlayerTank+1;
		if(PlayerTank>=MAX_TANK){
			PlayerTank = 0;
		}
	}
	str_cpy(themsg,subjectStr);     // "Tank "
	SetTankStr(PlayerTank);         // which tank is now the player
	str_cat(themsg,Tank_str);       // "Tank you"
	str_cat(themsg,playerstr);      // "Tank you is now the player "
	scroll_message(themsg);
} 
/////////////////////////////////////////////////////////////////////
// Desc: Cycle from 1st to 3rd to orbit person views
//
//	Effects 'person_3rd' value
// person_3rd camera function
//   5        automatic panoramic
//   4        disconnected from player, manual motion
//   3        chase  ***not implemented***
//   2        orbit PlayerTank
//   1        3rd ***not implemented***
//   0        1st
STRING firststr="Camera = 1st person";
STRING orbitstr="Camera = orbit player";
STRING manualstr="Camera = manual";
STRING panoramicstr="Camera = panoramic spin";
function cycle_person_view()
{
	// 5 -> 0 -> 2 -> 4 -> 5
	if(person_3rd > 4)   // was 5 which is 'panoramic' view
	{
		person_3rd = 0;  // switch to 1st person view
		ON_CUU = NULL;   // arrow keys have no effect in 1st person view
		ON_CUD = NULL;
		ON_CUL = NULL;
		ON_CUR = NULL;
		ON_PGUP = RotateHeadUp;   // look up
		ON_PGDN = RotateHeadDown; // look down
	   scroll_message(firststr);
		return;
	}
	if(person_3rd > 3)   // was 4 which is 'manual' view
	{
		person_3rd = 5;  // switch to panoramic view
		camera.genius = NULL;   // no Entity attached to view
//		PanoramicCameraSpeed = 0.02;
//		PanoramicCameraHeight = 500;
//		PanoramicCameraDirection = 1;
		ON_CUU = PanoramicUpArrow;
		ON_CUD = PanoramicDownArrow;
		ON_CUL = PanoramicLeftArrow;
		ON_CUR = PanoramicRightArrow;
		ON_PGUP = PanoramicPageUp;
		ON_PGDN = PanoramicPageDown;
	   scroll_message(panoramicstr);
		return;
	}
	if(person_3rd > 1)   // was 2 in 'orbit player' view
	{
		person_3rd = 4;  // switch to manual view
		camera.genius = NULL;   // no Entity attached to view
		ON_CUU = MoveCameraCloser;
		ON_CUD = MoveCameraAway;
		ON_CUL = RotateCameraLeft;
		ON_CUR = RotateCameraRight;
		ON_PGUP = RotateCameraUp;
		ON_PGDN = RotateCameraDown;
	   scroll_message(manualstr);
		return;
	}

							// was 0 in 'first' view
		person_3rd = 2;  // switch to orbit player
		ON_CUU = OrbitUpArrow;
		ON_CUD = OrbitDownArrow;
		ON_CUL = OrbitLeftArrow;
		ON_CUR = OrbitRightArrow;
		ON_PGUP = OrbitPageUp;
		ON_PGDN = OrbitPageDown;
	   scroll_message(orbitstr);
   	return;


 }
// Define ON_KEY functions
//ON_F7 toggle_person;
ON_F7	cycle_person_view;
ON_CUU = MoveCameraCloser;
ON_CUD = MoveCameraAway;
ON_CUL = RotateCameraLeft;
ON_CUR = RotateCameraRight;
ON_PGUP = RotateCameraUp;
ON_PGDN = RotateCameraDown;
ON_SPACE = PauseGame;
ON_F11 =	AbortGame_yesno;
ON_F8 =	NextPlayer;


string tank0_mdl = <tank0.mdl>; // tank model
string tank1_mdl = <tank1.mdl>; // tank model
string tank2_mdl = <tank2.mdl>; // tank model
string tank3_mdl = <tank3.mdl>; // tank model
//string tank4_mdl = <tank4.mdl>; // tank model
var startPosition[3];
var Buff[2]; // used for file I/O

function NextByte(){ var data;
	if(Buff[0]<=ASCII_9)
	{
		data = (Buff[0]-ASCII_0)<<4;
	}
	else
	{
		data = (10+Buff[0]-ASCII_A)<<4;
	}
	if(Buff[1]<=ASCII_9)
	{
		data += (Buff[1]-ASCII_0);
	}
	else
	{
		data += (10+Buff[1]-ASCII_A);
	}
	return(data);
}
// returns TRUE if successful
string filename="#50";
function LoadS19(tank){	 
	var numberLoaded=0; // number of bytes properly stored in memory  
	var length;
	var addr;
	var msb;
	var lsb;
	var data;
	var chksum;
	var mode=0;         // search mode
	
	SetTankStr(tank);   
	// tank goes from  0     1    2         103
	// TankNum_str is "A0" "A1" "A2", up to "Z3"
	str_cpy(filename,Tank_str);
	str_cat(filename,".s19"); // try .s19 first
	filehandle = file_open_read(filename); 
	if( filehandle == 0 )
	{
		str_cpy(filename,Tank_str);
		str_cat(filename,".sx"); // try .sx second first
		filehandle = file_open_read(filename); 
		if( filehandle == 0 )
		{
			return(0);   // no S19 or sx file of that name
		}
	}

	// 0 looking for S1
	// 1 looking for length
	// 2 looking for high byte address
	// 3 looking for low byte address
	// 4 reading data
	// 5 looking for checksum
	// 6 done
	while(mode<6) 
	{
		
		Buff[0] = file_asc_read (filehandle);
		if(Buff[0]<0){
			scroll_message("bad S19 file"); // end of file
			file_close (filehandle); 
			return(0); // error  	
		}
		Buff[1] = file_asc_read (filehandle);
		if(Buff[1]<0){
			scroll_message("bad S19 file");  // end of file
			file_close (filehandle); 
			return(0); // error  	
		}
		if( mode == 0) {
			if((Buff[0]==ASCII_S)&&(Buff[1]==ASCII_1))
			{
				mode = 1;
				chksum = 0;
			}
			if((Buff[0]==ASCII_S)&&(Buff[1]==ASCII_9))
			{
				mode = 6;  // S9 means done
			}
		}
		else
		{
			if(mode == 1)
			{
				length = NextByte();
				chksum += length;
				length -= 3;
				if(length>0)
				{
					mode = 2;
				}
				else 
				{
					mode=0;
				}
			}
			else
			{
				if(mode == 2)
				{
					msb = NextByte();
					chksum += msb;
					addr = msb<<8;
					mode = 3;
				}
				else
				{
					if(mode == 3)
					{
						lsb = NextByte();
						chksum += lsb;
						addr += lsb;
						mode = 4;
					}
					else
					{
						if(mode == 4)
						{
							data=NextByte();
							chksum += data;
							if(ProgramMem6812(addr,data,tank))
							{
								numberLoaded += 1;
							}
							addr += 1;
							length -= 1;
							if(length==0)
							{
								mode = 5;
							}
						}
						else
						{
							chksum = (chksum+NextByte())&255;
							if(chksum != 255){
								scroll_message("S19 chksum error");
								file_close (filehandle); 
								return(0); // error
							}
							mode = 0;
						}
					}
				}
			}
		}
	}
	str_cpy(themsg,"File ");
	str_cat(themsg,filename);
	str_cat(themsg," loads ");
	str_for_num(TankNum_str,numberLoaded);   // then do the number part
	str_cat(themsg,TankNum_str);
	str_cat(themsg," bytes");
	scroll_message(themsg);

	file_close (filehandle); 
	return (1); // success
}
var bLoading; // true while system finds tanks
// true if searching for start location

function Loading()
{
	var tank;
	tank = 0;
	while(tank<MAX_TANK)
	{
		TheScore[tank] = 0;   // starting score
		TheActive[tank] = LoadS19(tank);
		if(TheActive[tank])
		{

			NumberOfTanks += 1; // the number of tanks to be created
		}
		tank += 1;
	}
}

string IniVarStr="#50";  // variable part of TRobot.ini line
string IniNumStr="#50";  // number part of TRobot.ini line
string letterStr="#50";
// each line has the following format
// VariableName=number;  comments  
// spaces, tabs ignored, lines with = are ignored
function LoadIniFile(){	 
	var bstring;
	var bname;
	var bnum;
	var more;
	var letter;
	var number;
	str_cpy(filename,"Trobot.ini"); // in s19 directory
	filehandle = file_open_read(filename); 
	if( filehandle == 0 )
	{
		return(0);   // no Trobot.ini file 
	}

	more = 1;
	while(more) 
	{
		str_cpy(IniVarStr,""); // String will become variable name
		str_cpy(IniNumStr,""); // String will become number
		bstring = 1;        // searching for line
		bname = 1;          // searching for name
		bnum = 0;           // searching for number
		while(bstring)
		{
			letter = file_asc_read (filehandle);
			if(letter<0){
				file_close (filehandle); 
				return(1); // done  	
			}	
			if((letter==10)||(letter==13))
			{
				bstring = 0;  // end of line
			}
			else
			{
				if((letter!=32)||(letter==9))  // ignore spaces and tabs
				{   
					if(bname)
					{
						if(letter==61)//'=' is 0x3D is 61  
						{
							bname=0;
							bnum=1;
						}
						else
						{
							str_cpy(letterStr," ");
							str_for_asc(letterStr,letter);
							str_cat(IniVarStr,letterStr);
						}
					}
					else
					{
						if(bnum)
						{
							if(letter==59)//  ';' is 0x3B is 59  
							{
								bnum=0;
							}
							else
							{
								str_cpy(letterStr," ");
								str_for_asc(letterStr,letter);
								str_cat(IniNumStr,letterStr);
							}
						}
					}
				}
			}
		} 
		number = str_to_num(IniNumStr); 
		if(str_cmp(IniVarStr,"ShowX"))
		{
			bTheX = number;
		}
		if(str_cmp(IniVarStr,"ShowY"))
		{
			bTheY = number;
		}
		if(str_cmp(IniVarStr,"ShowDir"))
		{
			bThePan = number;
		}
		if(str_cmp(IniVarStr,"ShowDir"))
		{
			bThePan = number;
		}
		if(str_cmp(IniVarStr,"ShowTurret"))
		{
			bTheTurretV = number;
		}
		if(str_cmp(IniVarStr,"ShowLeft"))
		{
			bTheLeft = number;
		}
		if(str_cmp(IniVarStr,"ShowCenter"))
		{
			bTheFront = number;
		}
		if(str_cmp(IniVarStr,"ShowRight"))
		{
			bTheRight = number;
		}
		if(str_cmp(IniVarStr,"ShowHealth"))
		{
			bTheHealth = number;
		}
		if(str_cmp(IniVarStr,"ShowPC"))
		{
			bThePC = number;
		}
		if(str_cmp(IniVarStr,"ShowRegX"))
		{
			bTheRegX = number;
		}
		if(str_cmp(IniVarStr,"ShowRegY"))
		{
			bTheRegY = number;
		}
		if(str_cmp(IniVarStr,"Show3800"))
		{
			bTheRAM = number;
		}
		if(str_cmp(IniVarStr,"Show3802"))
		{
			bTheRAM2 = number;
		}
		if(str_cmp(IniVarStr,"Show3804"))
		{
			bTheRAM3 = number;
		}
		if(str_cmp(IniVarStr,"Show3806"))
		{
			bTheRAM4 = number;
		}
		if(str_cmp(IniVarStr,"PauseBetweenGames"))
		{
			bPauseBetweenGames = number;
		}
		if(str_cmp(IniVarStr,"StopWillPause"))
		{
			bStopWillPause = number;
		}
		if(str_cmp(IniVarStr,"CreateLogFile"))
		{
			bLogFile = number;
		}
		if(str_cmp(IniVarStr,"WallBounce"))
		{
			bWallBounce = number;
		}
		if(str_cmp(IniVarStr,"ShowScore"))
		{
			bTheScore = number;
		}
		if(str_cmp(IniVarStr,"NumberOfBattles"))
		{
			NumberOfBattles = number;
		}
		if(str_cmp(IniVarStr,"BattleTime"))
		{
			BattleTime = number;
		}
		if(str_cmp(IniVarStr,"KillBonus"))
		{
			KillBonus = number;
		}
		if(str_cmp(IniVarStr,"LiveBonus"))
		{
			LiveBonus = number;
		}
		if(str_cmp(IniVarStr,"MissileSpeed"))
		{
			MissileSpeed = number;
			if(MissileSpeed<5){
		     MissileSpeed = 5;
	      }
			if(MissileSpeed>100){
			  MissileSpeed = 100;
		   }
		}
		if(str_cmp(IniVarStr,"MinStepTime"))
		{
						
			TheMinStepTime = number;
			if(TheMinStepTime<0){
		     TheMinStepTime = 0;
	      }
			if(TheMinStepTime>10000){
			  TheMinStepTime = 10000;
		   }
		}
		if(str_cmp(IniVarStr,"BaudRate"))
		{
						
			if(number>=300){
				if(TheBaudRate<=250000){
					TheBaudRate = number;
				}
		   }
		}
		if(str_cmp(IniVarStr,"Camera"))
		{
			if(number==0)
			{
				person_3rd = 0;  // switch to 1st person view
				ON_CUU = NULL;   // arrow keys have no effect in 1st person view
				ON_CUD = NULL;
				ON_CUL = NULL;
				ON_CUR = NULL;
				ON_PGUP = RotateHeadUp;   // look up
				ON_PGDN = RotateHeadDown; // look down
			}
			if(number==5)
			{
				person_3rd = 5;  // switch to panoramic view
				camera.genius = NULL;   // no Entity attached to view
				PanoramicCameraSpeed = 0.02;
				PanoramicCameraHeight = 500;
				PanoramicCameraDirection = 1;
				ON_CUU = PanoramicUpArrow;
				ON_CUD = PanoramicDownArrow;
				ON_CUL = PanoramicLeftArrow;
				ON_CUR = PanoramicRightArrow;
				ON_PGUP = PanoramicPageUp;
				ON_PGDN = PanoramicPageDown;
			}
			if(number==4)
			{
				person_3rd = 4;  // switch to manual view
				camera.genius = NULL;   // no Entity attached to view
				ON_CUU = MoveCameraCloser;
				ON_CUD = MoveCameraAway;
				ON_CUL = RotateCameraLeft;
				ON_CUR = RotateCameraRight;
				ON_PGUP = RotateCameraUp;
				ON_PGDN = RotateCameraDown;
			}
			if(number==2)
			{
				person_3rd = 2;  // switch to orbit player
				ON_CUU = OrbitUpArrow;
				ON_CUD = OrbitDownArrow;
				ON_CUL = OrbitLeftArrow;
				ON_CUR = OrbitRightArrow;
				ON_PGUP = OrbitPageUp;
				ON_PGDN = OrbitPageDown;
			}
		}
		if(str_cmp(IniVarStr,"Player"))
		{
			PlayerTank = number;
		}
		if(str_cmp(IniVarStr,"StartX"))
		{
			if((number>50)&&(number<973))
			{
				ExplicitStartX[PlayerTank] = number;
			}
		}
		if(str_cmp(IniVarStr,"StartY"))
		{
			if((number>50)&&(number<973))
			{
				ExplicitStartY[PlayerTank] = number;
			}
		}
		if(str_cmp(IniVarStr,"StartDir"))
		{
			if((number>=0)&&(number<=1023))
			{
				ExplicitStartDir[PlayerTank] = number;
			}
		}
		if(str_cmp(IniVarStr,"StartTurret"))
		{
			if((number>=0)&&(number<=1023))
			{
				ExplicitStartTurret[PlayerTank] = number;
			}
		}
		if(str_cmp(IniVarStr,"BigFont"))
		{
			if(number)
			{
				ScoreBoard.font = green_font;
			}
			else
			{
				ScoreBoard.font = standard_font;
			}
		}
	}
	file_close (filehandle); 
	return (1); // success
}
/////////////////////////////////////////////////////////////////
// The main() function is started at game start
function main()
{
	var tank;
	var numWaiting;
	var numTankAlive;
	var theWinner;
	var theDistance;
	var i;
//	var theMinDistance;
	NumberOfBattles = 3;
	MissileSpeed=10;  // default missile speed
	BattleTime = 30;
	bLogFile = 0;     // do not save in logFile.txt file
	bWallBounce = 1;  // tanks bounce off wall
//	theMinDistance = 	MIN_START_DIST*(FIELD_MAXX-FIELD_MINX)/1024;  // in map units
   KillBonus = 0;    // bonus points for killing an opponent
   LiveBonus = 0;    // bonus points for staying alive for the entire battle


	//   if(video_switch(8,0,0) == 0)
	//   {
		//      video_switch(7,0,0);
	//   } 
	//   
	randomize(); // starts a initial value

	// set some common flags and variables
	//	warn_level = 2;	// announce bad texture sizes and bad wdl code
	tex_share = on;	   // map entities share their textures
	scroll.POS_X=800;
	// center the splash screen for non-640x480 resolutions, and display it
	splashscreen.pos_x = (screen_size.x - bmap_width(splashmap))/2;
	splashscreen.pos_y = (screen_size.y - bmap_height(splashmap))/2;
	splashscreen.visible = on;
	// wait 3 frames (for triple buffering) until it is flipped to the foreground
	wait(4);

	// now load the level
	level_load(level_str);
	// freeze the game
	freeze_mode = 1;
	// use the new 3rd person camera
	move_view_cap = 1;
	CAMERA.DIAMETER = 0;		 // make the camera passable
	camera.genius = NULL;    // no Entity attached to view
	camera.tilt -= 30;	    // point down a little
	camera.ambient = 25;     // maximum ambient is 100  
	clip_range = 100000;     // no clipping  	
	camera.fog_start = 0.99 * clip_range; // no fog
	camera.fog_end = 0.995 * clip_range; // no fog
   camera.clip_far = 100000;
	person_3rd = 4;          // manual camera view
	orbit_camera_pan = 180;  // pan around center point
	orbit_camera_dist = 400; // distance from center point
	orbit_camera_zOff = 250; // distance up
	NEPackX = int(1023*((LifeupNEx-FIELD_MINX)/(FIELD_MAXX-FIELD_MINX)));   // X position, in ADC units
	NEPackY = int(1023*((LifeupNEy-FIELD_MINY)/(FIELD_MAXY-FIELD_MINY)));   // Y position, in ADC units
	NWPackX = int(1023*((LifeupNWx-FIELD_MINX)/(FIELD_MAXX-FIELD_MINX)));   // X position, in ADC units
	NWPackY = int(1023*((LifeupNWy-FIELD_MINY)/(FIELD_MAXY-FIELD_MINY)));   // Y position, in ADC units
	SEPackX = int(1023*((LifeupSEx-FIELD_MINX)/(FIELD_MAXX-FIELD_MINX)));   // X position, in ADC units
	SEPackY = int(1023*((LifeupSEy-FIELD_MINY)/(FIELD_MAXY-FIELD_MINY)));   // Y position, in ADC units
	SWPackX = int(1023*((LifeupSWx-FIELD_MINX)/(FIELD_MAXX-FIELD_MINX)));   // X position, in ADC units
	SWPackY = int(1023*((LifeupSWy-FIELD_MINY)/(FIELD_MAXY-FIELD_MINY)));   // Y position, in ADC units
	
	while(tank<MAX_TANK)
	{
		StartX[tank] = 0; 
		StartY[tank] = 0;
		ExplicitStartX[tank] = 0;       // zero means position not specified by Ini file
		ExplicitStartY[tank] = 0;
		ExplicitStart[tank] = 0;        // 0 means random start position
		ExplicitStartDir[tank] = 0;     // Explicit starting direction, ADC units 0 to 1023
		ExplicitStartTurret[tank] = 0;  // Explicit starting turret angle, ADC units 0 to 1023
		tank += 1;
	}

	LoadIniFile();
	if(bLogFile)
	{
		filehandle = file_open_append ("logFile.txt"); // opens the file logFile.txt to read 
		file_str_write(filehandle,"******TRobots v1.84 by Jonathan Valvano******");
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_str_write(filehandle,"Life pack at (");
		file_var_write(filehandle,NEPackX);
		file_str_write(filehandle,", ");
		file_var_write(filehandle,NEPackY);
		file_str_write(filehandle,")");
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_str_write(filehandle,"Life pack at (");
		file_var_write(filehandle,NWPackX);
		file_str_write(filehandle,", ");
		file_var_write(filehandle,NWPackY);
		file_str_write(filehandle,")");
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_str_write(filehandle,"Life pack at (");
		file_var_write(filehandle,SEPackX);
		file_str_write(filehandle,", ");
		file_var_write(filehandle,SEPackY);
		file_str_write(filehandle,")");
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_str_write(filehandle,"Life pack at (");
		file_var_write(filehandle,SWPackX);
		file_str_write(filehandle,", ");
		file_var_write(filehandle,SWPackY);
		file_str_write(filehandle,")");
		file_asc_write(filehandle,13); // CR is added to the end of the file
		file_asc_write(filehandle,10); // LF is added to the end of the file
		file_close (filehandle); 
	}
	// wait the required second, then switch the splashscreen off.
	sleep(1);
	splashscreen.visible = off;
	bmap_purge(splashmap);	// remove splashscreen from video memory

	// load some global variables, like sound volume
	//load_status();

	// display the initial message
	msg_show(mission_str,2);

	// initialize lens flares when edition supports flares
	ifdef CAPS_FLARE;
		lensflare_start();
	endif;



	dll_open("Trobot12.dll");    // 6812 simulation
	
	bLoading = Init6812();
	SetMinStepTime(TheMinStepTime); // defines max tank speed
	SetBaudRate(TheBaudRate);
	NumberOfTanks = 0;
	Loading();

	if(NumberOfTanks<2)
	{
		str_cpy(themsg,"Need at least two tanks");
		scroll_message(themsg);
		return;
	}
	if(NumberOfTanks>MAX_NUM)
	{
		str_cpy(themsg,"Can have at most ");
		str_for_num(TankNum_str,MAX_NUM);   // then do the number part
		str_cat(themsg,TankNum_str);
		str_cat(themsg," tanks");
		scroll_message(themsg);
		return;
	}
	RunNum = NumberOfBattles;
	while(RunNum>0)
	{
		// step 1) choose the starting places for the tanks on the field
		tank = 0;
		while(tank<MAX_TANK)
		{
			if(TheActive[tank])
			{
				bLoading = 1;
				Backward[tank] = 0; // forward
				Reset6812(tank);    // searching for a good start location
				if((ExplicitStartX[tank]==0)||(ExplicitStartY[tank]==0))
				{
					while(bLoading)
					{
						StartX[tank]  = 200+int(random(FIELD_MAXX-FIELD_MINX-400))+FIELD_MINX; 
						StartY[tank] = 200+int(random(FIELD_MAXY-FIELD_MINY-400))+FIELD_MINY;
						bLoading = 0;  // assume it is ok
						i = 0;
						while(i<tank)
						{
							theDistance = abs(StartX[tank]-StartX[i]);
							if(theDistance<MIN_START_DIST)
							{
								theDistance = abs(StartY[tank]-StartY[i]);
								if(theDistance<MIN_START_DIST)
								{
									bLoading = 1; // too close, choose again
								}
							}
							i += 1;
						}
						i += 1;
						while(i<MAX_TANK)
						{
							theDistance = abs(StartX[tank]-StartX[i]);
							if(theDistance<MIN_START_DIST)
							{
								theDistance = abs(StartY[tank]-StartY[i]);
								if(theDistance<MIN_START_DIST)
								{
									bLoading = 1; // too close, choose again
								}
							}
							i += 1;
						}
						if((abs(StartX[tank])<UTTOWER_SIZE)||(abs(StartY[tank])<UTTOWER_SIZE)){
							bLoading = 1; // too close to UT tower, choose again
						}
						theDistance = abs(StartX[tank]);
						if(theDistance<UTTOWER_SIZE)
						{
							theDistance = abs(StartY[tank]-1000);
							if(theDistance<UTTOWER_SIZE)
							{
								bLoading = 1; // too close to north building, choose again
							}
						}
						theDistance = abs(StartX[tank]-1000);
						if(theDistance<UTTOWER_SIZE)
						{
							theDistance = abs(StartY[tank]);
							if(theDistance<UTTOWER_SIZE)
							{
							bLoading = 1; // too close to east building, choose again
							}
						}
						theDistance = abs(StartX[tank]);
						if(theDistance<UTTOWER_SIZE)
						{
							theDistance = abs(StartY[tank]+1000);
							if(theDistance<UTTOWER_SIZE)
							{
								bLoading = 1; // too close to south building, choose again
							}
						}
						theDistance = abs(StartX[tank]+1000);
						if(theDistance<UTTOWER_SIZE)
						{
							theDistance = abs(StartY[tank]);
							if(theDistance<UTTOWER_SIZE)
							{
								bLoading = 1; // too close to west building, choose again
							}
						}
					}
				} else
				{ // rounded to closest 4 so calculation won't overflow, add 4 just to make it work out??
					StartX[tank] = int((ExplicitStartX[tank]*((FIELD_MAXX-FIELD_MINX)/4))/256+FIELD_MINX+4);   // X position, in map units
					StartY[tank] = int((ExplicitStartY[tank]*((FIELD_MAXY-FIELD_MINY)/4))/256+FIELD_MINY+4);   // Y position, in map units
					ExplicitStart[tank] = 1; // 1 means start position specified by ini file
				}
			}
			tank += 1;
		}
		
		// step 2) create an entity for each tank
		tank = 0;
		bGameOver = 0;         // game ready to start
		while(tank<MAX_TANK)
		{
			if(TheActive[tank])
			{
				TheTankNumber = 1000+tank; // used when tanks first execute ent_create
				startPosition.x = StartX[tank]; 
				Last_X[tank] = StartX[tank];
				startPosition.y = StartY[tank];
				Last_Y[tank] = StartY[tank];
				startPosition.z = 30; // -110;  // -110 is floor
				if(tank<26)
				{       // tank 0 to 25
					ent_create (tank0_mdl, startPosition, move_me); // tanks A0 to Z0
				}
				else
				{
					if(tank<52)
					{      // tank 26 to 51
						ent_create (tank1_mdl, startPosition, move_me); // tanks A1 to Z1
					}
					else
					{
						if(tank<78)
						{					// tank 52 to 77,  A2 to Z2
							ent_create (tank2_mdl, startPosition, move_me); // tanks A2 to Z2
						}
						else
						{             	//  tank 78 to 103,   A3 to Z3
							ent_create (tank3_mdl, startPosition, move_me); // tanks A3 to Z3
						}
					}
				}
				wait(1); // allow entity to create and execute move_me
			}
			tank += 1;
		}
		
		// step 3) pause for operator to type SPACE
		if(bPauseBetweenGames)
		{
			str_cpy(themsg,"Type SPACE to start");
			scroll_message(themsg);
		}
		else
		{
			freeze_mode=0; // start run
		}
		
		// step 4) run until timeout or only one left
		TheTime = BattleTime;		 // simulation time in milliseconds
		TimeLimit = TIME_STEP;
		
		numTankAlive = NumberOfTanks;
		while((numTankAlive>1)&&(TheTime>0))  // need at least two to battle
		{
			numTankAlive = 0;
			numWaiting = 0;
			tank = 0;
			while(tank<MAX_TANK)
			{
				if(TheActive[tank])
				{
					if(Alive[tank])
					{
						theWinner = tank;
						numTankAlive += 1;
					}
					if(Waiting[tank])
					{
						numWaiting += 1;
					}
				}
				tank += 1;
			}
			if(numWaiting >= numTankAlive)
			{
				if(freeze_mode==0)  // update time only in RunMode
				{
					TimeLimit += TIME_STEP;  // run some more
					TheTime -= MS_STEP;
					if(person_3rd>4)   // panoramic mode
					{
						UpdatePanorama();
					}
				}
				UpdateScoreBoard();
			}
			
			wait(1);
		}
		// step 5) remove all tank entities, report scores
		bGameOver = 1;         // entities remove themselves
		wait(1);
		if(numTankAlive>1)
		{
			str_cpy(themsg,"Game over, time exceeded");
			scroll_message(themsg);
		}	
		else
		{
			str_cpy(themsg,"Game over, Tank ");
			SetTankStr(theWinner);   // Tank_str becomes "A0", "A1', etc.
			str_cat(themsg,Tank_str);
			str_cat(themsg," remains");
			scroll_message(themsg);
		}
		// freeze the game
		tank = 0;
		theWinner = 0;
		while(tank<MAX_TANK)
		{
			if(TheActive[tank])
			{
				if(TheScore[tank]>TheScore[theWinner])
				{
					theWinner = tank;
				}
				if(Alive[tank]){
					TheScore[tank] += LiveBonus;  // bonus for staying alive
				}
			}
			tank += 1;
		}
		str_cpy(themsg,"Tank ");
		SetTankStr(theWinner);   // Tank_str becomes "A0", "A1', etc.
		str_cat(themsg,Tank_str);
		str_cat(themsg," has the highest score");
		scroll_message(themsg);
		sleep(1);
		freeze_mode = 1;
		LogScoreBoard();
		RunNum -= 1;
	}

}


/////////////////////////////////////////////////////////////////
// The following definitions are for the pro edition window composer
// to define the start and exit window of the application.
//WINDOW WINSTART
//{
	//	TITLE			"Texas Robots";
	//	SIZE			640,480;
	//	MODE			IMAGE;	//STANDARD;
	//	BG_COLOR		RGB(240,240,240);
	//	FRAME			FTYP1,0,0,640,480;
	//	BUTTON		BUTTON_QUIT,SYS_DEFAULT,"Abort",400,288,72,24;
	//	TEXT_STDOUT	"Arial",RGB(0,0,0),10,10,460,280;
//}

/* no exit window at all..
WINDOW WINEND
{
	TITLE			"Finished";
	SIZE			540,320;
	MODE	 		STANDARD;
	BG_COLOR		RGB(0,0,0);
	TEXT_STDOUT	"",RGB(255,40,40),10,20,520,270;

	SET FONT		"",RGB(0,255,255);
	TEXT			"Any key to exit",10,270;
}*/

/////////////////////////////////////////////////////////////////
//INCLUDE <debug.wdl>;


