(atx_heading (inline) @text.title)
(setext_heading (paragraph) @text.title)

[
  (link_title)
  (indented_code_block)
] @string

[
  (fenced_code_block_delimiter)
] @punctuation.delimiter

(fenced_code_block
  (info_string
    (language) @string)
    (code_fence_content))

[
  (link_destination)
] @string.uri

[
  (link_label)
] @text.reference

[
  (backslash_escape)
] @string.escape
