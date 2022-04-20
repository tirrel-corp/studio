:: shop [tirrel]
::
/-  dice, mailer, nmi
/+  *shop, ntx=naive-transactions, eth=ethereum, default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  price=(unit price)
    ::
      =star-configs
      =pending-txs
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
  =/  old  !<(versioned-state old-vase)
  ?-  -.old
    %0  `this(state old)
  ==
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %shop-update
    =^  cards  state
      (shop-update !<(update vase))
    [cards this]
  ==
  ::
  ++  shop-update
    |=  =update
    ^-  (quip card _state)
    ?-    -.update
      %set-price      `state(price `price.update)
    ::
        %add-star-config
      |^
      ?<  (~(has by star-configs) who.update)
      ?>  =(%king (clan:title who.update))
      =*  c  config.update
      ?<  (check-dupes prv.c)
      =/  =address  (address-from-prv:key:eth prv.c)
      :_  %=  state
            star-configs  (~(put by star-configs) who.update c)
            pending-txs   (~(put by pending-txs) who.update ~)
            for-sale      (~(put by for-sale) who.update ~)
          ==
      :~  :^  %pass  /star/connect/(scot %p who.update)  %agent
          [[our.bowl %roller] %watch /connect/(scot %ux address)]
        ::
          :^  %pass  /star/txs/(scot %p who.update)  %agent
          [[our.bowl %roller] %watch /txs/(scot %ux address)]
      ==
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
            pending-txs   (~(del by pending-txs) who.update)
          ==
      :~  :^  %pass  /star/connect/(scot %p who.update)  %agent
          [[our.bowl %roller] %leave ~]
      ::
          :^  %pass  /star/txs/(scot %p who.update)  %agent
          [[our.bowl %roller] %leave ~]
      ==
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
      =|  pend=(map ship [@q (list @ux)])
      |-
      ?~  ships
        =/  new-pend
          (~(uni by (~(got by pending-txs) who)) pend)
        :-  cards
        state(pending-txs (~(put by pending-txs) who new-pend))
      =*  ship  i.ships
      =/  gen  (generate-txs ship nonce)
      %_  $
        ships    t.ships
        nonce    +(nonce)
        tickets  [[ship p.gen] tickets]
        cards    (weld cards q.gen)
        pend     (~(put by pend) ship [p.gen r.gen])
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
            (scry-for %roller (list pend-tx:dice) /pending/(scot %p who))
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
        ^-  (trel @q (list card) (list @ux))
        =/  addr  (address-from-prv:key:eth prv)
        =+  (wallet-for-ship prv ship)
        =/  spawn  (roller-tx addr nonce [[who proxy] %spawn ship addr])
        =/  conf-keys
          %^  roller-tx  addr  0
          :+  [ship %own]  %configure-keys
          [public.crypt.keys.net public.auth.keys.net 1 %.n]
        =/  transfer
          %^  roller-tx  addr  1
          [[ship %own] %transfer-point addr.keys.nod %.n]
        :+  tic
          [q.spawn q.conf-keys q.transfer ~]
        [p.spawn p.conf-keys p.transfer ~]
      ::
      ++  roller-tx
        |=  [=address:naive:ntx nonce=@ =tx:naive:ntx]
        ^-  (pair @ux card)
        =/  chain-id=@
          (scry-for %roller @ /chain-id)
        =+  [hash sig]=(fix-sign-tx prv nonce tx)
        :-  hash
        :^  %pass  /roller/(scot %ux hash)  %agent
        :+  [our.bowl %roller]  %poke
        roller-action+!>([%submit | address q:sig %don tx])
      ::
      ++  fix-sign-tx
        |=  [pk=@ nonce=@ =tx:naive:ntx]
        ^-  [@ux octs]
        =/  =octs  (gen-tx-octs:ntx tx)
        =/  chain-id=@
          (scry-for %roller @ /chain-id)
        =/  sign-data
          %-  hash-tx:ntx
          (unsigned-tx:ntx chain-id nonce octs)
        =+  (ecdsa-raw-sign:secp256k1:secp:crypto sign-data pk)
        =+  [len dat]=(cad:naive:ntx 3 1^v 32^s 32^r ~)
        :_  [len dat]
        (hash-raw-tx:ntx dat octs tx)
      --
    ::
        %sell-ships
      =*  sel  sel.update
      =*  who    who.update
      =*  email  email.update
      =*  time   time.update
      =*  password  password.update
      ?>  ?=(^ price)
      ?>  ?|  ?=(%& -.u.price)
              ?&  ?=(^ password.update)
                  (~(has in p.u.price) u.password.update)
          ==  ==
      |^
      =/  c=config  (~(got by star-configs) who)
      =/  sold=(map ship @q)
        (~(gas by *(map ship @q)) select-ships)
      =/  for-sale-who  (~(got by for-sale) who)
::      =.  for-sale
::        %+  ~(put by for-sale)  who
::        (~(dif by for-sale-who) sold)
      =.  sold-ships
        %^  uni:his  sold-ships
          time
        (make-records sold)
      =.  sold-ship-to-date
        %-  ~(uni by sold-ship-to-date)
        (ship-to-date sold)
      =?  price  ?&(?=(%| -.u.price) ?=(^ password.update))
        price(p.u (~(del in p.u.price) u.password.update))
      [(send-email sold)^~ state]
      ::
      ++  ship-to-date
        |=  s=(map ship @q)
        ^-  (map ship ^time)
        %-  ~(run in s)
        |=  [a=ship @q]
        [a time]
      ::
      ++  make-records
        |=  m=(map ship @q)
        ^-  (set record)
        %-  ~(run in m)
        |=  [=ship tic=@q]
        ^-  record
        [ship u.price email tic]
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
        |=  sold=(map ship @q)
        ^-  card
        =/  tx=(unit transaction:nmi)
          %^  scry-for  %nmi  (unit transaction:nmi)
          /transaction/(scot %da time)
        ?>  ?=(^ tx)
        ?>  ?=(%success -.u.tx)
        =*  fin  finis.u.tx
        =/  send-email=action:mailer
          :-  %send-email
          (make-email email sold now.bowl cc-num.fin transaction-id.fin)
        =/  =cage  [%mailer-action !>(send-email)]
        [%pass /fulfillment-email %agent [our.bowl %mailer] %poke cage]
      --
    ==
  ::
  ++  give
    |=  [paths=(list path) =update]
    ^-  (list card)
    [%give %fact paths %shop-update !>(update)]~
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
      [%x %records @ ~]
    =/  =time  (slav %da i.t.t.path)
    ``noun+!>(`records`(get:his sold-ships time))
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
      [%star @ @ ~]
    =/  who=ship  (slav %p i.t.t.wire)
    =/  con=config  (~(got by star-configs) who)
    :: TODO deal with both cases
    ?:  ?=(%kick -.sign)
      =/  =address  (address-from-prv:key:eth prv.con)
      :_  this
      [%pass wire %agent [our.bowl %roller] %watch /connect/(scot %ux address)]^~
    ?.  ?=(%fact -.sign)
      `this
    =+  (on-star who con)
    :-  ~
    %=  this
      pending-txs  (~(put by pending-txs) who p)
      for-sale     (~(put by for-sale) who f)
    ==
  ==
  ::
  ++  on-star
    |=  [who=ship con=config]
    ^-  [p=(map ship [@q (list @ux)]) f=(map ship @q)]
    =/  pend   (~(got by pending-txs) who)
    =/  for-s  (~(got by for-sale) who)
    %+  roll  ~(tap by pend)
    |=  $:  [=ship tic=@q txs=(list @ux)]
            p=_pend
            f=_for-s
        ==
    =/  success=?(%pending %failed %confirmed)
      %+  roll  txs
      |=  [x=@ux res=$~(%confirmed ?(%pending %failed %confirmed))]
      =/  scry=tx-status:dice
        (scry-for %roller tx-status:dice /tx/(scot %ux x)/status)
      ~&  >  scry+scry
      ?:  ?|(=(res %pending) =(res %failed))
        res
      ?-  status.scry
        ?(%pending %sending %unknown)  %pending
        ?(%failed %cancelled)          %failed
        %confirmed                     %confirmed
      ==
    ?-    success
        %confirmed
    :-  (~(del by p) ship)
    (~(put by f) ship tic)
    ::
      %pending    [p f]
      %failed     [(~(del by p) ship) f]
    ==
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
