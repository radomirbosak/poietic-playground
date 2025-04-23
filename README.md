# Poietic Playground

An educational tool, a virtual laboratory for modelling and simulation of
dynamical systems using the [Stock and Flow](https://en.wikipedia.org/wiki/Stock_and_flow)
methodology.

![Poietic Playground prototype screenshot](docs/screenshots/PoieticPlayground-prototype-screenshot-2025-04-23.png?raw=true)

Part of the [Open Poiesis](https://www.poietic.org) project.

## Primers

The following literature is a good start with the methodology used in the playground:

- [Thinking In Systems: A Primer](https://www.goodreads.com/book/show/3828902-thinking-in-systems) by Donella Meadows
- [Business Dynamics: Systems Thinking and Modeling for a Complex World](https://www.goodreads.com/book/show/808680.Business_Dynamics?ref=nav_sb_ss_1_36) by John D. Sterman

## Reqiurements

This is a **[Godot](http://godotengine.org)** application which uses the
Poietic Stock and Flow simulation engine plugin written in **[Swift](https://www.swift.org/)**.

### Instructions

1. Download the Godot Engine using one of the following methods:
	- [Download Webpage](https://godotengine.org/download) (version >= 4.4)
	- On MacOS use `brew install godot`
2. Install Swift:
	- On MacOS: [Install Xcode](https://developer.apple.com/xcode/).
	- On other platforms: [Install Swift](https://www.swift.org/getting-started/)

## Build from Sources

Get the Poietic Playground sources with submodules and run the `build` script:

```sh
git clone --recurse-submodules https://github.com/OpenPoiesis/poietic-playground.git
./build
```

The `build` script does the following:
	
- Updates the submodule.
- Builds the Swift Godot plugin
- Copies the artifacts into the `./bin` directory.

### Dependencies

- Poietic
	- [Core](https://github.com/OpenPoiesis/poietic-core) – Model and design representation library
	- [Flows](https://github.com/OpenPoiesis/poietic-flows) – Stock and Flow simulation library
	- [Godot](https://github.com/OpenPoiesis/poietic-godot) – Godot plugin that wraps the Poietic flows simulator
- [SwiftGodot](https://github.com/migueldeicaza/SwiftGodot) – Bridge for Godot plugins written in Swift

## Authors

- [Stefan Urbanek](mailto:stefan.urbanek@gmail.com)
