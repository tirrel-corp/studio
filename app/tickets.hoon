/-  circle, mailer, auth
/+  default-agent, dbug, verb, server, circle, uuidv4, pipe-render
|%
+$  card  $+(card card:agent:gall)
::
+$  ticket
  $:  token=@uv
      used=?
      product-id=(list [@t @ud])
      price=amount:circle
  ==
::
+$  purchase
  $:  tickets=(set ticket)
      total=amount:circle
      =metadata:circle
      purchase-date=@da
      delivered=?
  ==
::
+$  pending-data
  $:  product-id=(list [@t @ud])
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
::  =/  gateway-wire=wire  /master/(scot %p our.bowl)
  `this(state !<(state-0 old-vase))
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
        [%shop %sold ~]
      ?>  ?=(%'GET' method.request.req)
      :-  `this
      :-  [200 ~]
      =-  `(json-to-octs:server -)
      :-  %a
      %+  turn  ~(tap by sold)
      |=  [ses=@t =purchase]
      ^-  json
      =/  items=ticket  (snag 0 ~(tap in tickets.purchase))
      %-  pairs:enjs:format
      :~  session-id+s+ses
          delivered+b+delivered.purchase
          email+s+email.metadata.purchase
          :+  %products  %a
          %+  murn  product-id.items
          |=  [id=@t q=@ud]
          ^-  (unit json)
          ?:  =(q 0)  ~
          :-  ~
          %-  pairs:enjs:format
          :~  product-id+s+id
              quantity+(numb:enjs:format q)
          ==
      ==
    ::
        [%shop %deliver ~]
      ?>  ?=(%'POST' method.request.req)
      ?~  body.request.req
        [`this [[400 ~] ~]]
      =/  jon  (de-json:html `@t`q.u.body.request.req)
      ?~  jon
        [`this [[400 ~] ~]]
      =/  session-id=@t
        %.  u.jon
        %-  ot:dejs:format
        :~  session-id+so:dejs:format
        ==
      ?~  purchase=(~(get by sold) session-id)
        [`this [[400 ~] ~]]
      ?:  delivered.u.purchase
        [`this [[400 ~] ~]]
      =.  delivered.u.purchase  %.y
      =.  sold  (~(put by sold) session-id u.purchase)
      :-  `this
      :-  [200 ~]
      `(json-to-octs:server [%s 'Delivered'])
    ::
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
      |=  [i=@t q=@ud]
      ?~  sto=(~(get by stock) i)
        ~
      =/  subtotal=amount:circle
        [(mul q integer.amount.u.sto) 0 %'USD']
      :-  ~
      %-  pairs:enjs:format
      :~  product+s+i
          count+(numb:enjs:format q)
          amount+(amount:enjs:req:circle subtotal)
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
      =/  [total=amount:circle pend=(list [@t @ud])]
        %+  roll  params
        |=  [[id=@t q=@ud] total=amount:circle p=(list [@t @ud])]
        ?~  prod=(~(get by stock) id)
          [total p]
        ?.  (gte count.u.prod q)
          [total p]
        :-  [(add (mul q integer.amount.u.prod) integer.total) 0 %'USD']
        [[id q] p]
      =.  pending  (~(put by pending) sess-id [pend %.n ~])
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
        [`this not-found:gen:server]
      =/  tic=(unit ticket)
        %-  ~(rep in tickets.u.pur)
        |=  [=ticket out=(unit ticket)]
        `ticket
      ?~  tic
        [`this not-found:gen:server]
      =/  res=json
        %-  pairs:enjs:format
        :~  [%total (amount:enjs:req:circle total.u.pur)]
        ::
          :-  %items
          :-  %a
          %+  turn  product-id.u.tic
          |=  [i=@t q=@ud]
          =/  st  (~(got by stock) i)
          %-  pairs:enjs:format
          :~  %'productId'^s+i
              quantity+(numb:enjs:format q)
              price+(amount:enjs:req:circle amount.st)
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
    ?+  -.upd  `this
        %payment
      ?~  pend=(~(get by pending) p.upd)
        `this
      =*  id  product-id.u.pend
      :: remove count in pending-stock
      =.  pending-stock
        %+  roll  id
        |=  [[i=@t q=@ud] ps=_pending-stock]
        =/  p  (~(got by pending-stock) i)
        (~(put by ps) i (sub count.p q))
