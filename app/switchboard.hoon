::  switchboard [tirrel]
::
/-  *switchboard, pipe
/+  server,
    default-agent,
    dbug,
    verb,
    grate
|%
+$  card  card:agent:gall
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
  `this(state *_state)
::  =/  old-state  !<([%0 state-0] old-vase)
::  `this(state old-state)
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
    =/  res=simple-payload:http  (handle-http-request req)
    :_  this
    (give-simple-payload:app:server eyre-id res)
  ==
  ::
  ++  switchboard-action
    |=  act=action
    ^-  (quip card _state)
    ?-  -.act
        %add-site
      ?:  (~(has by sites) name.act)
        ~|("name taken" !!)
      =/  =binding:eyre  [`name.act ~]
      :-  [%pass /eyre %arvo %e %connect binding dap.bowl]^~
      %=  state
        sites  (~(put by sites) name.act ~)
      ==
    ::
        %del-site
      ?~  site=(~(get by sites) name.act)
        ~|("so such site" !!)
      =/  =binding:eyre  [`name.act ~]
      :-  [%pass /eyre %arvo %e %disconnect binding]^~
      %=  state
        sites  (~(del by sites) name.act)
      ==
    ::
        %add-plugin
      ?~  site=(~(get by sites) name.act)
        ~|("so such site" !!)
      ?:  (~(has by plugins.u.site) path.act)
        ~|("subpath taken" !!)
      =.  plugins.u.site  (~(put by plugins.u.site) path.act plugin.act)
      :_  %=  state
        sites  (~(put by sites) name.act u.site)
      ==
      ?-   -.plugin.act
          %pipe
        [%pass /pipe/[name.plugin.act] %agent [our.bowl %pipe] %watch /switch/[name.plugin.act]]^~
      ::
          %mailer  !!
      ==
    ::
        %del-plugin
      ?~  site=(~(get by sites) name.act)
        ~|("so such site" !!)
      ?~  plugin=(~(get by plugins.u.site) path.act)
        ~|("no such plugin" !!)
      =.  plugins.u.site  (~(del by plugins.u.site) path.act)
      :_  %=  state
        sites  (~(put by sites) name.act u.site)
      ==
      ?-   -.u.plugin
          %pipe
        [%pass /pipe/[name.u.plugin] %agent [our.bowl %pipe] %leave ~]^~
      ::
          %mailer  !!
      ==
    ==
  ::
  ++  handle-http-request
    |=  req=inbound-request:eyre
    ^-  simple-payload:http
    =/  req-line=request-line:server
      (parse-request-line:server url.request.req)
    =/  host=(unit @t)
      (get-header:http 'host' header-list.request.req)
    ~&  [host=host req-line=req-line]
    ?~  host
      not-found:gen:server
    ?~  site=(~(get by sites) u.host)
      not-found:gen:server
    ?~  plugins.u.site
      =/  =manx  ;div: site has not been configured yet
      (manx-response:gen:server manx)
    =/  sufi=(unit [=path =plugin])
      (get-plugin plugins.u.site site.req-line)
    ?~  sufi
      not-found:gen:server
    ?-  -.plugin.u.sufi
        %pipe
      (handle-pipe-request path.u.sufi website.plugin.u.sufi)
    ::
        %mailer
      not-found:gen:server
    ==
  ::
  ++  handle-pipe-request
    |=  [=path =website:pipe]
    !!
  ::
  ++  get-plugin
    |=  [plugins=(map path plugin) req-path=path]
    ^-  (unit [path plugin])
    =/  plug-list  ~(tap by plugins)
    |-
    =*  loop  $
    ?~  plug-list  ~
    =/  suf  (get-suffix -.i.plug-list req-path)
    ?^  suf
      `[u.suf +.i.plug-list]
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
    ~&  sign-arvo
    `this
  `this
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+  path  (on-watch:def path)
    [%http-response *]  `this
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    ?>  ?=([@ *] wire)
    =*  plugin  i.wire
    =*  path    t.wire
    :_  this
    [%pass wire %agent [our.bowl plugin] %watch %switch path]^~
  ::
      %fact
    `this
  ==
::
++  on-peek   on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
