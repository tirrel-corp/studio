/-  *post, groups, diary, channels
|%
+$  versioned-state
  $%  [%7 state-7]
      [%8 state-8]
      [%9 state-9]
      [%10 state-9]
      [%11 state-11]
  ==
::
+$  state-11
  $+  state-11
  $:  flows=(map name=term flow)
      styles=(map term style-vars)
  ==
::
+$  style-vars  (map @t @t)
::
+$  flow
  $:  =resource
      site=(unit site)
      email=(unit term)
      auth-rule=(unit auth-rule)
      style=(unit term)
  ==
::
+$  auth-rule
  $%  [%all p=@tas]
      [%subpaths p=@tas]
      [%per-subpath p=(map @t (unit @tas))]
      [%none ~]
  ==
::
+$  site
  $:  template=term
      comments=?
      headline=@t
      profile-img=@t
      header-img=@t
  ==
::
+$  edit-site
  $%  [%template =term]
      [%comments comments=?]
      [%whole site=(unit site)]
  ==
::
+$  edit
  $%  [%resource =resource]
      [%site =edit-site]
      [%email email=(unit term)]
      [%auth-rule rule=(unit auth-rule)]
      [%style style=(unit term)]
  ==
::
+$  action
  $%  [%add name=term =flow]
      [%remove name=term]
      [%edit name=term edits=(list edit)]
      [%build name=term]
      [%set-style name=term style=(map @t @t)]
  ==
::
+$  versioned-site-template
  $%  [%0 p=site-template]
  ==
::
+$  versioned-email-template
  $%  [%0 p=email-template]
  ==
::
+$  site-template
  $+  site-template
  $-(site-inputs website)
::
+$  email-template
  $+  email-template
  $-(email-inputs [email-mime (unit tang)])
::
+$  site-inputs
  $+  site-inputs
  $:  name=term
      =binding:eyre
      =posts:channels
      =channel:channel:groups
      comments=?
      =style-vars
      headline=@t
      profile-img=@t
      header-img=@t
  ==
::
+$  email-inputs
  $+  email-inputs
  $:  name=term
      site-binding=(unit binding:eyre)
      email-binding=(unit binding:eyre)
      =note:diary
      =channel:channel:groups
  ==
::
+$  website       (map @t webpage)
+$  paywall-snip  [head=marl body=marl]
+$  webpage       [dat=mime snip=(unit paywall-snip) err=(unit tang) auth=(unit @tas)]
+$  email-mime    [subject=@t body=mime]
+$  update
  $%  [%site name=term =website]
      [%email name=term email=email-mime]
      [%flows flows=(map term flow)]
      [%templates site=(set term) email=(set term)]
      [%errors err=(map term (map @t tang))]
      [%styles styles=(map term style-vars)]
  ==
::
::  old versions
::
+$  state-7
  $+  state-7
  $:  flows=(map name=term flow-7)
      *
  ==
::
+$  flow-7
  $:  =resource
      =index
      site=(unit site-8)
      email=(unit term)
      auth-rule=(unit auth-rule)
  ==
::
+$  state-8
  $+  state-8
  $:  flows=(map name=term flow-8)
      styles=(map term style-vars)
  ==
::
+$  flow-8
  $:  =resource
      site=(unit site-8)
      email=(unit term)
      auth-rule=(unit auth-rule)
      style=(unit term)
  ==
::
+$  site-8
  $:  template=term
      comments=?
      width=?(%1 %2 %3)
      lit=?
      accent=@ux
  ==
::
+$  site-9
  $:  template=term
      comments=?
  ==
::
+$  flow-9
  $:  =resource
      site=(unit site-9)
      email=(unit term)
      auth-rule=(unit auth-rule)
      style=(unit term)
  ==
::
+$  state-9
  $+  state-9
  $:  flows=(map name=term flow-9)
      styles=(map term style-vars)
  ==
::
+$  remove-inputs
  $:  site-name=term
      plugin-name=term
      sub-path=path
  ==
::
+$  edit-inputs
  $:  site-name=term
      old-sub-path=path
      new-sub-path=path
      old-plugin-name=term
      new-plugin-name=term
      =resource:resource
      template=term
      comments=?
      style=(unit term)
      headline=@t
      profile-img=@t
      header-img=@t
  ==
::
+$  add-inputs
  $:  site-name=term
      plugin-name=term
      sub-path=path
      =resource:resource
      template=term
      comments=?
      style=(unit term)
      headline=@t
      profile-img=@t
      header-img=@t
  ==
::
+$  thread-action
  $%  [%add add-inputs]
      [%edit edit-inputs]
      [%remove remove-inputs]
  ==
--
