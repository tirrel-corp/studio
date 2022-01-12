/-  *pipe
/+  resource, graph-store
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    %-  of
    :~  [%add (ot name+so flow+flow ~)]
        [%remove so]
        [%edit (ot name+so edits+(ar edit) ~)]
        [%watch-templates (ot desk+so ~)]
        [%wipe-templates ul]
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
        comments+bo
        width+width
        lit+bo
        accent+nu
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
  ++  binding
    %-  ot
    :~  site+(mu so)
        path+pa
    ==
  ::
  ++  edit
    %-  of
    :~  [%resource dejs:resource]
        [%site edit-site]
        [%email (mu so)]
    ==
  ::
  ++  edit-site
    %-  of
    :~  [%template so]
        [%binding binding]
        [%comments bo]
        [%width width]
        [%lit bo]
        [%accent nu]
        [%whole site]
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
    |=  s=(unit ^site)
    ^-  json
    ?~  s  ~
    %-  pairs
    :~  template+s+template.u.s
        binding+(binding binding.u.s)
        comments+b+comments.u.s
        width+s+(scot %ud width.u.s)
        lit+b+lit.u.s
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
