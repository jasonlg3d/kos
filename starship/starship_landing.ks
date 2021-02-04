CLEARSCREEN.

SET TOUCHDOWN_SPEED TO 1.0.
SET ENTRY_ANGLE TO 0.0.
SET LANDING_FLIP_ALT TO 3000.

SET ROW_STATE TO 20.

SET V0 TO GetVoice(0).

SET CURR_STATE TO "REENTRY".

SET MY_PITCH TO pitch_for().
SET MY_ROLL TO roll_for().
SET upper_tank TO SHIP:PARTSDUBBED("upper_tank")[0].
SET lower_tank TO SHIP:PARTSDUBBED("lower_tank")[0].

reentry().

function reentry {
	update_params().

	LOCK THROTTLE TO 0.
	SET CURR_STATE TO "REENTRY".

	SET Kp TO 0.5.
	SET Ki TO 0.0000000003.
	SET Kd TO 3.7.

	SET PID TO PIDLOOP(Kp, Ki, Kd).	

	SET PID:SETPOINT TO ENTRY_ANGLE.

	SET transfer_amt TO 0.

	UNTIL MY_ALT < LANDING_FLIP_ALT {
		update_params().


		SET PITCH_ERR TO ABS(ENTRY_ANGLE - MY_PITCH).

		if (PITCH_ERR > 3.0) {
			RCS ON.
		} else {
			RCS OFF.
		}.


		SET HEAD TO HEADING(SHIP:BEARING, ENTRY_ANGLE).
		SAS OFF.

		SET pitch_offset TO ENTRY_ANGLE - SHIP:SRFPROGRADE:PITCH.
		
		LOCAL up_angle IS UP.
		up_angle.
		LOCAL vec_pro_horizon IS VXCL(up_angle,PROGRADE:VECTOR).
		PRINT "pitch_offset: " + pitch_offset AT(0,0).
		PRINT SHIP:SRFPROGRADE AT (0, 1).
		LOCK STEERING TO vec_pro_horizon + R(0, 0, ENTRY_ANGLE).
		LOCK THROTTLE TO 0.0.
		
		SET transfer_amt TO PID:UPDATE(TIME:SECONDS, MY_PITCH).

		if (transfer_amt > 0) {
			SET lf_xfr TO TRANSFER("liquidfuel", upper_tank, lower_tank, transfer_amt).
			SET ox_xfr TO TRANSFER("oxidizer", upper_tank, lower_tank, transfer_amt).
			SET lf_xfr:ACTIVE TO TRUE.
			SET ox_xfr:ACTIVE TO TRUE.

			SET complete TO FALSE.

			UNTIL complete {
				print_stats_land("Transferring " + transfer_amt + " from upper tank. " + ox_xfr:STATUS, ox_xfr:MESSAGE).
				if (lf_xfr:STATUS = "Finished" OR ox_xfr:STATUS = "Finished") {
					SET complete TO TRUE.
					SET lf_xfr:ACTIVE TO FALSE.
					SET ox_xfr:ACTIVE TO FALSE.
				}.
				if (lf_xfr:STATUS = "Failed" OR ox_xfr:STATUS = "Failed") {
					SET complete TO TRUE.
					SET lf_xfr:ACTIVE TO FALSE.
					SET ox_xfr:ACTIVE TO FALSE.
				}.
				WAIT 0.1.
			}.
			print_stats_land("Transferring " + transfer_amt + " from upper tank. " + ox_xfr:STATUS, ox_xfr:MESSAGE).
		} else {
			SET lf_xfr TO TRANSFER("liquidfuel", lower_tank, upper_tank, -1 * transfer_amt).
			SET ox_xfr TO TRANSFER("oxidizer", lower_tank, upper_tank, -1 * transfer_amt).
			SET lf_xfr:ACTIVE TO TRUE.
			SET ox_xfr:ACTIVE TO TRUE.

			SET complete TO FALSE.

			UNTIL complete {
				print_stats_land("Transferring " + transfer_amt + " from lower tank. " + ox_xfr:STATUS, ox_xfr:MESSAGE).
				if (lf_xfr:STATUS = "Finished" OR ox_xfr:STATUS = "Finished") {
					SET complete TO TRUE.
					SET lf_xfr:ACTIVE TO FALSE.
					SET ox_xfr:ACTIVE TO FALSE.
				}.
				if (lf_xfr:STATUS = "Failed" AND ox_xfr:STATUS = "Failed") {
					SET complete TO TRUE.
					SET lf_xfr:ACTIVE TO FALSE.
					SET ox_xfr:ACTIVE TO FALSE.
				}.
				WAIT 0.1.
			}.
			print_stats_land("Transferring " + transfer_amt + " from lower tank. " + ox_xfr:STATUS, ox_xfr:MESSAGE).
		}
		print_stats_land("IDLE", "").
		WAIT 0.001.
	}.
	landing().
}.

