:: pipe [tirrel]
::
/-  *pipe,
    switchboard,
    diary,
    email,
    paywall,
    channels
/+  default-agent,
    dbug,
    verb,
    graph,
    pipe-json,
    server,
    *pipe-templates,
    pipe-render,
    resource,
    grate,
    switchboard,
    *constants
|%
+$  card  $+(card card:agent:gall)
--
::
=|  [%11 state-11]
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
  :-  ~
  this(styles default-styles)
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =+  !<(old=versioned-state old-vase)
  =/  cards=(list card)
    [behn-build ~]
  |-
  ?-  -.old
      %11
    =.  styles.old
      (~(uni by styles.old) default-styles)
    =.  styles.old  (~(del by styles.old) %light)
    =.  styles.old  (~(del by styles.old) %dark)
    [cards this(state old)]
  ::
      %10
    =/  new-flows=(map term flow)
      %-  ~(run by flows.old)
      |=  f=flow-9
      ^-  flow
      =/  new-site=(unit site)
        ?~  site.f  ~
        `[template.u.site.f comments.u.site.f '' '' '']
      :*  resource.f
          new-site
          email.f
          auth-rule.f
          style.f
      ==
    =/  new-state=state-11
      :*  new-flows
          styles.old
      ==
    $(old [%11 new-state])
  ::
      %9
    =/  new-flows=(map term flow-9)
      %-  ~(run by flows.old)
      |=  f=flow-9
      ^-  flow-9
      f(auth-rule `[%per-subpath ~])
    =/  new-state=state-9
      [new-flows styles.old]
    $(old [%10 new-state])
  ::
      %8
    =/  new-flows=(map term flow-9)
      %-  ~(run by flows.old)
      |=  f=flow-8
      ^-  flow-9
      =/  new-site=(unit site-9)
        ?~  site.f  ~
        `[template.u.site.f comments.u.site.f]
      =/  new-style=(unit term)
        ?~  site.f  ~
        [~ ?:(lit.u.site.f %light %dark)]
      :*  resource.f
          new-site
          email.f
          auth-rule.f
          new-style
      ==
    =/  new-state=state-9
      :*  new-flows
          default-styles
      ==
    $(old [%9 new-state])
  ::
      %7
    =/  new-flows=(map term flow-8)
      %-  ~(run by flows.old)
      |=  f=flow-7
      ^-  flow-8
      :*  resource.f
          site.f
          email.f
          auth-rule.f
          ~
      ==
    =/  new-state=state-8
      :*  new-flows
          ~
      ==
    $(old [%8 new-state])
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (moon:switchboard our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %handle-http-request
    `this
      %noun
    `this
  ::
      %pipe-action
    =^  cards  state
      (pipe-action !<(action vase))
    [cards this]
  ==
  ::
  ++  pipe-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %build
      ~|  [name.action flows]
      ?~  flow=(~(get by flows) name.action)
        ~&  %no-build
        `state
      :_  state
      (update-posts:pc name.action u.flow)
    ::
        %add
      ?<  (~(has by flows) name.action)
      ?~  site.flow.action  !!
      =.  flows  (~(put by flows) name.action flow.action)
      =/  =flag:diary  resource.flow.action
      =/  =path  /diary/(scot %p p.flag)/[q.flag]
      =/  =wire  /diary/(scot %p p.flag)/[q.flag]/[name.action]
      :_  state
      :~  give-flows:pc
          behn-build
          [%pass wire %agent [our.bowl %channels] %watch path]
      ==
    ::
        %remove
      =/  =flow  (~(got by flows) name.action)
      =.  flows  (~(del by flows) name.action)
      ~!  flow
      =/  =flag:diary  resource.flow
      =/  =wire  /diary/(scot %p p.flag)/[q.flag]/[name.action]
      :_  state
      :~  give-flows:pc
          [%pass wire %agent [our.bowl %channels] %leave ~]
      ==
    ::
        %edit
      |^
      =/  fl=flow  (~(got by flows) name.action)
      =/  new=flow
        %+  roll  edits.action
        |=  [=edit f=_fl]
        ?-  -.edit
            %resource   f(resource resource.edit)
            %email      f(email email.edit)
            %site       (site-edit edit-site.edit f)
            %auth-rule  f(auth-rule rule.edit)
            %style      f(style style.edit)
        ==
      =.  flows  (~(put by flows) name.action new)
      ?~  site.new
        `state
      =/  of=flag:diary  resource.fl
      =/  nf=flag:diary  resource.new
      =/  ow=path  /diary/(scot %p p.of)/[q.of]/[name.action]
      =/  np=path  /diary/(scot %p p.nf)/[q.nf]
      =/  nw=path  /diary/(scot %p p.nf)/[q.nf]/[name.action]
      =/  cards  (update-posts:pc name.action new)
      :_  state
      :*  give-flows:pc
          [%pass ow %agent [our.bowl %channels] %leave ~]
          [%pass nw %agent [our.bowl %channels] %watch np]
          cards
      ==
      ::
      ++  site-edit
        |=  [=edit-site f=flow]
        ^-  flow
        ?~  site.f
          ?>  ?=(%whole -.edit-site)
          ?~  site.edit-site  f  :: no change
          f(site site.edit-site)
        ?-  -.edit-site
          %template  f(template.u.site term.edit-site)
          %comments  f(comments.u.site comments.edit-site)
          %whole     f(site site.edit-site)
        ==
      --
    ::
        %set-style
      =.  styles
        ?~  style.action
          (~(del by styles) name.action)
        (~(put by styles) name.action style.action)
      =/  cards  update-all-posts:pc
      :_  state
      [give-styles:pc ~]
    ==
  --
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    ?.  ?=([%diary @ @ @ ~] wire)
      `this
    =/  =path  [%diary i.t.wire i.t.t.wire ~]
    :_  this
    [%pass wire %agent [our.bowl %channels] %watch path]^~
  ::
      %fact
    ?:  ?=([%diary @ @ @ ~] wire)
      =/  ship  (slav %p i.t.wire)
      =/  book  i.t.t.wire
      =/  name  i.t.t.t.wire
      =/  f=(unit flow)  (~(get by flows) name)
      ?~  f  `this
      :_  this
      (update-posts:pc name u.f)
    ::
    (on-agent:def wire sign)
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=(%eyre -.sign-arvo)
    `this
  ?:  ?=(%behn -.sign-arvo)
    :_  this
    update-all-posts:pc
  `this
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (moon:switchboard our.bowl src.bowl)
  ?+    path  (on-watch:def path)
      [%email @ ~]        `this
      [%http-response *]  `this
  ::
      [%updates ~]
    =/  templates=update
      :+  %templates
        ~(key by site-templates)
      ~(key by email-templates)
    =/  flow=update     [%flows flows]
    =/  sty=update  [%styles styles]
    :_  this
    :~  [%give %fact ~ %pipe-update !>(flow)]
        [%give %fact ~ %pipe-update !>(templates)]
        [%give %fact ~ %pipe-update !>(sty)]
    ==
  ::
      [%site @ ~]
    `this
  ::
      [%switch @ ~]
    `this
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
      [%x %resource @ ~]
    =*  name  i.t.t.path
    =/  res=(unit resource)
      ?~  f=(~(get by flows) name)  ~
      `resource.u.f
    ``noun+!>(res)
  ::
      [%x %flow @ ~]
    =*  name  i.t.t.path
    =/  res=(unit flow)  (~(get by flows) name)
    ``noun+!>(res)
  ::
      [%x %templates ~]
    :^  ~  ~  %json  !>
    %-  pairs:enjs:format
    :~  :+  %site  %a
        %+  turn  ~(tap by site-templates)
        |=  [=term *]
        [%s term]
    ::
        :+  %email  %a
        %+  turn  ~(tap by email-templates)
        |=  [=term *]
        [%s term]
    ==
  ::
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
++  get-email-template
  |=  name=term
  ^-  (unit versioned-email-template)
  (~(get by email-templates) name)
