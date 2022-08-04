/-  spider, pipe, switchboard, mailer
/+  strandio
|%
+$  parsed-inputs
  $:  site-name=term
      plugin-name=term
      sub-path=path
  ==
++  dejs
  =,  dejs:format
  ^-  $-(json parsed-inputs)
  %-  ot
  :~  site-name+so
      plugin-name+so
      sub-path+pa
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
=/  sp=action:switchboard
  :*  %del-plugin
      site-name.input
      sub-path.input
  ==
::
=/  pa=action:pipe
  :*  %remove
      plugin-name.input
  ==
::
;<  ml=(unit mailing-list:mailer)  bind:m
  %+  scry:strandio  (unit mailing-list:mailer)
  /gx/mailer/list/[plugin-name.input]/noun
::
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sp))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
?~   ml
  (pure:m !>(~))
::
=/  sm=action:switchboard
  :*  %del-plugin
      site-name.input
      /mail
  ==
=/  ma=action:mailer  [%del-list plugin-name.input]
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(ma))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sm))
(pure:m !>(~))
