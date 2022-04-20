:: nmi [tirrel]
::
::
/-  *nmi
/+  default-agent, dbug, verb, server
|%
+$  card  card:agent:gall
::
+$  state-0
  $:  api-key=(unit cord)
      site=(unit [host=cord suffix=(unit term)])
      redirect-url=(unit cord)
      =transactions
      =request-to-time
      =request-to-token
      =token-to-request
  ==
::
+$  versioned-state
  $%  [%0 *]
      [%1 *]
      [%2 state-0]
  ==
++  api-url  'https://secure.networkmerchants.com/api/v2/three-step'
++  timeout-interval  ~m1
--
::
=|  [%2 state-0]
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
  :-  [%pass /timeout %arvo %b %wait (add now.bowl timeout-interval)]~
  this
::
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  |^
  =/  old  !<(versioned-state old-vase)
  |-
  ?-    -.old
      %2
    `this(state old)
  ::
    ?(%0 %1)  `this
  ==
  --
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %nmi-action
    =^  cards  state
      (nmi-action !<(action vase))
    [cards this]
  ::
      %handle-http-request
    ::  TODO: add rate-limits for POST requests
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =|  sim=simple-payload:http
    =^  cards  sim
      (handle-http-request eyre-id inbound-request)
    =?  request-to-time  ?=(%'POST' method.request.inbound-request)
      (~(put by request-to-time) eyre-id now.bowl)
    :_  this
    %+  weld  cards
    (give-simple-payload:app:server eyre-id sim)
  ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta =inbound-request:eyre]
    |^
    ^-  [(list card) simple-payload:http]
    =/  req-line=request-line:server
      %-  parse-request-line:server
      url.request.inbound-request
    =*  req-head  header-list.request.inbound-request
    =*  req-body  body.request.inbound-request
    ?+    method.request.inbound-request  `not-found:gen:server
      %'GET'   `(handle-get-request req-head req-line)
      %'POST'  (handle-post-request req-head req-line req-body)
    ==
    ::
    +$  partial-action
      $%  [%initiate-sale who=ship sel=selector:nam]
          [%complete-sale token=cord]
      ==
    ::
    ++  handle-post-request
      =*  srv  server
      |=  [headers=header-list:http req=request-line:srv bod=(unit octs)]
      ?~  bod
        `[[400 ~] ~]
      ?~  maybe-json=(de-json:html q.u.bod)
        `[[400 ~] ~]
      =/  act=(each partial-action tang)
        (mule |.((dejs u.maybe-json)))
      ?:  ?=(%| -.act)
        `[[400 ~] ~]
      ?:  ?=(%initiate-sale -.p.act)
        =/  =action  [-.p.act eyre-id who.p.act sel.p.act]
        :_  [[201 ~] `(json-to-octs:srv s+eyre-id)]
        =-  [%pass /post-req/[eyre-id] %agent [our dap]:bowl %poke -]~
        [%nmi-action !>(action)]
      =/  =action  [-.p.act token.p.act]
      ?~  maybe-request=(~(get by token-to-request) token.p.act)
        `[[400 ~] ~]
      :_  [[201 ~] `(json-to-octs:srv s+u.maybe-request)]
      =-  [%pass /post-req/[eyre-id] %agent [our dap]:bowl %poke -]~
      [%nmi-action !>(action)]
    ::
    ++  dejs
      =,  dejs:format
      |^
      %-  of
      :~  [%initiate-sale init-sale]
          [%complete-sale so]
      ==
      ::
      ++  init-sale
        %-  ot
        :~  who+(su ;~(pfix sig fed:ag))
            sel+selector
        ==
      ::
      ++  selector
        |=  jon=json
        ^-  selector:nam
        ?>  ?=(^ jon)
        ?+  -.jon  !!
          %n  [%| (ni jon)]
          %a  [%& ((as (su ;~(pfix sig fed:ag))) jon)]
        ==
      --
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      ?.  ?=(^ ext.req)        not-found:gen:srv
      ?.  ?=(%json u.ext.req)  not-found:gen:srv
      ?+    site.req  not-found:gen:srv
          [* %'start' @ ~]
        ?~  token=(~(get by request-to-token) (rear `(list @t)`site.req))
          not-found:gen:srv
        (json-response:gen:srv s+u.token)
      ::
          [* %'finish' @ ~]
        ?~  time=(~(get by request-to-time) (rear `(list @t)`site.req))
          not-found:gen:srv
        =/  =records:nam
          (scry-for %shop records:nam /records/(scot %da u.time))
        %-  json-response:gen:srv
        ?:  =(~ records)  ~
        :-  %a
        %+  turn  ~(tap in records)
        |=  r=record:nam
        ^-  json
        %-  pairs:enjs:format
        :~  ship+s+(scot %p ship.r)
            ticket+s+(scot %q ticket.r)
        ==
      ==
    --
  ::
  ++  nmi-action
    |=  =action
    ^-  (quip card _state)
    |^
    ?-    -.action
        %set-api-key
      ?>  ?=(^ key.action)
      :_  state(api-key key.action)
      [%give %fact /configuration^~ nmi-action+!>(action)]^~
    ::
        %set-backend-url
      ?>  ?=(^ site.action)
      =*  host    host.u.site.action
      =*  suffix  suffix.u.site.action
      =/  old-pax=path  ?~(site ~ ?~(suffix.u.site ~ u.suffix.u.site^~))
      =/  old-host      ?~(site ~ `host.u.site)
      =/  suf-pax=path  ?~(suffix ~ u.suffix^~)
      :_  state(site `[host suffix])
      :-  [%give %fact /configuration^~ nmi-action+!>(action)]
      %-  zing
      :~  ?~  site  ~
          [%pass /eyre %arvo %e %disconnect [old-host old-pax]]~
        ::
          [%pass /eyre %arvo %e %connect [`host suf-pax] dap.bowl]~
      ==
    ::
        %set-redirect-url
      `state(redirect-url p.action)
    ::
        %initiate-sale
      ?>  ?=(^ api-key)
      ?>  ?=(^ redirect-url)
      =/  =time  (~(got by request-to-time) request-id.action)
      =/  =wire  /step1/[request-id.action]
      =/  total-price
        (calc-total-price who.action sel.action)
      :-  =-  [%pass wire %arvo %i %request -]~
          :_  *outbound-config:iris
          (request-step1 who.action sel.action total-price)
      %_    state
          transactions
        %^  put:orm  transactions  time
        [%pending [who.action sel.action %'USD' total-price] ~]
      ==
    ::
        %complete-sale
      ?>  ?=(^ api-key)
      ?>  ?=(^ redirect-url)
      =/  =wire  /step3/[token-id.action]
      =/  request-id    (~(got by token-to-request) token-id.action)
      =/  =time         (~(got by request-to-time) request-id)
      =/  =transaction  (got:orm transactions time)
      ?>  ?=(%pending -.transaction)
      =*  info  info.transaction
      =/  curr-total-price
        (calc-total-price who.info sel.info)
      ~|  %price-expired-for-sale
      ?>  =(total-price.info curr-total-price)
      :_  state
      =-  [%pass wire %arvo %i %request -]~
      [(request-step3 token-id.action) *outbound-config:iris]
    ==
    ::
    ++  calc-total-price
      |=  [who=ship sel=selector:nam]
      ^-  cord
      =/  =price:nam
        (need (scry-for %shop (unit price:nam) /price))
      ?>  ?=(%& -.price)
      ?>  ?=(%'USD' currency.p.price)
      =/  inventory
        (scry-for %shop (set [ship @q]) /inventory/(scot %p who))
      ?>  ?:  ?=(%| -.sel)
            (lte p.sel ~(wyt in inventory))
          =((~(int in p.sel) inventory) p.sel)
      %+  rsh  [3 2]
      %+  scot  %ui
      %+  mul  amount.p.price
      ?:(?=(%| -.sel) p.sel ~(wyt in p.sel))
    ::
    ++  request-step1
      |=  [who=ship sel=selector:nam amount=cord]
      ^-  request:http
      ?>  ?=(^ api-key)
      ?>  ?=(^ redirect-url)
      =.  amount  (crip (weld (trip amount) (trip '.00')))
      :^  %'POST'  api-url
        ['Content-type' 'text/xml']~
      :-  ~
      %-  xml-to-octs
      ;sale
        ;api-key
          ;+  ;/  (trip u.api-key)
        ==
        ;redirect-url
          ;+  ;/  (trip u.redirect-url)
        ==
        ;amount
          ;+  ;/  (trip amount)
        ==
      ==
    ::
    ++  request-step3
      |=  token=cord
      ^-  request:http
      ?>  ?=(^ api-key)
      :^  %'POST'  api-url
        ['Content-type' 'text/xml']~
      :-  ~
      %-  xml-to-octs
      ;complete-action
        ;api-key
          ;+  ;/  (trip u.api-key)
        ==
        ;token-id
          ;+  ;/  (trip token)
        ==
      ==
    ::
    ++  xml-to-octs
      |=  xml=manx
      ^-  octs
      (as-octt:mimes:html (en-xml:html xml))
    --
  ::
  ++  scry-for
    |*  [dap=term =mold =path]
    .^  mold
      %gx
      (scot %p our.bowl)
      dap
      (scot %da now.bowl)
      (snoc `^path`path %noun)
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
  ?:  ?=([%behn %wake *] sign-arvo)
    :_  filter-old-requests
    [%pass /timeout %arvo %b %wait (add now.bowl timeout-interval)]~
  ?.  ?=(%http-response +<.sign-arvo)
    (on-arvo:def wire sign-arvo)
  =^  cards  state
    (http-response wire client-response.sign-arvo)
  [cards this]
  ::
  ++  filter-old-requests
    ^+  this
    =^    req-ids=(list cord)
        request-to-time
      %+  roll  ~(tap by request-to-time)
      |=  [[req-id=cord =time] [req-ids=(list cord) req-to-tim=_request-to-time]]
      ?.  (lth time (sub now.bowl ~h1))
        req-ids^req-to-tim
      :-  req-id^req-ids
      (~(del by req-to-tim) req-id)
    |-
    ?~  req-ids
      this
    =/  token  (~(get by request-to-token) i.req-ids)
    ?~  token
      $(req-ids t.req-ids)
    %_  $
      req-ids           t.req-ids
      request-to-token  (~(del by request-to-token) i.req-ids)
      token-to-request  (~(del by token-to-request) u.token)
    ==
  ::
  ++  http-response
    |=  [=^wire res=client-response:iris]
    ^-  (quip card _state)
    |^
    ?.  ?=(%finished -.res)  `state
    ?+    wire  ~|('unknown request type coming from nmi' !!)
        [%step1 @ ~]
      =/  request-id  i.t.wire
      =/  nd  (normalize-data request-id full-file.res)
      ?.  ?=(%& -.nd)
        +.nd
      `(process-step1 request-id +.nd)
    ::
        [%step3 @ ~]
      =/  request-id  (~(got by token-to-request) i.t.wire)
      =/  nd  (normalize-data request-id full-file.res)
      ?.  ?=(%& -.nd)
        +.nd
      (process-step3 request-id +.nd)
    ==
    ::
    ++  process-step1
      |=  [request-id=cord tx=transaction m=(map @t $?(@t (map @t @t)))]
      ^-  _state
      ?>  ?=(%pending -.tx)
      =/  =time  (~(got by request-to-time) request-id)
      =/  result-code  (~(get by m) 'result-code')
      =/  result-text  (~(get by m) 'result-text')
      =/  form-url     (~(get by m) 'form-url')
      ?.  ?&(?=(^ result-code) ?=(^ result-text))
        %_    state
            transactions
          %^  put:orm  transactions  time
          [%failure info.tx token.tx ~]
        ==
      ?>  ?=(@t u.result-code)
      ?>  ?=(@t u.result-text)
      ?.  =('100' u.result-code)
        %_    state
            transactions
          %^  put:orm  transactions  time
          :^  %failure  info.tx  token.tx
          `[(slav %ud u.result-code) u.result-text]
        ==
      ?>  ?=([~ u=@t] form-url)
      =/  action-token  `@t`(rsh [3 54] u.form-url)
      %_    state
          transactions
        %^  put:orm  transactions  time
        [%pending info.tx `action-token]
      ::
        request-to-token  (~(put by request-to-token) request-id action-token)
        token-to-request  (~(put by token-to-request) action-token request-id)
      ==
    ::
    ++  process-step3
      |=  [request-id=cord tx=transaction m=(map @t $?(@t (map @t @t)))]
      ^-  (quip card _state)
      ?>  ?=(%pending -.tx)
      =/  result-code  (~(get by m) 'result-code')
      =/  result-text  (~(get by m) 'result-text')
      =/  =time  (~(got by request-to-time) request-id)
      =/  token  (need token.tx)
      ?.  ?&(?=(^ result-code) ?=(^ result-text))
        :-  ~
        %_    state
            transactions
          (put:orm transactions time [%failure info.tx token.tx ~])
        ==
      =/  shipping=$?(@t (map @t @t))  (~(got by m) 'shipping')
      ?@  shipping  !!
      =/  shp=(map @t @t)  shipping
      =/  email     (~(got by shp) 'email')
      ?>  ?=(@t u.result-code)
      ?>  ?=(@t u.result-text)
      ?.  =('100' u.result-code)
        :-  ~
        %_    state
            transactions
          %^  put:orm  transactions  time
          :^  %failure  info.tx  token.tx
          `[(slav %ud u.result-code) u.result-text]
        ==
      =/  transaction-id      (~(got by m) 'transaction-id')
      =/  authorization-code  (~(got by m) 'authorization-code')
      =/  cvv-result          (~(got by m) 'cvv-result')
      ?>  ?=(@t transaction-id)
      ?>  ?=(@t authorization-code)
      ?>  ?=(@t cvv-result)
      =/  billing=$?(@t (map @t @t))  (~(got by m) 'billing')
      ~&  billing
      ?@  billing  !!
      =/  bil=(map @t @t)  billing
      =/  cc-num=@t  (~(got by bil) 'cc-number')
      :_  %_    state
              transactions
            %^  put:orm  transactions  time
            :^  %success  info.tx  token.tx
            :*  (rash transaction-id dem)
                (rash authorization-code dem)
                cvv-result
                email
                cc-num
            ==
          ==
      =-  [%pass /sell-ship/[token] %agent [our.bowl %shop] %poke -]~
      :-  %shop-update
      !>(`update:nam`[%sell-ships who.info.tx sel.info.tx time email ~])
    ::
    ++  normalize-data
      |=  [request-id=cord full-file=(unit mime-data:iris)]
      ^-  (each [transaction (map @t $?(@t (map @t @t)))] (quip card _state))
      |^
      =/  =time  (~(got by request-to-time) request-id)
      =/  tx=transaction  (got:orm transactions time)
      ?.  ?=(%pending -.tx)
        [%| ~ state]
      ?~  full-file
        :+  %|  ~
        %_    state
            transactions
          %^  put:orm  transactions  time
          [%failure info.tx token.tx ~]
        ==
      =/  xml=(unit manx)
        (de-xml:html `@t`q.data.u.full-file)
      ?~  xml
        :+  %|  ~
        %_    state
            transactions
          %^  put:orm  transactions  time
          [%failure info.tx token.tx ~]
        ==
      [%& [tx (map-from-xml-body u.xml)]]
      ::
      ++  map-from-xml-body
        |=  xml=manx
        ^-  (map @t $@(@t (map @t @t)))
        %-  ~(gas by *(map @t $@(@t (map @t @t))))
        %+  murn  c.xml
        |=  =manx
        ^-  (unit [@t $@(@t (map @t @t))])
        ?.  ?=(@ n.g.manx)  ~
        =/  cman  c.manx
        ?~  cman          ~
        ?^  a.g.i.cman
          [~ n.g.manx (crip v.i.a.g.i.cman)]
        ^-  (unit [@t (map @t @t)])
        :-  ~
        :-  n.g.manx
        %-  ~(gas by *(map @t @t))
        %+  murn  c.manx
        |=  =^manx
        ^-  (unit [@t @t])
        ?.  ?=(@ n.g.manx)  ~
        ?~  c.manx          ~
        ?~  a.g.i.c.manx    ~
        [~ n.g.manx (crip v.i.a.g.i.c.manx)]
      --
    --
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  ?:  ?=([%updates ~] path)
    `this
  ?:  ?=([%configuration ~] path)
    :_  this
    :~  [%give %fact ~ nmi-action+!>([%set-api-key api-key])]
        [%give %fact ~ nmi-action+!>([%set-backend site])]
        [%give %fact ~ nmi-action+!>([%set-redirect-url site])]
    ==
  (on-watch:def path)
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    [%x %export ~]  ``noun+!>(state)
  ::
      [%x %site ~]
    :^  ~  ~  %json
    !>  ^-  json
    ?~  site  ~
    s+host.u.site
  ::
      [%x %api-key ~]
    :^  ~  ~  %json
    !>  ^-  json
    ?~  api-key  ~
    s+u.api-key
  ::
      [%x %transaction @ ~]
    =/  time  (slaw %da i.t.t.path)
    ?~  time  ~
    =/  tx=(unit transaction)  (get:orm transactions u.time)
    ``noun+!>(tx)
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
