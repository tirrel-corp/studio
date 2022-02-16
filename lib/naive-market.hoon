/-  *naive-market, mailer
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
  =/  point-salt  (cat 3 (scot %p ship) 'invites')
  =/  entropy  (shas seed point-salt)
  =/  ticket   (end [3 (div 64 3)] entropy)
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
  ~&  (cut 3 [31 1] res)
  ~&  (cut 3 [31 1] (swp 3 res))
  =/  bits   (add 27 (mod (cut 3 [31 1] (swp 3 res)) 2))
  `@ux`(swp 3 (cat 3 res bits))
::
++  make-email
  |=  address=@t
  ^-  email:mailer
  |^
  :*  ['isaac@tirrel.io' '~tirrel']
      'Planet Receipt'
      email-body^~
      [[address]~ ~ ~]~
  ==
  ::
  ++  email-body
    ^-  content-field:mailer
    :-  'text/html'
    =<  q
    %-  as-octt:mimes:html
    %-  en-xml:html
    %-  manx
    ;div
      ;p: here is your planet
    ==
  --
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
        set-referrals+(mu referral-policy)
        spawn-ships+(ot ship+ship sel+selector ~)
        sell-ships+(ot ship+ship sel+selector email+so ~)
        sell-from-referral+ship
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
    ^-  $-(json ^price)
    (ot amount+ni currency+so ~)
  ::
  ++  referral-policy
    ^-  $-(json ^referral-policy)
    (ot number-referrals+ni price+price ~)
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
        %set-referrals
      %+  frond  %set-referrals
      (referral-policy ref.upd)
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
      ==
    ::
        %sell-from-referral
      %+  frond  %sell-from-referral
      (ship who.upd)
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
    %-  pairs
    :~  amount+(numb amount.pri)
        currency+s+currency.pri
    ==
  ::
  ++  referral-policy
    |=  ref=(unit ^referral-policy)
    ^-  json
    ?~  ref
      ~
    %-  pairs
    :~  number-referrals+(numb number-referrals.u.ref)
        price+(price price.u.ref)
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
