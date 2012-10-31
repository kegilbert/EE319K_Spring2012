// Template file v5.202 (02/20/02)
////////////////////////////////////////////////////////////////////////
// File: messages.wdl
//		WDL prefabs for displaying messages
////////////////////////////////////////////////////////////////////////
// TRobots 1.62
// Jonathan Valvano 11/21/2006

////////////////////////////////////////////////////////////////////////
IFNDEF MSG_DEFS;
 FONT standard_font,<ackfont.pcx>,6,9;
 FONT standard_font2,<msgfont13.bmp>,12,13;	// new font

 DEFINE MSG_X,4;		// from left
 DEFINE MSG_Y,4;		// from above
 DEFINE BLINK_TICKS,6;	// msg blinking period
 DEFINE MSG_TICKS,64;	// msg appearing time
 DEFINE msg_font,standard_font;
 SOUND msg_sound,<msg.wav>;

 DEFINE PANEL_POSX,4;	// health panel from left
 DEFINE PANEL_POSY,-20;	// from below
 FONT digit_font,<digfont.pcx>,12,16;	// ammo/health font
ENDIF;

IFNDEF MSG_DEFS2;
 DEFINE SCROLL_X,4;		// scroll text from left
 DEFINE SCROLL_Y,4;		// from above
 DEFINE SCROLL_LINES,8;	// maximum 8;
ENDIF;

IFNDEF MSG_DEFS3;
 DEFINE HEALTHPANEL,game_panel;	// default health/ammo panel

 DEFINE touch_font,standard_font;
 DEFINE touch_sound,msg_sound;
ENDIF;

//////////////////////////////////////////////////////////////////////
var msg_counter = 0;
STRING empty_str[80];
STRING temp_str[80];

TEXT msg
{
	POS_X 450;
	POS_Y 350;
	FONT	standard_font2;
	STRING empty_str;
}

//////////////////////////////////////////////////////////////////////
// To display a message string for a given number of seconds, perform the instructions
// msg_show(string,time);

function msg_show(str,secs)
{
	exclusive_global;		// stop previous msg_show action
	snd_play(msg_sound,66,0);
	msg.string = str;
	msg.visible = on;
	waitt(secs*16);
	msg.string = empty_str;
	msg.visible = off;
}

// Desc: show message for 5 seconds
function show_message()
{
	msg_show(msg.string,5);
}

// The same, but message will blink
function msg_blink(str,secs)
{
//	ME = NULL;
	exclusive_global;
	snd_play(msg_sound,66,0);
	msg.string = str;
	msg_counter = secs*16;
	while(msg_counter > 0)
	{
		msg.visible = (msg.visible == off);
		waitt(BLINK_TICKS);
		msg_counter -= BLINK_TICKS;
	}
	msg.string = empty_str;
	msg.visible = off;
}

function blink_message()
{
	msg_blink(msg.string,5);
}

//////////////////////////////////////////////////////////////////////
// actions for scrolling messages
//////////////////////////////////////////////////////////////////////
STRING message_str,
 "                                                                    ";
TEXT enter_txt
{
	FONT	msg_font;
	STRING message_str;
}


//////////////////////////////////////////////////////////////////////
// Stuff for displaying object titles if the mouse touches them
TEXT touch_txt
{
	FONT	touch_font;
	STRING empty_str;
	FLAGS CENTER_X,CENTER_Y;
}

// Desc: display a touch text at mouse position
function _show_touch()
{
	if(MY.STRING1 != NULL)
	{
		snd_play(touch_sound,33,0);
		touch_txt.VISIBLE = ON;
		touch_txt.STRING = MY.STRING1;
		touch_txt.POS_X = MOUSE_POS.X;
		touch_txt.POS_Y = MOUSE_POS.Y;
		MY.ENABLE_RELEASE = ON;

	//	WHILE (touch_text.VISIBLE == ON)	// move text with mouse
	//	{
	//		touch_text.POSX = MOUSE_X;
	//		touch_text.POSY = MOUSE_Y;
	//		wait(1);
	//	}
	}
}

// Desc: hide touch text if it still displayed my string
function _hide_touch()
{
	if(touch_txt.STRING == MY.STRING1)
	{
		touch_txt.VISIBLE = OFF;
	}
}

// Desc: call this from a event action to operate the touch text
function handle_touch()
{
	if(EVENT_TYPE == EVENT_TOUCH) { _show_touch(); return; }
	if(EVENT_TYPE == EVENT_RELEASE) { _hide_touch(); return; }
}

