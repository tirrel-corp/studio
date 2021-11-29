/-  *post, meta=metadata-store
|%
+$  flow
  $:  =resource
      =index
      site=(unit [template=term =binding:eyre])
      email=(unit term)
  ==
+$  action
  $%  [%add name=term flow]
      [%remove name=term]
  ==
::
+$  site-inputs
  $:  name=term
      =binding:eyre
      posts=(list [@da post])
      =association:meta
  ==
::
+$  email-inputs
  $:  name=term
      site-binding=(unit binding:eyre)
      =post
      =association:meta
  ==
+$  site-template   $-(site-inputs website)
+$  email-template  $-(email-inputs email)
+$  website  (map path mime)
+$  email    [subject=@t body=mime]
+$  update
  $%  [%site name=term =website]
      [%email name=term =email]
      [%flows flows=(map term flow)]
      [%templates site=(set term) email=(set term)]
  ==
--