::      =/  pend-sto  (~(got by pending-stock) id)
::      =.  pending-stock
::        %+  ~(put by pending-stock)  id
::        (sub count.pend-sto count.u.pend)
      :: delete pending transaction
      =.  pending  (~(del by pending) p.upd)
      ::
      ?:  ?=(?(%confirmed %paid) status.q.upd)
        :: remove count in stocks
        =.  stock
          %+  roll  id
          |=  [[i=@t q=@ud] s=_stock]
          =/  sto  (~(got by stock) i)
          (~(put by s) i sto(count (sub count.sto q)))
::        =/  sto    (~(got by stock) id)
::        =.  stock  (~(put by stock) id sto(count (sub count.sto count.u.pend)))
        :: put in sold
        =^  cards  state
          %:  finalize-sale
            p.upd
            id
            (need metadata.u.pend)
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
          |=  [[i=@t q=@ud] p=_pending ps=_pending-stock]
          =/  ex  (~(got by ps) i)
          :-  (~(put by p) p.upd u.pend(started %.y, metadata r.upd))
          (~(put by ps) i (add count.ex q))
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
::  ++  gen-ticket
::    |=  [session-id=@t product-id=(list @t) =metadata:circle salt=@]
::    ^-  ticket
::    =/  amt=amount:circle
::      %+  roll  product-id
::      |=  [i=@ a=amount:circle]
::      =/  p  (~(got by stock) i)
::      :+  (add integer.a integer.amount.p)  0
::      %'USD'
::    :*  (shas salt eny.bowl)
::        %.n
::        product-id
::        amt
::    ==
  ::
  ++  finalize-sale
    |=  [session-id=@t product-id=(list [@t @ud]) =metadata:circle =amount:circle]
    ^-  (quip card _state)
    =/  =ticket  [eny.bowl %.n product-id amount]
    =/  =purchase
      :*  (sy ticket ~)
          amount
          metadata
          now.bowl
          %.n
      ==
    =.  sold              (~(put by sold) session-id purchase)
    =.  token-to-session  (~(put by token-to-session) token.ticket session-id)
    :_  state
    (send-email purchase)^~
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
    =/  =ticket  (snag 0 ~(tap in tickets))
    %+  murn  product-id.ticket
    |=  [i=@t q=@ud]
    ^-  (unit manx)
    =/  item  (~(got by stock) i)
    =/  price=amount:circle  [(mul q integer.amount.item) 0 %'USD']
    ?:  =(q 0)  ~
    :-  ~
    ^-  manx
    ;tr
      ;td(style "width: 50%", align "left")
        ;p
          ;b: {(trip i)} 
          ; × {(trip (rsh [3 2] (scot %ui q)))}
        ==
      ==
      ;td(style "width: 50%", align "right"): {(amount-to-tape price)}
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
    |=  =purchase
    ^-  manx
    ;div
      ;img(src "https://tirrel.io/assets/miami-header-big.png", width "800px");
      ;p: Hello!
      ;p: Thanks for your purchase at the Urbit Assembly Merch Store!
      ;b: Please pick up your items at the merch table by Sunday at 4pm.
      ;p: Please contact us at support@tirrel.io if there are any issues with your purchase, including returns and refunds

      ;p: See you on the network!
      ;p: Tirrel Corp. & The Urbit Assembly Team
      ;hr(style "margin:20px 0", color "grey", size "1", width "40%");
      ;b: Urbit Assembly Store Receipt:
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
      ;p: Processed by Tirrel Corporation
    ==
  ::
  ++  send-email
    |=  =purchase
    ^-  card
    =/  content=content-field:mailer
      :-  'text/html'
      =<  q
      %-  as-octt:mimes:html
      %-  en-xml:html
      ^-  manx
      (make-email purchase)
    =/  =action:mailer
      :*  %send-email
          ['delivery@tirrel.io' 'Urbit Assembly Merch Store']
          'Urbit Assembly Merch Store Receipt'
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
