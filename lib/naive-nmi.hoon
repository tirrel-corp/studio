/-  *naive-nmi
/+  nam=naive-market
|%
++  enjs
  =,  enjs:format
  |%
  ++  action
    |=  act=^action
    ^-  json
    %+  frond  -.act
    ?-  -.act
      %initiate-sale  ~
      %complete-sale  ~
      %set-api-key    ?~(key.act ~ s+u.key.act)
      %set-site       ~
    ==
  --
::
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  initiate-sale+(ot rid+so shp+ship:dejs:nam sel+selector:dejs:nam ~)
        complete-sale+so
        set-api-key+(mu so)
        set-site+(mu (ot host+so suffix+(mu so) ~))
    ==
  --
--
