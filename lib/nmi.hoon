/-  *nmi
/+  nam=shop
|%
++  enjs
  =,  enjs:format
  |%
  ++  action
    |=  act=^action
    ^-  json
    %+  frond  -.act
    ?-  -.act
      %initiate-sale     ~
      %complete-sale     ~
      %set-api-key       ?~(key.act ~ s+u.key.act)
      %set-backend-url   ~
      %set-redirect-url  ~
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
        set-backend-url+(mu (ot host+so suffix+(mu so) ~))
        set-redirect-url+(mu so)
    ==
  --
--
