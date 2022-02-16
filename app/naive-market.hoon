:: naive-market [tirrel]
::
/-  dice, mailer
/+  *naive-market, ntx=naive-transactions, eth=ethereum, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  price=(unit price)
      referrals=(unit referral-policy)
    ::
      =star-configs
      =for-sale
      =sold-ships
      =sold-ship-to-date
  ==
::
+$  versioned-state
  $%  [%0 state-0]
  ==
--
::
=|  [%0 state-0]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init   `this
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  ^-  (quip card _this)
  `this
  ::=/  old  !<(versioned-state old-vase)
::  ?-  -.old
::    ::%0  ::`this(state old)
::    %0  `this
::  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %naive-market-update
    =^  cards  state
      (market-update !<(update vase))
    [cards this]
  ==
  ::
  ++  market-update
    |=  =update
    ^-  (quip card _state)
    ?-    -.update
      %set-price      `state(price `price.update)
      %set-referrals  `state(referrals ref.update)
    ::
        %add-star-config
      |^
      ?<  (~(has by star-configs) who.update)
      ?>  =(%king (clan:title who.update))
      =*  c  config.update
      ?<  (check-dupes prv.c)
      =/  =address  (address-from-prv:key:eth prv.c)
      :_  state(star-configs (~(put by star-configs) who.update c))
      :_  ~
      :^  %pass  /star/(scot %p who.update)  %agent
      [[our.bowl %roller] %watch /connect/(scot %ux address)]
      ::
      ++  check-dupes
        |=  prv=@
        =/  cfgs  ~(val by star-configs)
        |-  ^-  ?
        ?~  cfgs  %|
        ?:(=(prv.i.cfgs prv) %& $(cfgs t.cfgs))
      --
    ::
        %del-star-config
      =/  c=config  (~(got by star-configs) who.update)
      =/  =address  (address-from-prv:key:eth prv.c)
      :_  %_  state
            star-configs  (~(del by star-configs) who.update)
            for-sale      (~(del by for-sale) who.update)
          ==
      :_  ~
      :^  %pass  /star/(scot %p who.update)  %agent
      [[our.bowl %roller] %leave ~]
    ::
        %spawn-ships
      =*  sel  sel.update
      =*  who  who.update
      =+  (~(got by star-configs) who)
      ~|  "cannot spawn more than 50 ships in a batch"
      ?>  ?:  ?=(%| -.sel)
            (gte 50 p.sel)
          (gte 50 ~(wyt in p.sel))
      |^
      =/  ships  select-ships
      =/  nonce=@
        ~|  "roller may not be set up"
        (need (scry-for %roller (unit @) /nonce/(scot %p who)/[proxy]))
      =|  cards=(list card)
      =|  tickets=(list (pair ship @q))
      |-
      ?~  ships
        ::  TODO: add tickets to state
        [cards state]
      =*  ship  i.ships
      =/  gen  (generate-txs ship nonce)
      %_  $
        ships    t.ships
        nonce    (add 3 nonce)
        tickets  [[ship p.gen] tickets]
        cards    (weld cards q.gen)
      ==
      ::
      ++  select-ships
        ^-  (list ship)
        =/  unspawned=(set ship)
          %-  ~(gas in *(set ship))
          (scry-for %roller (list ship) /unspawned/(scot %p who))
        =/  pending-spawns=(set ship)
          %-  ~(gas in *(set ship))
          %+  murn
            (scry-for %roller (list pend-tx:dice) /pending-by/(scot %p who))
          |=  pen=pend-tx:dice
          ^-  (unit ship)
          =*  skim-tx  +.tx.raw-tx.pen
          ?.  ?=(%spawn -.skim-tx)
            ~
          `ship.skim-tx
        =.  unspawned
          (~(dif in unspawned) pending-spawns)
        ?:  ?=(%| -.sel)
          (scag p.sel ~(tap in unspawned))
        ?>  =((~(int in unspawned) p.sel) p.sel)
        ~(tap in p.sel)
      ::
      ++  generate-txs
        |=  [=ship nonce=@]
        ^-  (pair @q (list card))
        =/  addr  (address-from-prv:key:eth prv)
        =+  (wallet-for-ship prv ship)
        :-  tic
        :~  (roller-card addr nonce [[who proxy] %spawn ship addr])
          ::
            %^  roller-card  addr  +(nonce)
            :+  [ship %own]  %configure-keys
            [public.crypt.keys.net public.auth.keys.net 1 %.n]
          ::
            %^  roller-card  addr  (add 2 nonce)
            [[who proxy] %transfer-point addr.keys.nod %.n]
        ==
      ::
      ++  roller-card
        |=  [=address:naive:ntx nonce=@ =tx:naive:ntx]
        ^-  card
        =/  sig  q:(gen-tx:ntx nonce tx prv)
        :^  %pass  /roller/(scot %ux sig)  %agent
        :+  [our.bowl %roller]  %poke
        roller-action+!>([%submit | address sig %don tx])
      --
    ::
        %sell-ships
      =*  sel  sel.update
      =*  who    who.update
      =*  email  email.update
      |^
      ?>  ?=(^ price)
      =/  c=config  (~(got by star-configs) who)
      =|  cards=(list card)
      =/  sold  select-ships
      [~ state]
