/-  *mailer
|%
++  dejs
  =,  dejs:format
  |%
  ++  action
    ^-  $-(json ^action)
    %-  of
    :~  [%send-email email]
        [%set-creds (ot api-key+(mu so) email+(mu so) ship-url+(mu so) ~)]
        [%unset-creds (ot api-key+bo email+bo ship-url+bo ~)]
        [%add-list (ot name+so list+(as so) ~)]
        [%del-list (ot name+so ~)]
        [%add-recipients (ot name+so list+(as so) ~)]
        [%del-recipients (ot name+so list+(as so) ~)]
    ==
  ++  email
    %-  ot
    :~  from+(ot email+so name+so ~)
        subject+so
        content+(ar (ot type+so value+so ~))
        personalizations+(ar personalization)
    ==
  ++  personalization
    %-  ot
    :~  to+(ar so)
        headers+(as (at so so ~))
        substitutions+(ar (at so so ~))
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
    ?-  -.u
        %initial
      %-  pairs
      :~  creds+(creds creds.u)
          mailing-lists+(mailing-lists ml.u)
      ==
    ==
  ::
  ++  creds
    |=  [api-key=(unit @t) email=(unit @t) ship-url=(unit @t)]
    ^-  json
    %-  pairs:enjs:format
    :~  email+?~(email ~ s+u.email)
        ship-url+?~(ship-url ~ s+u.ship-url)
    ==
  ::
  ++  mailing-lists
    |=  m=(map term ^mailing-list)
    ^-  json
    :-  %o
    (~(run by m) mailing-list)
  ::
  ++  mailing-list
    |=  m=^mailing-list
    ^-  json
    :-  %a
    %+  turn  ~(tap by m)
    |=  [w=@t *]
    [%s w]
  --
--
