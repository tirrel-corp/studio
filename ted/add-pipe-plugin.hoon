/-  spider, pipe, switchboard, graph-store
/+  strandio, resource
|%
+$  parsed-inputs
  $:  site-name=term
      plugin-name=term
      sub-path=path
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
      plugin-name+so
      sub-path+pa
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
=/  keys=update:graph-store
  .^(update:graph-store %gx /(scot %p our.bowl)/graph-store/(scot %da now.bowl)/keys/graph-update-3)
?>  ?=(%keys -.q.keys)
?.  (~(has in resources.q.keys) resource.input)
  (pure:m !>("no such notebook exists: {<resource.input>}"))
=/  pa=action:pipe
  :*  %add
      plugin-name.input
      resource.input
      ~
      `[template.input comments.input width.input lit.input 0x0]
      ~
      ~
  ==
::
=/  sa=action:switchboard
  :*  %add-plugin
      site-name.input
      sub-path.input
      [%pipe plugin-name.input]
  ==
;<  ~  bind:m  (poke-our:strandio %pipe %pipe-action !>(pa))
;<  ~  bind:m  (poke-our:strandio %switchboard %switchboard-action !>(sa))
(pure:m !>(~))
