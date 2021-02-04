runoncepath("lib/tabwidget").
runpath("lib_valkyrie").
runpath("lib/lib_num_to_str").
runpath("lib/lib_str_to_num").
runpath("lib/lib_location_constants").
BRAKES ON.
clearscreen.
local done is FALSE.
local gui is GUI(300).
set gui:DRAGGABLE to true.
local tabwidget is AddTabWidget(gui).

// -------- PID Page --------
local page is AddTab(tabwidget, "PID").
local box is page:ADDVBOX.

// Altitude PID
local l is box:ADDLABEL("Altitude").
local alt_kp_tf is box:ADDTEXTFIELD(num_to_str(alt_kp, 1, 5)).
set alt_kp_tf:ONCONFIRM to {
	parameter str.
	set alt_kp to str:TONUMBER(0.0).
	set alt_pid:KP to alt_kp.
	set alt_kp_tf:TEXT to num_to_str(alt_kp, 1, 5).
}.
local alt_ki_tf is box:ADDTEXTFIELD(num_to_str(alt_ki, 1, 5)).
set alt_ki_tf:ONCONFIRM to {
	parameter str.
	set alt_ki to str:TONUMBER(0.0).
	set alt_pid:KI to alt_ki.
	set alt_ki_tf:TEXT to num_to_str(alt_ki, 1, 5).
}.
local alt_kd_tf is box:ADDTEXTFIELD(num_to_str(alt_kd, 1, 5)).
set alt_kd_tf:ONCONFIRM to {
	parameter str.
	set alt_kd to str:TONUMBER(0.0).
	set alt_pid:KD to alt_kd.
	set alt_kd_tf:TEXT to num_to_str(alt_kd, 1, 5).
}.

// Pitch 
local l is box:ADDLABEL("Pitch").
local pit_kp_tf is box:ADDTEXTFIELD(num_to_str(pit_kp, 1, 5)).
set pit_kp_tf:ONCONFIRM to {
	parameter str.
	set pit_kp to str:TONUMBER(0.0).
	set pitch_pid:KP to pit_kp.
	set pit_kp_tf:TEXT to num_to_str(pit_kp, 1, 5).
}.
local pit_ki_tf is box:ADDTEXTFIELD(num_to_str(pit_ki, 1, 5)).
set pit_ki_tf:ONCONFIRM to {
	parameter str.
	set pit_ki to str:TONUMBER(0.0).
	set pitch_pid:KI to pit_ki.
	set pit_ki_tf:TEXT to num_to_str(pit_ki, 1, 5).
}.
local pit_kd_tf is box:ADDTEXTFIELD(num_to_str(pit_kd, 1, 5)).
set pit_kd_tf:ONCONFIRM to {
	parameter str.
	set pit_kd to str:TONUMBER(0.0).
	set pitch_pid:KD to pit_kd.
	set pit_kd_tf:TEXT to num_to_str(pit_kd, 1, 5).
}.

// Roll 
local l is box:ADDLABEL("Roll").
local roll_kp_tf is box:ADDTEXTFIELD(num_to_str(roll_kp, 1, 5)).
set roll_kp_tf:ONCONFIRM to {
	parameter str.
	set roll_kp to str:TONUMBER(0.0).
	set roll_pid:KP to roll_kp.
	set roll_kp_tf:TEXT to num_to_str(roll_kp, 1, 5).
}.
local roll_ki_tf is box:ADDTEXTFIELD(num_to_str(roll_ki, 1, 5)).
set roll_ki_tf:ONCONFIRM to {
	parameter str.
	set roll_ki to str:TONUMBER(0.0).
	set roll_pid:KI to roll_ki.
	set roll_ki_tf:TEXT to num_to_str(roll_ki, 1, 5).
}.
local roll_kd_tf is box:ADDTEXTFIELD(num_to_str(roll_kd, 1, 5)).
set roll_kd_tf:ONCONFIRM to {
	parameter str.
	set roll_kd to str:TONUMBER(0.0).
	set roll_pid:KD to roll_kd.
	set roll_kd_tf:TEXT to num_to_str(roll_kd, 1, 5).
}.

// Speed 
local l is box:ADDLABEL("Throttle").
local spd_kp_tf is box:ADDTEXTFIELD(num_to_str(spd_kp, 1, 5)).
set spd_kp_tf:ONCONFIRM to {
	parameter str.
	set spd_kp to str:TONUMBER(0.0).
	set spd_pid:KP to spd_kp.
	set spd_kp_tf:TEXT to num_to_str(spd_kp, 1, 5).
}.
local spd_ki_tf is box:ADDTEXTFIELD(num_to_str(spd_ki, 1, 5)).
set spd_ki_tf:ONCONFIRM to {
	parameter str.
	set spd_ki to str:TONUMBER(0.0).
	set spd_pid:KI to spd_ki.
	set spd_ki_tf:TEXT to num_to_str(spd_ki, 1, 5).
}.
local spd_kd_tf is box:ADDTEXTFIELD(num_to_str(spd_kd, 1, 5)).
set spd_kd_tf:ONCONFIRM to {
	parameter str.
	set spd_kd to str:TONUMBER(0.0).
	set spd_pid:KD to spd_kd.
	set spd_kd_tf:TEXT to num_to_str(spd_kd, 1, 5).
}.

