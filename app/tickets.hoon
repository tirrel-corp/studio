/-  circle, mailer, auth
/+  default-agent, dbug, verb, server, circle, uuidv4
|%
+$  card  $+(card card:agent:gall)
::
+$  ticket
  $:  token=@uv
      used=?
      product-id=@t
  ==
::
+$  state-0
  $+  state-0
  $:  sold=(map @uv ticket)
      stock=(map product-id=@t [count=@ud =amount:circle])
      pending=(map session-id=@t [product-id=@t count=@ud started=?])
      pending-stock=(map product-id=@t count=@ud)
  ==
::
++  provider  ~zod  :: hardcode tirrel gateway moon
::
+$  action
  $%  [%set-stock type=@t count=@ud =amount:circle]
      [%del-stock type=@t]
      [%add-verifier email=@t]
  ==
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  gateway-wire=wire  /master/(scot %p our.bowl)
  =/  verifier-auth=update:auth  [%add-service %ticket-verifier ~ ~]
  =/  buyer-auth=update:auth     [%add-service %ticket-buyer ~ ~]
  ::
  :_  this
  :~  [%pass /eyre %arvo %e %connect [~ /merchant] dap.bowl]
      [%pass gateway-wire %agent [provider %gateway] %watch gateway-wire]
      [%pass / %agent [our.bowl %auth] %poke %auth-update !>(verifier-auth)]
      [%pass / %agent [our.bowl %auth] %poke %auth-update !>(buyer-auth)]
  ==
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  :-  ~
  this(state !<(state-0 old-vase))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  (on-poke:def mark vase)
  ::
      %noun
    =+  !<(act=action vase)
    ?-  -.act
        %set-stock
      :-  ~
      %=  this
        stock  (~(put by stock) +.act)
        pending-stock  (~(put by pending-stock) type.act 0)
      ==
    ::
        %del-stock
      :-  ~
      %=  this
        stock  (~(del by stock) +.act)
        pending-stock  (~(del by pending-stock) +.act)
      ==
    ::
      %add-verifier  !!
    ==
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =|  sim=simple-payload:http
    =^  res=(pair (list card) _this)  sim
      (handle-http-request eyre-id inbound-request)
    :_  q.res
    %+  weld  p.res
    (give-simple-payload:app:server eyre-id sim)
  ==
  ::
  ++  enjs-stock
    |=  stock=(map @t [@ud amount:circle])
    ^-  json
    %-  pairs:enjs:format
    %+  turn  ~(tap by stock)
    |=  [type=@t count=@ud =amount:circle]
    ^-  [@t json]
    :-  type
    %-  pairs:enjs:format
    :~  count+(numb:enjs:format count)
        price+(amount:enjs:req:circle amount)
    ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta req=inbound-request:eyre]
    ^-  [(quip card _this) simple-payload:http]
    =/  req-line  (parse-request-line:server url.request.req)
    ?+    site.req-line  [`this not-found:gen:server]
        [%merchant %session ~]
      ?>  ?=(%'POST' method.request.req)
      =/  sess-id  (to-uuid:uuidv4 eny.bowl)
      ?~  body.request.req
        [`this [[400 ~] ~]]
      =/  jon  (de-json:html `@t`q.u.body.request.req)
      ?~  jon
        [`this [[400 ~] ~]]
      =/  params=[product-id=@t quantity=@ud]
        %.  u.jon
        %-  ot:dejs:format
        :~  product-id+so:dejs:format
            quantity+ni:dejs:format
        ==
      ?~  prod=(~(get by stock) product-id.params)
        [`this [[404 ~] ~]]
      ?.  (gte count.u.prod quantity.params)
        [`this [[500 ~] ~]]
      ::
      :: put sold product in pending field, so that it can't be sold
      =/  total=amount:circle
        [(mul quantity.params integer.amount.u.prod) 0 %'USD']
      =/  sess-id  (to-uuid:uuidv4 eny.bowl)
      =/  act
        [%add-session our.bowl sess-id total]
      :_  [[200 ~] `(json-to-octs:server s+sess-id)]
      =.  pending
        (~(put by pending) sess-id [product-id.params quantity.params %.n])
      :_  this
      [%pass / %agent [provider %gateway] %poke %noun !>(act)]^~
    ::
        [%merchant %remaining ~]
      [`this (json-response:gen:server (enjs-stock stock))]
    ::
        [%merchant %redeem ~]
      :: XX replace these  not-founds with a page that directs back to main page
      ?~  b64tok=(get-header:http 'token' args.req-line)
        [`this not-found:gen:server]
      ?~  token=(~(de base64:mimes:html | &) u.b64tok)
        [`this not-found:gen:server]
      ?~  ticket=(~(get by sold) q.u.token)
        [`this not-found:gen:server]
      ?:  used.u.ticket
        [`this not-found:gen:server]
      =/  success=manx
        ;div: ticket valid!
      =.  used.u.ticket  %.y
      =.  sold  (~(put by sold) q.u.token u.ticket)
      [`this (manx-response:gen:server success)]
    ::
        [%merchant %delivery ~]
      !!
    ::
        [%merchant %verify ~]
      !!
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  (on-watch:def path)
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?.  ?=([%master @ ~] wire)
    (on-agent:def wire sign)
  ?+    -.sign  (on-agent:def wire sign)
      %fact
    =+  !<(upd=update:circle q.cage.sign)
    ?+  -.upd  `this
        %payment
      =/  pend  (~(got by pending) p.upd)
      =*  id  product-id.pend
      :: remove count in pending-stock
      =/  pend-sto  (~(got by pending-stock) id)
      =.  pending-stock
        %+  ~(put by pending-stock)  id
        (sub count.pend-sto count.pend)
      :: delete pending transaction
      =.  pending  (~(del by pending) p.upd)
      ::
      ?:  ?=(?(%confirmed %paid) status.q.upd)
        :: remove count in stocks
        =/  sto    (~(got by stock) id)
        =.  stock  (~(put by stock) id sto(count (sub count.sto count.pend)))
        :: put in sold
        =/  c  count.pend
        =.  sold
          |-
          ?:  =(c 0)
            sold
          =/  tic  (gen-ticket id c)
          $(sold (~(put by sold) token.tic tic), c (dec c))
        `this
      ::
      ?:  ?=(%failed status.q.upd)
        `this
      !!
    ::
        %card
      ?:  ?=(%complete status.q.upd)
        =/  pend-trans  (~(got by pending) p.upd)
        =/  pend-stock  (~(got by pending-stock) product-id.pend-trans)
        =:  pending
          (~(put by pending) p.upd pend-trans(started %.y))
            pending-stock
          %+  ~(put by pending-stock)  product-id.pend-trans
          (add count.pend-stock count.pend-trans)
        ==
        `this
      ?:  ?=(%failed status.q.upd)
        =.  pending  (~(del by pending) p.upd)
        `this
      !!
    ==
  ::
      %kick
    :_  this
    =-  [%pass - %agent [provider %gateway] %watch -]^~
    /master/(scot %p our.bowl)
  ==
  ::
  ++  gen-ticket
    |=  [product-id=@t salt=@]
    ^-  ticket
    :*  (shas salt eny.bowl)
        %.n
        product-id
    ==
  ::
::  ++  finalize-sale
::    |=  =ticket
::    ^-  (quip card _state)
::    =.  sold  (~(put by sold) token.ticket ticket)
::    =/  ticket-stock  (~(got by stock) type.ticket)
::    =.  count.ticket-stock  (dec count.ticket-stock)
::    =.  stock  (~(put by stock) type.ticket ticket-stock)
::    ::
::::    =/  =action:mailer
::::      :-  %send-email
::    :_  state
::    ~
::    :~  [%pass / %agent [our.bowl %mailer] %poke %mailer-action !>(action)]
::    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl "bind rejected!" binding.sign-arvo]
    [~ this]
  (on-arvo:def wire sign-arvo)
::
++  on-peek  on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
