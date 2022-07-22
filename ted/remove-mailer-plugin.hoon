/-  spider, pipe, switchboard, graph-store, mailer
/+  strandio, resource
|%
+$  parsed-inputs
  $:  site-name=term
      sub-path=path
      plugin-name=term
  ==
++  dejs
  =,  dejs:format
  ^-  $-(json parsed-inputs)
  %-  ot
  :~  site-name+so
      sub-path+pa
      plugin-name+so
  ==
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
::
=/  pa=action:pipe
  :*  %edit
      plugin-name.input
      [%email ~]^~
  ==
=/  del-list=action:mailer
  [%del-list plugin-name.input]
::
=/  sa=action:switchboard
  :*  %del-plugin
      site-name.input
      sub-path.input
  ==
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(del-list))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sa))
(pure:m !>(~))
