/-  spider, pipe, switchboard, graph-store
/+  strandio, resource
^-  thread:spider
|=  arg=vase
=/  m  (strand:spider ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  !<(input=(unit thread-action:pipe) arg)
?~  input
  (pure:m !>(>"invalid input"<^~))
?>  ?=(%add -.u.input)
=/  has-site=?
  .^(? %gx /(scot %p our.bowl)/switchboard/(scot %da now.bowl)/has-site/[site-name.u.input]/noun)
?.  has-site
  (pure:m !>(>"no such switchboard site exists: {<site-name.u.input>}"<^~))
::=/  keys=update:graph-store
::  .^(update:graph-store %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/keys/graph-update-3)
::?>  ?=(%keys -.q.keys)
::?.  (~(has in resources.q.keys) resource.u.input)
::  (pure:m !>(s+'no such notebook exists: {<resource.u.input>}'))
=/  pa=action:pipe
  :*  %add
      plugin-name.u.input
      resource.u.input
      `[template.u.input comments.u.input headline.u.input profile-img.u.input header-img.u.input]
      `%light
      `[%per-subpath ~]
      style.u.input
  ==
::
=/  sa=action:switchboard
  :*  %add-plugin
      site-name.u.input
      sub-path.u.input
      [%pipe plugin-name.u.input]
  ==
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sa))
(pure:m !>(~))
