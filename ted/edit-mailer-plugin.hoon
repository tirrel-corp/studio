/-  spider, pipe, switchboard, graph-store, mailer
/+  strandio, resource
|%
+$  parsed-inputs
  $:  site-name=term
      old-path=path
      new-path=path
      old-name=term
      new-name=term
      api-key=@t
      email=@t
      mailing-list=(set @t)
      template=term
  ==
++  dejs
  =,  dejs:format
  ^-  $-(json parsed-inputs)
  %-  ot
  :~  site-name+so
      old-path+pa
      new-path+pa
      old-name+so
      new-name+so
      api-key+so
      email+so
      mailing-list+(as so)
      template+so
  ==
::
--
^-  thread:spider
|=  arg=vase
~&  %edit-thread
=/  m  (strand:spider ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  !<(jon=(unit json) arg)
?~  jon
  ~&  %no-json
  (pure:m !>("invalid input"))
=/  input=parsed-inputs  (dejs u.jon)
~&  %succeeded-parsing
::
=/  pa=action:pipe
  :*  %edit
      new-name.input
      [%email `template.input]^~
  ==
=/  del-list=action:mailer
  [%del-list old-name.input]
=/  add-list=action:mailer
  [%add-list new-name.input mailing-list.input]
=/  set-creds=action:mailer
  [%set-creds `api-key.input `email.input ~]
::
=/  del-s=action:switchboard
  :*  %del-plugin
      site-name.input
      old-path.input
  ==
=/  add-s=action:switchboard
  :*  %add-plugin
      site-name.input
      new-path.input
      %mailer
      new-name.input
  ==
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(set-creds))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(del-s))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(del-list))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(add-list))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(add-s))
(pure:m !>(~))