::
++  get-site-template
  |=  name=term
  ^-  (unit versioned-site-template)
  (~(get by site-templates) name)
::
++  give-site
  |=  [name=term =website]
  ^-  card
  =/  =update  [%site name website]
  [%give %fact [/site/[name]]~ %pipe-update !>(update)]
::
++  give-switch
  |=  [name=term =website]
  ^-  card
  =/  =update  [%site name website]
  [%give %fact [/switch/[name]]~ %pipe-update !>(update)]
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
++  poke-aggregator
  |=  [=resource agg=agg-data:paywall]
  ^-  card
  =/  =action:paywall
    [%pipe-data resource `agg]
  (poke-controller / action)
::
++  poke-controller
  |=  [=wire act=action:paywall]
  ^-  card
  [%pass wire %agent [controller %paywall] %poke %paywall-action !>(act)]
::
++  give-templates
  ^-  card
  =/  =update
    :+  %templates
      ~(key by site-templates)
    ~(key by email-templates)
  [%give %fact [/updates]~ %pipe-update !>(update)]
::
++  give-flows
  ^-  card
  =/  =update  [%flows flows]
  [%give %fact [/updates]~ %pipe-update !>(update)]
::
++  give-styles
  ^-  card
  =/  =update  [%styles styles]
  [%give %fact [/updates]~ %pipe-update !>(update)]
::
++  behn-build
  ^-  card
  [%pass /build %arvo %b %wait now.bowl]
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
++  scry
  |*  [=term =mold =path]
  ~|  path
  .^  mold  %gx
      (scot %p our.bowl)
      term
      (scot %da now.bowl)
      path
  ==
::
++  apply-auth-to-site
  |=  [w=website rule=(unit auth-rule)]
  ^-  website
  ?~  rule  w
  =*  rul  u.rule
  %-  ~(gas by *website)
  %+  turn  ~(tap by w)
  |=  [p=@t q=webpage]
  ^-  [@t webpage]
  :-  p
  ?-    -.rul
    %all          q(auth `p.rul)
    %subpaths     q(auth ?:(=('/' p) ~ `p.rul))
    %none         q(auth ~)
  ::
      %per-subpath
    =/  val  (~(get by p.rul) p)
    ?~  val  q(auth ~)
    q(auth u.val)
  ==
::
++  get-site-errors
  |=  =website
  ^-  (map @t tang)
  %-  ~(gas by *(map @t tang))
  %+  murn  ~(tap by website)
  |=  [path=@t page=mime snip=(unit paywall-snip) err=(unit tang) auth=(unit @tas)]
  ^-  (unit [@t tang])
  ?~  err  ~
  `[path u.err]
::
++  get-site-inputs
  |=  [name=term =flow =posts:channels]
  ^-  site-inputs
  =/  s  (need site.flow)
  =/  site-binding=binding:eyre
    %-  need
    (scry %switchboard ,(unit binding:eyre) /site-by-plugin/pipe/[name]/noun)
  =/  style=style-vars
    ?~  style.flow  ~
    ?~  s=(~(get by styles) u.style.flow)  ~
    u.s
  :*  name
      site-binding
      posts
      (get-group-info resource.flow)
      comments.s
      style
      headline.s
      profile-img.s
      header-img.s
  ==
::
++  update-all-posts
  ^-  (list card)
  %-  zing
  (turn ~(tap by flows) update-posts)
::
++  update-posts
  |=  [name=term =flow]
  ^-  (list card)
  ~&  building+name
  ?~  site.flow  ~
  =/  vs=versioned-site-template
    ~|  "no such template: {<template.u.site.flow>}"
    (need (get-site-template template.u.site.flow))
  ?>  ?=(%0 -.vs)
  =/  scry-path
    :~  %v1
        %diary
        (scot %p entity.resource.flow)
        name.resource.flow
        %posts
        %newest
        '100.000'
        %post
        %channel-posts
    ==
  =/  paged-posts  (scry %channels paged-posts:channels scry-path)
  =/  site-inputs  (get-site-inputs name flow posts.paged-posts)
  =/  agg  (gen-agg-data name u.site.flow posts.paged-posts)
  =/  =website  (p.vs site-inputs)
  =.  website   (apply-auth-to-site website auth-rule.flow)
  :*  (give-site name website)
      (give-switch name website)
      ?~(agg ~ (poke-aggregator u.agg)^~)
  ==
::
++  gen-agg-data
  |=  [name=term s=site p=posts:channels]
  ^-  (unit [resource agg-data:paywall])
  =/  site-name=(unit term)
    .^((unit term) %gx /(scot %p our.bowl)/switchboard/(scot %da now.bowl)/site-key-by-plugin/pipe/[name]/noun)
  =/  full-url=(unit @t)
    .^((unit term) %gx /(scot %p our.bowl)/switchboard/(scot %da now.bowl)/url-for-blog/[name]/noun)
  =/  on-posts  ((on id-post:channels (unit post:channels)) lte)
  =/  latest=(unit [t=time n=(unit post:channels)])
    (ram:on-posts p)
  =/  last-data=(unit [@t @t @t @da])
    ?~  latest  ~
    ?~  n.u.latest  ~
    ?>  ?=(%diary -.kind-data.u.n.u.latest)
    :-  ~
    :*  (cat 3 '/' (strip-title:pipe-render title.kind-data.u.n.u.latest))
        title.kind-data.u.n.u.latest
        image.kind-data.u.n.u.latest
        sent.u.n.u.latest
    ==
  ?~  site-name  ~
  ?~  full-url   ~
  :+  ~
    [our.bowl u.site-name]
  :*  u.full-url
      `headline.s
      `profile-img.s
      `header-img.s
      last-data
  ==
::
++  get-group-info
  |=  df=resource
  ^-  channel:channel:groups
  =/  channel-perm=perm:channels
    .^(perm:channels %gx /(scot %p our.bowl)/channels/(scot %da now.bowl)/v1/diary/(scot %p entity.df)/[name.df]/perm/channel-perm)
  =/  gs=groups:groups :: (scry %groups groups:groups %gx /groups/groups)
    .^(groups:groups %gx /(scot %p our.bowl)/groups/(scot %da now.bowl)/groups/groups)
  =/  =group:groups   (~(got by gs) group.channel-perm)
  (~(got by channels.group) %diary df)
::
++  default-styles
  ^-  (map term style-vars)
  =/  dark=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#111111'
        :-  '--text-main'        '#FFFFFF'
        :-  '--text-bright'      '#FFFFFF'
        :-  '--selection'        '#1c76c5'
        :-  '--links'            '#41adff'
        :-  'font'  'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZhrib2Bg-4.ttf'
    ==
  =/  dark-serif=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#111111'
        :-  '--text-main'        '#FFFFFF'
        :-  '--text-bright'      '#FFFFFF'
        :-  '--selection'        '#1c76c5'
        :-  '--links'            '#41adff'
        :-  'font'  'https://fonts.gstatic.com/s/gentiumbookbasic/v16/pe0zMJCbPYBVokB1LHA9bbyaQb8ZGjcIV7t7w6bE2A.ttf'
    ==
  =/  light=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#FFFFFF'
        :-  '--text-main'        '#111111'
        :-  '--text-bright'      '#111111'
        :-  '--selection'        '#9e9e9e'
        :-  '--links'            '#0076d1'
        :-  'font'  'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZhrib2Bg-4.ttf'
    ==
  =/  light-serif=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#FFFFFF'
        :-  '--text-main'        '#111111'
        :-  '--text-bright'      '#111111'
        :-  '--selection'        '#9e9e9e'
        :-  '--links'            '#0076d1'
        :-  'font'  'https://fonts.gstatic.com/s/gentiumbookbasic/v16/pe0zMJCbPYBVokB1LHA9bbyaQb8ZGjcIV7t7w6bE2A.ttf'
    ==
  =/  legal-pad=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#fffca8'
        :-  '--text-main'        '#000000'
        :-  '--text-bright'      '#000000'
        :-  '--selection'        '#4dc9ff'
        :-  '--links'            '#3200ff'
        :-  'font'  'https://fonts.gstatic.com/s/comicneue/v8/4UaHrEJDsxBrF37olUeDx63j5pN1MwI.ttf'
    ==
  =/  meltdown=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#000000'
        :-  '--text-main'        '#00dc1a'
        :-  '--text-bright'      '#00dc1a'
        :-  '--selection'        '#17e4ff'
        :-  '--links'            '#3700ff'
        :-  'font'  'https://fonts.gstatic.com/s/orbitron/v25/yMJMMIlzdpvBhQQL_SC3X9yhF25-T1nyGy6xpmIyXjU1pg.ttf'
    ==
  =/  paper=style-vars
    %-  ~(gas by *(map @t @t))
    :~  :-  '--background-body'  '#fffcf0'
        :-  '--text-main'        '#000000'
        :-  '--text-bright'      '#000000'
        :-  '--selection'        '#17e4ff'
        :-  '--links'            '#000000'
        :-  'font'  'https://fonts.gstatic.com/s/inriaserif/v14/fC1lPYxPY3rXxEndZJAzN0SsfSzNr0Ck.ttf'
    ==
  %-  ~(gas by *(map term style-vars))
  :~  [%'Dark' dark]
      [%'Dark Serif' dark-serif]
      [%'Light' light]
      [%'Light Serif' light-serif]
      [%'Legal Pad' legal-pad]
      [%'Meltdown' meltdown]
      [%'Paper' paper]
  ==
--
