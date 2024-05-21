/-  *auth
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  [%add-service (ot name+so service+service ~)]
        [%del-service so]
        [%mod-access-duration (ot name+so duration+(mu ri) ~)]
        [%mod-details (ot name+so pricing+pricing title+so copy+(ar so) shipping+bo ~)]
        [%add-user (ot name+so id+id user+user ~)]
        [%add-subscribers (ot name+so users+(om bo) ~)]
        [%del-user (ot name+so id+id ~)]
        [%ask-access (ot name+so id+id ~)]
        [%add-payout payout-data]
        [%trigger-payout price]
        [%forward-id so]
    ==
  ++  update
    ^-  $-(json ^update)
    %-  of
    :~  [%add-service (ot name+so service+service ~)]
        [%del-service so]
        [%mod-access-duration (ot name+so duration+(mu ri) ~)]
        [%mod-details (ot name+so pricing+pricing title+so copy+(ar so) shipping+bo ~)]
        [%add-user (ot name+so id+id user+user ~)]
        [%del-user (ot name+so id+id ~)]
        [%ask-access (ot name+so id+id ~)]
    ==
  ::
  ++  payout-data
    ^-  $-(json ^payout-data)
    %-  of
    :~  [%usdc so]
        [%wire payout-form]
    ==
  ::
  ++  payout-form
    ^-  $-(json ^payout-form)
    %-  ot
    :~  %'accountNumber'^so
        %'routingNumber'^so
        %'billingDetails'^billing-details
        %'bankAddress'^bank-address
    ==
  ::
  ++  billing-details
    ^-  $-(json ^billing-details)
    %-  ot
    :~  %'name'^so
        %'city'^so
        %'country'^so
        %'line1'^so
        %'line2'^(mu so)
        %'district'^(mu so)
        %'postalCode'^so
    ==
  ::
  ++  bank-address
    ^-  $-(json ^bank-address)
    %-  ot
    :~  %'name'^(mu so)
        %'city'^(mu so)
        %'country'^so
        %'line1'^(mu so)
        %'line2'^(mu so)
        %'district'^(mu so)
    ==
  ::
  ++  id
    |=  jon=json
    ^-  ^id
    ?:  ?=([%s *] jon)
      `@p`(rash p.jon fed:ag)
    ?:  ?=([%o *] jon)
      =/  email=json  (~(got by p.jon) 'email')
      ?>  ?=([%s *] email)
      [%email `@t`p.email]
    !!
  ::
  ++  user  (ot access-code+ul expiry-date+ul security-clearance+bo free+bo mailing-list+bo ~)
  ::
  ++  ri                                           ::  number as relative date
    |=  jon=json
    ?>  ?=([%n *] jon)
    =/  n=@  (rash p.jon dem)
    `@dr`(mul ~s1 n)
  ::
  ++  service
    ^-  $-(json ^service)
    %-  ot
    :~  users+ul
        duration+(mu ri)
        pricing+pricing
        title+so
        copy+(ar so)
        url+so
        shipping+bo
    ==
  ::
  ++  pricing
    ^-  $-(json ^pricing)
    (om (ot price+price copy+(ar so) ~))
  ::
  ++  price
    |=  jon=json
    ^-  ^price
    ~|  jon
    ?>  ?=(%o -.jon)
    =/  c  (~(got by p.jon) %cents)
    ?>  ?=(%n -.c)
    =/  n=@  (rash p.c dem)
    [n %'USD']
  --
