/-  *post, meta=metadata-store
|%
+$  versioned-state
  $%  state-0
      state-1
  ==
+$  state-1
  $:  %1
      flows=(map name=term flow)
      sites=(map name=term website)
      uid-to-name=(jug uid name=term)
      host-to-name=(map @t name=term)
  ==
::
+$  flow
  $:  =resource
      =index
      site=(unit [template=term =binding:eyre comments=?])
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
      posts=(list [@da post (list post)])
      =association:meta
      comments=?
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
::
::  old versions
::
+$  flow-0
  $:  =resource
      =index
      site=(unit [template=term =binding:eyre])
      email=(unit term)
  ==
+$  state-0
  $:  %0
      flows=(map name=term flow-0)
      sites=(map name=term website)
      uid-to-name=(jug uid name=term)
      host-to-name=(map @t name=term)
  ==
--
