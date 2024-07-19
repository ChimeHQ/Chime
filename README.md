<div align="center">

[![Build Status][build status badge]][build status]
[![Documentation][documentation badge]][documentation]
[![Matrix][matrix badge]][matrix]

</div>

# Chime
An editor for macOS

An alpha of 3.0 is available in [releases][releases]. The more stable, but closed-source 2.x version is available on the [website][download].

Goals:
- develop modular, open source components
- be an editor people enjoy using
- support cool [extensions][chimekit]

Features:
- completions
- command line tool
- document/project-scoped search
- [editorconfig](https://editorconfig.org)
- [extensions][chimekit]
- file navigator
- Quick Look Preview extension
- semantic symbol information
- Shortcuts extension (text highlighting)
- structure highlighting
- syntax highlighting (driven by tree-sitter and LSP)
- textual/symbolic quick open
- UI theming

## Project State

Chime, as an editor, should be considered mostly **non-functional** right now. If you want to use it in that capacity, you can [download][download] the current stable version. However, the Quick Look Preview extension exists to help expose real, useful features of this project. You can check that out via [releases][releases].

Chime used to be commercial, but is now free. It built up some pretty significant cruft over time. In particular, the core UI application architecture is just in a bad state. It is also quite complex to build. So, I've opted to re-implement that core and pull in parts as appropriate. I'll be putting an emphasis on extracting components into packages as I go. A fitting rebirth, I would say.

## Contributing

It is always a good idea to **discuss** before taking on a significant task. That said, I have a strong bias towards enthusiasm. If you are excited about doing something, I'll do my best to get out of your way.

The project is [internally documented][documentation] with [DocC](https://www.swift.org/documentation/docc/#). The docs contains details about getting started, structure, and internal systems/behaviors. Both [Matrix][matrix] and [Discord][discord] are available for live help, but GitHub issues/discussions is preferred.

There are a few areas that would make for excellent targets though, if you really feel so inclined.

- The text search system is bad and I'd love to build something better
- The view-based [extension system][chimekit] could really use some more attention
- I'd like to finish migrating the preferences to SwiftUI
- Support for the [Debug Adapter Protocol](https://github.com/ChimeHQ/DebugAdapterProtocol)
- The autocomplete result window isn't very pretty

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

### Building

**Note**: requires Xcode 15 and macOS 14

- clone the repo
- `git submodule update --init --recursive`
- `cp User.xcconfig.template User.xcconfig`
- update `User.xcconfig` with your personal information
- build/run with Xcode

Why the submodules you ask? Chime embeds many of its extensions inside the application itself for ease of installation. However, because of limitations in how you can influence the linking process with SPM, I cannot figure out how to use SPM *and also* link against the included ChimeKit.framework.

### Guidelines

- SwiftUI where possible, AppKit where useful
- using packages is a wonderful way to support open source software
- supporting older versions of macOS is nice, not critical

### Conventions

- tabs for indentation
- configuration in xcconfig files
- project resources are sorted alphabetically
- imports are sorted by alphabetically, but partitioned to system/non-system

### Significant Issues

Chime is a reasonably complex project. It's bound to run into bugs in Apple frameworks, Xcode, and other systems that present a real problem to its development. This is a list of the **most serious** issues, which have a major impact on either the user or developer experience.

- FB12094161: System Settings extension approval system does not appear to work
- FB11716027: EXAppExtensionBrowserViewController duplicate apps
- FB11748287: Static metadata for extension available in AppExtensionIdentity
- FB13384096: Package with non-Swift target fails to build unless explicitly linked

## Other Notable Projects

- [BBEdit](https://www.barebones.com/products/bbedit/)
- [CodeEdit](https://www.codeedit.app)
- [CodeRunner](https://coderunnerapp.com)
- [CotEditor](https://coteditor.com)
- [Nova](https://nova.app)

[download]: https://www.chimehq.com/download
[releases]: https://github.com/ChimeHQ/Chime/releases
[chimekit]: https://github.com/ChimeHQ/ChimeKit
[build status]: https://github.com/ChimeHQ/Chime/actions
[build status badge]: https://github.com/ChimeHQ/Chime/workflows/CI/badge.svg
[documentation]: https://chimehq.github.io/Chime/documentation/chime/
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
[matrix]: https://matrix.to/#/%23chimehq%3Amatrix.org
[matrix badge]: https://img.shields.io/matrix/chimehq%3Amatrix.org?label=Matrix
[discord]: https://discord.gg/esFpX6sErJ
