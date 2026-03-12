[
  (jsx_opening_element
    (jsx_attribute) @jsxprop.outer)

  (jsx_self_closing_element
    (jsx_attribute) @jsxprop.outer)
]

[
  (jsx_opening_element
    (jsx_attribute) @jsxprop.inner)

  (jsx_self_closing_element
    (jsx_attribute) @jsxprop.inner)
]

[
  (jsx_opening_element
    (jsx_attribute
      (property_identifier) @jsxprop.key.inner) @jsxprop.key.outer)

  (jsx_self_closing_element
    (jsx_attribute
      (property_identifier) @jsxprop.key.inner) @jsxprop.key.outer)
]

[
  (jsx_opening_element
    (jsx_attribute
      (property_identifier)
      (string) @jsxprop.value.outer))

  (jsx_self_closing_element
    (jsx_attribute
      (property_identifier)
      (string) @jsxprop.value.outer))
]

[
  (jsx_opening_element
    (jsx_attribute
      (property_identifier)
      (string
        (string_fragment) @jsxprop.value.inner)))

  (jsx_self_closing_element
    (jsx_attribute
      (property_identifier)
      (string
        (string_fragment) @jsxprop.value.inner)))
]

[
  (jsx_opening_element
    (jsx_attribute
      (property_identifier)
      (jsx_expression) @jsxprop.value.outer))

  (jsx_self_closing_element
    (jsx_attribute
      (property_identifier)
      (jsx_expression) @jsxprop.value.outer))
]

[
  (jsx_opening_element
    (jsx_attribute
      (property_identifier)
      (jsx_expression
        (_) @jsxprop.value.inner)))

  (jsx_self_closing_element
    (jsx_attribute
      (property_identifier)
      (jsx_expression
        (_) @jsxprop.value.inner)))
]
