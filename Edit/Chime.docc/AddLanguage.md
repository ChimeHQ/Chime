# Adding a Language

Learn how to add a new language to Chime.

## Overview

There are multiple steps involved in adding new language support to Chime. Today, extensions cannot supply all of the needed functionality to support languages. In particular, all of the syntactic features require in-app changes.

### Determine UTIs

Chime relies heavily internally on [UTIs](https://developer.apple.com/documentation/uniformtypeidentifiers) for identifying file types. It is critical that the UTI is correctly set for all content. If you are unsure, you can verify it with the `kMDItemContentType` key from the `mdls` tool.

```
mdls path/to/your/file
```

These UTIs should first be incorporated into [ChimeKit][]. From there, they can be added as "Imported Type Identifiers" in Chime's Info.plist. To do this, you'll need to know the file extensions used. ChimeKit also supports well-known file names, like `Makefile`, which the Uniform Type Identifier APIs do not currently support. 

## Tree-Sitter

### Parser

The easiest path to supporting the language syntax is to use Chime's tree-sitter support. Once the parser supports SPM, to incorporate it you must:

- Add the SPM package to the `TreeSitterParsers` target of the `Dependencies` local package
- Modify `Dependencies/Sources/TreeSitterParsers/TreeSitterParsers` to re-export the parser symbols
- Include the library module name in `NonSwiftWorkaround.xcconfig` to address an Xcode bug
- Add a new case to `RootLanguage` in `SyntaxService` for the language
- Add new static property to `LanguageProfile` for the language
- Match the language UTI and return it in `LanguageProfile.profile(for:)`
- Add the language UTI to Preview > Info.plist > `NSExtension` > `NSExtensionAttributes` > `QLSupportedContentTypes`

Chime also needs to locate the correct tree-sitter query definitions to perform highlighting and embedded language detection. This will be done automatically if the parser SPM package includes queries.

### Embedding Queries

Even if a parser package includes queries, they should be copied into a dedicated directory within `Resources/LanguageData`. This will make it possible for them to be loaded by the Quick Look Preview extension. This duplication is not ideal, but I have not yet been able to find a workaround.

You might also be tempted to adjust these queries. Try to resist this temptation and instead fix the queries within their own projects. 

## Language Server

After syntactic support is working, you can refer to [ChimeKit]'s documentation on how to set up an extension for language server support.

[ChimeKit]: https://github.com/ChimeHQ/ChimeKit
