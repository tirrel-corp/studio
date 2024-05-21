/-  spider, pipe, switchboard
/+  strandio
^-  thread:spider
|=  arg=vase
=/  m  (strand:spider ,vase)
^-  form:m
;<  =bowl:spider  bind:m  get-bowl:strandio
=+  !<(input=(unit thread-action:pipe) arg)
?~  input
  (pure:m !>(>"invalid input"<^~))
?>  ?=(%remove -.u.input)
::
=/  sp=action:switchboard
  :*  %del-plugin
      site-name.u.input
      sub-path.u.input
  ==
::
=/  pa=action:pipe
  :*  %remove
      plugin-name.u.input
  ==
::
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sp))
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
(pure:m !>(~))