::      |-
::      ?~  sold
::        :_  state
::        %+  weld  cards
::        (give /updates^~ update)
::      %_  $
::        pending            t.pending
::        sold-ships         (put:his sold-ships now [ship u.price referrals email])
::        for-sale           (~(del ju for-sale) who ship)
::        sold-ship-to-date  (~(put by sold-ship-to-date) ship now)
::        cards              [send-email cards]
::      ==
      ::
      ++  select-ships
        ^-  (list (pair ship @q))
        =/  avail=(map ship @q)
          (~(got by for-sale) who)
        =|  lis=(list (pair ship @q))
        ?:  ?=(%& -.sel)
          =/  ships  ~(tap in p.sel)
          |-
          ?~  ships
            lis
          $(ships t.ships, lis [[i.ships (~(got by avail) i.ships)] lis])
        =/  ships  ~(tap by avail)
        (scag p.sel ships)
      ::
      ++  send-email
        ^-  card
        =/  send-email=action:mailer  [%send-email (make-email email)]
        =/  =cage  [%mailer-action !>(send-email)]
        [%pass /fulfillment-email %agent [our.bowl %mailer] %poke cage]
      --
    ::
        %sell-from-referral
      :-  (give /updates^~ update)
      ::  check that a code is available and that the ship in question
      ::  has referrals left to give out.
      ::  if not, crash. if yes, then sell at the referral code price.
      state
    ==
  ::
  ++  give
    |=  [paths=(list path) =update]
    ^-  (list card)
    [%give %fact paths %naive-market-update !>(update)]~
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
++  on-watch
  |=  =path
  |^
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%updates ~] path)
    `this
  ?:  ?=([%configuration ~] path)
    :_  this
    %+  turn  state-to-json
    |=  =json
    ^-  card
    [%give %fact /configuration^~ %json !>(json)]
  (on-watch:def path)
  ::
  ++  state-to-json
    ^-  (list json)
    =-  ?~  price  -
        [(update:enjs [%set-price u.price]) -]
    ^-  (list json)
    :-  (update:enjs [%set-referrals referrals])
    %+  turn  ~(tap by star-configs)
    |=  [who=ship =config]
    ^-  json
    (update:enjs [%add-star-config who config])
  --
::
++  on-leave  on-leave:def
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?+    path  (on-peek:def path)
    [%x %export ~]  ``noun+!>(state)
    [%x %price ~]   ``noun+!>(price)
  ::
      [%x %inventory @ ~]
    =/  who=ship  (slav %p i.t.t.path)
    ``noun+!>(`(set (pair ship @q))`(~(get ju for-sale) who))
  ::
      [%x %star-configs ~]
    :^  ~  ~  %json
    !>  ^-  json
    a+(turn ~(tap in ~(key by star-configs)) |=(=ship s+(scot %p ship)))
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  |^
  ?+    wire  (on-agent:def wire sign)
      [%star @ ~]
    ~&  wire
    =/  who=ship  (slav %p i.t.wire)
    =/  con=config  (~(got by star-configs) who)
    ?:  ?=(%kick -.sign)
      =/  =address  (address-from-prv:key:eth prv.con)
      :_  this
      [%pass wire %agent [our.bowl %roller] %watch /connect/(scot %ux address)]^~
    ?.  ?=(%fact -.sign)
      `this
    `this
  ==
  ::
::  ++  on-star
::    |=  [who=ship con=config]
::    ^-  _state
::    ::  TODO: ensure we remove pending sales from set
::    =/  =address  (address-from-prv:key:eth prv.con)
::    =-  state(for-sale (~(put by for-sale) who -))
::    %-  %~  dif  in
::      %-  ~(gas in *(set ship))
::      %+  murn
::        (scry-for %roller (list ship) /ships/(scot %ux address))
::      |=  s=ship
::      ?.(=(%duke (clan:title s)) ~ `s)
::    ~(key by sold-ship-to-date)
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
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
