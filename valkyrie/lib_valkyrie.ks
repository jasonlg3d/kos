runpath("lib/lib_navball").
runpath("lib/lib_location_constants").
clearscreen.

global alt_kp is 0.083.
global alt_ki is 0.0.
global alt_kd is 0.015.
global alt_pid is PIDLOOP(alt_kp, alt_ki, alt_kd).

global pit_kp is 0.00110.
global pit_ki is 0.00001.
global pit_kd is 0.00440.
global pitch_pid is PIDLOOP(pit_kp, pit_ki, pit_kd).

global roll_kp is 0.00020.
global roll_ki is 0.0.
global roll_kd is 0.001.
global roll_pid is PIDLOOP(roll_kp, roll_ki, roll_kd).

global spd_kp is 0.0016.
global spd_ki is 0.0.
global spd_kd is 0.0121.
global spd_pid is PIDLOOP(spd_kp, spd_ki, spd_kd).

global vs_kp is 0.031.
global vs_ki is 0.00000.
global vs_kd is 0.081.
global vs_pid to PIDLOOP(vs_kp, vs_ki, vs_kd).

global yaw_kp is 0.0007.
global yaw_ki is 0.0.
global yaw_kd is 0.00680.
global yaw_pid is PIDLOOP(yaw_kp, yaw_ki, yaw_kd).

global mode_idle is 0.
global mode_takeoff is 1.
global mode_fly_at is 2.
global mode_approach is 3.
global mode_climbout is 4.
global mode_apoapsis is 5.
global mode_circularize is 6.
global mode_deorbit is 7.
global mode_reentry is 8.
global mode is mode_idle. 
global last_mode is mode_idle.

global alt_cmd is 0.
global bank_cmd is 0.
global hdg_cmd is 0.
global pit_cmd is 0.
global spd_cmd is 0.
global vs_cmd is 0.

global bank_limit is 30.
global yaw_limit is 0.8.
global pitch_max is 25.
global pitch_min is -15.
global vs_max is 75.
global vs_min is -100.

global full_stop is false.
global debug is true.
global turn_right_prev is true.
global last_term_height is TERMINAL:HEIGHT.
global ready_to_deorbit_burn is false.
global periapsis_cmd is 0.
global warp_complete is false.
global is_warping is false.
global retro_burn_lng is 90.
global ready_for_approach is false.
global fly_at_initialized is false.
global counter is 0.

function reset_pids {
	alt_pid:RESET().
	pitch_pid:RESET().
	roll_pid:RESET().
	spd_pid:RESET().
	vs_pid:RESET().
	yaw_pid:RESET().
}.

function deorbit_init {
	if debug {
		print "deorbit_init called.           " AT (0,2).
	}.

	RCS ON.
	lock STEERING to SHIP:RETROGRADE.
	lock THROTTLE to 0.
	set periapsis_cmd to 50000.
	set ready_to_deorbit_burn to false.
	set warp_complete to false.
	set is_warping to false.
}.

function deorbit_process {
	set last_mode to mode_deorbit.
	local thrott is 0.
	lock THROTTLE to thrott.
	if not ready_to_deorbit_burn {
		print "Steering error: " + STEERINGMANAGER:ANGLEERROR + "          " AT (0,4).
		print "SHIP:GEOPOSITION:LNG:    " + SHIP:GEOPOSITION:LNG + "          " AT(0,5).
		if not warp_complete {
			if SHIP:GEOPOSITION:LNG > retro_burn_lng - 10 AND SHIP:GEOPOSITION:LNG < retro_burn_lng {
				print "Warp complete.           " AT (0,6).
				KUNIVERSE:TIMEWARP:CANCELWARP().
				set warp_complete to true.
				set is_warping to false.
			} else {
				set KUNIVERSE:TIMEWARP:MODE to "RAILS".
				set KUNIVERSE:TIMEWARP:WARP to 3.
				set is_warping to true.
			}.
		
		} else {
			lock STEERING to SHIP:RETROGRADE.
			if ((abs(STEERINGMANAGER:ANGLEERROR) < 0.5) AND (SHIP:GEOPOSITION:LNG >= retro_burn_lng)) {
				lock STEERING to SHIP:RETROGRADE.
				set ready_to_deorbit_burn to true.
			}.
		}.

		if debug {
			print_state().
		}
	} else if SHIP:PERIAPSIS > periapsis_cmd {
		set thrott to thrott + 0.1.
		lock STEERING to SHIP:RETROGRADE.
		if debug {
			print_state().
		}.
	} else {
		set thrott to 0.0.
		set mode to mode_reentry.
	}.
}.

