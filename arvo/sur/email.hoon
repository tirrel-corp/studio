|%
+$  from-field     [email=cord name=cord]
+$  content-field  [type=cord value=cord]
+$  personalization-field
  $:  to=(list cord)
      cc=(list cord)
      bcc=(list cord)
      headers=(map cord cord)
      substitutions=(list [cord cord])
  ==
+$  email
  $:  from=from-field
      subject=cord
      content=(list content-field)
      personalizations=(list personalization-field)
  ==
::
+$  email-fields
  $:  name=cord
      subject=cord
      content=(list content-field)
  ==
--
