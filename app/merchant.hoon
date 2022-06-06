/+  default-agent, dbug, verb, server, *merchant, merchant-js, uuidv4
|%
+$  card  card:agent:gall
::
+$  state-0
  $:  public-key=(unit @t)
      cards=(map @t pay-card:res)
      payments=(map @t payment:res)
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
    ~&  %http
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
          [%merchant %card @ ~]
        =*  id  i.t.t.url
        :-  ~
        =-  [[200 ~] `(json-to-octs:server -)]
        %+  frond:enjs:format  %card
        ?~  card=(~(get by cards) id)  ~
        %-  pairs:enjs:format
        :~  id+s+id.u.card
            status+s+status.u.card
        ==
      ::
          [%merchant %payment @ ~]
        =*  id  i.t.t.url
        :-  ~
        =-  [[200 ~] `(json-to-octs:server -)]
        %+  frond:enjs:format  %payment
        ?~  pam=(~(get by payments) id)  ~
        %-  pairs:enjs:format
        :~  id+s+id.u.pam
            status+s+status.u.pam
        ==
      ::
          [%merchant ~]
        =-  `[[200 ~] ~ -]
        %-  manx-to-octs:server
        ;html
          ;head
            ;meta(charset "utf-8");
            ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
            ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
          ==
          ;body.pa3.sans-serif.absolute.h-100.w-100.flex.flex-column.justify-center.items-center
            ;div.w-100.mw6.pa3
              ;h1: Merchant
              ;div.flex.flex-column.mv4
                ;span.mv2.w-70.flex.justify-between.items-center
                  ;label: Card Number
                  ;input#card-cnum.ba.pa2.ml3.bw1.br2(placeholder "4007400000000007");
                ==
                ;span.mv2.w-70.flex.justify-between.items-center
                  ;label: Card CVV
                  ;input#card-cvv.ba.pa2.ml3.bw1.br2(placeholder "111");
                ==
                ;button#card-btn.pv3.ph4.white.bg-black.bn.pointer.br2: Create Card
              ==
              ;br;
              ;div.flex.flex-column.mv4
                ;span.mv2.w-70.flex.justify-between.items-center
                  ;label: Amount
                  ;input#amount.ba.pa2.ml3.bw1.br2(placeholder "10.00");
                ==
                ;button#pay-btn.pv3.ph4.white.bg-black.bn.pointer.br2: Create Payment
              ==
            ==
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
      ==
    ::
        %'POST'
      =*  bod  body.request.inbound-request
      ?~  bod
        `[[400 ~] ~]
      =*  ip  address.inbound-request
      =/  =metadata
        ['logan@tirrel.io' ~ (to-uuid:uuidv4 eny.bowl) (rsh [3 1] (scot %if +.ip))]
      ?+    url  `[[404 ~] ~]
          [%merchant %card ~]
        =/  jon  (de-json:html `@t`q.u.bod)
        =/  car-deet  (bind jon create-card:dejs)
        ?~  car-deet  `[[500 ~] ~]
        ~&  [metadata u.car-deet]
        =/  =ask
          [our.bowl %create-card metadata u.car-deet]
        :_  [[200 ~] `(json-to-octs:server s+'card')]
        [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
      ::
          [%merchant %payment ~]
        =/  jon  (de-json:html `@t`q.u.bod)
        =/  pay-deet  (bind jon create-payment:dejs)
        ?~  pay-deet  `[[500 ~] ~]
        =/  =ask
          [our.bowl %create-payment metadata u.pay-deet]
        :_  [[200 ~] `(json-to-octs:server s+'payment')]
        [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
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
    [%ask ~]  `this
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
        `this(cards (~(put by cards) [p q]:upd))
      ::
          %payment
        ~&  upd
        `this(payments (~(put by payments) [p q]:upd))
      ==
    ::
        %kick
      :_  this
      [%pass /master %agent [provider %circle] %watch /master/(scot %p our.bowl)]^~
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
