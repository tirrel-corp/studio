/-  *naive-market
|%
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
        sell-ships+(ot ship+ship sel+selector to+nu ~)
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
          to+s+(en:base16:mimes:html [(met 3 to.upd) to.upd])
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
