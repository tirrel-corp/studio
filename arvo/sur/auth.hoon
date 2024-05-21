|%
+$  price      [cents=@ud currency=%'USD']
+$  pricing    (map @t [=price copy=(list @t)])
+$  pricing-2  (map @t price)
::
+$  services    (map @tas service)
+$  services-2  (map @tas service-2)
+$  service
  $:  users=(map id user)
      access-duration=(unit @dr)
      =pricing
      title=@t
      copy=(list @t)
      url=@t
      shipping=?
  ==
+$  service-2
  $:  users=(map id user)
      access-duration=(unit @dr)
      pricing=pricing-2
      title=@t
      copy=(list @t)
      url=@t
      shipping=?
  ==
::
+$  id
  $@  @p
  [%email p=@tas]
::
+$  user
  $:  access-code=(unit @q)
      expiry-date=(unit @da)
      security-clearance=?
      free=?
      mailing-list=?
  ==
::
+$  update
  $%  [%add-service p=@tas q=service]
      [%del-service p=@tas]
      [%mod-access-duration p=@tas q=(unit @dr)]
      [%mod-details p=@tas q=pricing r=@t s=(list @t) t=?]
      [%add-subscribers p=@tas q=(map @t ?)]
      [%add-user p=@tas q=id r=user]
      [%del-user p=@tas q=id]
      [%ask-access p=@tas q=id]
      [%set-access p=@tas q=id token=@q]
      [%set-kyc p=?]
      $:  %payout-status
          p=(unit payout-status)
          q=(unit payout-brief)
          r=price  :: earnings
          s=(unit [a=price b=payout-status])  :: pending payout
      ==
  ==
::
+$  action
  $%  [%add-service p=@tas q=service]
      [%del-service p=@tas]
      [%mod-access-duration p=@tas q=(unit @dr)]
      [%mod-details p=@tas q=pricing r=@t s=(list @t) t=?]
      [%add-subscribers p=@tas q=(map @t ?)]
      [%add-user p=@tas q=id r=user]
      [%del-user p=@tas q=id]
      [%ask-access p=@tas q=id]
      [%set-access p=@tas q=id token=@q]
      [%add-payout p=payout-data]
      [%trigger-payout q=price]
      [%forward-id p=@t]
  ==
::
+$  payout-data
  $%  [%usdc address=@t]
      [%wire =payout-form]
  ==
::
+$  payout-brief
  $%  [%usdc id=@t address=@t]
      [%wire id=@t acct=@t]
  ==
::
+$  payout-status
  ?(%complete %pending %failed)
::
+$  payout-form
  $:  account-number=@t
      routing-number=@t
      =billing-details
      =bank-address
  ==
::
+$  billing-details
  $:  name=@t
      city=@t
      country=@t
      line-1=@t
      line-2=(unit @t)
      district=(unit @t)
      postal-code=@t
  ==
::
+$  bank-address
  $:  name=(unit @t)
      city=(unit @t)
      country=@t
      line-1=(unit @t)
      line-2=(unit @t)
      district=(unit @t)
  ==
::
++  wire-response
  $:  id=@t
      status=payout-status
  ==
::
+$  id-status
  $?  %created
      %processing
      %pending
      %approved
      %declined
  ==
--
