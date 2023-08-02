[![License][license badge]][license]

# Chime
An editor for macOS

Goals:
- develop modular, open source components
- be an editor people enjoy using
- support cool [extensions][chimekit]

## Project State

Chime used to be commercial, but is now [free][download]. It built up some pretty significant cruft over time. In particular, the core UI application architecture is just in a bad state. It is also quite complex to build. So, I've opted to re-implement that core and pull in parts as appropriate. I'll be putting an emphasis on extracting additional components as I go. A fitting rebirth, I would say.

I don't yet have a good sense for when this version will be usable. Those two buttons up at the top will help. ⭐️💖

## Contributing

**Ask** before taking on a significant task. That said, I have a strong bias towards enthusiasm. If you are excited about doing something, I'll do my best to get out of your way.

### Building
 
- clone the repo
- `cp User.xcconfig.template User.xcconfig`
- update `User.xcconfig` with your personal information
- build/run with Xcode

### Guidelines

- SwiftUI where possible, AppKit where useful
- using packages is a wonderful way to support open source software
- supporting older OSes is less important that making something good
- correct first, fast second

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