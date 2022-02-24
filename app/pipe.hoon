:: pipe [tirrel]: graph-store to website conversion
::
::
/-  *pipe, meta=metadata-store
/+  default-agent,
    dbug,
    verb,
    graph,
    pipe-json,
    server,
    *pipe-templates,
    pipe-render,
    resource,
    meta-lib=metadata-store
|%
+$  card  card:agent:gall
--
::
=|  [%4 state-3]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    pc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  :_  this(state [%4 *state-3])
  [%pass /graph %agent [our.bowl %graph-store] %watch /updates]~
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  |^
  =+  !<(old=versioned-state old-vase)
  |-
  ?-    -.old
      %4
    :_  this(state old)
    %+  turn  ~(tap by flows.old)
    |=  [=term =flow]
    [%pass /update-site/[term] %arvo %b %wait now.bowl]
  ::
    %3  $(old (state-3-to-4 old))
    %2  $(old (state-2-to-3 old))
    %1  $(old (state-1-to-2 old))
    %0  $(old (state-0-to-1 old))
  ==
  ++  state-3-to-4
    |=  [%3 s=state-2]
    ^-  [%4 state-3]
    [%4 s(sites ~, custom-site ~, custom-email ~)]
  ::
  ++  state-2-to-3
    |=  [%2 s=state-1]
    ^-  [%3 state-2]
    :*  %3
        %-  ~(run by flows.s)
        |=  f=flow-1
        ^-  flow
        %=    f
            site
          ?~  site.f
            ~
          :-  ~
          :*  ?+  template.u.site.f  !!
                %dark-urbit   %urbit
                %light-urbit  %urbit
                %dark-basic   %basic
                %light-basic  %basic
              ==
            ::
              binding.u.site.f
              comments.u.site.f
              %2
            ::
              ?+  template.u.site.f  !!
                %dark-urbit   %.n
                %light-urbit  %.y
                %dark-basic   %.n
                %light-basic  %.y
              ==
            ::
              0x0
          ==
        ==
        sites.s
        uid-to-name.s
        ~
        ~
        ~
    ==
  ::
  ++  state-1-to-2
    |=  [%1 s=state-1]
    ^-  [%2 state-1]
    :-  %2
    %=  s
        flows
      %-  ~(rut by flows.s)
      |=  [name=term f=flow-1]
      ^-  flow-1
      %=  f
        email
        ?~  email.f  ~
        ::?.  (scry:pc %mailer ? /has-list/[name]/noun)
          ~
        ::Email.f
      ==
    ==
  ::
  ++  state-0-to-1
    |=  [%0 s=state-0]
    ^-  [%1 state-1]
    :-  %1
    %=  s
        flows
      %-  ~(run by flows.s)
      |=  f=flow-0
      ^-  flow-1
      :*  resource.f
          index.f
          (site-0-to-1 site.f)
          email.f
      ==
    ==
  ::
  ++  site-0-to-1
    |=  old=(unit [t=term b=binding:eyre])
    ^-  (unit [term binding:eyre ?])
    ?~  old  ~
    `[t.u.old b.u.old %.n]
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %pipe-action
    =^  cards  state
      (pipe-action !<(action vase))
    [cards this]
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta req=inbound-request:eyre] vase)
    :_  this
    %+  give-simple-payload:app:server  eyre-id
    (handle-http-request req)
  ==
  ::
  ++  pipe-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %add
      ?<  (~(has by flows) name.action)
      ?~  site.action  !!
      ?:  (binding-taken binding.u.site.action)
        ~|("binding already taken {<`path`path.binding.u.site.action>}" !!)
      =.  flows  (~(put by flows) name.action +>.action)
      =.  uid-to-name
        %+  ~(put ju uid-to-name)
          [resource.action index.action]
        name.action
      =/  =site-template
        ~|  "no such template: {<template.u.site.action>}"
        (need (get-site-template:pc template.u.site.action))
      =/  =website  (site-template (get-site-inputs:pc name.action +>.action))
      =.  sites     (~(put by sites) name.action website)
      :_  state
      :*  (give-site:pc name.action website)
          give-flows:pc
          (serve:pc name.action binding.u.site.action)
      ==
    ::
        %remove
      =/  =flow  (~(got by flows) name.action)
      =/  cards=(list card)
        ?~  site.flow  ~
        [%pass /eyre %arvo %e %disconnect binding.u.site.flow]~
      =.  flows  (~(del by flows) name.action)
      =.  sites  (~(del by sites) name.action)
      =.  uid-to-name
        %+  ~(del ju uid-to-name)
          [resource.flow index.flow]
        name.action
      :_  state
      [give-flows:pc cards]
    ::
        %edit
      |^
      =/  fl=flow  (~(got by flows) name.action)
      =/  [cards=(list card) new=flow rebuild=?]
        %+  roll  edits.action
        |=  [=edit cards=(list card) f=_fl rebuild=_|]
        ?-  -.edit
            %resource  [cards f(resource resource.edit) %.y]
            %email     [cards f(email email.edit) %.y]
            %site      (site-edit edit-site.edit cards f %.y)
        ==
      =.  flows  (~(put by flows) name.action new)
      ?~  site.new
        [cards state(sites (~(del by sites) name.action))]
      ?.  rebuild
        :_  state
        :*  give-flows:pc
            cards
        ==
      =/  =site-template
        ~|  "no such template: {<template.u.site.new>}"
        (need (get-site-template:pc template.u.site.new))
      =/  =website  (site-template (get-site-inputs:pc name.action new))
      =.  sites     (~(put by sites) name.action website)
      :_  state
      :*  give-flows:pc
          (give-site:pc name.action website)
          cards
      ==
      ::
      ++  site-edit
        |=  [=edit-site cards=(list card) f=flow rebuild=?]
        ^-  [(list card) flow ?]
        ?~  site.f
          ?>  ?=(%whole -.edit-site)
          ?~  site.edit-site  [cards f rebuild]  :: no change
          :+  [(connect binding.u.site.edit-site) cards]
            f(site site.edit-site)
          %.y
        ?-  -.edit-site
          %template  [cards f(template.u.site term.edit-site) %.y]
          %comments  [cards f(comments.u.site comments.edit-site) %.y]
          %width     [cards f(width.u.site width.edit-site) %.y]
          %lit       [cards f(lit.u.site lit.edit-site) %.y]
          %accent    [cards f(accent.u.site accent.edit-site) %.y]
        ::
            %binding
          ?:  (binding-taken binding.edit-site)
            [cards f rebuild]
          :+  :*  (disconnect binding.u.site.f)
                  (connect binding.edit-site)
                  cards
              ==
            f(binding.u.site binding.edit-site)
          %.y
        ::
            %whole
          ?~  site.edit-site
            [[(disconnect binding.u.site.f) cards] f(site ~) %.y]
          :+  :*  (disconnect binding.u.site.f)
                  (connect binding.u.site.edit-site)
                  cards
              ==
            f(site site.edit-site)
          %.y
        ==
      ::
      ++  connect
        |=  =binding:eyre
        ^-  card
        [%pass /eyre %arvo %e %connect binding dap.bowl]
      ::
      ++  disconnect
        |=  =binding:eyre
        ^-  card
        [%pass /eyre %arvo %e %disconnect binding]
      --
    ::
        %watch-templates
      =/  known-desks  .^((set desk) %cd (en-beam byk.bowl /))
      ?.  (~(has in known-desks) desk.action)
        ~&  "no such desk {<desk.action>}"
        `state
      =/  cards=(list card)
        ?~  template-desk  ~
        =/  =beak  [our.bowl u.template-desk %da now.bowl]
        =/  paths=(list path)
          %+  weld
          .^((list path) %ct (en-beam beak /site))
          .^((list path) %ct (en-beam beak /email))
        %+  turn  paths
        |=  =path
        =/  wire  [%a (scag (dec (lent path)) path)]
        (template-warp:pc wire u.template-desk %a path ~)
      =.  cards
        %+  weld  cards
        :~  (template-warp:pc /t/site desk.action %t /site %sing)
            (template-warp:pc /t/email desk.action %t /email %sing)
        ==
      :_  state(template-desk `desk.action)
      ?~  template-desk
        cards
      ~&  "replacing old template desk {<u.template-desk>}"
      :*  (template-warp:pc /t/site u.template-desk %t /site ~)
          (template-warp:pc /t/email u.template-desk %t /email ~)
          cards
      ==
   ::
        %wipe-templates
      ?~  template-desk
        ~&  "not watching any desks"
        `state
      =/  =beak  [our.bowl u.template-desk %da now.bowl]
      =/  paths=(list path)
        %+  weld
        .^((list path) %ct (en-beam beak /site))
        .^((list path) %ct (en-beam beak /email))
      =/  cards=(list card)
        %+  turn  paths
        |=  =path
        =/  wire  [%a (scag (dec (lent path)) path)]
        (template-warp:pc wire u.template-desk %a path ~)
      :_  state(template-desk ~)
      :*  (template-warp:pc /t/site u.template-desk %t /site ~)
          (template-warp:pc /t/email u.template-desk %t /email ~)
          cards
      ==
    ==
  ::
  ++  binding-taken
    |=  =binding:eyre
    ^-  ?
    %-  ~(rep by flows)
    |=  [[term f=flow] out=_|]
    ?~  site.f       out
    ?:  out          out
    =(binding.u.site.f binding)
  ::
  ++  handle-http-request
    |=  req=inbound-request:eyre
    ^-  simple-payload:http
    |^
    =/  req-line=request-line:server
      (parse-request-line:server url.request.req)
    =/  host=(unit @t)
      (~(get by (~(gas by *(map @t @t)) header-list.request.req)) 'host')
    ::
    =/  flow-req=(unit [name=term path=@t])
      %-  ~(rep by flows)
      |=  [[name=term =flow] out=(unit [term @t])]
      ?~  site.flow  out
      ?.  =(site.binding.u.site.flow host)  out
      =/  suffix=(unit path)
        (get-suffix path.binding.u.site.flow site.req-line)
      ?~  suffix  out
      `[name (spat u.suffix)]
    ::
    ?~  flow-req
      not-found:gen:server
    ::
    =/  web=(unit website)
      (~(get by sites) name.u.flow-req)
    =/  page=(unit [mime (unit tang)])
      ?~  web  ~
      (~(get by u.web) path.u.flow-req)
    ?~  page
      not-found:gen:server
    [[200 [['content-type' 'text/html'] ~]] `q.-.u.page]
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
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    :_  this
    ?.  ?=([%graph ~] wire)
      ~
    [%pass /graph %agent [our.bowl %graph-store] %watch /updates]^~
  ::
      %fact
    |^
    ?.  ?=(%graph-update-3 p.cage.sign)
      (on-agent:def wire sign)
    =/  =update:store:graph  !<(update:store:graph q.cage.sign)
    ?+  -.q.update
      `this
    ::
        %remove-graph
      =/  name=(unit term)
        %-  ~(rep by flows)
        |=  [[name=term =flow] out=(unit term)]
        ?:  =(resource.q.update resource.flow)
          `name
        out
      ?~  name
        `this
      :-  ~
      %=  this
        flows         (~(del by flows) u.name)
        sites         (~(del by sites) u.name)
        uid-to-name   (~(del by uid-to-name) [resource.q.update ~])
      ==
    ::
        %remove-posts
      =^  cards  state
        %+  roll  (update-to-flows update)
        |=  $:  [name=term =flow]
                [cards=(list card) sty=_state]
            ==
        ^-  [(list card) _state]
        =^  site-cards   sty
          (update-site:pc name flow)
        :_  sty
        (weld site-cards cards)
      [cards this]
    ::
        %add-nodes
      =^  cards  state
        %+  roll  (update-to-flows update)
        |=  $:  [name=term =flow]
                [cards=(list card) sty=_state]
            ==
        ^-  [(list card) _state]
        =^  site-cards   sty
          (update-site:pc name flow)
        =/  email-cards
          (update-email name flow update)
        :_  sty
        :(weld site-cards email-cards cards)
      [cards this]
    ==
    ::
    ++  update-email
      |=  [name=term =flow =update:store:graph]
      ^-  (list card)
      ?~  email.flow
        ~
      ?.  ?=(%add-nodes -.q.update)
        ~
      =/  post=(unit post:store:graph)
        %-  ~(rep by nodes.q.update)
        |=  [[=index =node:store:graph] out=(unit post:store:graph)]
        ?.  ?=([@ @ @ ~] index)
          out
        ?.  =(1 i.t.t.index)  :: only send first revision
          out
        ?.  ?=(%& -.post.node)
          out
        `p.post.node
      ?~  post
        ~
      =/  =email-template  (need (get-email-template:pc u.email.flow))
      =/  [em=email err=(unit tang)]
        (email-template (get-email-inputs:pc name flow u.post))
      [(give-email:pc name em)]~
    ::
    ++  update-to-flows
      |=  =update:store:graph
      ^-  (list [term flow])
      ?>  ?=(?(%add-nodes %remove-posts) -.q.update)
      %+  murn  ~(tap by flows)
      |=  [name=term =flow]
      ?.  =(resource.flow resource.q.update)
        ~
      `[name flow]
    ::
    ++  update-to-flows-old
    :: XX unused, but kept here in case we want to start using indices again
      |=  =update:store:graph
      ^-  (list [term flow])
      ?>  ?=(%add-nodes -.q.update)
      =*  rid    resource.q.update
      =*  nodes  nodes.q.update
      =-  %+  murn  -
          |=  name=term
          ?~  maybe-flow=(~(get by flows) name)
            ~
          `[name u.maybe-flow]
      %~  tap  in
      %-  ~(gas in *(set term))
      %-  zing
      %+  turn  ~(tap in ~(key by nodes))
      |=  =index
      ^-  (list term)
      =|  names=(set term)
      |-
      ?~  index
        %~  tap  in
        %-  ~(uni in names)
        (~(get ju uid-to-name) [rid index])
      %_  $
        index  (snip `(list @)`index)
        names  (~(uni in names) (~(get ju uid-to-name) [rid index]))
      ==
    --
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%behn -.sign-arvo)
    ?:  ?=([%update-site @ ~] wire)
      =/  name  i.t.wire
      =/  flow  (~(got by flows) name)
      =^  cards  state
        (update-site:pc name flow)
      [cards this]
    `this
  ::
  ?:  ?=(%eyre -.sign-arvo)
    `this
  ?.  ?=([%clay %writ *] sign-arvo)
    (on-arvo:def wire sign-arvo)
  ?+  wire  (on-arvo:def wire sign-arvo)
  ::
      [%t ?(%site %email) ~]
    ?~  p.sign-arvo  !!
    =/  files  !<((list path) q.r.u.p.sign-arvo)
    =*  which  i.t.wire
    =*  desk   r.p.u.p.sign-arvo
    =/  diff   (diff-files files which)
    =?  custom-site  =(which %site)
      %-  ~(rep in del.diff)
      |=  [=term out=_custom-site]
      (~(del by out) term)
    =?  custom-email  =(which %email)
      %-  ~(rep in del.diff)
      |=  [=term out=_custom-email]
      (~(del by out) term)
    :_  this
    ?~  template-desk  ~
    :-  (template-warp:pc wire u.template-desk %t /[which] %next)
    %+  weld
      (process-add add.diff which desk)
    (process-del del.diff which desk)
  ::
      [%a ?(%site %email) @ ~]
    =*  which  i.t.wire
    =*  name   i.t.t.wire
    =/  =path  /[which]/[name]/hoon
    =?  custom-site  =(which %site)
      ?~  template-desk
        (~(del by custom-site) name)
      ?~  p.sign-arvo
        (~(del by custom-site) name)
      =+  !<(=vase q.r.u.p.sign-arvo)
      =/  mid=(each site-template tang)
        (mule |.(!<(site-template vase)))
      ?-  -.mid
          %.y
        %-  (slog leaf+"built template: {<path>}" ~)
        (~(put by custom-site) name p.mid)
      ::
          %.n
        %-  (slog leaf+"template build failure: {<path>}" ~)
        (~(del by custom-site) name)
      ==
    =?  custom-email  =(which %email)
      ?~  template-desk
        (~(del by custom-email) name)
      ?~  p.sign-arvo
        (~(del by custom-email) name)
      =+  !<(=vase q.r.u.p.sign-arvo)
      =/  mid=(each email-template tang)
        (mule |.(!<(email-template vase)))
      ?-  -.mid
          %.y
        %-  (slog leaf+"built template: {<path>}" ~)
        (~(put by custom-email) name p.mid)
      ::
          %.n
        %-  (slog leaf+"template build failure: {<path>}" ~)
        (~(del by custom-email) name)
      ==

    :_  this
    ?~  template-desk  [give-templates:pc]~
    ?~  p.sign-arvo    [give-templates:pc]~
    :~  give-templates:pc
        (template-warp:pc wire u.template-desk %a path %next)
    ==
  ==
  ::
  ++  diff-files
    |=  [new-list=(list path) which=?(%site %email)]
    ^-  [add=(set term) del=(set term)]
    =/  old=(set term)
      ?-  which
        %site   ~(key by custom-site)
        %email  ~(key by custom-email)
      ==
    =/  new=(set term)
      %-  ~(gas in *(set term))
      %+  turn  new-list
      |=  =path
      ^-  term
      ?>  ?=([@ @ %hoon ~] path)
      i.t.path
    =/  add  (~(dif in new) old)
    =/  del  (~(dif in old) new)
    [add del]
  ::
  ++  process-add
    |=  [add=(set term) which=?(%site %email) =desk]
    ^-  (list card)
    %+  turn  ~(tap in add)
    |=  =term
    (template-warp:pc /a/[which]/[term] desk %a /[which]/[term]/hoon %sing)
  ::
  ++  process-del
    |=  [del=(set term) which=?(%site %email) =desk]
    ^-  (list card)
    %+  turn  ~(tap in del)
    |=  =term
    ^-  card
    (template-warp:pc /a/[which]/[term] desk %a /[which]/[term]/hoon ~)
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?+    path  (on-watch:def path)
      [%email @ ~]        `this
      [%http-response *]  `this
  ::
      [%updates ~]
    =/  templates=update
      :+  %templates
        (~(uni in ~(key by site-templates)) ~(key by custom-site))
      (~(uni in ~(key by email-templates)) ~(key by custom-email))
    =/  flow=update    [%flows flows]
    =/  errors=update  [%errors get-all-errors:pc]
    :_  this
    :~  [%give %fact ~ %pipe-update !>(flow)]
        [%give %fact ~ %pipe-update !>(templates)]
        [%give %fact ~ %pipe-update !>(errors)]
    ==
  ::
      [%site @ ~]
    =*  name  i.t.path
    =/  =update  [%site name (~(got by sites) name)]
    :_  this
    [%give %fact ~ %pipe-update !>(update)]~
  ::
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
      [%x %export ~]
    ``noun+!>(state)
  ::
      [%x %flows ~]
    :^  ~  ~  %json  !>
    :-  %o
    %-  ~(rut by flows)
    |=  [name=term =flow]
    =/  =association:meta  (get-metadata:pc resource.flow)
    %-  pairs:enjs:format
    :~  flow+(flow:enjs:pipe-json flow)
        metadata+(metadatum:enjs:meta-lib metadatum:association)
    ==
  ::
      [%x %notebooks ~]
    =/  assoc=associations:meta
      %^  scry:pc  %metadata-store
        associations:meta
      /app-name/graph/noun
    :^  ~  ~  %json  !>
    :-  %a
    %-  ~(rep by assoc)
    |=  [[=md-resource:meta =association:meta] out=(list json)]
    ?.  ?&  =(our.bowl entity.resource.md-resource)
            =(our.bowl creator.metadatum.association)
            =([%graph %publish] config.metadatum.association)
        ==
      out
    :_  out
    %-  pairs:enjs:format
    :~  resource+(enjs:resource resource.md-resource)
        metadata+(metadatum:enjs:meta-lib metadatum.association)
    ==
  ::
      [%x %templates ~]
    :^  ~  ~  %json  !>
    %-  pairs:enjs:format
    :~  :+  %site  %a
        %+  turn  (weld ~(tap by site-templates) ~(tap by custom-site))
        |=  [=term *]
        [%s term]
    ::
        :+  %email  %a
        %+  turn  (weld ~(tap by email-templates) ~(tap by custom-email))
        |=  [=term *]
        [%s term]
    ==
  ::
      [%x %preview ?(%site %email) @ ~]
    ?+  i.t.t.path  !!
        %site
      =/  temp  (~(get by site-templates) i.t.t.t.path)
      ?~  temp
        [~ ~]
      =/  site  (u.temp lorem-ipsum:pipe-render)
      =/  [index=mime (unit tang)]    (~(got by site) '/')
      =/  [article=mime (unit tang)]  (~(got by site) '/ut-enim-ad-minim-veniam')
      :^  ~  ~  %json  !>
      %-  pairs:enjs:format
      :~  index+s+q.q.index
          article+s+q.q.article
      ==
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
::
|_  =bowl:gall
+*  gra  ~(. graph bowl)
++  our-beak
  ^-  beak
  [our.bowl q.byk.bowl %da now.bowl]