global reentry_ready is false.
function reentry_init {
	RCS ON.
	BRAKES OFF.
	lock STEERING to SHIP:PROGRADE.
	wait 10.
	set reentry_ready to false.
	set hdg_cmd to compass_for().
	set warp_complete to false.
	set is_warping to false.
	set ready_for_approach to false.
	set fly_at_initialized to false.
}.

function reentry_process {
	set last_mode to mode_reentry.
	if not reentry_ready {
		print "Reentry not ready...                 " AT(0,4).
		if not warp_complete {
			if SHIP:ALTITUDE > 72000 AND not is_warping {
				set KUNIVERSE:TIMEWARP:MODE to "RAILS".
				set KUNIVERSE:TIMEWARP:WARP to 2.
				set is_warping to true.
			} else if SHIP:ALTITUDE < 72000 {
				print "Warp complete.           " AT (0,6).
				set warp_complete to true.
				KUNIVERSE:TIMEWARP:CANCELWARP().
				set is_warping to false.
			}.
		} else {
			print "Steering error: " + STEERINGMANAGER:ANGLEERROR + "          " AT (0,4).
			if (abs(STEERINGMANAGER:ANGLEERROR) < 0.08) {
				set hdg to compass_for().
				set reentry_ready to true.
				if debug { clearscreen. }.
			}.
		}.

		if debug {
			print_state().
		}.
	} else {
		if SHIP:ALTITUDE > 7000 {
			activate_surfaces().
			set pit to 90.
			lock THROTTLE to 0.
			print "Reentry phase...                 " AT(0,4).

			lock STEERING to HEADING(hdg, pit).

			if (SHIP:ALTITUDE < 64500) {
				set pit to 45.
			}.

			if (SHIP:ALTITUDE < 59000) {
				set pit to 25.
			}.

			if (SHIP:ALTITUDE < 54000) {
				set pit to 19.
			}.

			if (SHIP:ALTITUDE < 48000) {
				set pit to 17.
				BRAKES ON.
				RCS OFF.
			}.

			if (SHIP:ALTITUDE < 45000) {
				set pit to 16.
			}.

			if (SHIP:AIRSPEED < 1200) {
				set pit to 18.
			}.
				
			if SHIP:AIRSPEED < 800 {
				set pit to 1/45 * SHIP:AIRSPEED - 18.
				BRAKES OFF.
			}.

			print_state().
			print "Pitching to " + pit + " deg                " AT (0,8).
		} else {
			print "Approach phase... " + counter + "                 " AT(0,4).
			local td is location_constants:kerbin:runway_09_start.

			if not ready_for_approach {
				shutdown_nukes().
				open_intakes().
				start_rapiers().
				set_rapiers_to_air().
				activate_surfaces().
				BRAKES OFF.
				set hdg_cmd to location_constants:kerbin:runway_09_start:HEADING.
				set alt_cmd to 6500.
				set spd_cmd to 250.
				set ready_for_approach to true.
				print "Ready for approach                  " AT(0,8).
			}.

			if td:DISTANCE > 50000 {
				print "Flying towards KSC... " + counter + "          " AT (0,5).
				if not fly_at_initialized {
					print "Initializing PIDs... " + counter + "          " AT (0,6).
					reset_pids().

					set pitch_cmd to pitch_for().
					set vs_cmd to 0.
					set spd_cmd to 250.

					set alt_pid:SETPOINT to alt_cmd.
					set pitch_pid to pitch_cmd.
					set vs_pid:SETPOINT to vs_cmd.
					set spd_pid:SETPOINT to spd_cmd.
					set yaw_pid:SETPOINT to hdg_cmd.
					set fly_at_initialized to true.
				}.

				maintain_alt().
				maintain_heading().
				maintain_speed().
				print_state().
			} else {
				print "Making final approach... " + counter + "          " AT (0,5).
				set mode to mode_approach.
			}.
		}.
	}.
	increment_counter().
}.

