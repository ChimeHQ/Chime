(atx_heading (inline) @text.title)
(setext_heading (paragraph) @text.title)

[
  (atx_h1_marker)
  (atx_h2_marker)
  (atx_h3_marker)
  (atx_h4_marker)
  (atx_h5_marker)
  (atx_h6_marker)
  (setext_h1_underline)
  (setext_h2_underline)
  (list_marker_plus)
  (list_marker_minus)
  (list_marker_star)
  (list_marker_dot)
  (list_marker_parenthesis)
  (thematic_break)
  (block_quote_marker)
] @punctuation.special

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
