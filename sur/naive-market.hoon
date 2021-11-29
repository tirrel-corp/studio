/+  *jog
|%
+$  address  @ux
+$  price  [amount=@ud currency=@ta]
::
+$  selector  (each (set ship) @ud)
::
+$  referral-policy  [number-referrals=@ud =price]
+$  record           [=ship =price ref=(unit referral-policy)]
+$  records          (set record)
::
+$  config        [prv=@ proxy=?(%own %spawn)]
+$  star-configs  (map ship config)
::
+$  update
  $%  [%add-star-config who=ship =config]
      [%del-star-config who=ship]
      [%set-price =price]
      [%set-referrals ref=(unit referral-policy)]
    ::
      [%spawn-ships who=ship sel=selector]
      [%sell-ships who=ship sel=selector to=address]
      [%sell-from-referral who=ship]
  ==
::
+$  sold-ship-to-date  (map ship time)
+$  for-sale           (jug ship ship)
+$  keys               [encrypt=@ auth=@]
+$  ship-to-keys       (map ship keys)
::
+$  sold-ships         ((jog time record) gth)
++  his                ((jo time record) gth)
--

