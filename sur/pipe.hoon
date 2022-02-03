/-  *post, meta=metadata-store
|%
+$  versioned-state
  $%  [%0 state-0]
      [%1 state-1]
      [%2 state-1]
      [%3 state-2]
      [%4 state-3]
  ==
::
+$  state-3
  $:  flows=(map name=term flow)
      sites=(map name=term website)
      uid-to-name=(jug uid name=term)
      template-desk=(unit desk)
      custom-site=(map term site-template)
      custom-email=(map term email-template)
  ==
::
+$  flow
  $:  =resource
      =index
      site=(unit site)
      email=(unit term)
  ==
::
+$  site
  $:  template=term
      =binding:eyre
      comments=?
      width=?(%1 %2 %3)
      lit=?
      accent=@ux
  ==
::
+$  edit-site
  $%  [%template =term]
      [%binding =binding:eyre]
      [%comments comments=?]
      [%width width=?(%1 %2 %3)]
      [%lit lit=?]
      [%accent accent=@ux]
      [%whole site=(unit site)]
  ==
::
+$  edit
  $%  [%resource =resource]
      [%site =edit-site]
      [%email email=(unit term)]
  ==
::
+$  action
  $%  [%add name=term flow]
      [%remove name=term]
      [%edit name=term edits=(list edit)]
      [%watch-templates =desk]
      [%wipe-templates ~]
  ==
::
+$  site-inputs
  $:  name=term
      =binding:eyre
      posts=(list [@da post (list post)])
      =association:meta
      comments=?
      email=?
      width=?(%1 %2 %3)
      lit=?
      accent=@ux
  ==
::
+$  email-inputs
  $:  name=term
      site-binding=(unit binding:eyre)
      =post
      =association:meta
  ==
::
+$  site-template   $-(site-inputs website)
+$  email-template  $-(email-inputs (each email tang))
+$  website  (map path (each mime tang))
+$  email    [subject=@t body=mime]
+$  update
  $%  [%site name=term =website]
      [%email name=term =email]
      [%flows flows=(map term flow)]
      [%templates site=(set term) email=(set term)]
      [%errors err=(map term (map path tang))]
  ==
::
::  old versions
::
+$  state-2
  $:  flows=(map name=term flow)
      sites=(map name=term website-0)
      uid-to-name=(jug uid name=term)
      template-desk=(unit desk)
      custom-site=(map term site-template-0)
      custom-email=(map term email-template-0)
  ==
::
+$  site-template-0   $-(site-inputs website-0)
+$  email-template-0  $-(email-inputs email)
+$  website-0        (map path mime)
::
+$  flow-1
  $:  =resource
      =index
      site=(unit [template=term =binding:eyre comments=?])
      email=(unit term)
  ==
::
+$  state-1
  $:  flows=(map name=term flow-1)
      sites=(map name=term website-0)
      uid-to-name=(jug uid name=term)
      host-to-name=(map @t name=term)
  ==
::
+$  flow-0
  $:  =resource
      =index
      site=(unit [template=term =binding:eyre])
      email=(unit term)
  ==
::
+$  state-0
  $:  flows=(map name=term flow-0)
      sites=(map name=term website-0)
      uid-to-name=(jug uid name=term)
      host-to-name=(map @t name=term)
  ==
--
