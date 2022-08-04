/-  spider, pipe, switchboard, graph-store, mailer
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
;<  has-site=?  bind:m
  (scry:strandio ? /gx/switchboard/has-site/[site-name.input]/noun)
?.  has-site
  (pure:m !>("no such switchboard site exists: {<site-name.input>}"))
::
=/  del-sp=action:switchboard
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
=/  add-sp=action:switchboard
  :*  %add-plugin
      site-name.input
      new-sub-path.input
      [%pipe new-plugin-name.input]
  ==
=/  del-sm=action:switchboard
  [%del-plugin site-name.input /mail]
=/  add-sm=action:switchboard
  :*  %add-plugin
      site-name.input
      /mail
      [%mailer new-plugin-name.input]
  ==
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(del-sp))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(del-pipe))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(add-pipe))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(add-sp))
;<  ml=(unit mailing-list:mailer)  bind:m
  %+  scry:strandio  (unit mailing-list:mailer)
  /gx/mailer/list/[old-plugin-name.input]/noun
?~  ml
  (pure:m !>(~))
=/  m-del  [%del-list old-plugin-name.input]
=/  m-add  [%add-list new-plugin-name.input (~(run in u.ml) head)]
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(del-sm))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(m-del))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(m-add))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(add-sm))
(pure:m !>(~))