::
++  enjs
  =,  enjs:format
  |%
  ++  action
    |=  u=^action
    ^-  json
    %+  frond  -.u
    ?+  -.u  !!
        %add-service
      %-  pairs
      :~  name+s+p.u
          service+(service q.u)
      ==
    ::
        %del-service
      %-  pairs
      :~  name+s+p.u
      ==
    ::
        %mod-access-duration
      %-  pairs
      :~  name+s+p.u
          duration+?~(q.u ~ n+(rsh [3 2] (scot %ui (div u.q.u ~s1))))
      ==
    ::
        %mod-details
      %-  pairs
      :~  name+s+p.u
          price+(pricing q.u)
          title+s+r.u
          copy+a+(turn s.u |=(a=@t s+a))
          shipping+b+t.u
      ==
    ::
        %add-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ::
        %del-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ::
        %add-payout  ~
    ==
  ::
  ++  update
    |=  u=^update
    ^-  json
    %+  frond  -.u
    ?+  -.u  !!
        %add-service
      %-  pairs
      :~  name+s+p.u
          service+(service q.u)
      ==
    ::
        %del-service
      %-  pairs
      :~  name+s+p.u
      ==
    ::
        %mod-access-duration
      %-  pairs
      :~  name+s+p.u
          duration+?~(q.u ~ n+(rsh [3 2] (scot %ui (div u.q.u ~s1))))
      ==
    ::
        %mod-details
      %-  pairs
      :~  name+s+p.u
          pricing+(pricing q.u)
          title+s+r.u
          copy+a+(turn s.u |=(a=@t s+a))
          shipping+b+t.u
      ==
    ::
        %add-subscribers
      %-  pairs
      :~  name+s+p.u
          :-  %users
          :-  %o
          %-  ~(run by q.u)
          |=  b=?
          ^-  json
          [%b b]
      ==
    ::
        %add-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ::
        %del-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ::
        %set-kyc  b+p.u
    ::
        %payout-status
      %-  pairs
      :~  status+?~(p.u ~ s+u.p.u)
          brief+?~(q.u ~ (payout-brief u.q.u))
          earnings+(price r.u)
          :-  %pending
          ?~  s.u  ~
          %-  pairs
          :~  amount+(price a.u.s.u)
              status+s+b.u.s.u
          ==
      ==
    ==
  ::
  ++  price
    |=  p=^price
    ^-  json
    %-  pairs
    :~  cents+(numb cents.p)
        currency+s+currency.p
    ==
  ::
  ++  pricing
    |=  p=^pricing
    ^-  json
    :-  %o
    %-  ~(run by p)
    |=  [m=^price c=(list @t)]
    ^-  json
    %-  pairs
    :~  price+(price m)
        copy+a+(turn c |=(x=@t s+x))
    ==
  ::
  ++  payout-brief
    |=  s=^payout-brief
    ^-  json
    ?-  -.s
      %usdc  (pairs type+s+-.s id+s+id.s address+s+address.s ~)
      %wire  (pairs type+s+-.s id+s+id.s acct+s+acct.s ~)
    ==
  ::
  ++  service
    |=  s=^service
    ^-  json
    =*  ad  access-duration.s
    %-  pairs
    :~  users+(users users.s)
        duration+?~(ad ~ n+(rsh [3 2] (scot %ui (div u.ad ~s1))))
        pricing+(pricing pricing.s)
        title+s+title.s
        copy+a+(turn copy.s |=(a=@t s+a))
        url+s+url.s
        shipping+b+shipping.s
    ==
  ::
  ++  users
    |=  u=(map id user)
    ^-  json
    :-  %o
    %-  ~(gas by *(map @t json))
    %+  turn  ~(tap by u)
    |=  [p=id q=user]
    ^-  [@t json]
    ?>  ?=(^ p)
    :-  p.p
    %-  pairs
    :~  free+b+free.q
        mailing-list+b+mailing-list.q
        security-clearance+b+security-clearance.q
    ==
  --
::
++  find-token
  |=  [token=@q =service]
  ^-  (unit (pair email=@tas user))
  =/  pairs  ~(tap by users.service)
  |-
  ?~  pairs  ~
  =/  tail=(list (pair id user))  t.pairs
  =+  [=id =user]=i.pairs
  ?@  id                           $(pairs tail)
  ?~  access-code.user             $(pairs tail)
  ?:  =(token u.access-code.user)  $(pairs tail)
  `[p.id user]
::
--
