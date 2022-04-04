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
  =/  hax    (keccak-256:keccak:crypto (met 3 msg-2) msg-2)
  =/  raw-sig    (ecdsa-raw-sign:secp256k1:secp:secp:crypto hax priv)
  =/  res    (cat 3 (swp 3 r.raw-sig) (swp 3 s.raw-sig))
  =/  bits   (add 27 (mod (cut 3 [31 1] (swp 3 res)) 2))
  `@ux`(swp 3 (cat 3 res bits))
::
++  make-email
  |=  [address=@t sold=(map ship @q) now=@da cc-num=@t tid=@ud]
  ^-  email:mailer
  :*  ['delivery@tirrel.io' '~tirrel']
      'You got a planet!'
      (email-body address sold now cc-num tid)^~
      [[address]~ ~ ~]~
  ==
  ::
++  email-body
  |=  [address=@t sold=(map ship @q) now=@da cc-num=@t tid=@ud]
  ^-  content-field:mailer
  =/  num  ~(wyt by sold)
  =/  orange  "color: #ff6300"
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
    ;div(style "max-width: 600px")
      ;h1: Welcome to Urbit!
      ;p
        ; You now own the planet
        ;b: {(scow %p ship)}!
      ==
      ;b: Follow these steps to get your Urbit running:
      ;ol
        ;li
          ;a(href bu, style orange): Activate your planet in Bridge
        ==
        ;li
          ;a(href "https://urbit.org/getting-started#port", style orange): Download Port
          ; , Urbit's desktop client
        ==
        ;li
          ; Follow the
          ;a(href "https://urbit.org/getting-started/planet#step-3-boot", style orange): Installation Guide
          ;  for detailed instructions
        ==
        ;li
          ; If you need assistance with installation, book a
          ;a(href "https://calendly.com/tirrel/onboarding", style orange): live onboarding session
        ==
      ==
      ;b: Support Resources:
      ;ul
        ;li
          ; For purchase-related problems, please contact:
          ;a(href "mailto:support@tirrel.io", style orange): support@tirrel.io
        ==
        ;li
          ; If you have questions on Urbit, join our support group: ~tirrel/tirrel-support
        ==
      ==
      ;p: See you on the network!
      ;p: - Planet Market
      ;p
        ;a(href "https://planet.market", style orange): https://planet.market
      ==
      ;br;
      ;p
        ; Activate planet link:
        ;a(href bu, style orange): {bu}
      ==
      ;hr(style "margin: 30px 0", color "black", size "1");
      ;b: Planet Market Receipt
      ;p: Receipt #{(trip (rsh [3 2] (scot %ui tid)))}
      ;p: {(trip (print-date-full now))}
      ;p
        ; Delivery to:
        ;a(href "mailto:{(trip address)}", style orange): {(trip address)}
      ==
      ;table(width "100%", style "margin-top: 30px")
        ;tr
          ;td(style "width: 50%", align "left")
            ;b: Planet
          ==
          ;td(style "width: 50%", align "right"): $20.00
        ==
      ==
      ;hr(style "margin: 30px 0", color "black", size "1");
      ;table(width "100%")
        ;tr
          ;td(style "width: 50%", align "left"): Subtotal
          ;td(style "width: 50%", align "right"): $20.00
        ==
        ;tr
          ;td(style "width: 50%", align "left")
            ;b: Total Paid
          ==
          ;td(style "width: 50%", align "right")
            ;b: $20.00
          ==
        ==
        ;tr
          ;td(style "width: 50%", align "left"): {(trip cc-num)}
          ;td(style "width: 50%", align "right"): {(trip (print-date-num now))}
        ==
      ==
    ==
  !!
::
++  print-date-full
  |=  d=@da
  ^-  @t
  =/  date   (yore d)
  =/  month  (crip (snag (dec m.date) mon:yu:chrono:userlib))
  %:  rap  3
    month
    ' '
    (scot %ud d.t.date)
    ', '
    (rsh [3 2] (scot %ui y.date))
    ~
  ==
++  print-date-num
  |=  d=@da
  ^-  @t
  =/  date   (yore d)
  =/  hour=@t
    ?:  (gte h.t.date 10)  (scot %ud h.t.date)
    (cat 3 '0' (scot %ud h.t.date))
  =/  minute=@t
    ?:  (gte m.t.date 10)  (scot %ud m.t.date)
    (cat 3 '0' (scot %ud m.t.date))
  %:  rap  3
    (scot %ud m.date)
    '/'
    (scot %ud d.t.date)
    '/'
    (rsh [3 2] (scot %ui y.date))
    ' '
    hour
    ':'
    minute
    ~
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
