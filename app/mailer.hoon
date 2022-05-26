:: mailer [tirrel]
::
::
/-  *mailer, pipe, meta=metadata-store
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
+$  state-2
  $:  %2
      $=  creds
      $:  api-key=(unit @t)
          email=(unit @t)
          ship-url=(unit @t)
      ==
      ml=(map term mailing-list)
      campaign-templates=(map term campaign-template)
      campaigns=(map term campaign)
  ==
+$  versioned-state
  $%  state-0
      state-1
      state-2
  ==
--
::
=|  state-2
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
  :: pass to eyre: bind /mailer HTTP endpoint
  :: https://urbit.org/docs/arvo/eyre/tasks#connect
  :: https://urbit.org/docs/arvo/eyre/guide#agents-direct-http
  [%pass /connect %arvo %e %connect [~ /'mailer'] dap.bowl]~
::
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  |^
  ?:  %.y  [~ this(state *state-2)] :: reset state on every load
  =+  !<(old=versioned-state old-vase)
  =|  cards=(list card)
  |-
  ?-  -.old
    %2  [cards this(state old)]
    %1  $(old *state-2)
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
  :: handle pokes from other gall agents
      %mailer-action
    =^  cards  state
      (mailer-action !<(action vase))
    [cards this]
  :: handle HTTP requests to /mailer eyre endpoint ?
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =^  cards  state
      (handle-http-request eyre-id inbound-request)
    [cards this]
      %noun
    ?:  ?=([%stop term] q.vase)
      =/  campaign-name=term  +.q.vase
      =/  =campaign  (~(got by campaigns) campaign-name)
      :_  this(campaigns (~(del by campaigns) campaign-name))
      [%pass /timer/[campaign-name] %arvo %b %rest next-time.campaign]^~
    ?:  ?=(%stop q.vase)
      ~|("must provide name of campaign" !!)
    [~ this]
  ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta inbound-request:eyre]
    ^-  (quip card _state)
    |^
    =/  req-line=request-line:server
      %-  parse-request-line:server
      url.request
    ?+  site.req-line
      :_  state
      (give-simple-payload:app:server eyre-id not-found:gen:server)
    ::
        [%mailer %unsubscribe ~]
      =/  args=(map @t @t)  (~(gas by *(map @t @t)) args.req-line)
      =/  b64tok=(unit @t)  (~(get by args) 'token')
      ?~  b64tok
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  details=(unit [=term email=@t token=@uv confirmed=?])
        (get-user-by-token:do u.b64tok)
      ?~  details
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  old-ml  (~(got by ml) term.u.details)
      =/  new-ml  (~(del by old-ml) email.u.details)
      :_  state(ml (~(put by ml) term.u.details new-ml))
      %+  give-simple-payload:app:server  eyre-id
      (manx-response:gen:server (unsubscribe-landing:do term.u.details))
    ::
        [%mailer %subscribe ~]
      ?.  ?=(%'POST' method.request)
        :_  state
        :: what does `give-simple-payload` actually do?
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  headers=(map @t @t)  (~(gas by *(map @t @t)) header-list.request)
      =/  type=(unit @t)       (~(get by headers) 'content-type')
      ?:  ?|(?=(~ body.request) ?=(~ type))
        :_  state :: no-op?
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  parsed-form  (rush q.u.body.request yquy:de-purl:html)
      ?~  parsed-form
        :_  state :: no-op?
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  args=(map @t @t)   (~(gas by *(map @t @t)) u.parsed-form)
      =/  who=(unit @t)      (~(get by args) 'who') :: email? token?
      =/  book=(unit @t)     (~(get by args) 'book') :: blog name?
      ?:  ?|(?=(~ who) ?=(~ book))
        :_  state :: no-op?
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  old-ml=(unit mailing-list)  (~(get by ml) u.book)
      ?~  old-ml
        :_  state :: no-op?
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      ?:  (~(has by u.old-ml) u.who)
        :_  state :: no-op?
        %+  give-simple-payload:app:server  eyre-id
        (manx-response:gen:server (subscribe-landing:do u.book))
      =/  token=@uv  (sham u.who eny.bowl) :: todo: what does `sham` do?
      =/  new-ml  (~(put by u.old-ml) u.who token %.n)
      :_  state(ml (~(put by ml) u.book new-ml))
      :*  (confirm-email:do u.who u.book token) :: send confirmation email
          %+  give-simple-payload:app:server  eyre-id
          (manx-response:gen:server (subscribe-landing:do u.book))
      ==
    :: handle email confirmation
        [%mailer %confirm ~]
      =/  args=(map @t @t)  (~(gas by *(map @t @t)) args.req-line)
      =/  b64tok=(unit @t)  (~(get by args) 'token')
      ?~  b64tok
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  details=(unit [=term email=@t token=@uv confirmed=?])
        (get-user-by-token:do u.b64tok)
      ?~  details
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  new-token  (sham email.u.details eny.bowl)
      =/  old-ml     (~(got by ml) term.u.details)
      =/  new-ml     (~(put by old-ml) email.u.details new-token %.y)
      :_  state(ml (~(put by ml) term.u.details new-ml))
      %+  give-simple-payload:app:server  eyre-id
      (manx-response:gen:server (confirm-landing:do term.u.details))
    :: upload mailing list CSV
        [%mailer %upload ~]
      ?.  ?=(%'POST' method.request)
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      ?~  parts=(de-request:multipart [header-list body]:request)
        ~|("failed to parse submitted data" !!)
      =/  parts-map  (~(gas by *(map @t part:multipart)) u.parts)
      =/  name  (~(get by parts-map) 'name')
      ?~  name
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      =/  csv  (~(get by parts-map) 'csv')
      ?~  csv
        :_  state
        (give-simple-payload:app:server eyre-id not-found:gen:server)
      ::
      =/  addresses=(set @t)  (parse-csv:do body.u.csv)
      ::
      =/  old=(unit mailing-list)  (~(get by ml) body.u.name)
      ?~  old  ~|("no such mailing list: {<u.name>}" !!)
      =/  recipients=mailing-list
        %-  ~(run in addresses)
        |=  email=@t
        [email (sham email eny.bowl) %.y]
      =/  new=mailing-list  (~(uni by u.old) recipients)
      =.  ml  (~(put by ml) body.u.name new)
      :_  state
      (give-simple-payload:app:server eyre-id not-found:gen:server)
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
      :: %i - iris (HTTP Client) https://urbit.org/docs/arvo/iris/iris
      :: Presumably /send-email calls ++send-email
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
      =/  recipients=mailing-list
        %-  ~(run in mailing-list.act)
        |=  email=@t
        [email (sham email eny.bowl) %.y]
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
    ::
        %create-campaign-template
      ?:  (~(has by campaign-templates) name.act)
        ~&  >>  'campaign template already exists!'  [~ state]
      ~&  >  'creating new campaign template'
      =|  template=campaign-template
      =.  template  template(from from.act, email-sequence email-sequence.act)
      :-  [give-update:do]~
      state(campaign-templates (~(put by campaign-templates) name.act template))
        %start-campaign
      ?:  (~(has by campaigns) name.act)
        ~&  >>  'campaign already started!'  [~ state]
      =/  template=(unit campaign-template)  (~(get by campaign-templates) template-name.act)
      ?~  template
        ~&  >>>  'campaign-template does not exist'  [~ state]
      ?:  ?&  ?=(%.n -.recipients.act)
              !(~(has by ml) p.recipients.act)
          ==
        ~&  >>>  'mailing list does not exist!'  [~ state]
      =|  =campaign
      =.  campaign
      %=  campaign
        next-time  now.bowl
        recipients  recipients.act
        template-name  template-name.act
        interval  interval.act
      ==
      :-  :~  [give-update:do]
              [%pass /timer/[name.act] %arvo %b %wait now.bowl]
          ==
      state(campaigns (~(put by campaigns) name.act campaign))
    ==
  --
