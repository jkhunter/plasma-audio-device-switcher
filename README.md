# plasma-audio-device-switcher

Simple KDE/Plasma widget (plasmoid) to change the default audio output device (sink) or the default audio input device (source).

Tested on KDE/Plasma 5.27 and PipeWire 1.0.0. Since it uses the PulseAudio API, it should also work under PulseAudio. (Well, a lot of the work is done by KDE's own [plasma-pa](https://invent.kde.org/plasma/plasma-pa), as this widget here reuses the PulseAudio integration implemented there.)

## How to develop

1. Clone this repository.
2. Create the necessary directory, if needed: `mkdir -p ~/.local/share/plasma/plasmoids`
3. Link this repository over there: `ln -s path-to-this/repo/package ~/.local/share/plasma/plasmoids/clone.plasma-audio-device-switcher`
    * Using a distinct name to install the dev version alongside the stable version.
4. [Test it on a stand-alone window](https://develop.kde.org/docs/plasma/widget/testing/):
    * `plasmawindowed clone.plasma-audio-device-switcher`
    * `plasmoidviewer -a clone.plasma-audio-device-switcher`
    * `plasmoidviewer -a ./package`

These steps are inspired by the [Plasma Widget Tutorial](https://develop.kde.org/docs/plasma/widget/).

## How to install

There are several ways, just pick one:

* `plasmapkg2 -i package` will install it on `~/.local/share/plasma/plasmoids/`.
* `plasmapkg2 -g -i package` will install it system-wide.
* `plasmapkg2 -u package` to upgrade it.
* You can also install it manually `cp -a package ~/.local/share/plasma/plasmoids/org.kde.plasma.audiodeviceswitcher-ng/`.
* Or you can unzip the release zipfile onto that directory.

## Credits

Originally created by [akrutzler](https://github.com/akrutzler/plasma-audio-device-switcher) and published as <https://store.kde.org/p/1195707/>.

More than one year after the last commit on that original repository, [lolcabanon's fork](https://github.com/lolcabanon/plasma-audio-device-switcher) [merged many pull requests](https://github.com/lolcabanon/plasma-audio-device-switcher/commit/2cda18ad121d11f17dbc4bb52cce229162a40d83), such as [#13](https://github.com/akrutzler/plasma-audio-device-switcher/pull/13), [#15](https://github.com/akrutzler/plasma-audio-device-switcher/pull/15), [#17](https://github.com/akrutzler/plasma-audio-device-switcher/pull/17), plus adding a few extra features.

Almost one year later [denilsonsa's fork](https://github.com/denilsonsa/plasma-audio-device-switcher) merged [one other pull request](https://github.com/akrutzler/plasma-audio-device-switcher/pull/13), and implemented further improvements.

With thanks to [davidosomething](https://github.com/davidosomething/plasma-audio-device-switcher/commit/53b387127763f3780215c90371d5de3c01fefe7d), [xpt3](https://github.com/xpt3/plasma-audio-device-switcher/commit/09b32256baaf9b1af7a1d67f6bbf65433a9696bb), [Phen-Ro](https://github.com/Phen-Ro/plasma-audio-device-switcher/commit/788e4376ba2e723d65a812ef90e21ef93fde9c33). [emvaized](https://github.com/emvaized/plasma-audio-device-switcher/commit/8498d7ab7e2d6b3e88f14d811084ad06b911282f).
