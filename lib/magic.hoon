/-  *magic
|%
++  dejs
  =,  dejs:format
  |%
  ++  update
    ^-  $-(json ^update)
    %-  of
    :~  [%add-service (ot name+so service+service ~)]
        [%del-service so]
        [%mod-access-duration (ot name+so duration+(mu ri) ~)]
        [%add-user (ot name+so id+id user+user ~)]
        [%del-user (ot name+so id+id ~)]
        [%ask-access (ot name+so id+id ~)]
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
  ++  user  (ot access-code+ul expiry-date+ul ~)
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
    ==
  --
--
