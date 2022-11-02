/-  *auth
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
        [%ask-access (ot name+so id+id opt+opt ~)]
    ==
  ++  opt
    |=  jon=json
    ^-  (unit [@t @p])
    ?~  jon  ~
    :-  ~
    ((ot ref+so patp+(se %p) ~) jon)
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
::
++  enjs
  =,  enjs:format
  |%
  ++  update
    |=  u=^update
    ^-  json
    %+  frond  -.u
    ?+  -.u  !!
        %add-service
      %-  pairs
      :~  name+s+p.u
          service+(service q.u)
      ==
    ::
        %del-service
      %-  pairs
      :~  name+s+p.u
      ==
    ::
        %mod-access-duration
      %-  pairs
      :~  name+s+p.u
          duration+?~(q.u ~ n+(rsh [3 2] (scot %ui (div u.q.u ~s1))))
      ==
    ::
        %add-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ::
        %del-user
      %-  pairs
      :~  name+s+p.u
          :-  %user
          ?>  ?=(^ q.u)
          s+p.q.u
      ==
    ==
  ::
  ++  opt
    |=  o=(unit [@t @p])
    ^-  json
    ?~  o  ~
    %-  pairs
    :~  ref+s+-.u.o
        patp+s+(scot %p +.u.o)
    ==
  ::
  ++  service
    |=  s=^service
    ^-  json
    =*  ad  access-duration.s
    %-  pairs
    :~  users+(users users.s)
        duration+?~(ad ~ n+(rsh [3 2] (scot %ui (div u.ad ~s1))))
    ==
  ::
  ++  users
    |=  u=(map id user)
    ^-  json
    :-  %a
    ::%-  ~(gas by *(map @t json))
    %+  turn  ~(tap by u)
    |=  [p=id q=user]
    ^-  json
    ?>  ?=(^ p)
    s+p.p
  --
--
