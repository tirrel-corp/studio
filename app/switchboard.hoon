::  switchboard [tirrel]
::
/-  *switchboard, pipe, mailer, meta=metadata-store, *resource
/+  server,
    default-agent,
    dbug,
    verb,
    grate,
    pages=switchboard-pages
|%
+$  card  $+(card card:agent:gall)
--
::
=|  [%0 state-0]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::    do    ~(. +> bowl)
::
++  on-init  `this
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
::  `this(state *_state)
  =/  old-state  !<([%0 state-0] old-vase)
  `this(state old-state)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+  mark  (on-poke:def mark vase)
      %switchboard-action
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
  ++  switchboard-action
    |=  act=action
    ^-  (quip card _state)
    ?-  -.act
        %add-site
      ?:  (~(has by sites) name.act)
        ~|("name taken" !!)
      =/  =binding:eyre  [`host.act path.act]
      =.  sites    (~(put by sites) name.act [binding ~])
      =.  by-binding  (~(put by by-binding) binding name.act)
      =/  =update  act
      :_  state
      :~  [%pass /eyre %arvo %e %connect binding dap.bowl]
          [%give %fact [/update]~ %switchboard-update !>(update)]
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
        ::
            %mailer
          =/  =plugin  [%mailer name.plugin-state]
          =/  =wire  (weld /mailer/[name.plugin-state]/[name.act] path)
          =/  del=action:mailer  [%del-list name.plugin-state]
          :_  (~(del by out) plugin)
          :+  [%pass wire %agent [our.bowl %mailer] %leave ~]
            [%pass wire %agent [our.bowl %mailer] %poke %mailer-action !>(del)]
          cad
        ==
      =/  =update  act
      :_  state
      :*  [%pass /eyre %arvo %e %disconnect binding.u.site]
          [%give %fact [/update]~ %switchboard-update !>(update)]
          cards
      ==
    ::
        %add-plugin
      ?~  site=(~(get by sites) name.act)
        ~|("no such site" !!)
      ?:  (~(has by plugins.u.site) path.act)
        ~|("subpath taken" !!)
      =/  =plugin-state
        ?-  -.plugin.act
          %pipe    [%pipe name.plugin.act ~]
          %mailer  [%mailer name.plugin.act]
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
      ::
          %mailer
        =/  =wire  (weld /mailer/[name.plugin.act]/[name.act] path.act)
        :~  [%give %fact [/update]~ %switchboard-update !>(update)]
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
          %mailer  [%mailer name.u.plugin-state]
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
      ::
          %mailer
        =/  =wire  (weld /mailer/[name.plugin]/[name.act] path.act)
        :~  [%pass wire %agent [our.bowl %mailer] %leave ~]
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
    ::
        %mailer
      %:  handle-mailer
          sub-path.u.plugin
          args.req-line
          request.req
      ==
    ==
  ::
  ++  handle-mailer
    |=  [=path args=(list [@t @t]) =request:http]
    ^-  (quip card simple-payload:http)
    ?+  path  `not-found:gen:server
    ::
        [%unsubscribe ~]
      =/  token=(unit @t)  (get-header:http 'token' args)
      ?~  token
        `not-found:gen:server
      =/  details=(unit [name=term email=@t @uv ?])
        (scry %mailer ,(unit [term @t @uv ?]) /ship-token/[u.token]/noun)
      ?~  details  `not-found:gen:server
      =/  title=@t  (get-blog-title name.u.details)
      :-  (poke-mailer %del-recipients name.u.details (sy email.u.details ~))^~
      (manx-response:gen:server (unsubscribe:pages title))
    ::
        [%subscribe ~]
      ?.  ?=(%'POST' method.request)
        `not-found:gen:server
      =/  type=(unit @t)  (get-header:http 'content-type' header-list.request)
      ?:  ?|(?=(~ body.request) ?=(~ type))
        `not-found:gen:server
      ?~  parsed-body=(rush q.u.body.request yquy:de-purl:html)
        `not-found:gen:server
      =/  who=(unit @t)   (get-header:http 'who' u.parsed-body)
      =/  book=(unit @t)  (get-header:http 'book' u.parsed-body)
      ?:  ?|(?=(~ who) ?=(~ book))
        `not-found:gen:server
      =/  title=@t  (get-blog-title u.book)
      :-  (poke-mailer %add-recipients u.book (sy u.who ~) %.n)^~
      (manx-response:gen:server (subscribe:pages title))
    ::
        [%confirm ~]
      =/  token=(unit @t)  (get-header:http 'token' args)
      ?~  token
        `not-found:gen:server
      =/  det=(unit [name=term email=@t @uv ?])
        (scry %mailer ,(unit [term @t @uv ?]) /ship-token/[u.token]/noun)
      ?~  det  `not-found:gen:server
      =/  title=@t  (get-blog-title name.u.det)
      :-  (poke-mailer %add-recipients name.u.det (sy email.u.det ~) %.y)^~
      (manx-response:gen:server (confirm:pages title))
    ==
  ::
  ++  get-blog-title
    |=  name=term
    ^-  @t
    =/  res=resource
      %-  need
      (scry %pipe (unit resource) /resource/[name]/noun)
    =/  assoc=association:meta
      %-  need
      %^  scry  %metadata-store
        (unit association:meta)
      /metadata/graph/ship/(scot %p our.bowl)/[name.res]/noun
    title.metadatum.assoc
  ::
  ++  scry
    |*  [=term =mold =path]
    .^(mold %gx (scot %p our.bowl) term (scot %da now.bowl) path)
  ::
  ++  poke-mailer
    |=  act=action:mailer
    ^-  card
    =/  =wire  /foo
    [%pass wire %agent [our.bowl %mailer] %poke mailer-action+!>(act)]
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
  ?:  ?=(%eyre -.sign-arvo)
    ::~&  sign-arvo
    `this
  `this
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
    ::
        %mailer
      `this
    ==
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+  path  (on-peek:def path)
      [%x %has-site @ ~]
    =*  name  i.t.t.path
    ``noun+!>((~(has by sites) name))
  ::
      [%x %site-by-plugin ?(%pipe %mailer) @ ~]
    =*  plugin-type  i.t.t.path
    =*  name    i.t.t.t.path
    =/  =plugin
      ?-  plugin-type
        %pipe    [%pipe name]
        %mailer  [%mailer name]
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
  ==
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