::
++  serve
  |=  [name=term =binding:eyre]
  ^-  (list card)
  =/  cards=(list card)
    [%pass /eyre %arvo %e %connect binding dap.bowl]~
  =/  flo  (~(get by flows) name)
  ?~  flo
    cards
  ?~  site.u.flo
    cards
  :_  cards
  [%pass /eyre %arvo %e %disconnect binding.u.site.u.flo]
::
++  get-email-template
  |=  name=term
  ^-  (unit email-template)
  =/  res  (~(get by custom-email) name)
  ?^  res  res
  (~(get by email-templates) name)
::
++  get-site-template
  |=  name=term
  ^-  (unit site-template)
  =/  res  (~(get by custom-site) name)
  ?^  res  res
  (~(get by site-templates) name)
::
++  give-site
  |=  [name=term =website]
  ^-  card
  =/  =update  [%site name website]
  [%give %fact [/site/[name]]~ %pipe-update !>(update)]
::
++  give-errors
  |=  [name=term =website]
  ^-  card
  =/  errors=(map @t tang)  (get-site-errors website)
  =/  =update
    :-  %errors
    %-  ~(gas by *(map term (map @t tang)))
    [name errors]^~
  [%give %fact [/site/[name]]~ %pipe-update !>(update)]
::
++  give-email
  |=  [name=term =email]
  ^-  card
  =/  =update  [%email name email]
  [%give %fact [/email/[name]]~ %pipe-update !>(update)]
