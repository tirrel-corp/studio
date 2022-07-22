/-  spider, pipe, switchboard
/+  strandio
|%
+$  parsed-inputs
  $:  site-name=term
      plugin-name=term
      plugin-path=path
  ==
++  dejs
  =,  dejs:format
  ^-  $-(json parsed-inputs)
  %-  ot
  :~  site-name+so
      plugin-name+so
      plugin-path+pa
  ==
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
=/  sa=action:switchboard
  :*  %del-plugin
      site-name.input
      plugin-path.input
  ==
::
=/  pa=action:pipe
  :*  %remove
      plugin-name.input
  ==
::
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sa))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
(pure:m ~)
