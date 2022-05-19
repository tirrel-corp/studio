/-  *circle
|%
++  dejs
  =,  dejs:format
  |%
  ++  error
    ^-  $-(json error:res)
    (ot code+ni message+so ~)
  ::
  ++  ping
    ^-  $-(json ping:res)
    (ot message+so ~)
  ::
  ++  config
    ^-  $-(json config:res)
    (ot data+(ot payments+(ot 'masterWalletId'^so ~) ~) ~)
  ::
  ++  public-key
    ^-  $-(json public-key:res)
    (ot data+(ot 'keyId'^so 'publicKey'^so ~) ~)
  ::
  ++  card-status
    |=  jon=json
    ^-  card-status:res
    ?>  ?=(%s -.jon)
    ?>  ?=(card-status:res p.jon)
    p.jon
  ::
  ++  cvv
    |=  jon=json
    ^-  cvv:res
    ?>  ?=(%s -.jon)
    ?>  ?=(cvv:res p.jon)
    p.jon
  ::
  ++  card-network
    |=  jon=json
    ^-  card-network:res
    ?>  ?=(%s -.jon)
    ?>  ?=(card-network:res p.jon)
    p.jon
  ::
  ++  risk-decision
    |=  jon=json
    ^-  risk-decision:res
    ?>  ?=(%s -.jon)
    ?>  ?=(risk-decision:res p.jon)
    p.jon
  ::
  ++  one-pay-card
    ^-  $-(json pay-card:res)
    (ot data+pay-card ~)
  ::
  ++  pay-card
    ^-  $-(json pay-card:res)
    %-  ot
    :~  id+so
        status+card-status
        'billingDetails'^(ot country+so district+so ~)
        'expMonth'^ni
        'expYear'^ni
        network+card-network
        bin+so
        'issuerCountry'^so
        fingerprint+so
        verification+(ot avs+so cvv+cvv ~)
        'createDate'^so
        'updateDate'^so
    ==
  ::
  ++  pay-card-list
    ^-  $-(json pay-card-list:res)
    (ot data+(ar pay-card) ~)
  ++  one-payment
    ^-  $-(json payment:res)
    (ot data+payment ~)
  ::
  ++  amount
    ^-  $-(json ^amount)
    |=  jon=json
    ^-  ^amount
    ?>  ?=(%o -.jon)
    =/  amo  (~(got by p.jon) 'amount')
    ?>  ?=(%s -.amo)
    =/  cur  (~(got by p.jon) 'currency')
    ?>  ?=(%s -.cur)
    =/  i=(unit @ud)
      (find "." (trip p.amo))
    ?>  ?=(^ i)
    =/  pre  (slav %ud (cut 3 [0 u.i] p.amo))
    =/  suf  (cut 3 [+(u.i) (sub (met 3 p.amo) u.i)] p.amo)
    :+  pre
      ?:  =('00' suf)  0
      (slav %ud pre)
    p.cur
  ::
  ++  payment-source
    ^-  $-(json ^payment-source)
    |=  jon=json
    ^-  ^payment-source
    ?>  ?=(%o -.jon)
    =/  pid  (~(got by p.jon) 'id')
    ?>  ?=(%s -.pid)
    =/  typ  (~(got by p.jon) 'type')
    ?>  ?=(%s -.typ)
    ?>  ?=(?(%card %ach) p.typ)
    [p.pid p.typ]
  ::
  ++  payment-status
    ^-  $-(json payment-status:res)
    |=  j=json
    ^-  payment-status:res
    ?>  ?=(%s -.j)
    ?>  ?=(payment-status:res p.j)
    p.j
  ::
  ++  verification
    ^-  $-(json ^verification)
    |=  j=json
    ^-  ^verification
    ~&  j
    ?>  ?=(%s -.j)
    ?>  ?=(^verification p.j)
    p.j
  ::
  ++  payment-type
    |=  j=json
    ?>  ?=(%s -.j)
    ?>  ?=(?(%payment %refund %cancel) p.j)
    p.j
  ::
  ++  payment
    ^-  $-(json payment:res)
    %-  ot
    :~  id+so
        type+payment-type
        'merchantId'^so
        'merchantWalletId'^so
        amount+amount
        source+payment-source
        description+so
        status+payment-status
        ::verification+(mu verification)
        ::fees+amount
        'createDate'^so
        'updateDate'^so
    ==
  ::
  ++  payment-list
    ^-  $-(json (list payment:res))
    (ot data+(ar payment) ~)
  ::
  ++  ask
    ^-  $-(json ^ask)
    |=  j=json
    ^-  ^ask
    :-  *@p     ::  NOTE: this is replaced with our.bowl in merchant.hoon
    %.  j
    %-  of
    :~  card+so
        payment+so
        card-list+ul
        payment-list+ul
    ==
  ::
  +$  payment-details
    $:  idempotency-key=@tas
        key-id=(unit @tas)
        =^amount
        =^verification
        ver-succ-url=(unit @t)
        ver-fail-url=(unit @t)
        source=^payment-source
        description=(unit @t)
        encrypted-data=@t
        channel=(unit @t)
    ==
  ::
  ++  create-payment
    ^-  $-(json payment-details)
    %-  ot
    :~  %'idempotencyKey'^so
        %'keyId'^(mu so)
        amount+amount
        verification+verification
        %'verificationSuccessUrl'^(mu so)
        %'verificationFailureUrl'^(mu so)
        source+payment-source
        description+(mu so)
        %'encryptedData'^so
        channel+(mu so)
    ==
  ::
  +$  card-details
    $:  idempotency-key=@t
        encrypted-data=@t
        billing-details=[country=@t district=@t]
        exp-month=@ud
        exp-year=@ud
    ==
  ::
  ++  create-card
    ^-  $-(json card-details)
    %-  ot
    :~  %'idempotencyKey'^so
        %'encryptedData'^so
        %'billingDetails'^(ot country+so district+so ~)
        %'expMonth'^ni
        %'expYear'^ni
    ==
  --
--
