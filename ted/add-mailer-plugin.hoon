/-  spider, pipe, switchboard, graph-store, mailer
/+  strandio, resource
|%
+$  parsed-inputs
  $:  site-name=term
      sub-path=path
      plugin-name=term
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
      sub-path+pa
      plugin-name+so
      api-key+so
      email+so
      mailing-list+(as so)
      template+so
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
;<  has-site=?  bind:m
  (scry:strandio ? /gx/switchboard/has-site/[site-name.input]/noun)
?.  has-site
  (pure:m !>("no such site exists: {<site-name.input>}"))
::
;<  res=(unit resource)  bind:m
  (scry:strandio (unit resource) /gx/pipe/resource/[plugin-name.input]/noun)
?~  res
  (pure:m !>("no such pipe-plugin exists: {<plugin-name.input>}"))
::
=/  pa=action:pipe
  :*  %edit
      plugin-name.input
      [%email `template.input]^~
  ==
=/  set-creds=action:mailer
  [%set-creds `api-key.input `email.input ~]
=/  add-list=action:mailer
  [%add-list plugin-name.input mailing-list.input]
::
=/  sa=action:switchboard
  :*  %add-plugin
      site-name.input
      sub-path.input
      [%mailer plugin-name.input]
  ==
=/  rebuild=action:pipe  [%build plugin-name.input]
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(set-creds))
;<  ~  bind:m  (poke-our:strandio %mailer %mailer-action !>(add-list))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sa))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(rebuild))
(pure:m !>(~))
