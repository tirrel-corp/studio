/-  *circle
/+  server
|_  [api-url=@t api-key=@t]
++  req
  |%
  ++  get-ping
    %+  req-to-card  /ping
    :^  %'GET'  (cat 3 api-url '/ping')
      header
    ~
  ::
  ++  get-configuration
    %+  req-to-card  /configuration
    :^  %'GET'  (cat 3 api-url '/v1/configuration')
      header
    ~
  ::
  ++  get-subscription-list
    %+  req-to-card  /subscription-list
    :^  %'GET'  (cat 3 api-url '/v1/notifications/subscriptions')
      header
    ~
  ::
  ++  get-public-key
    ::  TODO: publish this value to merchant servers for them to
    ::  cache. Circle recommends invalidating the cache every 24
    ::  hours.
    ::
    %+  req-to-card  /public-key
    :^  %'GET'  (cat 3 api-url '/v1/encryption/public')
      header
    ~
  ::
  ++  get-payment
    |=  [=ship pay-id=@tas]
    %+  req-to-card  /ask/(scot %p ship)/payment/[pay-id]
    :^  %'GET'  (rap 3 api-url '/v1/payments/' pay-id ~)
      header
    ~
  ::
  ++  get-payment-list
    |=  =ship
    %+  req-to-card  /ask/(scot %p ship)/payment-list
    :^  %'GET'  (cat 3 api-url '/v1/payments')
      header
    ~
  ::
  ++  create-payment
    |=  $:  =ship
        $:  =metadata
            idempotency-key=@tas
            key-id=@tas
            =amount
            =verification
            ver-succ-url=(unit @t)
            ver-fail-url=(unit @t)
            source=payment-source
            description=(unit @t)
            encrypted-data=@t
            channel=(unit @t)
        ==  ==
    %+  req-to-card  /ask/(scot %p ship)/create-payment/[idempotency-key]
    :^  %'POST'  (cat 3 api-url '/v1/payments')
      header
    :-  ~
    %-  json-to-octs:server
    %-  pairs:enjs:format
    %-  zing
    ^-  (list (list [@t json]))
    :~  ['idempotencyKey' s+idempotency-key]^~
        ['keyId' s+key-id]^~
        [%metadata (metadata:enjs metadata)]^~
        [%amount (amount:enjs amount)]^~
        ['autoCapture' b+&]^~
        [%verification s+verification]^~
        ?~(ver-succ-url ~ ['verificationSuccessUrl' s+u.ver-succ-url]^~)
        ?~(ver-fail-url ~ ['verificationFailureUrl' s+u.ver-fail-url]^~)
        [%source (payment-source:enjs source)]^~
        ?~(description ~ [%description s+u.description]^~)
      ::
        ?:  =((met 3 encrypted-data) 0)  ~
        ['encryptedData' s+encrypted-data]^~
      ::
        ?~(channel ~ [%channel s+u.channel]^~)
    ==
  ::
  ++  get-card
    |=  [=ship card-id=@tas]
    %+  req-to-card  /ask/(scot %p ship)/card/[card-id]
    :^  %'GET'  (rap 3 api-url '/v1/cards/' card-id ~)
      header
    ~
  ::
  ++  get-card-list
    |=  =ship
    %+  req-to-card  /ask/(scot %p ship)/card-list
    :^  %'GET'  (cat 3 api-url '/v1/cards')
      header
    ~
  ::
  ++  create-card
    |=  $:  =ship
        $:  =metadata
            idempotency-key=@tas
            key-id=@tas
            encrypted-data=@t
            =billing-details
            exp-month=@ud
            exp-year=@ud
        ==  ==
    %+  req-to-card  /ask/(scot %p ship)/create-card/[idempotency-key]
    :^  %'POST'  (cat 3 api-url '/v1/cards')
      header
    :-  ~
    %-  json-to-octs:server
    %-  pairs:enjs:format
    %-  zing
    ^-  (list (list [@t json]))
    :~  ['idempotencyKey' s+idempotency-key]^~
        ['keyId' s+key-id]^~
        ['encryptedData' s+encrypted-data]^~
        ['billingDetails' (billing-details:enjs billing-details)]^~
        ['expMonth' n+(rsh [3 2] (scot %ui exp-month))]^~
        ['expYear' n+(rsh [3 2] (scot %ui exp-year))]^~
        [%metadata (metadata:enjs metadata)]^~
    ==
  ::
  ++  create-subscription
    |=  endpoint=@t
    %+  req-to-card  /create-subscription
    :^  %'POST'  (cat 3 api-url '/v1/notifications/subscriptions')
      header
    :-  ~
    %-  json-to-octs:server
    %-  pairs:enjs:format
    [%endpoint s+endpoint]^~
  ::
  ++  remove-subscription
    |=  id=@tas
    %+  req-to-card  /remove-subscription/[id]
    :^  %'DELETE'  (rap 3 api-url '/v1/notifications/subscriptions/' id ~)
      header
    ~
  ::
  ++  enjs
    =,  enjs:format
    |%
    ++  metadata
      |=  m=^metadata
      ^-  json
      %-  pairs
      %-  zing
      :~  [%email s+email.m]^~
          ?~(phone.m ~ [%phone s+u.phone.m]^~)
          [%'sessionId' s+session-id.m]^~
          [%'ipAddress' s+ip-address.m]^~
      ==
    ::
    ++  amount
      |=  a=^amount
      ^-  json
      %-  pairs
      :~  :+  %amount  %s
          %+  rap  3
          :~  (rsh [3 2] (scot %ui integer.a))
              '.'
              (rsh [3 2] (scot %ui (mod decimal.a 100)))
          ==
        ::
          [%currency s+currency.a]
      ==
    ::
    ++  payment-source
      |=  p=^payment-source
      ^-  json
      %-  pairs
      :~  [%id s+id.p]
          [%type s+type.p]
      ==
    ::
    ++  billing-details
      |=  b=^billing-details
      ^-  json
      %-  pairs
      %-  zing
      :~  [%name s+name.b]^~
          [%city s+city.b]^~
          [%country s+country.b]^~
          [%line1 s+line1.b]^~
          ?~(line2.b ~ [%line2 s+u.line2.b]^~)
          ?~(district.b ~ [%district s+u.district.b]^~)
          ['postalCode' s+postal-code.b]^~
      ==
    --
  --
::
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
  --
::
++  req-to-card
  |=  [=wire =request:http]
  ^-  card:agent:gall
  =-  [%pass wire %arvo %i %request -]
  [request *outbound-config:iris]
::
++  header
  :~  ['Content-type' 'application/json']
      ['Accept' 'application/json']
      ['Authorization' (cat 3 'Bearer ' api-key)]
  ==
--
