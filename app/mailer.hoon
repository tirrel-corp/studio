:: mailer [tirrel]
::
::
/-  *mailer, pipe, meta=metadata-store, *resource
/+  default-agent, dbug, verb, server, mailer, multipart
|%
+$  card  card:agent:gall
+$  mailing-list-0  (map @t @uv)
+$  state-0
  $:  %0
      $=  creds
      $:  api-key=(unit @t)
          email=(unit @t)
          ship-url=(unit @t)
      ==
      ml=(map term mailing-list-0)
  ==
+$  state-1
  $:  %1
      $=  creds
      $:  api-key=(unit @t)
          email=(unit @t)
          ship-url=(unit @t)
      ==
      ml=(map term mailing-list)
  ==
+$  versioned-state
  $%  state-0
      state-1
  ==
--
::
=|  state-1
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
=<
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    do    ~(. +> bowl)
::
++  on-init
  `this
::
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  |^
  =+  !<(old=versioned-state old-vase)
  =/  cards=(list card)
    [%pass /connect %arvo %e %disconnect [~ /'mailer']]^~
  |-
  ?-  -.old
    %1  [cards this(state old)]
    %0  $(old (state-0-to-1 old))
  ==
  ::
  ++  state-0-to-1
    |=  s=state-0
    ^-  state-1
    %=  s
      -   %1
      ml  (~(run by ml.s) list-0-to-1)
    ==
  ::
  ++  list-0-to-1
    |=  m=mailing-list-0
    ^-  mailing-list
    %-  ~(run by m)
    |=  t=@uv
    [t %.y]
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %mailer-action
    =^  cards  state
      (mailer-action !<(action vase))
    [cards this]
  ==
  ::
  ++  mailer-action
    |=  act=action
    ^-  (quip card _state)
    ?-    -.act
        %send-email
      =/  =wire  /send-email/(scot %uv eny.bowl)
      :_  state
      =-  [%pass wire %arvo %i %request -]~
      [(send-email:do email.act) *outbound-config:iris]
    ::
        %set-creds
      =?  api-key.creds   ?=(^ api-key.act)
        api-key.act
      =?  email.creds     ?=(^ email.act)
        email.act
      =?  ship-url.creds  ?=(^ ship-url.act)
        ship-url.act
      :_  state
      [give-update:do]~
    ::
        %unset-creds
      =?  api-key.creds   api-key.act   ~
      =?  email.creds     email.act     ~
      =?  ship-url.creds  ship-url.act  ~
      :_  state
      [give-update:do]~
    ::
        %add-list
      ?:  (~(has by ml) name.act)
        ~|("mailing list already exists: {<name.act>}" !!)
      =/  recipients=mailing-list
        %-  ~(run in mailing-list.act)
        |=  email=@t
        [email (sham email eny.bowl) %.y]
      =.  ml  (~(put by ml) name.act recipients)
      :_  state
      :~  give-update:do
          [%pass /pipe/[name.act] %agent [our.bowl %pipe] %watch /email/[name.act]]
      ==
    ::
        %del-list
      ?.  (~(has by ml) name.act)
        ~|("no such mailing list: {<name.act>}" !!)
      =.  ml  (~(del by ml) name.act)
      :_  state
      :~  give-update:do
          [%pass /pipe/[name.act] %agent [our.bowl %pipe] %leave ~]
      ==
    ::
        %add-recipients
      =/  old=(unit mailing-list)  (~(get by ml) name.act)
      ?~  old  ~|("no such mailing list: {<name.act>}" !!)
      =/  [cards=(list card) recipients=mailing-list]
        %-  ~(rep in mailing-list.act)
        |=  [email=@t cad=(list card) ml=mailing-list]
        ^-  [(list card) mailing-list]
        =/  token  (sham email eny.bowl)
        ?:  confirm.act
          :-  ~
          (~(put in ml) email [token confirm.act])
        :-  [(confirm-email:do email name.act token) cad]
        (~(put in ml) email [token confirm.act])
      =/  new=mailing-list  (~(uni by u.old) recipients)
      =.  ml  (~(put by ml) name.act new)
      :_  state
      [give-update:do cards]
    ::
        %del-recipients
      =/  old=(unit mailing-list)  (~(get by ml) name.act)
      ?~  old  ~|("no such mailing list: {<name.act>}" !!)
      =/  new=mailing-list
        %-  ~(rep in mailing-list.act)
        |=  [email=@t out=_u.old]
        (~(del by out) email)
      =.  ml  (~(put by ml) name.act new)
      :_  state
      [give-update:do]~
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  |^
  ?:  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl "bind rejected!" binding.sign-arvo]
    [~ this]
  ?.  ?=(%http-response +<.sign-arvo)
    (on-arvo:def wire sign-arvo)
  =^  cards  state
    (http-response wire client-response.sign-arvo)
  [cards this]
  ::
  ++  http-response
    |=  [=^wire res=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.res)  `state
    ?+    wire  ~|('unknown request type coming from mailer' !!)
        [%send-email @ ~]
      ?~  full-file.res
        `state
      [~ state]
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  ?:  ?=([%updates ~] path)
    =/  =update  [%initial creds ml]
    :_  this
    [%give %fact ~ %mailer-update !>(update)]~
  (on-watch:def path)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
      [%x %export ~]
    ``noun+!>(state)
  ::
      [%x %has-list @ ~]
    =*  li  i.t.t.path
    ``noun+!>((~(has by ml) li))
  ::
      [%x %ship-token @ ~]
    =*  token  i.t.t.path
    ``noun+!>((get-user-by-token:do token))
  ::
      [%x %subscribe-landing @ ~]
    =*  name  i.t.t.path
    ``hymn+!>((subscribe-landing:do name))
  ::
      [%x %unsubscribe-landing @ ~]
    =*  name  i.t.t.path
    ``hymn+!>((unsubscribe-landing:do name))
  ::
      [%x %confirm-landing @ ~]
    =*  name  i.t.t.path
    ``hymn+!>((confirm-landing:do name))
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    ?>  ?=([%pipe @ ~] wire)
    =*  name  i.t.wire
    :_  this
    [%pass /pipe/[name] %agent [our.bowl %pipe] %watch /email/[name]]~
  ::
      %fact
    ?>  ?=([%pipe @ ~] wire)
    ?>  ?=(%pipe-update p.cage.sign)
    ?~  api-key.creds
      `this
    ?~  email.creds
      `this
    =*  name  i.t.wire
    =+  !<(=update:pipe q.cage.sign)
    ?.  ?=(%email -.update)
      `this
    =/  content=(list [@t @t])
      =*  a  body.email.update
      [[(rsh [3 1] (spat p.a)) q.q.a] ~]
    =/  =mailing-list  (~(got by ml) name)
    =/  person=(list personalization-field)
      %+  murn  ~(tap by mailing-list)
      |=  [address=@t token=@uv confirmed=?]
      ?.  confirmed  ~
      =/  mailer-binding=binding:eyre
        %-  need
        (scry:do %switchboard ,(unit binding:eyre) /site-by-plugin/mailer/[name]/noun)
      =/  callback=@t
        %:  rap  3
            (need site.mailer-binding)
            (spat path.mailer-binding)
            '/unsubscribe?token='
            (encode-token token)
            ~
        ==
      :-  ~
      :*  [address]~
          ~
          [['%unsubscribe-callback%' callback] ~]
      ==
    =/  =email
      :*  [u.email.creds (scot %p our.bowl)]
          subject.email.update
          content
          person
      ==
    :_  this
    =-  [%pass /send-email/(scot %uv eny.bowl) %arvo %i %request -]~
    [(send-email:do email) *outbound-config:iris]
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
|_  =bowl:gall
::
++  encode-token
  |=  tok=@uv
  ^-  @t
  (~(en base64:mimes:html | &) [(met 3 tok) tok])