function increment_counter {
	set counter to counter + 1.
	if counter > 9 {
		set counter to 0.
	}.
}.

function circularize_init {
	clearscreen.
	if debug {
		print "circularize_init called." AT(0, 2).
	}.
	
	alert().
	shutdown_rapiers().
	lock THROTTLE to 0.
}.

function circularize_process {
	set last_mode to mode_circularize.

	if debug {
		print "circularize_process called." AT(0, 2).
	}.
	
	if SHIP:ALTITUDE < 70000 {
		lock STEERING to SHIP:PROGRADE.

		if debug {
			set row to 4.
			print_state().
		}.
	} else {
		disable_surfaces().	
		RCS ON.
		print "Circularizing...                   " AT (0,4).
		circ().
		clearscreen.
		print "Launch complete.".
		set mode to mode_idle.
	}
}.

function apoapsis_init {
	clearscreen.
	if debug {
		print "apoapsis_init called." AT(0, 2).
	}.

	alert().
	start_nukes().
	set_rapiers_to_closed_cycle().
	close_intakes().
}.

function apoapsis_process {
	set last_mode to mode_apoapsis.

	if debug {
		print "apoapsis_process called." AT(0, 2).
	}.

	set apoapsis_tgt to 85000.
	set pit to pitch_for().

	if SHIP:ALTITUDE < 600000 {	
		if SHIP:APOAPSIS < apoapsis_tgt {
			lock STEERING to HEADING(hdg_cmd, pit_cmd).
			set pit_cmd to pit_cmd + 0.035.

			if (pit_cmd > 45) {
				set pit_cmd to 45.
			}.

			if debug {
				set row to 4.
				print_state().
			}.
		} else {
			set mode to mode_circularize.
		}.
	} else {

	}.
}.

function climbout_init {
	clearscreen.
	if debug {
		print "climbout_init called." AT(0, 2).
	}.

	alert().
	reset_pids().
	set vs_cmd to 10.
	set pit_cmd to pitch_for().
	set hdg_cmd to 90.
	set spd_cmd to 250.
	set SHIP:CONTROL:PITCH to 0.
	set SHIP:CONTROL:ROLL to 0.
	set SHIP:CONTROL:YAW to 0.
}.

