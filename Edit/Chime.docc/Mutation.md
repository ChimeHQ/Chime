# Text Mutation

Understand how Chime manages changes to the content of a document.

## Overview

The fundamental core of an editor is the text content is displays. Nothing about text is straightforward or simple. And, something that makes it substantially more complex is supporting mutation that scales. The size of the document, the size of the mutations, and the number of mutations are all unbounded.

### Relationship with TextKit

`NSTextView` and `NSTextStorage` are extremely tightly coupled together by both TextKit 1 and TextKit 2. Even a reasonably deep look into TextKit 2 might make it seem like this is not the case, but in practice, neither `NSTextContentManager` or `NSTextContentStorage` actually provide any meaningful levels of abstraction.

Now, luckily `NSTextStorage` is extremely fast at both loading data and processing single changes. It is not clear what kind of data structure it uses internally, but I'm speculating it is some kind of rope.

### Mutation Sources

Changes to the content can come from four places:

- typing
- a paste operation
- extension-supplied edits
- programmatic mutation

Mutations that are triggered programmatically or that come from an extension don't have to change one single place. There can be many of them proposed all at once. This is true for paste and typing as well, when you support multiple cursors. The point is, one atomic mutation can be made up of an arbitrarily large number of non-overlapping edits.

### Typing Completions

Mutations that come from keyboard input also go though a transformation to support typing completions. These are specialized per-language, and do things like match open-and-closing parentheses. They are selection-sensitive, and can result in not just text mutations both also influence the selection state on a per-cursor basis.