::
++  give-templates
  ^-  card
  =/  =update
    :+  %templates
      (~(uni in ~(key by site-templates)) ~(key by custom-site))
    (~(uni in ~(key by email-templates)) ~(key by custom-email))
  [%give %fact [/updates]~ %pipe-update !>(update)]
::
++  give-flows
  ^-  card
  =/  =update  [%flows flows]
  [%give %fact [/updates]~ %pipe-update !>(update)]
::
++  orm  ((on atom node:store:graph) gth)
::
++  get-comments
  |=  =node:store:graph
  ^-  (list post:store:graph)
  ?.  ?=(%graph -.children.node)
    ~
  %+  murn  ~(val by p.children.node)
  |=  n=node:store:graph
  ?>  ?=(%graph -.children.n)
  =/  com  (got:orm p.children.n 1)
  ?.  ?=(%& -.post.com)
    ~
  `p.post.com
::
++  get-posts
  |=  [res=resource comments=?]
  ^-  %-  list
      $:  initial-date=@da
          latest-post=post:store:graph
          comments=(list post:store:graph)
      ==
  =/  =update:store:graph
    %+  scry-for:gra  update:store:graph
    /graph/(scot %p entity.res)/[name.res]/node/children/kith/'~'/'~'
  ?>  ?=(%add-nodes -.q.update)
  %+  sort
    %+  murn  ~(tap by nodes.q.update)
    |=  [=index =node:store:graph]
    ?:  ?=(%| -.post.node)
      ~
    ?>  ?=(%graph -.children.node)
    =/  arc=node:store:graph  (got:orm p.children.node 1)
    =/  com=node:store:graph  (got:orm p.children.node 2)
    ?>  ?=(%graph -.children.arc)
    =/  latest=(unit [@ node:store:graph])  (pry:orm p.children.arc)
    =/  first=(unit [@ node:store:graph])   (ram:orm p.children.arc)
    ?~  latest  !!
    ?~  first   !!
    ?>  ?=(%& -.post.+.u.latest)
    ?>  ?=(%& -.post.+.u.first)
    :-  ~
    :*  time-sent.p.post.+.u.first
        p.post.+.u.latest
        ?.(comments ~ (get-comments com))
    ==
  |=  $:  a=[t=@da *]
          b=[t=@da *]
      ==
  (gth t.a t.b)
::
++  get-metadata
  |=  res=resource
  ^-  association:meta
  %-  need
  %^  scry  %metadata-store
    (unit association:meta)
  /metadata/graph/ship/(scot %p entity.res)/[name.res]/noun
::
++  get-site-inputs
  |=  [name=term =flow]
  ^-  site-inputs
  =/  s  (need site.flow)
  :*  name
      binding.s
      (get-posts resource.flow comments.s)
      (get-metadata resource.flow)
      comments.s
      ?=(^ email.flow)
      width.s
      lit.s
      accent.s
  ==
::
++  get-email-inputs
  |=  [name=term =flow =post:store:graph]
  ^-  email-inputs
  =/  site-binding=(unit binding:eyre)
    ?~  site.flow  ~
    `binding.u.site.flow
  :*  name
      site-binding
      post
      (get-metadata resource.flow)
  ==
