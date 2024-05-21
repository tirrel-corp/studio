/-  *pipe
/+  resource, graph-store
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  [%add (ot name+so flow+flow ~)]
        [%remove so]
        [%edit (ot name+so edits+(ar edit) ~)]
        [%set-style (ot name+so style+(om so) ~)]
    ==
  ::
  ++  flow
    ^-  $-(json ^flow)
    %-  ot
    :~  resource+dejs:resource
        site+(mu site)
        email+(mu so)
        auth+(mu auth-rule)
        style+(mu so)
    ==
  ::
  ++  auth-rule
    ^-  $-(json ^auth-rule)
    %-  of
    :~  all+so
        subpaths+so
        per-subpath+(om (mu so))
        none+ul
    ==
  ::
  ++  site
    ^-  $-(json ^site)
    %-  ot
    :~  template+so
        comments+bo
        headline+so
        profile-img+so
        header-img+so
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
    ^-  $-(json binding:eyre)
    %-  ot
    :~  site+(mu so)
        path+pa
    ==
  ::
  ++  edit
    ^-  $-(json ^edit)
    %-  of
    :~  [%resource dejs:resource]
        [%site edit-site]
        [%email (mu so)]
        [%auth-rule (mu auth-rule)]
        [%style (mu so)]
    ==
  ::
  ++  edit-site
    ^-  $-(json ^edit-site)
    %-  of
    :~  [%template so]
        [%comments bo]
        [%whole (mu site)]
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
    ::
        %errors
      :-  %o
      %-  ~(gas by *(map @t json))
      %+  turn  ~(tap by err.u)
      |=  [=term e=(map @t tang)]
      ^-  [@t json]
      :-  term
      :-  %o
      %-  ~(run by e)
      |=  =tang
      ^-  json
      :-  %a
      %-  zing
      %+  turn  (flop tang)
      |=  =^tank
      (turn (wash [0 80] tank) tape)
    ::
        %styles
      :-  %o
      %-  ~(gas by *(map @t json))
      %+  turn  ~(tap by styles.u)
      |=  [name=term s=style-vars]
      ^-  [@t json]
      :-  name
      (styles s)
    ==
  ::
  ++  styles
    |=  s=style-vars
    ^-  json
    :-  %o
    %-  ~(gas by *(map @t json))
    %+  turn  ~(tap by s)
    |=  [k=@t v=@t]
    ^-  [@t json]
    [k s+v]
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
        site+(site site.f)
        email+?~(email.f ~ [%s u.email.f])
        auth+?~(auth-rule.f ~ (auth-rule u.auth-rule.f))
        style+?~(style.f ~ s+u.style.f)
    ==
  ::
  ++  auth-rule
    |=  rul=^auth-rule
    ^-  json
    %+  frond  -.rul
    ?-  -.rul
        %none         ~
        %all          s+p.rul
        %subpaths     s+p.rul
        %per-subpath
      :-  %o
      %-  ~(gas by *(map @t json))
      %+  murn  ~(tap by p.rul)
      |=  [k=@t v=(unit @tas)]
      ^-  (unit [@t json])
      ?~  v  ~
      `[k s+u.v]
    ==
  ::
  ++  site
    |=  s=(unit ^site)
    ^-  json
    ?~  s  ~
    %-  pairs
    :~  template+s+template.u.s
        comments+b+comments.u.s
        headline+s+headline.u.s
        profile-img+s+profile-img.u.s
        header-img+s+header-img.u.s
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
