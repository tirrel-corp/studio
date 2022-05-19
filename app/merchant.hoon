/+  default-agent, dbug, verb, server, *merchant, merchant-js, uuidv4
|%
+$  card  card:agent:gall
::
+$  state-0
  $:  public-key=(unit @t)
  ==
++  provider  ~zod
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
    mjs   ~(. merchant-js public-key)
::
++  on-init
  :_  this
  [%pass /eyre %arvo %e %connect [~ /merchant] dap.bowl]^~
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  `this(state !<(state-0 old-vase))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  (on-poke:def mark vase)
      %circle-ask
    =/  =ask
      !<(ask vase)
    =.  p.ask  our.bowl
    :_  this
    [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
  ::
      %noun
    :_  this
    =-  [%pass /master %agent [provider %circle] %watch -]^~
    /master/(scot %p our.bowl)
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =|  sim=simple-payload:http
    =^  cards  sim
      (handle-http-request eyre-id inbound-request)
    :_  this
    %+  weld  cards
    (give-simple-payload:app:server eyre-id sim)
  ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta =inbound-request:eyre]
    ^-  [(list card) simple-payload:http]
    =/  url  (stab url.request.inbound-request)
    ?+    method.request.inbound-request  `not-found:gen:server
        %'GET'
      ?+    url  `[[404 ~] ~]
          [%merchant ~]
        =-  `[[200 ~] ~ -]
        %-  manx-to-octs:server
        ;html
          ;body
            ;h1: Merchant
            ;button#card-btn: Create Card
            ;button#pay-btn: Create Payment
            ;script@"https://unpkg.com/openpgp@5.2.1/dist/openpgp.min.js";
            ;script@"https://unpkg.com/uuid@latest/dist/umd/uuidv4.min.js";
            ;script(type "text/javascript"): {pk-var-definition:mjs}
            ;script(type "text/javascript"): {encrypt-function:mjs}
            ;script(type "text/javascript"): {create-card-function:mjs}
            ;script(type "text/javascript"): {create-payment-function:mjs}
            ;script(type "text/javascript"): {card-button:mjs}
            ;script(type "text/javascript"): {pay-button:mjs}
          ==
        ==
      ::
          [%merchant %card @ ~]
        =*  id  i.t.t.url
        =/  =ask
          [our.bowl %card id]
        :_  [[200 ~] ~]
        [%pass /ask %agent [provider %circle] %poke %circle-ask !>(ask)]^~
      ::
          [%merchant %payment @ ~]
        =*  id  i.t.t.url
        =/  =ask
          [our.bowl %payment id]
        :_  [[200 ~] ~]
        [%pass /ask %agent [provider %circle] %poke %circle-ask !>(ask)]^~
      ==
    ::
        %'POST'
      =*  bod  body.request.inbound-request
      ?~  bod
        `[[400 ~] ~]
      =*  ip  address.inbound-request
      =/  =metadata
        ['logan@tirrel.io' ~ (to-uuid:uuidv4 eny.bowl) (rsh [3 1] (scot %if +.ip))]
      ?+    url.request.inbound-request  `[[404 ~] ~]
          %'/merchant/card'
        =/  jon  (de-json:html `@t`q.u.bod)
        =/  car-deet  (bind jon create-card:dejs)
        ?~  car-deet  `[[500 ~] ~]
        =/  =ask
          [our.bowl %create-card metadata u.car-deet]
        :_  [[200 ~] `(json-to-octs:server s+'card')]
        [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
      ::
          %'/merchant/payment'
        =/  jon  (de-json:html `@t`q.u.bod)
        =/  pay-deet  (bind jon create-payment:dejs)
        ?~  pay-deet  `[[500 ~] ~]
        =/  =ask
          [our.bowl %create-payment metadata u.pay-deet]
        :_  [[200 ~] `(json-to-octs:server s+'payment')]
        [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
      ==
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
  ?+    wire  !!
      [%ask ~]
    ~&  [wire sign]
    `this
  ::
      [%master ~]
    ?+    -.sign  ~&  [wire sign]  `this
        %fact
      =/  upd=update
        !<(update q.cage.sign)
      ?+  -.upd  `this
          %public-key
        `this(public-key `key.p.upd)
      ::
          %card
        ~&  upd
        `this
      ::
          %payment
        ~&  upd
        `this
      ==
    ::
        %kick
      :_  this
      [%pass /master %agent [~zod %circle] %watch /master/(scot %p our.bowl)]^~
    ==
  ==
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
