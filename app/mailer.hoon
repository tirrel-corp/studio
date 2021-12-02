:: mailer [tirrel]
::
::
/-  *mailer, pipe
/+  default-agent, dbug, verb, server, mailer, multipart
|%
+$  card  card:agent:gall
+$  state-0
  $:  %0
      $=  creds
      $:  api-key=(unit @t)
          email=(unit @t)
          ship-url=(unit @t)
      ==
      ml=(map term mailing-list)
  ==
+$  versioned-state
  $%  state-0
  ==
--
::
=|  state-0
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
  :_  this
  [%pass /connect %arvo %e %connect [~ /'mailer'] dap.bowl]~
::
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
::  `this(state *state-0)
  =+  !<(old=versioned-state old-vase)
  ?-  -.old
    %0  `this(state [%0 +.old])
  ==
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
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =^  sim  state
      (handle-http-request eyre-id inbound-request)
    :_  this
    (give-simple-payload:app:server eyre-id sim)
  ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta inbound-request:eyre]
    ^-  [simple-payload:http _state]
    |^
    =/  req-line=request-line:server
      %-  parse-request-line:server
      url.request
    ?+  site.req-line
      :_  state
      not-found:gen:server
    ::
        [%mailer %unsubscribe @ ~]
      ?~  ext.req-line
        :_  state
        not-found:gen:server
      =/  del-token=@uv
        (slav %uv (rap 3 i.t.t.site.req-line '.' u.ext.req-line ~))
      =.  ml
        %-  ~(rep by ml)
        |=  [[=term =mailing-list] bs=_ml]
        =.  mailing-list
          %-  ~(rep by mailing-list)
          |=  [[addr=@t token=@uv] ml2=_mailing-list]
          ^-  ^mailing-list
          ?.  =(token del-token)
            ml2
          (~(del by ml2) addr)
        (~(put by bs) term mailing-list)
      =/  res=manx
        ;div: Unsubscribed successfully
      :_  state
      (manx-response:gen:server res)
    ::
        [%mailer %upload ~]
      ?.  ?=(%'POST' method.request)
        :_  state
        not-found:gen:server
      ?~  parts=(de-request:multipart [header-list body]:request)
        ~|("failed to parse submitted data" !!)
      =/  parts-map  (~(gas by *(map @t part:multipart)) u.parts)
      =/  name  (~(get by parts-map) 'name')
      ?~  name
        :_  state
        not-found:gen:server
      =/  csv  (~(get by parts-map) 'csv')
      ?~  csv
        :_  state
        not-found:gen:server
      ::
      =/  addresses=(set @t)  (parse-csv:do body.u.csv)
      ::
      =/  old=(unit mailing-list)  (~(get by ml) body.u.name)
      ?~  old  ~|("no such mailing list: {<u.name>}" !!)
      =/  recipients=mailing-list
        %-  ~(run in addresses)
        |=  email=@t
        [email (sham email eny.bowl)]
      =/  new=mailing-list  (~(uni by u.old) recipients)
      =.  ml  (~(put by ml) body.u.name new)
      :_  state
      not-found:gen:server
      ::[give-update:do]~
    ==
    ::
    ++  fip
      =,  de-purl:html
      %+  cook
        |=(pork (weld q (drop p)))
      (cook deft (more fas smeg))
    --
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
        [email (sham email eny.bowl)]
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
      =/  recipients=mailing-list
        %-  ~(run in mailing-list.act)
        |=  email=@t
        [email (sham email eny.bowl)]
      =/  new=mailing-list  (~(uni by u.old) recipients)
      =.  ml  (~(put by ml) name.act new)
      :_  state
      [give-update:do]~
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
    :_  this
    [%give %fact ~ %mailer-update !>([%initial creds ml])]~
  (on-watch:def path)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
      [%x %export ~]
    ``noun+!>(state)
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
      ~|("No Sendgrid credentials set up" !!)
    ?~  email.creds
      ~|("No Sendgrid credentials set up" !!)
    ?~  ship-url.creds
      ~|("No domain name set up" !!)
    =*  name  i.t.wire
    =+  !<(=update:pipe q.cage.sign)
    ?.  ?=(%email -.update)
      `this
    =/  content=(list [@t @t])
      =*  a  body.email.update
      [[(rsh [3 1] (spat p.a)) q.q.a] ~]
    =/  =mailing-list  (~(got by ml) name)
    =/  person=(list personalization-field)
      %+  turn  ~(tap by mailing-list)
      |=  [address=@t token=@uv]
      =/  callback=@t
        %:  rap  3
            u.ship-url.creds
            '/mailer/unsubscribe/'
            (scot %uv token)
            ~
        ==
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
--