::
++  get-user-by-token
  |=  tok=@t
  ^-  (unit [term @t @uv ?])
  =/  token=(unit octs)  (~(de base64:mimes:html | &) tok)
  ?~  token
    ~
  %-  ~(rep by ml)
  |=  $:  [name=term m=mailing-list]
          out=(unit [term @t @uv ?])
      ==
  ?^  out  out
  %-  ~(rep by m)
  |=  $:  in=[@t t=@uv ?]
          out=(unit [term @t @uv ?])
      ==
  ?^  out  out
  ?:  =(t.in q.u.token)
    `[name in]
  out
::
++  parse-csv
  |=  csv=@t
  ^-  (set @t)
  |^
  =/  w=wain  (to-wain:format csv)
  %+  roll  w
  |=  [txt=@t out=(set @t)]
  %-  ~(put in out)
  (snag 0 (slice-comma txt))
  ::
  ++  slice-comma
    |=  txt=@t
    =/  len=@  (met 3 txt)
    =/  cut  =+(cut -(a 3, c 1, d txt))
    =/  sub  sub
    =|  [i=@ out=wain]
    |-  ^+  out
    =+  |-  ^-  j=@
        ?:  ?|  =(i len)
                =(',' (cut(b i)))
            ==
          i
        $(i +(i))
    =.  out  :_  out
      (cut(b i, c (sub j i)))
    ?:  =(j len)
      (flop out)
    $(i +(j))
  --
::
++  give-update
  ^-  card
  =/  =update  [%initial creds ml]
  [%give %fact [/updates]~ %mailer-update !>(update)]
::
++  send-email
  |=  =email
  ^-  request:http
  ?>  ?=(^ api-key.creds)
  :^  %'POST'  'https://api.sendgrid.com/v3/mail/send'
    :~  ['Content-type' 'application/json']
        ['Authorization' (cat 3 'Bearer ' u.api-key.creds)]
    ==
  :-  ~
  %-  json-to-octs:server
  ^-  json
  %-  pairs:enjs:format
  :~  ['from' (from-to-json from.email)]
      ['subject' s+subject.email]
      ['content' a+(turn content.email content-to-json)]
    ::
      :-  'personalizations'
      a+(turn personalizations.email personalization-to-json)
  ==
::
++  from-to-json
  |=  from=from-field
  ^-  json
  %-  pairs:enjs:format
  :~  ['email' s+email.from]
      ['name' s+name.from]
  ==
::
++  content-to-json
  |=  con=content-field
  ^-  json
  %-  pairs:enjs:format
  :~  ['type' s+type.con]
      ['value' s+value.con]
  ==
::
++  personalization-to-json
  |=  per=personalization-field
  ^-  json
  %-  pairs:enjs:format
  :~  to+(to-to-json to.per)
      headers+(headers-to-json headers.per)
      substitutions+(subs-to-json substitutions.per)
  ==
::
++  to-to-json
  |=  to=(list cord)
  ^-  json
  :-  %a
  %+  turn  to
  |=  recipient=@t
  ^-  json
  (frond:enjs:format %email s+recipient)
::
++  headers-to-json
  |=  headers=(map cord cord)
  ^-  json
  :-  %o
  %-  ~(gas by *(map @t json))
  %+  turn  ~(tap by headers)
  |=  [a=@t b=@t]
  [a s+b]
::
++  subs-to-json
  |=  subs=(list [@t @t])
  ^-  json
  :-  %o
  %-  ~(gas by *(map @t json))
  %+  turn  subs
  |=  [a=@t b=@t]
  [a %s b]
::
++  subscribe-landing
  |=  name=term
  ^-  manx
  ;div: Subscribed to {(trip (get-title name))}, check your email for confirmation
::
++  unsubscribe-landing
  |=  name=term
  ^-  manx
  ;div: Unsubscribed from {(trip (get-title name))}
::
++  confirm-landing
  |=  name=term
  ^-  manx
  ;div: Confirmed subscription to {(trip (get-title name))}
::
++  confirm-body
  |=  [title=@t token=@uv =binding:eyre]
  ^-  (list content-field)
  =/  link=@t
    %:  rap  3
        (need site.binding)
        (spat path.binding)
        '/confirm?token='
        (encode-token token)
        ~
    ==
  :_  ~
  :-  'text/html'
  =<  q
  %-  as-octt:mimes:html
  %-  en-xml:html
  ^-  manx
  ;div
    ;p: Please confirm your subscription to {(trip title)}, if you did not subscribe you can ignore this email.
    ;a(href (trip link)): Confirm Subscription
  ==
::
++  confirm-email
  |=  [email-address=@t name=term token=@uv]
  ^-  card
  =/  title  (get-title name)
  ?~  email.creds  !!
  =/  =binding:eyre
    %-  need
    (scry %switchboard (unit binding:eyre) /site-by-plugin/mailer/[name]/noun)
  =/  =email
    :*  [u.email.creds (scot %p our.bowl)]
        (cat 3 'Confirm your subscription to ' title)
        (confirm-body title token binding)
        [[email-address]~ ~ ~]~
    ==
  =-  [%pass /send-email/(scot %uv eny.bowl) %arvo %i %request -]
  [(send-email email) *outbound-config:iris]
::
++  get-title
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
  .^  mold  %gx
      (scot %p our.bowl)
      term
      (scot %da now.bowl)
      path
  ==
--