// Vertical Speed 
local l is box:ADDLABEL("Vertical Speed").
local vs_kp_tf is box:ADDTEXTFIELD(num_to_str(vs_kp, 1, 5)).
set vs_kp_tf:ONCONFIRM to {
	parameter str.
	set vs_kp to str:TONUMBER(0.0).
	set vs_pid:KP to vs_kp.
	set vs_kp_tf:TEXT to num_to_str(vs_kp, 1, 5).
}.
local vs_ki_tf is box:ADDTEXTFIELD(num_to_str(vs_ki, 1, 5)).
set vs_ki_tf:ONCONFIRM to {
	parameter str.
	set vs_ki to str:TONUMBER(0.0).
	set vs_pid:KI to vs_ki.
	set vs_ki_tf:TEXT to num_to_str(vs_ki, 1, 5).
}.
local vs_kd_tf is box:ADDTEXTFIELD(num_to_str(vs_kd, 1, 5)).
set vs_kd_tf:ONCONFIRM to {
	parameter str.
	set vs_kd to str:TONUMBER(0.0).
	set vs_pid:KD to vs_kd.
	set vs_kd_tf:TEXT to num_to_str(vs_kd, 1, 5).
}.

// Yaw 
local l is box:ADDLABEL("Yaw").
local yaw_kp_tf is box:ADDTEXTFIELD(num_to_str(yaw_kp, 1, 5)).
set yaw_kp_tf:ONCONFIRM to {
	parameter str.
	set yaw_kp to str:TONUMBER(0.0).
	set yaw_pid:KP to yaw_kp.
	set yaw_kp_tf:TEXT to num_to_str(yaw_kp, 1, 5).
}.
local yaw_ki_tf is box:ADDTEXTFIELD(num_to_str(yaw_ki, 1, 5)).
set yaw_ki_tf:ONCONFIRM to {
	parameter str.
	set yaw_ki to str:TONUMBER(0.0).
	set yaw_pid:KI to yaw_ki.
	set yaw_ki_tf:TEXT to num_to_str(yaw_ki, 1, 5).
}.
local yaw_kd_tf is box:ADDTEXTFIELD(num_to_str(yaw_kd, 1, 5)).
set yaw_kd_tf:ONCONFIRM to {
	parameter str.
	set yaw_kd to str:TONUMBER(0.0).
	set yaw_pid:KD to yaw_kd.
	set yaw_kd_tf:TEXT to num_to_str(yaw_kd, 1, 5).
}.

// -------- Fly to Page ----------
local page is AddTab(tabwidget, "Control").
local takeoff_btn is page:ADDBUTTON("Takeoff").
set takeoff_btn:ONCLICK to { 

	if mode = mode_idle {
		set alt_cmd to 3000.
		set mode to mode_takeoff.
	}.
}.
local params is page:ADDVBOX.
local line is params:ADDHBOX.
local l is line:ADDLABEL("Altitude:").
local alt_field is line:ADDTEXTFIELD(num_to_str(SHIP:ALTITUDE, 1, 0)).
local line is params:ADDHBOX.
local l is line:ADDLABEL("Speed:").
local speed_field is line:ADDTEXTFIELD(num_to_str(SHIP:AIRSPEED, 1, 0)).
local line is params:ADDHBOX.
local l is line:ADDLABEL("Heading:").
local hdg_field is line:ADDTEXTFIELD(num_to_str(compass_for(), 1, 0)).
local line is params:ADDHBOX.
local l is line:ADDLABEL("Max Vertical Speed:").
local vs_field is line:ADDTEXTFIELD("75").
local fly_engage_btn is page:ADDBUTTON("Engage").
set fly_engage_btn:ONCLICK to { 
	set alt_cmd to str_to_num(alt_field:TEXT:TRIM()).
	set spd_cmd to str_to_num(speed_field:TEXT:TRIM()).
	set hdg_cmd to str_to_num(hdg_field:TEXT:TRIM()).
	set mode to mode_fly_at. 
}.
local orbit_btn is page:ADDBUTTON("Go to Orbit").
set orbit_btn:ONCLICK to {
	set mode to mode_climbout.
}.

local deorbit_btn is page:ADDBUTTON("Deorbit").
set deorbit_btn:ONCLICK to {
	set mode to mode_deorbit.
}.

local approach_btn is page:ADDBUTTON("Approach").
set approach_btn:ONCLICK to {
	set mode to mode_approach.
}.

local close_btn is gui:ADDBUTTON("Close").
set close_btn:ONCLICK to { set done to true. }.

gui:SHOW().

ChooseTab(tabwidget, 1).

until done {
	if (debug) {
		print "MODE : " + mode AT(0,0).
	}.
	if last_mode <> mode {
		if debug {
			print mode + ", " + last_mode AT (0,3).
		}.
		if mode = mode_takeoff {
			takeoff_init().
		} else if mode = mode_fly_at {
			fly_at_init().
		} else if mode = mode_climbout {
			climbout_init().
		} else if mode = mode_apoapsis {
			apoapsis_init().
		} else if mode = mode_circularize {
			circularize_init().
		} else if mode = mode_deorbit {
			deorbit_init().
		} else if mode = mode_reentry {
			reentry_init().
		}.
	}.

	if mode = mode_takeoff {
		takeoff_process().
	} else if mode = mode_fly_at {
		fly_at_process().
	} else if mode = mode_approach {
		approach_process(location_constants:kerbin:runway_09_start, location_constants:kerbin:runway_09_end, 90).
	} else if mode = mode_climbout {
		climbout_process().	
	} else if mode = mode_apoapsis {
		apoapsis_process().	
	} else if mode = mode_circularize {
		circularize_process().	
	} else if mode = mode_deorbit {
		deorbit_process().	
	} else if mode = mode_reentry {
		reentry_process().	
	}.

	wait 0.01.
}.
gui:HIDE().
