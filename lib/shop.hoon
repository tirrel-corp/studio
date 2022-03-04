/-  *shop, mailer
/+  kg=keygen
|%
::
++  wallet-for-ship
  |=  [prv=@ =ship]
  ^-  [tic=@q nod=node:kg net=uode:kg]
  =/  a  (get-auth-token prv)
  =/  iw  (generate-invite-wallet ship a)
  =/  oad  ::  ownership seed
    (to-seed:bip39:kg seed.q.iw "")
  =/  sed  (derive-network-seed:kg oad 1)
  =/  network=uode:kg  [1 sed (urbit:ds:kg sed)]
  [p.iw q.iw network]
::
++  generate-invite-wallet
  |=  [ship=@p seed=@ux]
  ^-  (pair @q node:kg)
  =/  ticket  (make-deterministic-ticket ship seed)
  =/  w  (ownership-wallet-from-ticket:kg ship ticket ~)
  [+.ticket w]
::
++  make-deterministic-ticket
  |=  [ship=@p seed=@ux]
  ^-  byts
  =/  point-salt  (cat 3 (rsh [3 2] (scot %ui ship)) 'invites')
  =/  entropy  (shas point-salt (swp 3 seed))
  =/  ticket   (swp 3 (end [1 32] entropy))
  [(met 3 ticket) ticket]
::
++  get-auth-token
  |=  priv=@ux
  ^-  @ux
  =/  msg  'Bridge Authentication Token'
  =/  msg-2
    %:  rap  3
      '\19Ethereum Signed Message:\0a'
      (scot %ud (met 3 msg))
      msg
      ~
    ==
  =/  hax    (swp 3 (shax msg-2))
  =/  raw-sig    (ecdsa-raw-sign:secp256k1:secp:secp:crypto hax priv)
  =/  res    (cat 3 (swp 3 r.raw-sig) (swp 3 s.raw-sig))
  =/  bits   (add 27 (mod (cut 3 [31 1] (swp 3 res)) 2))
  `@ux`(swp 3 (cat 3 res bits))
::
++  make-email
  |=  [address=@t sold=(map ship @q)]
  ^-  email:mailer
  :*  ['isaac@tirrel.io' '~tirrel']
      'You got a planet!'
      (email-body sold)^~
      [[address]~ ~ ~]~
  ==
  ::
++  email-body
  |=  sold=(map ship @q)
  ^-  content-field:mailer
  =/  num  ~(wyt by sold)
  :-  'text/html'
  =<  q
  %-  as-octt:mimes:html
  %-  en-xml:html
  ^-  manx
  ?:  =(num 1)
    =/  lis  ~(tap by sold)
    ?>  ?=(^ lis)
    =/  ship    -.i.lis
    =/  ticket  +.i.lis
    =/  bu  (bridge-url ship ticket)
    ;div
      ;p: Welcome to Urbit, you now own the planet {(scow %p ship)}
      ;table
        ;tr
          ;td: Please activate it in Bridge:
          ;td
            ;a(href bu): {bu}
          ==
        ==
      ==
    ==
  =/  lis  ~(tap by sold)
  ?>  ?=(^ lis)
  =/  ship    -.i.lis
  =/  ticket  +.i.lis
  ;div
    ;p: Welcome to Urbit, you now own the following planets. Click the bridge link beside each planet to activate it
    ;table
      ;*  %+  turn  lis
          |=  [s=@p t=@q]
          ^-  manx
          ;tr
            ;td: {(scow %p s)}
            ;td
              ;a(href (bridge-url s t)): {(bridge-url s t)}
            ==
          ==
    ==
  ==
::
++  bridge-url
  |=  [p=@p t=@q]
  ^-  tape
  "https://bridge.urbit.org/#{(slag 1 (scow %q t))}-{(slag 1 (scow %p p))}"
::
++  dejs
  =,  dejs:format
  |%
  ++  ship  (su ;~(pfix sig fed:ag))
  ++  update
    ^-  $-(json ^update)
    %-  of
    :~  add-star-config+(ot ship+ship config+config ~)
        del-star-config+ship
        set-price+price
        spawn-ships+(ot ship+ship sel+selector ~)
        sell-ships+(ot ship+ship sel+selector time+di email+so password+(mu so) ~)
    ==
  ::
  ++  config
    ^-  $-(json ^config)
    %-  ot
    :~  prv+nu
        proxy+(su (perk %own %spawn ~))
    ==
  ::
  ++  price
    |=  jon=json
    ^-  ^price
    %&^((ot amount+ni currency+so ~) jon)
  ::
  ++  selector
    |=  jon=json
    ^-  ^selector
    ?:  ?=(%n -.jon)
      [%| (ni jon)]
    [%& ((as ship) jon)]
  --
::
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  upd=^update
    ^-  json
    ?-    -.upd
        %add-star-config
      %+  frond  %add-star-config
      %-  pairs
      :~  who+(ship who.upd)
          config+(config config.upd)
      ==
    ::
        %del-star-config
      %+  frond  %del-star-config
      (ship who.upd)
    ::
        %set-price
      %+  frond  %set-price
      (price price.upd)
    ::
        %spawn-ships
      %+  frond  %spawn-ships
      %-  pairs
      :~  who+(ship who.upd)
          sel+(selector sel.upd)
      ==
    ::
        %sell-ships
      %+  frond  %sell-ships
      %-  pairs
      :~  who+(ship who.upd)
          sel+(selector sel.upd)
          email+s+email.upd
          time+(time time.upd)
      ==
    ==
  ::
  ++  config
    |=  con=^config
    ^-  json
    %-  pairs
    :~  prv+s+(en:base16:mimes:html [(met 3 prv.con) prv.con])
        proxy+s+proxy.con
    ==
  ::
  ++  price
    |=  pri=^price
    ^-  json
    ?:  ?=(%| -.pri)
      a+(turn ~(tap in p.pri) |=(t=@t s+t))
    %-  pairs
    :~  amount+(numb amount.p.pri)
        currency+s+currency.p.pri
    ==
  ::
  ++  selector
    |=  sel=^selector
    ^-  json
    ?:  ?=(%| -.sel)
      (numb p.sel)
    a+(turn ~(tap in p.sel) ship)
  --
--