function climbout_process {
	set last_mode to mode_climbout.

	if debug {
		print "climbout_process called." AT(0, 2).
	}.

	local thrott is 1.
	lock THROTTLE to thrott.

	if SHIP:ALTITUDE < alt_cmd {

		set max_vs_cmd to 275.
		set min_vs_cmd to 50.
		set alt_cmd to 21000.
		print "Climbing to " + alt_cmd + " m        " AT (0, 4).
		print "Accelerating to " + spd_cmd + " m/s            " AT (0, 5).

		if SHIP:altitude < 5000 {
			set spd_cmd to 250.
		} else if ship:altitude < 8000 {
			set spd_cmd to 450.
		} else if ship:altitude < 12000 {
			set spd_cmd to 900.
		} else if ship:altitude < 15000 {
			set spd_cmd to 1100.
		} else if ship:altitude < 18000 {
			set spd_cmd to 1300.
		} else {
			set spd_cmd to 1500.
		}
		if (SHIP:AIRSPEED > spd_cmd) {
			set vs_cmd to vs_cmd + 0.20.
		} else {
			set vs_cmd to vs_cmd - 0.15.
		}.

		if vs_cmd > max_vs_cmd {
			set vs_cmd to max_vs_cmd.
		}.

		if (vs_cmd < min_vs_cmd) {
			set vs_cmd to min_vs_cmd.
		}.

		set vs_pid:SETPOINT to vs_cmd.
		local d_pit is vs_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED) * 300 / SHIP:AIRSPEED.
		if d_pit > 0.25 { set d_pit to 0.25 * 200 / SHIP:AIRSPEED. }
		else if d_pit < -0.25 { set d_pit to -0.25 * 300 / SHIP:AIRSPEED. }
		print "Delta pitch: " + d_pit + " deg              " AT (0,6).

		set pit_cmd to pit_cmd + d_pit.
		
		if (pit_cmd > pitch_max) {
			set pit_cmd to pitch_max.
		} else if (pit_cmd < pitch_min) {
			set pit_cmd to pitch_min.
		}.

		lock STEERING to HEADING(hdg_cmd, pit_cmd).

		if debug {
			set row to 4.
			print_state().
		}.
	} else {
		set mode to mode_apoapsis.
	}
}.

function approach_init {
	clearscreen.
	if debug {
		print "approach_init called." AT(0, 2).
	}.
}.

function approach_process {
	set last_mode to mode_approach.

	if debug {
		print "approach_process called." AT(0, 2).
	}.

	parameter pt_a.
	parameter pt_b.
	parameter rwy_hdg.

	local brg_a is pt_a:BEARING.
	local brg_b is pt_b:BEARING.

	local hdg_a is pt_a:HEADING.
	local hdg_b is pt_b:HEADING.

	local brg_diff is brg_a - brg_b.	

	local intercept_hdg is 0.
	local hdg_diff is hdg_a - compass_for().
	
	if (brg_a < 0) {
		set intercept_hdg to rwy_hdg + 30.
	} else {
		set intercept_hdg to rwy_hdg - 30.
	}.

	if abs(brg_diff) > 0.4 {
		set hdg_cmd to intercept_hdg.	
	} else {
		set hdg_cmd to compass_for() + 1.3 * hdg_diff + brg_diff.
	}.

	if not full_stop {

		set alt_cmd to pt_a:DISTANCE * sin(4).
		
		if SHIP:ALTITUDE < alt_cmd {
			set alt_cmd to SHIP:ALTITUDE.
		}.

		local td_alt is pt_a:TERRAINHEIGHT.

		if SHIP:ALTITUDE < td_alt + 200 {
			GEAR ON.
		}.

		if pt_a:DISTANCE > 10000 {
			set spd_cmd to 180.
			BRAKES OFF.
		} else if pt_a:DISTANCE > 7500 {
			set spd_cmd to 145.
		} else if pt_a:DISTANCE > 1500 {
			set spd_cmd to 90.
			set bank_limit to 3.
		} else if pt_a:DISTANCE < 500 {
			set hdg_cmd to compass_for() + brg_b. 
			set spd_cmd to 65.
			set bank_limit to 0.
			set full_stop to true.
		}.

		maintain_heading().
		maintain_alt().
	} else {
		local flare is 5.
		if SHIP:BOUNDS:BOTTOMALTRADAR < 10 {
			set spd_cmd to 0.
			set flare to 15.
		}.

		if SHIP:BOUNDS:BOTTOMALTRADAR < 2 {
			BRAKES ON.
		}.

		set SHIP:CONTROL:PITCH to 0.
		set SHIP:CONTROL:ROLL to 0.
		set SHIP:CONTROL:YAW to 0.

		lock STEERING to HEADING(pt_b:HEADING, flare).
		
		if (SHIP:AIRSPEED <= 3) {
			shutdown_rapiers().
		}.
	}.
	maintain_speed().
	
	if (debug) {
		set row to 4.
		print "RWY:         " + round(rwy_hdg, 1) AT(0,row).
		set row to row + 1.
		print "intercept_hdg: " + round(intercept_hdg, 1) AT(0,row).
		set row to row + 1.
		print "brg_diff: " + round(brg_diff, 5) AT(0,row).
		set row to row + 1.
		print "Heading A: " + round(hdg_a, 5) AT(0,row).
		set row to row + 1.
		print "Heading B: " + round(hdg_b, 5) AT(0,row).
		set row to row + 1.
		print "Bearing A: " + round(brg_a, 5) AT(0,row).
		set row to row + 1.
		print "Bearing B: " + round(brg_b, 5) AT(0,row).
		set row to row + 1.
		print "Distance A: " + round(pt_a:DISTANCE, 5) AT(0,row).
		set row to row + 1.
		print "Distance B: " + round(pt_b:DISTANCE, 5) AT(0,row).
		set row to row + 1.
		print "Altitude A: " + round(pt_a:TERRAINHEIGHT, 5) AT(0,row).
		set row to row + 1.
		print_state().
	}
}.