::
++  scry
  |*  [=term =mold =path]
  .^  mold  %gx
      (scot %p our.bowl)
      term
      (scot %da now.bowl)
      path
  ==
::
++  template-warp
  |=  [=wire =desk =care:clay =path mod=?(~ %sing %next)]
  ^-  card
  =/  =mood:clay  [care [%da now.bowl] path]
  =/  rav=(unit rave:clay)
    ?-  mod
      ~       ~
      %sing   `[%sing mood]
      %next   `[%next mood]
    ==
  [%pass wire %arvo %c %warp our.bowl desk rav]
::
++  update-site
  |=  [name=term =flow]
  ^-  (quip card _state)
  ?~  site.flow
    `state
  =/  =site-template  (need (get-site-template template.u.site.flow))
  =/  =website   (site-template (get-site-inputs name flow))
  =.  sites      (~(put by sites) name website)
  =/  errors=update  [%errors get-all-errors]
  :_  state
  :~  (give-site name website)
      [%give %fact [/updates]~ %pipe-update !>(errors)]
  ==
::
++  get-all-errors
  ^-  (map term (map @t tang))
  (~(run by sites) get-site-errors)
::
++  get-site-errors
  |=  =website
  ^-  (map @t tang)
  %-  ~(gas by *(map @t tang))
  %+  murn  ~(tap by website)
  |=  [path=@t page=mime err=(unit tang)]
  ^-  (unit [@t tang])
  ?~  err  ~
  `[path u.err]
--