:: on response from vane
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  |^
  ?:  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo :: if unable to bind path w/ eyre
      [dap.bowl "bind rejected!" binding.sign-arvo]
    [~ this]
  ?:  ?=(%http-response +<.sign-arvo)
    =^  cards  state               :: if http response ... ?
      (http-response wire client-response.sign-arvo)
    [cards this]
  ?:  ?=([%behn %wake *] sign-arvo)
    ~&  "timer fired!"
    ?>  ?=([%timer @ ~] wire)
    =*  name  i.t.wire
    =/  campaign  (~(get by campaigns) name)
    ?~  campaign  ~&  >>>  "campaign {<name>} does not exist!"  [~ this]
    =/  template  (~(got by campaign-templates) template-name.u.campaign)
    ?:  (gte index.u.campaign (lent email-sequence.template))
      ~&  "campaign {<name>}: finished!"  [~ this]
    ~&  "campaign {<name>}: {<+(index.u.campaign)>} of {<(lent email-sequence.template)>}!"
    =^  cards  state
      (email-campaign:do u.campaign)
    =.  next-time.u.campaign  (add now.bowl interval.u.campaign)
    =.  index.u.campaign  +(index.u.campaign)
    :_  this(campaigns (~(put by campaigns) name u.campaign))
    :-  [%pass wire %arvo %b %wait next-time.u.campaign]
    cards
  (on-arvo:def wire sign-arvo) :: no-op
  ::
  ++  http-response
    |=  [=^wire res=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.res)  `state
    :: only recognized wire (request type) is %send-email
    ?+    wire  ~|('unknown request type coming from mailer' !!)
        [%send-email @ ~]
      ?~  full-file.res
        `state
      [~ state]
    ==
  --
