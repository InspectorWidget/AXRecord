# AXRecord

AXRecord is an opensource application (GUI or CLI) to log applications states (window change events, tree of containing/contained widgets) through the accessibility API.

The UIElementUtilities class has been forked from the Apple UIElementInspector sample code (Version 1.4, 2010-06-03): 
https://developer.apple.com/library/content/samplecode/UIElementInspector/Introduction/Intro.html#//apple_ref/doc/uid/DTS10000728-Intro-DontLinkElementID_2

## Installation

### Dependencies

For now AXRecord only works on macOS.

It requires CMake:
 * to install it with homebrew:
```
brew install cmake
```
 * to install it with MacPorts:
```
sudo port install cmake
```

### Compilation
First clone the repository.

Then open a terminal in a build directory of your choice:
```
cmake <source_directory_path>
make
```

### Usage
Launch `AXRecordGUI.app` (GUI) or `AXRecordCLI` (commandline).

Logs are saved as XML files, named with a timestamp, in the Movies folder under the home directory of your user account.

## License

AXRecord is released under the terms of the [GPLv3](http://www.gnu.org/licenses/gpl-3.0.html) license.

## Authors
 * [Sylvain Malacria](http://www.malacria.fr) ([Inria Lille](https://www.inria.fr/en/centre/lille), [Mjolnir](http://mjolnir.lille.inria.fr) team): main developer
 * [Christian Frisson](http://christian.frisson.re) ([Inria Lille](https://www.inria.fr/en/centre/lille), [Mjolnir](http://mjolnir.lille.inria.fr) team): contributor
