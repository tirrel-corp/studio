/+  *jog
|%
+$  address  @ux
+$  price  [amount=@ud currency=@ta]
::
+$  selector  (each (set ship) @ud)
::
+$  record   [=ship =price email=@t ticket=@q]
+$  records  (set record)
::
+$  config        [prv=@ proxy=?(%own %spawn)]
+$  star-configs  (map ship config)
::
+$  update
  $%  [%add-star-config who=ship =config]
      [%del-star-config who=ship]
      [%set-price =price]
    ::
      [%spawn-ships who=ship sel=selector]
      [%sell-ships who=ship sel=selector time=@da email=@t session=@t]
  ==
::
+$  sold-ship-to-date  (map ship time)
+$  for-sale           (map ship (map ship @q))
+$  pending-txs        (map ship (map ship [@q (list @ux)]))
+$  sold-ships         ((jog time record) gth)
++  his                ((jo time record) gth)
::
++  his-0              ((jo time record-0) gth)
+$  price-0       (each [amount=@ud currency=@ta] (set @t))
+$  record-0      [=ship price=price-0 email=@t ticket=@q]
+$  sold-ships-0  ((jog time record-0) gth)
--