function landing {
	SET CURR_STATE TO "REENTRY".

	update_params().

	SAS OFF.
	LOCK STEERING TO SHIP:SRFRETROGRADE.
	RCS ON.
	

	SET lf_xfr TO TRANSFERALL("liquidfuel", upper_tank, lower_tank).
	SET ox_xfr TO TRANSFERALL("oxidizer", upper_tank, lower_tank).
	SET lf_xfr:ACTIVE TO TRUE.
	SET ox_xfr:ACTIVE TO TRUE.

	SET fuel_xfr_complete TO FALSE.

	UNTIL fuel_xfr_complete {

		print_stats_land("Transfering fuel to lower tank.", ox_xfr:MESSAGE).

		if (((lf_xfr:STATUS = "Finished" OR lf_xfr:STATUS = "Failed") AND (ox_xfr:STATUS = "Finished" OR ox_xfr:STATUS = "Failed")) OR (MY_ALT < (LANDING_FLIP_ALT - 500))) {
			SET fuel_xfr_complete TO TRUE.
		}.
	}.

	SET Kp TO 0.04.
	SET Ki TO 0.0.
	SET Kd TO 0.0002.

	SET PID TO PIDLOOP(Kp, Ki, Kd).	

	SET PID:SETPOINT TO -100.
	
	SET thrott TO 1.
	LOCK THROTTLE TO thrott.

	UNTIL MY_ALT < 1200 {
		update_params().
		SET thrott TO PID:UPDATE(TIME:SECONDS, MY_SPEED).
		print_stats_land("Throttle setting: " + thrott, "Throttle Delta: ").
	}.

	SET PID:SETPOINT TO -50.
	UNTIL MY_ALT < 200 {
		update_params().
		SET thrott TO PID:UPDATE(TIME:SECONDS, MY_SPEED).
		print_stats_land("Throttle setting: " + thrott, "Throttle Delta: ").
	}

	SET PID:SETPOINT TO -10.
	UNTIL MY_ALT < 50 {
		update_params().
		SET thrott TO PID:UPDATE(TIME:SECONDS, MY_SPEED).
		print_stats_land("Throttle setting: " + thrott, "Throttle Delta: ").
	}

	SET PID:SETPOINT TO -TOUCHDOWN_SPEED.
	UNTIL MY_ALT < 0 {
		update_params().
		SET thrott TO PID:UPDATE(TIME:SECONDS, MY_SPEED).
		print_stats_land("Throttle setting: " + thrott, "Throttle Delta: ").
	}
}.

function calculate_suicide_burn {
	
}.

function update_params {
	SET MY_ALT TO SHIP:BOUNDS:BOTTOMALTRADAR.
	SET MY_PITCH TO pitch_for().
	SET MY_ROLL TO roll_for().
	SET MY_SPEED TO SHIP:VERTICALSPEED.
}.

function print_stats_land {
	parameter additional1.
	parameter additional2.
	SET ROW TO ROW_STATE.
	PRINT " === " + CURR_STATE + " ===               " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT "Altitude: " + MY_ALT + " m                " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT "Pitch   : " + MY_PITCH + " deg               " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT "Roll    : " + MY_ROLL + " deg               " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT "V/S     : " + MY_SPEED + " m/s               " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT additional1 + "                    " AT (0, ROW).
	SET ROW TO ROW + 1.
	PRINT additional2 + "                    " AT (0, ROW).
}.

// lib_navball.ks - A library of functions to calculate navball-based directions.
// Copyright © 2015,2017,2019 KSLib team 
// Lic. MIT


function east_for {
  parameter ves is ship.

  return vcrs(ves:up:vector, ves:north:vector).
}

function compass_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).

  local result is arctan2(trig_y, trig_x).

  if result < 0 {
    return 360 + result.
  } else {
    return result.
  }
}

function pitch_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }

  return 90 - vang(ves:up:vector, pointing).
}

function roll_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing.
  if not thing:istype("string") {
    if thing:istype("vessel") or pointing:istype("part") {
      set pointing to thing:facing.
    } else if thing:istype("direction") {
      set pointing to thing.
    } else {
      print "type: " + thing:typename + " is not reconized by roll_for".
	}
  }

  local trig_x is vdot(pointing:topvector,ves:up:vector).
  if abs(trig_x) < 0.0035 {//this is the dead zone for roll when within 0.2 degrees of vertical
    return 0.
  } else {
    local vec_y is vcrs(ves:up:vector,ves:facing:forevector).
    local trig_y is vdot(pointing:topvector,vec_y).
    return arctan2(trig_y,trig_x).
  }
}

function compass_and_pitch_for {
  parameter ves is ship,thing is "default".

  local pointing is ves:facing:forevector.
  if not thing:istype("string") {
    set pointing to type_to_vector(ves,thing).
  }

  local east is east_for(ves).

  local trig_x is vdot(ves:north:vector, pointing).
  local trig_y is vdot(east, pointing).
  local trig_z is vdot(ves:up:vector, pointing).

  local compass is arctan2(trig_y, trig_x).
  if compass < 0 {
    set compass to 360 + compass.
  }
  local pitch is arctan2(trig_z, sqrt(trig_x^2 + trig_y^2)).

  return list(compass,pitch).
}

function bearing_between {
  parameter ves,thing_1,thing_2.

  local vec_1 is type_to_vector(ves,thing_1).
  local vec_2 is type_to_vector(ves,thing_2).

  local fake_north is vxcl(ves:up:vector, vec_1).
  local fake_east is vcrs(ves:up:vector, fake_north).

  local trig_x is vdot(fake_north, vec_2).
  local trig_y is vdot(fake_east, vec_2).

  return arctan2(trig_y, trig_x).
}

function type_to_vector {
  parameter ves,thing.
  if thing:istype("vector") {
    return thing:normalized.
  } else if thing:istype("direction") {
    return thing:forevector.
  } else if thing:istype("vessel") or thing:istype("part") {
    return thing:facing:forevector.
  } else if thing:istype("geoposition") or thing:istype("waypoint") {
    return (thing:position - ves:position):normalized.
  } else {
    print "type: " + thing:typename + " is not recognized by lib_navball".
  }
}

