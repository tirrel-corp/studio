::  switchboard [tirrel]
::
/-  *switchboard,
    pipe,
    *resource,
    pals,
    hark-store,
    groups,
    auth
/+  server,
    default-agent,
    dbug,
    verb,
    grate,
    pages=switchboard-pages,
    switchboard,
    constants
|%
+$  card  $+(card card:agent:gall)
++  controller  ~tirrel
+$  local-action
  $%  [%add-serf lord=ship serf=ship]
      [%add-rule lord=ship =rule]
      [%add-lord lord=ship]
      [%del-lord lord=ship]
      [%wipe-rules lord=ship]
  ==
--
::
=|  [%4 state-4]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =/  old-state  !<(versioned-state old-vase)
  =|  cards=(list card)
  |-
  ?-  -.old-state
      %4
    [cards this(state old-state)]
  ::
      %3
    =/  new-sites=(map term site)
      %-  ~(urn by sites.old-state)
      |=  [n=term s=site-3]
      ^-  site
      =/  new-plugs=(map path plugin-state)
        %-  ~(gas by *(map path plugin-state))
        %+  murn  ~(tap by plugins.s)
        |=  [=path p=plugin-state-3]
        ^-  (unit [^path plugin-state])
        ?-  -.p
          %pipe    `[path `plugin-state`[%pipe name.p website.p]]
          %mailer  ~
        ==
      [n binding.s new-plugs]
    =/  new-plugins=(map plugin [term path])
      %-  ~(gas by *(map plugin [term path]))
      %+  murn  ~(tap by by-plugin.old-state)
      |=  [p=plugin-3 =term =path]
      ^-  (unit [plugin ^term ^path])
      ?-  -.p
        %pipe    `[p term path]
        %mailer  ~
      ==
    %=  $
        old-state
      :*  %4
        new-sites
        by-binding.old-state
        new-plugins
        join-rules.old-state
        bg-image.old-state
      ==
    ==
  ::
      %2
    =/  [cad=(list card) new-sites=(map term site-3)]
      %-  ~(rep by sites.old-state)
      |=  [[t=term s=site-2] cad=(list card) dat=(map term site-3)]
      ^-  [(list card) (map term site-3)]
      =/  [pcad=(list card) ps=(map path plugin-state-3)]
        %-  ~(rep by plugins.s)
        |=  [[pa=path p=plugin-state-2] cad=(list card) dat=(map path plugin-state-3)]
        ^-  [(list card) (map path plugin-state-3)]
        ?-  -.p
            %mailer  [cad (~(put by dat) pa p)]
            %pipe
          =/  pipe-act=action:pipe  [%build name.p]
          :_  (~(put by dat) pa p(website ~))
          [[%pass / %agent [our.bowl %pipe] %poke %pipe-action !>(pipe-act)] cad]
        ==
      :_  (~(put by dat) t [binding.s ps])
      (weld cad pcad)
    %=  $
        cards  cad
    ::
        old-state
      :*  %3
        new-sites
        by-binding.old-state
        by-plugin.old-state
        join-rules.old-state
        bg-image.old-state
      ==
    ==
  ::
      %1
    %=  $
      old-state   [%4 *state-4]
    ==
  ::
      %0
    %=  $
        old-state
      :*  %1
          sites.old-state
          by-binding.old-state
          by-plugin.old-state
          ~
      ==
    ==
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?+  mark  (on-poke:def mark vase)
      %noun
    ?>  (moon:switchboard our.bowl src.bowl)
    =+  !<(act=local-action vase)
    ?-  -.act
        %wipe-rules
      ?~  join-data=(~(get by join-rules) lord.act)
        ~&  >>>  "lord doesn't exists"
        `this
      =.  rule-set.u.join-data  *rule-set
      =.  join-rules
        (~(put by join-rules) lord.act u.join-data)
      `this
    ::
        %del-lord
      ?.  (~(has by join-rules) lord.act)
        ~&  >>>  "lord doesn't exists"
        `this
      =.  join-rules  (~(del by join-rules) lord.act)
      `this
    ::
        %add-lord
      ?:  (~(has by join-rules) lord.act)
        ~&  >>>  "lord already exists"
        `this
      =.  join-rules  (~(put by join-rules) lord.act ~ [%1 ~ ~ ~])
      `this
    ::
        %add-serf
      =/  =join-data  (~(got by join-rules) lord.act)
      =.  serfs.join-data  (~(put in serfs.join-data) serf.act)
      =.  join-rules  (~(put by join-rules) lord.act join-data)
      =/  groups-cards=(list card)
        %+  roll  ~(tap in groups.rule-set.join-data)
        |=  [[=resource private=?] out=(list card)]
        =/  =wire  /control/group-add/(scot %p entity.resource)/(scot %p name.resource)/(scot %p serf.act)
        =/  cact=controller-action
          [%group-add resource serf.act]
        ?.  private
          :_  out
          [%pass wire %agent [serf.act %switchboard] %poke %switchboard-control !>(cact)]
        :+  [%pass wire %agent [entity.resource %switchboard] %poke %switchboard-control !>(cact)]
          [%pass wire %agent [serf.act %switchboard] %poke %switchboard-control !>(cact)]
        out
      =/  pals-cards=(list card)
        %+  roll  ~(tap in pals.rule-set.join-data)
        |=  [=ship out=(list card)]
        =/  =wire  /control/pal-add/(scot %p ship)
        =/  cact=controller-action
          [%pal-add lord.act serf.act]
        :+  [%pass wire %agent [lord.act %switchboard] %poke %switchboard-control !>(cact)]
          [%pass wire %agent [serf.act %switchboard] %poke %switchboard-control !>(cact)]
        out
      =/  cards=(list card)
        ?~  bg-image.rule-set.join-data
          (weld groups-cards pals-cards)
        =/  img=controller-action
          [%bg-image u.bg-image.rule-set.join-data]
        =/  =wire  /control/img-add
        :_  (weld groups-cards pals-cards)
        [%pass wire %agent [serf.act %switchboard] %poke %switchboard-control !>(img)]
      [cards this]
    ::
        %add-rule
      =/  =join-data  (~(got by join-rules) lord.act)
      =.  join-data
        ?-  -.rule.act
            %bg-image
          ~!  act
          =.  bg-image.rule-set.join-data  `img.rule.act
          join-data
        ::
            %group
          =.  groups.rule-set.join-data
            (~(put in groups.rule-set.join-data) resource.rule.act private.rule.act)
          join-data
        ::
            %pals
          =.  pals.rule-set.join-data
            (~(put in pals.rule-set.join-data) ship.rule.act)
          join-data
        ==
      =.  join-rules  (~(put by join-rules) lord.act join-data)
      `this
    ==
  ::
      %switchboard-control
    ?>  (moon:switchboard controller src.bowl)  :: note different permissions
    =^  cards  state
      (control-action !<(controller-action vase))
    [cards this]
  ::
      %switchboard-action
    ?>  (moon:switchboard our.bowl src.bowl)
    =^  cards  state
      (switchboard-action !<(action vase))
    [cards this]
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    =/  res=(pair (list card) simple-payload:http)
      (handle-http-request req)
    :_  this
    %+  weld  p.res
    (give-simple-payload:app:server eyre-id q.res)
  ==
  ::
  ++  control-action
    |=  act=controller-action
    ^-  (quip card _state)
    ?-  -.act
        %bg-image
      =.  bg-image  `img.act
      `state
    ::
        %group-add
      ?:  =(entity.resource.act our.bowl)
        =/  =invite:groups  [resource.act who.act]
        =/  add=action:groups
          [resource.act now.bowl %cordon %shut %add-ships %pending (sy who.act ~)]
        :_  state
        [%pass /group-invite %agent [our.bowl %groups] %poke %group-invite !>(add)]^~
      ?:  =(who.act our.bowl)
        =/  =join:groups  [resource.act %.y]
        :_  state
        [%pass /group-join %agent [our.bowl %groups] %poke %group-join !>(join)]^~
      `state
    ::
        %pal-add
      ?:  =(lord.act our.bowl)
        =/  pact=command:pals  [%meet who.act (sy 'hosting' ~)]
        :_  state
        [%pass /pals %agent [our.bowl %pals] %poke %pals-command !>(pact)]^~
      =/  pact=command:pals  [%meet lord.act ~]
      :_  state
      [%pass /pals %agent [our.bowl %pals] %poke %pals-command !>(pact)]^~
    ::
    ==
  ::
  ++  switchboard-action
    |=  act=action
    ^-  (quip card _state)
    ?-  -.act
        %add-site
      ~&  >>  act
      ?:  (~(has by sites) name.act)
        ~|("name taken" !!)
      =/  sec  .^([? (unit @ud) host:eyre] %e /(scot %p our.bowl)/host/(scot %da now.bowl))
      =/  =binding:eyre  [`host.act path.act]
      =/  url
        %+  rap  3
        :~  ?:  -.sec  'https://'
            'http://'
            host.act
        ::    (spat path.act)
        ==
      =.  sites    (~(put by sites) name.act [title.act binding ~])
      =.  by-binding  (~(put by by-binding) binding name.act)
      =/  =service:auth
        [~ ~ ~ title.act ~ url %.n]
      =/  auth-act=action:auth  [%add-service name.act service]
      =/  =update  act
      :_  state
      :~  [%pass /eyre %arvo %e %connect binding dap.bowl]
          [%give %fact [/update]~ %switchboard-update !>(update)]
          [%pass /auth %agent [our.bowl %auth] %poke %auth-action !>(auth-act)]
      ==
    ::
        %edit-site
      ?~  site=(~(get by sites) name.act)
        ~|("no such site" !!)
      =/  old=binding:eyre  binding.u.site
      =/  new=binding:eyre  [`host.act path.act]
      =.  by-binding  (~(del by by-binding) old)
      =.  by-binding  (~(put by by-binding) new name.act)
      =.  binding.u.site  new
      =.  name.u.site    title.act
      =.  sites    (~(put by sites) name.act u.site)
      =/  =update  act
      :_  state
      :~  [%pass /eyre %arvo %e %disconnect old]
          [%pass /eyre %arvo %e %connect new dap.bowl]
          [%give %fact [/update]~ %switchboard-update !>(update)]
      ==
    ::
        %del-site
      ?~  site=(~(get by sites) name.act)
        ~|("no such site" !!)
      =.  sites       (~(del by sites) name.act)
      =.  by-binding  (~(del by by-binding) binding.u.site)
      =^  cards  by-plugin
        %-  ~(rep by plugins.u.site)
        |=  [[=path =plugin-state] cad=(list card) out=_by-plugin]
        ?-  -.plugin-state
            %pipe
          =/  =plugin  [%pipe name.plugin-state]
          =/  =wire  (weld /pipe/[name.plugin-state]/[name.act] path)
          =/  del=action:pipe  [%remove name.plugin-state]
          :_  (~(del by out) plugin)
          :+  [%pass wire %agent [our.bowl %pipe] %leave ~]
            [%pass wire %agent [our.bowl %pipe] %poke %pipe-action !>(del)]
          cad
        ==
      =/  auth-act=action:auth  [%del-service name.act]
      =/  =update  act
      :_  state
      :*  [%pass /eyre %arvo %e %disconnect binding.u.site]
          [%give %fact [/update]~ %switchboard-update !>(update)]
          [%pass /auth %agent [our.bowl %auth] %poke %auth-action !>(auth-act)]
          cards
      ==
    ::
        %add-plugin
      ?~  site=(~(get by sites) name.act)
        ~|("no such site" !!)
      ?:  (~(has by plugins.u.site) path.act)
        ~&  >>  ~(key by plugins.u.site)
        ~&  >>  path.act
        ~|("subpath taken" !!)
      =/  =plugin-state
        ?-  -.plugin.act
          %pipe    [%pipe name.plugin.act ~]
        ==
      =.  plugins.u.site  (~(put by plugins.u.site) path.act plugin-state)
      =.  sites           (~(put by sites) name.act u.site)
      =.  by-plugin       (~(put by by-plugin) plugin.act [name.act path.act])
      =/  =update  act
      :_  state
      ?-   -.plugin.act
          %pipe
        =/  pipe-act=action:pipe  [%build name.plugin.act]
        =/  =wire  (weld /pipe/[name.plugin.act]/[name.act] path.act)
        :~  [%pass wire %agent [our.bowl %pipe] %watch /switch/[name.plugin.act]]
            [%pass wire %agent [our.bowl %pipe] %poke %pipe-action !>(pipe-act)]
            [%give %fact [/update]~ %switchboard-update !>(update)]
        ==
      ==
    ::
        %del-plugin
      ?~  site=(~(get by sites) name.act)
        ~|("no such site" !!)
      ?~  plugin-state=(~(get by plugins.u.site) path.act)
        ~|("no such plugin" !!)
      =/  =plugin
        ?-  -.u.plugin-state
          %pipe    [%pipe name.u.plugin-state]
        ==
      =.  plugins.u.site  (~(del by plugins.u.site) path.act)
      =.  sites           (~(put by sites) name.act u.site)
      =.  by-plugin       (~(del by by-plugin) plugin)
      =/  =update  act
      :_  state
      ?-   -.plugin
          %pipe
        =/  =wire  (weld /pipe/[name.plugin]/[name.act] path.act)
        :~  [%pass wire %agent [our.bowl %pipe] %leave ~]
            [%give %fact [/update]~ %switchboard-update !>(update)]
        ==
      ==
    ==
  ::
  ++  get-site
    |=  [host=@t =path]
    ^-  (unit [name=term =site =^path])
    %-  ~(rep by by-binding)
    |=  [[=binding:eyre name=term] out=(unit [term site ^path])]
    ?^  out  out
    ?.  =(`host site.binding)
      out
    ?~  suffix=(get-suffix path.binding path)
      out
    ?~  site=(~(get by sites) name)
      out
    `[name u.site u.suffix]
  ::
  ++  handle-http-request
    |=  req=inbound-request:eyre
    ^-  (quip card simple-payload:http)
    =/  req-line=request-line:server
      (parse-request-line:server url.request.req)
    =?  site.req-line  ?=(^ ext.req-line)
      %+  snoc
        (scag (dec (lent site.req-line)) site.req-line)
      (rap 3 (rear site.req-line) '.' u.ext.req-line ~)
    =/  host=(unit @t)
      (get-header:http 'host' header-list.request.req)
    ?~  host
      `not-found:gen:server
    ?~  details=(get-site u.host site.req-line)
      `not-found:gen:server
    =/  [name=term =site =path]  u.details
    ?~  plugins.site
      `(manx-response:gen:server not-configured:pages)
    ?~  plugin=(get-plugin plugins.site path)
      `not-found:gen:server
    ~|  -.plugin-state.u.plugin
    ?-  -.plugin-state.u.plugin
        %pipe
      =/  webpage=(unit webpage:pipe)
        (~(get by website.plugin-state.u.plugin) (spat sub-path.u.plugin))
      ?~  webpage
        `not-found:gen:server
      ~(open grate u.webpage sub-path.u.plugin request.req [our now]:bowl)
    ==
  ::
  ++  get-plugin
    |=  [plugins=(map path plugin-state) req-path=path]
    ^-  (unit [=sub=path =plugin-state])
    =/  plug-list  ~(tap by plugins)
    =|  possible=(list [path path plugin-state])
    |-
    =*  loop  $
    ?~  plug-list
      =/  sorted=(list [path path plugin-state])
        %+  sort  possible
        |=  [[a=path path plugin-state] [b=path path plugin-state]]
        (gth (lent a) (lent b))
      ?~  sorted  ~
      `+.i.sorted
    =/  suf  (get-suffix -.i.plug-list req-path)
    ?^  suf
      %=  loop
        possible   [[-.i.plug-list u.suf +.i.plug-list] possible]
        plug-list  t.plug-list
      ==
    loop(plug-list t.plug-list)
  ::
  ++  get-suffix
    |=  [a=path b=path]
    ^-  (unit path)
    ?:  (gth (lent a) (lent b))  ~
    |-
    ?~  a  `b
    ?~  b  ~
    ?.  =(i.a i.b)  ~
    %=  $
      a  t.a
      b  t.b
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%eyre -.sign-arvo)
    ::~&  sign-arvo
    `this
  ?:  ?=([%khan %arow *] sign-arvo)
    =^  cards  state
      (handle-thread-response wire p.sign-arvo)
    [cards this]
  `this
  ::
  ++  handle-thread-response
    |=  [=^wire p=(each cage goof)]
    ^-  (quip card _state)
    ?+  wire  `state
      [%group-invite ~]
        ?.  ?=(%.y -.p)
          ~&  >>>  "invite failed"
          `state
        `state
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
      [%http-response *]  `this
  ::
      [%update ~]
    =/  =update  [%full sites]
    :_  this
    [%give %fact ~ %switchboard-update !>(update)]^~
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %watch-ack
    ?~  p.sign
      `this
    ?>  ?=([@ @ @ *] wire)
    =*  plugin       i.wire
    =*  plugin-name  i.t.wire
    =*  host-name    i.t.t.wire
    =*  path         t.t.t.wire
    ?~  site=(~(get by sites) host-name)
      !!
    %-  (slog u.p.sign)
    =.  plugins.u.site  (~(del by plugins.u.site) path)
    =.  sites           (~(put by sites) host-name u.site)
    `this
  ::
      %kick
    ?>  ?=([@ @ *] wire)
    =*  plugin        i.wire
    =*  plugin-name   i.t.wire
    :_  this
    [%pass wire %agent [our.bowl plugin] %watch /switch/[plugin-name]]^~
  ::
      %fact
    ?>  ?=([@ @ @ *] wire)
    =*  plugin       i.wire
    =*  plugin-name  i.t.wire
    =*  host-name    i.t.t.wire
    =*  path         t.t.t.wire
    ::
    ?~  site=(~(get by sites) host-name)
      !!
    ?~  old-state=(~(get by plugins.u.site) path)
      !!
    ?>  =(-.u.old-state plugin)
    ?-  -.u.old-state
        %pipe
      ?>  ?=(%pipe-update p.cage.sign)
      =/  =update:pipe  !<(update:pipe q.cage.sign)
      ?>  ?=(%site -.update)
      ?>  =(name.u.old-state plugin-name)
      ?>  =(name.u.old-state name.update)
      =/  new=plugin-state  [%pipe name.update website.update]
      =.  plugins.u.site  (~(put by plugins.u.site) path new)
      =.  sites           (~(put by sites) host-name u.site)
      `this
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:def path)
      [%x %url-for-blog @ ~]
    =*  plugin-name  i.t.t.path
    =/  =plugin  [%pipe plugin-name]
    =/  p   (~(get by by-plugin) plugin)
    ?~  p   ``noun+!>(~)
    =/  site   (~(get by sites) -.u.p)
    ?~  site  ``noun+!>(~)
    =/  sec   .^([? (unit @ud) host:eyre] %e /(scot %p our.bowl)/host/(scot %da now.bowl))
    =/  res=(unit @t)
      :-  ~
      %+  rap  3
      :~  ?:  -.sec  'https://'
          'http://'
          (need site.binding.u.site)
          (spat (weld path.binding.u.site +.u.p))
      ==
    ``noun+!>(res)
  ::
      [%x %scene-bg ~]
    ?~  bg-image
      ``json+!>(~)
    ``json+!>(s+u.bg-image)
  ::
      [%x %full ~]
    =/  =update  [%full sites]
    ``switchboard-update+!>(update)
  ::
      [%x %has-site @ ~]
    =*  name  i.t.t.path
    ``noun+!>((~(has by sites) name))
  ::
      [%x %site-by-plugin %pipe @ ~]
    =*  plugin-type  i.t.t.path
    =*  name    i.t.t.t.path
    =/  =plugin
      ?-  plugin-type
        %pipe    [%pipe name]
      ==
    =/  plugin-site=(unit [term ^path])  (~(get by by-plugin) plugin)
    ?~  plugin-site
      ``noun+!>(~)
    ?~  site=(~(get by sites) -.u.plugin-site)
      ``noun+!>(~)
    =/  =binding:eyre
      :-  site.binding.u.site
      (weld path.binding.u.site +.u.plugin-site)
    ``noun+!>(`binding)
  ::
      [%x %site-key-by-plugin %pipe @ ~]
    =*  plugin-type  i.t.t.path
    =*  name    i.t.t.t.path
    =/  =plugin
      ?-  plugin-type
        %pipe    [%pipe name]
      ==
    =/  plugin-site=(unit [term ^path])  (~(get by by-plugin) plugin)
    ?~  plugin-site
      ``noun+!>(~)
    ?~  site=(~(get by sites) -.u.plugin-site)
      ``noun+!>(~)
    ``noun+!>(`-.u.plugin-site)
  ==
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