function fly_at_init {
	clearscreen.
	if debug {
		print "fly_at_init called." AT(0, 1).
	}.
	
	reset_pids().

	set pitch_cmd to pitch_for().
	set vs_cmd to 0.

	set alt_pid:SETPOINT to alt_cmd.
	set vs_pid:SETPOINT to vs_cmd.
	set spd_pid:SETPOINT to spd_cmd.
	set yaw_pid:SETPOINT to hdg_cmd.
}.

function fly_at_process {
	if debug {
		print "fly_at_process called." AT(0, 2).
	}.

	set last_mode to mode_fly_at.

	maintain_alt().
	maintain_heading().
	maintain_speed().

	if debug {
		set row to 4.
		print_state().
	}.
}.

function takeoff_init {
	clearscreen.
	if debug {
		print "takeoff_init called." AT(0, 1).
	}.
	start_rapiers().
	set_rapiers_to_air().
	shutdown_nukes().
	BRAKES OFF.
	
	if MAXTHRUST = 0 {
		stage.
	}.

	set pit_cmd to 0.
	set hdg_cmd to 90.
}.

function takeoff_process {
	if debug {
		print "takeoff_process called." AT(0, 2).
	}.

	set last_mode to mode_takeoff.


	if SHIP:BOUNDS:BOTTOMALTRADAR < 300 {
		lock THROTTLE to 1.0.
		
		if SHIP:AIRSPEED > 145 {
			set hdg_cmd to 90.
			set pit_cmd to 35.
		} else {
			set hdg_cmd to location_constants:kerbin:runway_09_end:HEADING.
			set pit_cmd to 0.
		}.

		if SHIP:VERTICALSPEED > 10 {
			GEAR OFF.
			set pit_cmd to 22.
		}.

		lock STEERING to HEADING(hdg_cmd, pit_cmd).

		if debug {
			set row to 4.
			print_state().
		}.
	} else {
		set hdg_cmd to 90.
		set vs_cmd to 50.
		set spd_cmd to 220.
		set mode to mode_fly_at.
	}.
}.

function maintain_alt {
	set alt_pid:SETPOINT to alt_cmd.
	set vs_cmd to alt_pid:UPDATE(TIME:SECONDS, SHIP:ALTITUDE).

	if SHIP:AIRSPEED < 300 {
		set vs_max to 50.
	} else {
		set vs_max to 75.
	}.

	if (vs_cmd > vs_max) {
		set vs_cmd to vs_max.
	} else if (vs_cmd < vs_min) {
		set vs_cmd to vs_min.
	}.

	maintain_vs().
}.

