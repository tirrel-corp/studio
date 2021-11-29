:: naive-nmi [tirrel]
::
::
/-  *naive-nmi
/+  default-agent, dbug, verb, server
|%
+$  card  card:agent:gall
::
+$  state-0
  $:  %0
      api-key=(unit cord)
      site=(unit [host=cord suffix=(unit term)])
      redirect-url=(unit cord)
      =transactions
      =request-to-time
      =request-to-token
      =token-to-request
  ==
++  api-url  'https://secure.networkmerchants.com/api/v2/three-step'
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
++  on-init  `this
::
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  =/  old  !<(state-0 old-vase)
  `this(state old)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %naive-nmi-action
    =^  cards  state
      (naive-nmi-action !<(action vase))
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
      ~&  u.maybe-json
      =/  act=(each partial-action tang)
        (mule |.((dejs u.maybe-json)))
      ~&  act
      ?:  ?=(%| -.act)
        `[[400 ~] ~]
      ?-    -.p.act
          %initiate-sale
        =/  =action  [-.p.act eyre-id who.p.act sel.p.act]
        ~&  action
        :_  [[201 ~] `(json-to-octs:srv s+eyre-id)]
        =-  [%pass /post-req/[eyre-id] %agent [our dap]:bowl %poke -]~
        [%naive-nmi-action !>(action)]
      ::
          %complete-sale
        =/  =action  [-.p.act token.p.act]
        ?~  maybe-request=(~(get by token-to-request) token.p.act)
          ~&  %failed
          `[[400 ~] ~]
        :_  [[201 ~] `(json-to-octs:srv s+eyre-id)]
        =-  [%pass /post-req/[eyre-id] %agent [our dap]:bowl %poke -]~
        [%naive-nmi-action !>(action)]
      ==
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
      ::  TODO: make this generic
      ?~  ext.req
        $(ext.req `%html, site.req [%index ~])
      ~&  [site.req ext.req]
      ?.  ?=(%json u.ext.req)
        =/  file=(unit octs)
          (get-file-at /app/naive-nmi site.req u.ext.req)
        ?~  file   not-found:gen:srv
        ?+  u.ext.req  not-found:gen:srv
          %html  (html-response:gen:srv u.file)
          %js    (js-response:gen:srv u.file)
          %css   (css-response:gen:srv u.file)
        ==
      ?~  site.req
        not-found:gen:srv
      =/  maybe-token  (~(get by request-to-token) i.site.req)
      ?~  maybe-token
        not-found:gen:srv
      %-  json-response:gen:srv
      s+u.maybe-token
    ::
    ++  get-file-at
      |=  [base=path file=path ext=@ta]
      ^-  (unit octs)
      ?.  ?=(?(%html %css %js) ext)
        ~
      =/  =path
        :*  (scot %p our.bowl)
            q.byk.bowl
            (scot %da now.bowl)
            (snoc (weld base file) ext)
        ==
      ?.  .^(? %cu path)  ~
      %-  some
      %-  as-octs:mimes:html
      .^(@ %cx path)
    --
  ::
  ++  naive-nmi-action
    |=  =action
    ^-  (quip card _state)
    |^
    ?-    -.action
        %set-api-key
      ?>  ?=(^ key.action)
      :_  state(api-key key.action)
      [%give %fact /configuration^~ naive-nmi-action+!>(action)]^~
    ::
        %set-site
      ?>  ?=(^ site.action)
      =*  host    host.u.site.action
      =*  suffix  suffix.u.site.action
      =/  full-url=cord
        %+  rap  3
        :-  'https://'
        ?~  suffix
          host^~
        ~[host '/' u.suffix]
      =/  old-pax=path  ?~(site ~ ?~(suffix.u.site ~ u.suffix.u.site^~))
      =/  old-host      ?~(site ~ `host.u.site)
      =/  suf-pax=path  ?~(suffix ~ u.suffix^~)
      :_  state(redirect-url `full-url, site `[host suffix])
      :-  [%give %fact /configuration^~ naive-nmi-action+!>(action)]
      %-  zing
      :~  ?~  site  ~
          [%pass /eyre %arvo %e %disconnect [old-host old-pax]]~
        ::
          [%pass /eyre %arvo %e %connect [`host suf-pax] dap.bowl]~
      ==
    ::
        %initiate-sale
      ?>  ?=(^ api-key)
      ?>  ?=(^ redirect-url)
      ~&  action
      =/  =time  (~(got by request-to-time) request-id.action)
      =/  =wire  /step1/[request-id.action]
      =/  total-price
        (calc-total-price who.action sel.action)
      ~&  total-price
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
        (need (scry-for %naive-market (unit price:nam) /price))
      ?>  ?=(%'USD' currency.price)
      =/  inventory=(set ship)
        (scry-for %naive-market (set ship) /inventory/(scot %p who))
      ?>  ?:  ?=(%| -.sel)
            (lte p.sel ~(wyt in inventory))
          =((~(int in p.sel) inventory) p.sel)
      %+  rsh  [3 2]
      %+  scot  %ui
      %+  mul  amount.price
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
    |^
    ?.  ?=(%finished -.res)  `state
    ?+    wire  ~|('unknown request type coming from naive-nmi' !!)
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
      |=  [request-id=cord tx=transaction m=(map @t @t)]
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
      ?.  =('100' u.result-code)
        %_    state
            transactions
          %^  put:orm  transactions  time
          :^  %failure  info.tx  token.tx
          `[(slav %ud u.result-code) u.result-text]
        ==
      =/  action-token  `@t`(rsh [3 54] (need form-url))
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
      |=  [request-id=cord tx=transaction m=(map @t @t)]
      ^-  (quip card _state)
      ?>  ?=(%pending -.tx)
      =/  result-code  (~(get by m) 'result-code')
      =/  result-text  (~(get by m) 'result-text')
      =/  =time  (~(got by request-to-time) request-id)
      =/  token  (need token.tx)
      ~&  m
      =:  request-to-token  (~(del by request-to-token) request-id)
          request-to-time   (~(del by request-to-time) request-id)
          token-to-request  (~(del by token-to-request) token)
        ==
      ?.  ?&(?=(^ result-code) ?=(^ result-text))
        :-  ~
        %_    state
            transactions
          (put:orm transactions time [%failure info.tx token.tx ~])
        ==
      ?.  =('100' u.result-code)
        :-  ~
        %_    state
            transactions
          %^  put:orm  transactions  time
          :^  %failure  info.tx  token.tx
          `[(slav %ud u.result-code) u.result-text]
        ==
      :_  %_    state
              transactions
            %^  put:orm  transactions  time
            :^  %success  info.tx  token.tx
            ::  TODO: parse result
            *finis
          ==
      ~&  info.tx
      =-  [%pass /sell-ship/[token] %agent [our.bowl %naive-market] %poke -]~
      :-  %naive-market-update
      !>(`update:nam`[%sell-ships who.info.tx sel.info.tx 0x1234])
    ::
    ++  normalize-data
      |=  [request-id=cord full-file=(unit mime-data:iris)]
      ^-  (each [transaction (map @t @t)] (quip card _state))
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
        ^-  (map @t @t)
        %-  ~(gas by *(map @t @t))
        %+  murn  c.xml
        |=  =manx
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
    ~&  path
    :_  this
    :~  [%give %fact ~ naive-nmi-action+!>([%set-api-key api-key])]
        [%give %fact ~ naive-nmi-action+!>([%set-site site])]
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
  ==
::
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
