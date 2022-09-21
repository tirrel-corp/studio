/-  circle, mailer, auth
/+  default-agent, dbug, verb, server, circle, uuidv4, pipe-render
|%
+$  card  $+(card card:agent:gall)
::
+$  ticket
  $:  token=@uv
      used=?
      product-id=(list @t)
      price=amount:circle
  ==
::
+$  purchase
  $:  tickets=(set ticket)
      total=amount:circle
      =metadata:circle
      purchase-date=@da
  ==
::
+$  pending-data
  $:  product-id=(list @t)
      count=@ud
      started=?
      metadata=(unit metadata:circle)
  ==
::
+$  state-0
  $+  state-0
  $:  sold=(map session-id=@t purchase)
      stock=(map product-id=@t [count=@ud =amount:circle])
      pending=(map session-id=@t pending-data)
      pending-stock=(map product-id=@t count=@ud)
      token-to-session=(map @uv session-id=@t)
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
  :~  [%pass /eyre %arvo %e %connect [~ /shop] dap.bowl]
      [%pass gateway-wire %agent [provider %gateway] %watch gateway-wire]
  ==
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
::  `this
  =/  gateway-wire=wire  /master/(scot %p our.bowl)
  :_  this(state !<(state-0 old-vase))
  ~
::  :~  [%pass /eyre %arvo %e %connect [~ /shop] dap.bowl]
::      [%pass gateway-wire %agent [provider %gateway] %watch gateway-wire]
::  ==
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
        [%shop %ticket @ ~]
      ?>  ?=(%'GET' method.request.req)
      =*  sess-id  i.t.t.site.req-line
      :-  `this
      ?~  pen=(~(get by pending) sess-id)
        [[404 ~] ~]
      :-  [200 ~]
      =-  `(json-to-octs:server -)
      :-  %a
      %+  murn  product-id.u.pen
      |=  i=@t
      ?~  sto=(~(get by stock) i)
        ~
      :-  ~
      %-  pairs:enjs:format
      :~  product+s+i
          count+(numb:enjs:format count.u.pen)
          amount+(amount:enjs:req:circle amount.u.sto)
      ==
    ::
        [%shop %session ~]
      ?>  ?=(%'POST' method.request.req)
      =/  sess-id  (to-uuid:uuidv4 eny.bowl)
      ?~  body.request.req
        [`this [[400 ~] ~]]
      =/  jon  (de-json:html `@t`q.u.body.request.req)
      ?~  jon
        [`this [[400 ~] ~]]
      =/  params=(list [product-id=@t quantity=@ud])
        %.  u.jon
        %-  ar:dejs:format
        %-  ot:dejs:format
        :~  product-id+so:dejs:format
            quantity+ni:dejs:format
        ==
      =/  sess-id  (to-uuid:uuidv4 eny.bowl)

      =^  total  pending
        %+  roll  params
        |=  [[id=@t q=@ud] total=amount:circle p=_pending]
        ?~  prod=(~(get by stock) id)
          [total p]
        ?.  (gte count.u.prod q)
          [total p]
        :-  [(add (mul q integer.amount.u.prod) integer.total) 0 %'USD']
        (~(put by pending) sess-id [id^~ q %.n ~])
      ::
      =/  act
        [%add-session our.bowl sess-id total]
      :_  [[200 ~] `(json-to-octs:server s+sess-id)]
      :_  this
      [%pass / %agent [provider %gateway] %poke %noun !>(act)]^~
    ::
        [%shop %remaining ~]
      [`this (json-response:gen:server (enjs-stock stock))]
    ::
    ::  list of tickets by session-id
::        [%shop %group @ ~]
::      =*  session-id  i.t.t.site.req-line
::      =/  pur=(unit purchase)  (~(get by sold) session-id)
::      ?~  pur
::        [`this not-found:gen:server]
::      =/  res=(list json)
::        %-  ~(rep in tickets.u.pur)
::        |=  [tic=ticket out=(list json)]
::        =/  b64=@t
::          (~(en base64:mimes:html | &) [(met 3 token.tic) token.tic])
::        :_  out
::        %-  pairs:enjs:format
::        :~  token+s+b64
::            used+b+used.tic
::            %'productId'^s+product-id.tic
::        ==
::      [`this (json-response:gen:server [%a res])]
    ::
    ::  single ticket
        [%shop %individual @ ~]
      =*  session-id  i.t.t.site.req-line
      =/  pur=(unit purchase)  (~(get by sold) session-id)
      ?~  pur
        ~&   %no-purchase
        [`this not-found:gen:server]
      =/  tic=(unit ticket)
        %-  ~(rep in tickets.u.pur)
        |=  [=ticket out=(unit ticket)]
        `ticket
      ?~  tic
        ~&  %no-ticket
        [`this not-found:gen:server]
      =/  res=json
        %-  pairs:enjs:format
        :~  [%total (numb:enjs:format integer.total.u.pur)]
        ::
          :-  %items
          :-  %a
          %+  turn  product-id.u.tic
          |=  a=@t
          =/  st  (~(got by stock) a)
          %-  pairs:enjs:format
          :~  %'productId'^s+a
              price+(numb:enjs:format integer.amount.st)
          ==
        ==
      [`this (json-response:gen:server res)]
    ::
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
    ~&  fact+-.upd
    ?+  -.upd  `this
        %payment
      ~&  %payment-fact
      ?~  pend=(~(get by pending) p.upd)
        `this
      =*  id  product-id.u.pend
      :: remove count in pending-stock
      =.  pending-stock
        %+  roll  id
        |=  [i=@ ps=_pending-stock]
        =/  p  (~(got by pending-stock) i)
        (~(put by ps) i (sub count.p count.u.pend))
::      =/  pend-sto  (~(got by pending-stock) id)
::      =.  pending-stock
::        %+  ~(put by pending-stock)  id
::        (sub count.pend-sto count.u.pend)
      :: delete pending transaction
      =.  pending  (~(del by pending) p.upd)
      ::
      ?:  ?=(?(%confirmed %paid) status.q.upd)
        ~&  %payment-confirmed
        :: remove count in stocks
        =.  stock
          %+  roll  id
          |=  [i=@ s=_stock]
          =/  sto  (~(got by stock) i)
          (~(put by s) i sto(count (sub count.sto count.u.pend)))
::        =/  sto    (~(got by stock) id)
::        =.  stock  (~(put by stock) id sto(count (sub count.sto count.u.pend)))
        :: put in sold
        =^  cards  state
          %:  finalize-sale
            p.upd
            id
            (need metadata.u.pend)
            count.u.pend
            amount.q.upd
          ==
        [cards this]
      ::
      ?:  ?=(%failed status.q.upd)
        `this
      !!
    ::
        %card
      ?:  ?=(%complete status.q.upd)
        ?~  pend=(~(get by pending) p.upd)
          `this
        =/  [p=_pending ps=_pending-stock]
          %+  roll  product-id.u.pend
          |=  [i=@ p=_pending ps=_pending-stock]
          =/  ex  (~(got by ps) i)
          :-  (~(put by p) p.upd u.pend(started %.y, metadata r.upd))
          (~(put by ps) i (add count.ex count.u.pend))
        =.  pending  p
        =.  pending-stock  ps
::        =/  pend-stock  (~(got by pending-stock) product-id.u.pend)
::        =:  pending
::          (~(put by pending) p.upd u.pend(started %.y, metadata r.upd))
::            pending-stock
::          %+  ~(put by pending-stock)  product-id.u.pend
::          (add count.pend-stock count.u.pend)
::        ==
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
    |=  [session-id=@t product-id=(list @t) =metadata:circle salt=@]
    ^-  ticket
    =/  amt=amount:circle
      %+  roll  product-id
      |=  [i=@ a=amount:circle]
      =/  p  (~(got by stock) i)
      :+  (add integer.a integer.amount.p)  0
      %'USD'
    :*  (shas salt eny.bowl)
        %.n
        product-id
        amt
    ==
  ::
  ++  finalize-sale
    |=  [session-id=@t product-id=(list @t) =metadata:circle num=@ud =amount:circle]
    ^-  (quip card _state)
    =|  sold-tickets=(set ticket)
    ~&  %finalize-sale
    |-
    ?:  =(num 0)
      =/  =purchase
        :*  sold-tickets
            amount
            metadata
            now.bowl
        ==
      =.  sold  (~(put by sold) session-id purchase)
      :_  state
      (send-email session-id purchase)^~
    =/  =ticket  (gen-ticket session-id product-id metadata num)
    %=  $
      num               (dec num)
      token-to-session  (~(put by token-to-session) token.ticket session-id)
      sold-tickets      (~(put in sold-tickets) ticket)
    ==
  ::
  ++  amount-to-tape
    |=  =amount:circle
    ^-  tape
    =/  decimal=@t
      =/  a  (rsh [3 2] (scot %ui decimal.amount))
      ?:  (lth decimal.amount 10)
        (cat 3 '0' a)
      a
    %-  trip
    %+  rap  3
    :~  '$'
        (rsh [3 2] (scot %ui integer.amount))
        '.'
        decimal
    ==
  ::
  ++  ticket-rows
    |=  tickets=(set ticket)
    ^-  marl
    =/  sorted-tickets=(list ticket)
      %+  sort  ~(tap by tickets)
      |=  [a=ticket b=ticket]
      (gte integer.price.a integer.price.b)
    %+  turn  sorted-tickets
    |=  tic=ticket
    ^-  manx
    ;tr
      ;td(style "width: 50%", align "left")
        ;b: {(trip (snag 0 product-id.tic))}  :: XX
      ==
      ;td(style "width: 50%", align "right"): {(amount-to-tape price.tic)}
    ==
  ::
  ++  gen-link
    |=  session-id=@t
    ^-  tape
    =/  host=@t  'http://demo.urbit.studio:3000'
    %-  trip
    (rap 3 host '/confirmation/' session-id ~)
  ::
  ++  make-email
    |=  [session-id=@t =purchase]
    ^-  manx
    =/  link  (gen-link session-id)
    ;div
      ;img(src "https://tirrel.io/assets/miami-header-big.png", width "800px");
      ;p: Hello!
      ;p: Thank you for your purchase. Your tickets can be accessed here:
      ;a(href link): {link}
      ;p
      ; We look forward to meeting you in Miami Beach! In the meantime you can join
        ;b: ~rondev/assembly-miami 
      ; to chat with other attendees.
      ==
      ;p: See you on the network!
      ;p: - The Urbit Foundation
      ;hr(style "margin:20px 0", color "grey", size "1", width "40%");
      ;b: Receipt:
      ;p: Transaction: {(trip session-id)}
      ;p: {(trip (print-date:pipe-render purchase-date.purchase))}
      ;p: Delivery to: {(trip email.metadata.purchase)}
      ;table(width "40%", style "margin-top: 30px")
        ;*  (ticket-rows tickets.purchase)
      ==
      ;hr(style "margin:20px 0", color "grey", size "1", width "40%");
      ;table(width "40%")
        ;tr
          ;td(style "width: 50%", align "left"): Subtotal
          ;td(style "width: 50%", align "right")
          ; {(amount-to-tape total.purchase)}
          ==
        ==
        ;tr
          ;td(style "width: 50%", align "left")
            ;b: Total Paid
          ==
          ;td(style "width: 50%", align "right")
            ;b: {(amount-to-tape total.purchase)}
          ==
        ==
      ==
      ;p: Customer Support: support@tirrel.io
      ;p: Processed by Tirrel Corporation
    ==
  ::
  ++  send-email
    |=  [session-id=@t =purchase]
    ^-  card
    =/  content=content-field:mailer
      :-  'text/html'
      =<  q
      %-  as-octt:mimes:html
      %-  en-xml:html
      ^-  manx
      (make-email session-id purchase)
    =/  =action:mailer
      :*  %send-email
          ['isaac@tirrel.io' 'Urbit Foundation']
          'Urbit Assembly Miami Tickets'
          [content ~]
          [email.metadata.purchase^~ ~ ~]^~
      ==
    [%pass / %agent [our.bowl %mailer] %poke %mailer-action !>(action)]
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
