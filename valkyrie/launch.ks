runpath("0:/lib/lib_navball").
runpath("0:/valkyrie/lib_valkyrie").

clearscreen.
clearvecdraws().

set vs_kp to 0.0125.
set vs_ki to 0.0006.
set vs_kd to 0.0014.

takeoff().
climbout().
nooxaccel().
apoapsis().
circularize(). 
