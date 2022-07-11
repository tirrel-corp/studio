|%
+$  ask
  $%  [%card card-id=@t session-id=@t]
      [%payment payment-id=@t session-id=@t]
      $:  %create-card
          =metadata
          idempotency-key=@tas
          key-id=@tas
          encrypted-data=@t
          =billing-details
          exp-month=@ud
          exp-year=@ud
      ==
    ::
      $:  %create-payment
          =metadata
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
::
+$  request
  $%  [%ping ~]
      [%config ~]
      [%public-key ~]
    ::
      [%subscription-list ~]
      [%create-subscription endpoint=@t]
      [%remove-subscription id=@tas]
  ==
::
+$  session-id  @t
::
+$  update
  $%  [%public-key p=public-key:res]
      [%payment p=session-id q=payment:res]
      [%card p=session-id q=pay-card:res r=(unit metadata)]
      [%error p=session-id q=error:res]
  ==
::
+$  billing-details
  $:  name=@t
      city=@t
      country=@t
      line1=@t
      line2=(unit @t)
      district=(unit @t)
      postal-code=@t
  ==
::
+$  metadata
  [email=@t phone=(unit @t) session-id=@t ip-address=@t]
::
+$  amount  [integer=@ud decimal=@ud currency=@t]
+$  verification  ?(%none %cvv %'three_d_secure')
+$  payment-source
  [id=@tas type=?(%card %ach)]
::
++  res
  |%
  +$  error  [code=@ud msg=@t]
  +$  ping   @t
  +$  config  @t
  +$  public-key  [id=@t key=@t]
  +$  cvv  ?(%'not-requested' %pass %fail %unavailable %pending)
  +$  card-status  ?(%pending %complete %failed)
  +$  card-network  ?(%'VISA' %'MASTERCARD' %'AMEX' %'UNKNOWN')
  +$  risk-decision  ?(%approved %denied %review)
  +$  pay-card-list   (list pay-card)
  +$  pay-card
    $:  id=@t
        status=card-status
        location=[country=@t district=@t]
        exp-month=@ud
        exp-year=@ud
        network=card-network
        bin=@t
        issuer-country=@t
        fingerprint=@t
        verification=[avs=@t =cvv]
        create-date=@t
        update-date=@t
    ==
  ::
  +$  payment-status
    ?(%pending %confirmed %paid %failed)
  ::
  +$  payment
    $:  id=@t
        type=?(%payment %refund %cancel)
        merchant-id=@t
        merchant-wallet-id=@t
        =amount
        source=payment-source
        description=@t
        status=payment-status
        ::verification=(unit verification)
        ::fees=amount
        create-date=@t
        update-date=@t
    ==
  --
--