function maintain_vs {
	set vs_pid:SETPOINT to vs_cmd.
	set pit_cmd to pit_cmd + vs_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED).
	if (SHIP:AIRSPEED < 200) {
		if (pit_cmd > 22) {
			set pit_cmd to 20.
		}.
	}.

	if (pit_cmd > pitch_max) {
		set pit_cmd to pitch_max.
	} else if (pit_cmd < pitch_min) {
		set pit_cmd to pitch_min.
	}.

	set pitch_pid:SETPOINT to pit_cmd.
	set SHIP:CONTROL:PITCH to SHIP:CONTROL:PITCH + pitch_pid:UPDATE(TIME:SECONDS, pitch_for()).

	if SHIP:AIRSPEED > 300 {
		set pitch_pid:KP to pit_kp * (2500 - SHIP:AIRSPEED) / 2500.
		set pitch_pid:KI to pit_ki * (2500 - SHIP:AIRSPEED) / 2500.
		set pitch_pid:KD to pit_kd * (2500 - SHIP:AIRSPEED) / 2500.
	}.
}.

function maintain_heading {
	local curr_hdg is compass_for().
	local hdg_mod is mod(curr_hdg - hdg_cmd + 360, 360).
	local turn_right is hdg_mod > 180.
	local hdg_err is 0.

	if turn_right {
		if hdg_cmd < curr_hdg {
			set hdg_err to -((360 - curr_hdg) + hdg_cmd).
		} else {
			set hdg_err to curr_hdg - hdg_cmd.
		}.
	} else {
		if hdg_cmd > curr_hdg + 180 {
			set hdg_err to 360 - hdg_cmd + curr_hdg.
		} else {
			set hdg_err to curr_hdg - hdg_cmd.
		}.
	}.

	if curr_hdg >= 0 AND curr_hdg < 90 {
	} else if curr_hdg >= 90 AND curr_hdg < 180 {
	} else if curr_hdg >= 180 AND curr_hdg < 270 {
	} else {
	}.

	set bank_cmd to hdg_err * -5.

	if (bank_cmd > bank_limit) { set bank_cmd to bank_limit. }
	else if bank_cmd < -bank_limit { set bank_cmd to -bank_limit. }.

	set roll_pid:SETPOINT to bank_cmd.
	set SHIP:CONTROL:ROLL to SHIP:CONTROL:ROLL + roll_pid:UPDATE(TIME:SECONDS, roll_for()).

	if turn_right <> turn_right_prev {
		set SHIP:CONTROL:YAW to 0.
	}.

	if not (abs(roll_pid:ERROR) > 10 AND abs(bank_cmd) = bank_limit) {
		set yaw_pid:SETPOINT to 0.
		set SHIP:CONTROL:YAW to SHIP:CONTROL:YAW + yaw_pid:UPDATE(TIME:SECONDS, hdg_err).
		if SHIP:CONTROL:YAW > yaw_limit { set SHIP:CONTROL:YAW to yaw_limit. }.
		else if SHIP:CONTROL:YAW < -yaw_limit { set SHIP:CONTROL:YAW to -yaw_limit. }.
	}

	set turn_right_prev to turn_right.
}.

function maintain_speed {
	set spd_pid:SETPOINT to spd_cmd.
	set dv_thrott to spd_pid:UPDATE(TIME:SECONDS, SHIP:AIRSPEED).
	lock THROTTLE to THROTTLE + dv_thrott.
}.

function start_rapiers {
	SET rapier_list to SHIP:PARTSTAGGED("rapier").

	for eng in rapier_list {
		eng:ACTIVATE.
	}.
}.

function shutdown_rapiers {
	SET rapier_list to SHIP:PARTSTAGGED("rapier").

	for eng in rapier_list {
		eng:SHUTDOWN.
	}.
}.

function start_nukes {
	SET nuke_list to SHIP:PARTSTAGGED("nuke").

	for eng in nuke_list {
		eng:ACTIVATE.
	}.
}.

