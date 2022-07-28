/-  spider, pipe, switchboard, graph-store
/+  strandio, resource
|%
+$  parsed-inputs
  $:  site-name=term
      old-sub-path=path
      new-sub-path=path
      old-plugin-name=term
      new-plugin-name=term
      =resource:resource
      template=term
      comments=?
      width=?(%1 %2 %3)
      lit=?
  ==
++  dejs
  =,  dejs:format
  ^-  $-(json parsed-inputs)
  %-  ot
  :~  site-name+so
      old-sub-path+pa
      new-sub-path+pa
      old-plugin-name+so
      new-plugin-name+so
      resource+dejs:resource
      template+so
      comments+bo
      width+width
      lit+bo
  ==
::
++  width
  |=  j=json
  ^-  ?(%1 %2 %3)
  ?>  ?=(%n -.j)
  ?:  =(p.j ~.1)  %1
  ?:  =(p.j ~.2)  %2
  ?:  =(p.j ~.3)  %3
  !!
::
--
^-  thread:spider
|=  arg=vase
=/  m  (strand:spider ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  !<(jon=(unit json) arg)
?~  jon
  (pure:m !>("invalid input"))
=/  input=parsed-inputs  (dejs u.jon)
=/  has-site=?
  .^(? %gx /(scot %p our.bowl)/switchboard/(scot %da now.bowl)/has-site/[site-name.input]/noun)
?.  has-site
  (pure:m !>("no such switchboard site exists: {<site-name.input>}"))
::
=/  del-switch=action:switchboard
  [%del-plugin site-name.input old-sub-path.input]
=/  del-pipe=action:pipe
  [%remove old-plugin-name.input]
=/  add-pipe=action:pipe
  :*  %add
      new-plugin-name.input
      resource.input
      ~
      `[template.input comments.input width.input lit.input 0x0]
      ~
      ~
  ==
=/  add-switch=action:switchboard
  :*  %add-plugin
      site-name.input
      new-sub-path.input
      [%pipe new-plugin-name.input]
  ==
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(del-switch))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(del-pipe))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(add-pipe))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(add-switch))
(pure:m !>(~))
