/-  spider, pipe, switchboard, graph-store, mailer
/+  strandio, resource
::
^-  thread:spider
|=  arg=vase
=/  m  (strand:spider ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  !<(input=(unit thread-action:pipe) arg)
?~  input
  (pure:m !>(>"invalid input"<^~))
?>  ?=(%edit -.u.input)
;<  has-site=?  bind:m
  (scry:strandio ? /gx/switchboard/has-site/[site-name.u.input]/noun)
?.  has-site
  (pure:m !>(>"no such switchboard site exists: {<site-name.u.input>}"<^~))
;<  old-flow=(unit flow:pipe)  bind:m
  (scry:strandio (unit flow:pipe) /gx/pipe/flow/[old-plugin-name.u.input]/noun)
?~  old-flow
  (pure:m !>(>"no such flow exists: {<old-plugin-name.u.input>}"<^~))
::
=/  del-sp=action:switchboard
  [%del-plugin site-name.u.input old-sub-path.u.input]
=/  del-pipe=action:pipe
  [%remove old-plugin-name.u.input]
=/  add-pipe=action:pipe
  :*  %add
      new-plugin-name.u.input
      resource.u.input
      `[template.u.input comments.u.input headline.u.input profile-img.u.input header-img.u.input]
      email.u.old-flow
      auth-rule.u.old-flow
      style.u.input
  ==
=/  add-sp=action:switchboard
  :*  %add-plugin
      site-name.u.input
      new-sub-path.u.input
      [%pipe new-plugin-name.u.input]
  ==
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(del-sp))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(del-pipe))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(add-pipe))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(add-sp))
(pure:m !>(~))