function shutdown_nukes {
	SET nuke_list to SHIP:PARTSTAGGED("nuke").

	for eng in nuke_list {
		eng:SHUTDOWN.
	}.
}.

function set_rapiers_to_air {
	SET rapier_list to SHIP:PARTSTAGGED("rapier").

	for eng in rapier_list {
		set module to eng:GETMODULE("MultiModeEngine").
		if module:GETFIELD("mode") = "ClosedCycle" {
			module:DOACTION("switch mode", true).
		}
	}.
}.

function set_rapiers_to_closed_cycle {
	SET rapier_list to SHIP:PARTSTAGGED("rapier").

	for eng in rapier_list {
		set module to eng:GETMODULE("MultiModeEngine").
		if module:GETFIELD("mode") = "AirBreathing" {
			module:DOACTION("switch mode", true).
		}
	}.
}.

function close_intakes {
	set intake_list to SHIP:PARTSTAGGED("intake").

	for intake in intake_list {
		set module to intake:GETMODULE("ModuleResourceIntake").
		if module:GETFIELD("status") <> "Closed" {
			module:DOACTION("toggle intake", true).
		}.
	}.
}.

function open_intakes {
	set intake_list to SHIP:PARTSTAGGED("intake").

	for intake in intake_list {
		set module to intake:GETMODULE("ModuleResourceIntake").
		if module:GETFIELD("status") = "Closed" {
			module:DOACTION("toggle intake", true).
		}.
	}.
}.

function deploy_airbrakes {
	set ab_list to SHIP:PARTSTAGGED("airbrake").
	for brake in ab_list {
		set module to brake:GETMODULE("ModuleAeroSurface").
		module:DOACTION("extend", true).
	}.
}.

function retract_airbrakes {
	set ab_list to SHIP:PARTSTAGGED("airbrake").
	for brake in ab_list {
		set module to brake:GETMODULE("ModuleAeroSurface").
		module:DOACTION("retract", true).
	}.
}.

function disable_surfaces {
	TOGGLE AG3.
}.

function activate_surfaces {
	TOGGLE AG4.
}

function circ {
	//circularization script, starts immediately when called.
	set th to 0.
	lock throttle to th.
	set dV to ship:facing:vector:normalized.
	lock steering to lookdirup(dV, ship:facing:topvector).

	local timeout is time:seconds + 9000.
	when dV:mag < 0.05 then set timeout to time:seconds + 3.
	until dV:mag < 0.02 or time:seconds > timeout {
		set posVec to ship:position - body:position.
		set vecNormal to vcrs(posVec,velocity:orbit).
		set vecHorizontal to -1 * vcrs(ship:position-body:position, vecNormal).
		set vecHorizontal:mag to sqrt(body:MU/(body:Radius + altitude)). //this is the desired velocity vector to obtain circular orbit at current altitude

		set dV to vecHorizontal - velocity:orbit. //deltaV as a vector

		//Debug vectors
		//set mark_n to VECDRAWARGS(ship:position, vecNormal:normalized * (velocity:orbit:mag / 100), RGB(1,0,1), "n", 1, true).
		//set mark_h to VECDRAWARGS(ship:position, vecHorizontal / 100, RGB(0,1,0), "h", 1, true).
		//set mark_v to VECDRAWARGS(ship:position, velocity:orbit / 100, RGB(0,0,1), "dv", 1, true).
		//set mark_dv to VECDRAWARGS(ship:position + velocity:orbit / 100, dV, RGB(1,1,1), "dv", 1, true).

		//throttle control
		if vang(ship:facing:vector,dV) > 1 { set th to 0. }
		else { set th to max(0,min(1,dV:mag/10)). }
		print_state().
		print "dV: " + dv + "                   " AT (0,1).
		wait 0.1.
	}.
}.

