switch to 0.
compile "0:/lib/lib_num_to_str.ks".
compile "0:/lib/lib_location_constants.ks".
compile "0:/lib/lib_str_to_num.ks".
compile "0:/lib/lib_navball.ks".
compile "0:/lib/tabwidget.ks".
compile "0:/valkyrie/gui.ks".
compile "0:/valkyrie/lib_valkyrie.ks".
createDir("1:/lib").
COPYPATH("0:/lib/lib_num_to_str.ksm", "1:/lib/lib_num_to_str.ksm").
COPYPATH("0:/lib/lib_location_constants.ksm", "1:/lib/lib_location_constants.ksm").
COPYPATH("0:/lib/lib_str_to_num.ksm", "1:/lib/lib_str_to_num.ksm").
COPYPATH("0:/lib/lib_navball.ksm", "1:/lib/lib_navball.ksm").
COPYPATH("0:/lib/tabwidget.ksm", "1:/lib/tabwidget").
COPYPATH("0:/valkyrie/lib_valkyrie.ksm", "1:/").
COPYPATH("0:/valkyrie/gui.ksm", "1:/").
switch to 1.
runpath("gui.ksm").
