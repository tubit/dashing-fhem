This is a customized [dashing](http://shopify.github.com/dashing) dashboard for [FHEM](http://fhem.de).

# FHEM Dashboard
FHEM Dashboard is based on 'dashing' by spotify, see [1] for more.

The Jsonlist Plugin needs to be activated in FHEM for this dashboard to work. JsonList2 won't work, because no typespec support.

Only tested for Homematic Devices, typespec CUL_HM.

Check out http://shopify.github.com/dashing for more information.

## Screenshot

This is a screenshot of my FHEM Dashing Dashboard at home
<img src="https://raw.github.com/tubit/dashing-fhem/master/misc/screenshot.png" /></img>

## Getting started
Clone this repository, bundle install all Gems and then fire up dashing with `dashing start`.
Please read the dashing and dashing widget documentation first!

## Customizing
To create your very own FHEM dashboard, you need to change almost everything inside of `jobs/fhem.rb`. :)
As you can assume, this dashboard relies on _your_ FHEM configuration, _your_ components and names...

Maybe it's the best option to enable Jsonlist (not Jsonlist2) in your FHEM installation and just browse around
the output of [http://fhem:8083/fhem?cmd=jsonlist%20CUL_HM&XHR=1](http://fhem:8083/fhem?cmd=jsonlist%20CUL_HM&XHR=1).

For my dashboard I'm looking for heating information and window states. I defined all interesting windows
inside an `windows`-array and all heating thermostates in a `heating`-hash. For thermostates the
last value is saved to the hash, so the number widgets display can display increase or decrease of the room temperatures.

Happy hacking. :-)

