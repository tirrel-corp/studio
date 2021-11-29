/-  *pipe
/+  resource, graph-store
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    %-  of
    :~  [%add (ot name+so flow+flow ~)]
        [%remove (ot name+so ~)]
    ==
  ::
  ++  flow
    %-  ot
    :~  resource+dejs:resource
        index+(su ;~(pfix fas (more fas dem)))
        site+site
        email+(mu so)
    ==
  ::
  ++  site
    %-  mu
    %-  ot
    :~  template+so
        binding+binding
    ==
  ::
  ++  binding
    %-  ot
    :~  site+(mu so)
        path+pa
    ==
  --
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  u=^update
    ^-  json
    %+  frond  -.u
    ?-  -.u
        %site   ~
        %email  ~
    ::
        %flows
      :-  %o
      %-  ~(gas by *(map @t json))
      %+  turn  ~(tap by flows.u)
      |=  [name=term f=^flow]
      ^-  [@t json]
      :-  name
      (flow f)
    ::
        %templates
      %-  pairs
      :~  site+(templates site.u)
          email+(templates email.u)
      ==
    ==
  ::
  ++  templates
    |=  s=(set term)
    ^-  json
    :-  %a
    %+  turn  ~(tap in s)
    |=  t=term
    ^-  json
    [%s t]
  ::
  ++  flow
    |=  f=^flow
    ^-  json
    %-  pairs
    :~  resource+(enjs:resource resource.f)
        index+(index:enjs:graph-store index.f)
        site+(site site.f)
        email+?~(email.f ~ [%s u.email.f])
    ==
  ::
  ++  site
    |=  s=(unit [template=term =binding:eyre])
    ^-  json
    ?~  s  ~
    %-  pairs
    :~  template+s+template.u.s
        binding+(binding binding.u.s)
    ==
  ::
  ++  binding
    |=  =binding:eyre
    ^-  json
    %-  pairs
    :~  site+?~(site.binding ~ [%s u.site.binding])
        path+s+(spat path.binding)
    ==
  --
--
