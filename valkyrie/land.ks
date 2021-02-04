runpath("0:/valkyrie/lib_valkyrie").
clearscreen.

//deorbit().
reentry().

function deorbit {
	print " --- Deorbit ---           " AT (0, 0).

	RCS ON.
	lock STEERING to SHIP:RETROGRADE.
	lock THROTTLE to 0.

	print_state().
	
	set ready_to_burn to false.

	until ready_to_burn {
		print "Steering error: " + STEERINGMANAGER:ANGLEERROR + "          " AT (0,1).
		if (abs(STEERINGMANAGER:ANGLEERROR < 1.0)) {
			set ready_to_burn to true.
		}.
		print_state().
		wait 0.1.
	}.

	set tgt_periapsis to 50000.
	until (SHIP:PERIAPSIS < tgt_periapsis) {
		lock THROTTLE to 1.0.
		print_state().
		wait 0.1.
	}.

}.

function reentry {
	print " --- Reentry ---           " AT (0, 0).
	RCS ON.
	lock STEERING to SHIP:PROGRADE.

	wait 10.

	set ready to false.
	set hdg to compass_for().

	until (ready) {
		print "Steering error: " + STEERINGMANAGER:ANGLEERROR + "          " AT (0,1).
		if (abs(STEERINGMANAGER:ANGLEERROR) < 0.07) {
			set hdg to compass_for().
			set ready to true.
		}.
		print_state().
		wait 0.1.
	}

	TOGGLE AG4.

	lock THROTTLE to 0.

	set pit to 90.

	until SHIP:ALTITUDE < 15000 {

		local vec_pro_horizon is vxcl(up:vector, prograde:vector).
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

		if (SHIP:AIRSPEED < 1500) {
			set pit to 20.
		}.

		if (SHIP:ALTITUDE < 30000) {
			RCS OFF.
		}.

		if (SHIP:AIRSPEED < 800) {
			BRAKES OFF.
		}.

		print_state().
		print "Heading: " + compass_for() AT(0,2).
		wait 0.5.
	}

}