:: what is subscribing to mailer?
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  ?:  ?=([%updates ~] path)
    =/  =update  [%initial creds ml campaign-templates campaigns]
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
  ==
:: handle ack's from other agents
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    ?>  ?=([%pipe @ ~] wire) :: crash if kicked from agent other than %pipe
    =*  name  i.t.wire
    :_  this
    :: attempt to subscribe again if kicked by %pipe?
    [%pass /pipe/[name] %agent [our.bowl %pipe] %watch /email/[name]]~
  ::
      %fact
    ?>  ?=([%pipe @ ~] wire)
    ?>  ?=(%pipe-update p.cage.sign)
    ?~  api-key.creds
      `this
    ?~  email.creds
      `this
    ?~  ship-url.creds
      `this
    :: =* -> alias (evaluate every time)
    :: =/ -> pin (evaluate once)
    :: why alias instead of pin here?
    =*  name  i.t.wire
    =+  !<(=update:pipe q.cage.sign)
    ?.  ?=(%email -.update)
      `this
    =/  content=(list [@t @t])
      =*  a  body.email.update
      [[(rsh [3 1] (spat p.a)) q.q.a] ~] :: converts (path) /text/html -> (cord) text/html
    =/  =mailing-list  (~(got by ml) name)
    =/  person=(list personalization-field)
      %+  murn  ~(tap by mailing-list)
      |=  [address=@t token=@uv confirmed=?]
      ?.  confirmed  ~
      =/  callback=@t
        %:  rap  3
            u.ship-url.creds
            '/mailer/unsubscribe?token='
            (encode-token token)
            ~
        ==
      :-  ~
      :*  [address]~
          ~
          [['%unsubscribe-callback%' callback] ~]
      ==
    :: build email from components
    =/  =email
      :*  [u.email.creds (scot %p our.bowl)]
          subject.email.update
          content
          person
      ==
    :_  this
    :: iris: make HTTP request to /send-email ?
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
  =/  =update  [%initial creds ml campaign-templates campaigns]
  [%give %fact [/updates]~ %mailer-update !>(update)]
::
++  email-campaign
  |=  =campaign
  ^-  (quip card _state)
  =/  template  (~(got by campaign-templates) template-name.campaign)
  =/  email-sequence  email-sequence.template
  =/  [subject=cord html=cord]  (snag index.campaign email-sequence)
  =/  content-field  ['text/html' html]
  =/  personalizations=(list personalization-field)
    ?:  ?=(%.y -.recipients.campaign)
      [[p.recipients.campaign ~] ~ ~]^~
    =/  mailing-list  (~(got by ml) p.recipients.campaign)
    %+  turn  ~(tap by mailing-list)
    |=  [address=@t *]
    [[address ~] ~ ~]
  =/  =email
    :*  from.template
        subject
        content-field^~
        personalizations
    ==
  :_  state
  =+  [(send-email email) *outbound-config:iris]
  [%pass /send-email/(scot %uv eny.bowl) %arvo %i %request -]^~
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
  |=  [title=@t token=@uv]
  ^-  (list content-field)
  ?~  ship-url.creds  !!
  =/  link=@t
    %:  rap  3
        u.ship-url.creds
        '/mailer/confirm?token='
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
  |=  [addr=@t name=term token=@uv]
  ^-  card
  =/  title  (get-title name)
  ?~  email.creds  !!
  =/  =email
    :*  [u.email.creds (scot %p our.bowl)]
        :: why all these (cat 3 x y) ?
        (cat 3 'Confirm your subscription to ' title)
        (confirm-body title token)
        [[addr]~ ~ ~]~
    ==
  =-  [%pass /send-email/(scot %uv eny.bowl) %arvo %i %request -]
  [(send-email email) *outbound-config:iris]
:: gets title of notebook from graph-store
++  get-title
  |=  name=term
  ^-  @t
  =/  assoc=association:meta
    %-  need
    %^  scry  %metadata-store
      (unit association:meta)
    /metadata/graph/ship/(scot %p our.bowl)/[name]/noun
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