function alert {
	set v0 to GetVoice(0).
	set v0:VOLUME to 1.0.
	v0:PLAY(NOTE(440, 1)).

	v0:PLAY(
		LIST(
			NOTE("A#4", 0.2, 0.25),
			NOTE("A4", 0.2, 0.25),
			NOTE("R", 0.2, 0.25),
			SLIDENOTE("C5", "F5", 0.45, 0.5),
			NOTE("R", 0.2, 0.25)
		)
	).
}.

function print_state {
	if last_term_height <> TERMINAL:HEIGHT { clearscreen. }
	set last_term_height to TERMINAL:HEIGHT.
	set row to TERMINAL:HEIGHT - 22.
	print "Heading: ...............  " + round(compass_for(), 2) + " deg                 " AT (0, row).	
	set row to row + 1.
	print "Pitch: .................  " + round(pitch_for(), 2) + " deg                  " AT (0, row).
	set row to row + 1.
	print "Radar Alt: .............  " + round(SHIP:BOUNDS:BOTTOMALTRADAR,1) + " m          " AT (0, row).
	set row to row + 1.
	print "Airspeed: ..............  " + round(SHIP:AIRSPEED, 1) + " m/s                " AT(0, row).
	set row to row + 1.
	print "Altitude (sea): ........  " + round(SHIP:ALTITUDE, 0) + " m                  " AT (0, row).
	set row to row + 1.
	print "Vertical Speed: ........  " + round(SHIP:VERTICALSPEED,2) + " m/s           " AT (0, row).
	set row to row + 1.
	print "Orbit Velocity: ........  " + round(SHIP:ORBIT:VELOCITY:ORBIT:MAG, 1) + " m/s " AT (0,row).
	set row to row + 1.
	print "Orbit Velocity(sfc): ...  " + round(SHIP:ORBIT:VELOCITY:ORBIT:MAG, 1) + " m/s " AT (0,row).
	set row to row + 1.
	print "alt_cmd: ...............  " + round(alt_cmd, 0) + " m          " AT (0, row).
	set row to row + 1.
	print "bank_cmd: ..............  " + round(bank_cmd, 5) + " deg        " AT(0,row).
	set row to row + 1.
	print "hdg_cmd: ...............  " + round(hdg_cmd,5) + " deg          " AT (0, row).
	set row to row + 1.
	print "pit_cmd: ...............  " + round(pit_cmd,5) + " deg          " AT (0, row).
	set row to row + 1.
	print "spd_cmd: ...............  " + round(spd_cmd, 1) + " m/s          " AT (0, row).
	set row to row + 1.
	print "vs_cmd: ................  " + round(vs_cmd, 1) + " m/s          " AT (0, row).
	set row to row + 1.
	print "Alt Error: .............  " + round(alt_pid:ERROR, 5) + " m          " AT(0,row).
	set row to row + 1.
	print "Bank Error: ............  " + round(roll_pid:ERROR, 5) + " deg        " AT(0,row).
	set row to row + 1.
	print "Heading Error: .........  " + round(yaw_pid:ERROR, 5) + " deg        " AT(0,row).
	set row to row + 1.
	print "Pitch error: ...........  " + round(pitch_pid:ERROR, 5) + " deg          " AT (0, row).
	set row to row + 1.
	print "VS error: ..............  " + round(vs_pid:ERROR,2) + " m/s          " AT (0, row).
	set row to row + 1.
	print "SHIP:CONTROL:ROLL: .....  " + round(SHIP:CONTROL:ROLL,5) + "           " AT (0, row).
	set row to row + 1.
	print "SHIP:CONTROL:PITCH: ....  " + round(SHIP:CONTROL:PITCH,5) + "           " AT (0, row).
	set row to row + 1.
	print "SHIP:CONTROL:YAW: ......  " + round(SHIP:CONTROL:YAW,5) + "           " AT (0, row).
	set row to row + 1.
}.
