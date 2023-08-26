[![License][license badge]][license]

# Chime
An editor for macOS

Goals:
- develop modular, open source components
- be an editor people enjoy using
- support cool [extensions][chimekit]

Features:
- completions
- command line tool
- document/project-scoped search
- [extensions][chimekit]
- file navigator
- syntax highlighting (driven by tree-sitter and LSP)
- structure highlighting
- semantic symbol information
- textual/symbolic quick open
- UI theming

## Project State

**Non-Functional**. I don't yet have a good sense for when this version will be usable.

Chime used to be commercial, but is now [free][download]. It built up some pretty significant cruft over time. In particular, the core UI application architecture is just in a bad state. It is also quite complex to build. So, I've opted to re-implement that core and pull in parts as appropriate. I'll be putting an emphasis on extracting components into packages as I go. A fitting rebirth, I would say.

## Contributing

**Ask** before taking on a significant task. That said, I have a strong bias towards enthusiasm. If you are excited about doing something, I'll do my best to get out of your way.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

### Building
 
- clone the repo
- `cp User.xcconfig.template User.xcconfig`
- update `User.xcconfig` with your personal information
- build/run with Xcode

### Guidelines

- SwiftUI where possible, AppKit where useful
- using packages is a wonderful way to support open source software
- supporting older versions of macOS is nice, not critical

### Conventions

- tabs for indentation
- configuration in xcconfig files

## Other Notable Projects

- [BBEdit](https://www.barebones.com/products/bbedit/)
- [CodeEdit](https://www.codeedit.app)
- [CodeRunner](https://coderunnerapp.com)
- [CotEditor](https://coteditor.com)
- [Nova](https://nova.app)

[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/Chime
[download]: https://www.chimehq.com/download
[chimekit]: https://github.com/ChimeHQ/ChimeKit
