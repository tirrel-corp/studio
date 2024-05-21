/-  *resource, auth, email
|%
::
++  action
  $%  [%register-service =resource url=@t =pricing title=@t copy=(list @t) shipping=?]
      [%wipe-service =resource]
      [%register-client =ship]
      [%set-details =resource =pricing title=@t copy=(list @t) shipping=?]
      [%set-kyc =resource kyc=?]
      [%add-payout =ship =payout-data:auth]
      [%trigger-payout =ship =price:auth]
      [%passbase-id ship=@p id=@t]
      [%send-email email=email-fields:email]
      [%add-subscribers =resource subs=(map @t ?)]
      [%pipe-data =resource agg=(unit agg-data)]
  ==
::
+$  pricing      (map @t [=price:auth copy=(list @t)])
+$  pricing-0    (map @t price:auth)
::
+$  user-key
  [email=@t =resource]
::
+$  client-data
  $+  client-data
  $:  kyc=?
      passbase-id=(unit [@t id-status:auth])
      pending-payout=(unit [price:auth payout-status:auth])
      payout-status=(unit payout-status:auth)
      payout-info=(unit payout-brief:auth)
      services=(set resource)
      earnings=price:auth
  ==
::
+$  agg-data
  $:  full-url=@t
      headline=(unit @t)
      profile=(unit @t)
      header=(unit @t)
      last-post=(unit [p=@t q=@t r=@t s=@da])  :: path, title, image, date
  ==
::
+$  service
  $+  service
  $:  =resource
      client-patp=@p
      url=@t
      =pricing
      users=(set @t)
      title=@t
      copy=(list @t)
      shipping=?
      agg=(unit agg-data)
  ==
::
+$  service-1
  $+  service-1
  $:  =resource
      client-patp=@p
      url=@t
      =pricing
      users=(set @t)
      title=@t
      copy=(list @t)
      shipping=?
  ==
::
+$  service-0
  $+  service-0
  $:  =resource
      client-patp=@p
      url=@t
      pricing=pricing-0
      users=(set @t)
      title=@t
      copy=(list @t)
      shipping=?
  ==
::
++  update
  $%  [%subscription-status email=@t da=(unit @da) free=? mailing-list=?]
      [%kyc-status kyc=?]
      [%initial-service =service]
      [%initial-client =client-data]
      [%passbase-status id=@t =id-status:auth]
      $:  %payout-info
          status=(unit payout-status:auth)
          brief=(unit payout-brief:auth)
          pending=(unit [price:auth payout-status:auth])
          earnings=price:auth
      ==
  ==
--
