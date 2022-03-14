::  magic [tirrel]: user database and login system
::
/-  *magic
/+  default-agent, dbug, verb
|%
+$  card  card:agent:gall
+$  state-0
  $:  =services
  ==
--
::
=|  [%0 state-0]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this
++  on-save   !>(state)
++  on-load
  |=  old-vase=vase
  =/  old-state  !<([%0 state-0] old-vase)
  `this(state old-state)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
      %magic-update
    =^  cards  state
      (magic-update !<(update vase))
    [cards this]
  ==
  ::
  ++  magic-update
    |=  upd=update
    ^-  (quip card _state)
    ?-  -.upd
        %add-service
      ?<  (~(has by services) p.upd)
      `state(services (~(put by services) p.upd q.upd))
    ::
        %del-service
      ?>  (~(has by services) p.upd)
      `state(services (~(del by services) p.upd))
    ::
        %mod-access-duration
      =/  srv=service  (~(got by services) p.upd)
      =.  access-duration.srv  q.upd
      `state(services (~(put by services) p.upd srv))
    ::
        %add-user
      =/  srv=service  (~(got by services) p.upd)
      ?<  (~(has by users.srv) q.upd)
      =.  users.srv  (~(put by users.srv) q.upd r.upd)
      `state(services (~(put by services) p.upd srv))
    ::
        %del-user
      =/  srv=service  (~(got by services) p.upd)
      ?>  (~(has by users.srv) q.upd)
      =.  users.srv  (~(del by users.srv) q.upd)
      `state(services (~(put by services) p.upd srv))
    ::
        %ask-access
      =/  srv=service      (~(got by services) p.upd)
      =/  usr=user  (~(got by users.srv) q.upd)
      =/  new-cod  `@q`(rsh [3 60] eny.bowl)
      =/  new-exp=(unit @da)
        ?~  access-duration.srv  ~
        `(add now.bowl u.access-duration.srv)
      =.  users.srv  (~(put by users.srv) q.upd [`new-cod new-exp])
      :_  state(services (~(put by services) p.upd srv))
      =/  serial-id=path
        ?@  q.upd
          /ship/(scot %p q.upd)
        /email/[p.q.upd]/(scot %p q.q.upd)
      =/  new-wire=wire
        ^-  wire  ^-  (list @)
        %-  zing
        :~  /[p.upd]
            serial-id
            /(scot %q new-cod)
        ==
      =*  cod  access-code.usr
      =*  exp  expiry-date.usr
      =/  del-old-timer
        ?~  cod  ~
        ?~  exp  ~
        =/  old-wire=wire
          ^-  wire  ^-  (list @)
          %-  zing
          :~  /[p.upd]
              serial-id
              /(scot %q u.cod)
          ==
        [%pass old-wire %arvo %b %rest u.exp]^~
      =/  set-new-timer
        ?~  new-exp  ~
        [%pass new-wire %arvo %b %wait u.new-exp]^~
      %-  zing
      :~  del-old-timer
          set-new-timer
      ==
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%behn %wake *] sign-arvo)
    (on-arvo:def wire sign-arvo)
  ?~  wire  !!
  ?.  (~(has by services) i.wire)
    `this
  =/  srv  (~(got by services) i.wire)
  ?+    t.wire  !!
      [%ship @ @ ~]
    =/  =ship  (slav %p i.t.t.wire)
    ?.  (~(has by users.srv) ship)
      `this
    =.  users.srv  (~(put by users.srv) ship [~ ~])
    `this(services (~(put by services) i.wire srv))
  ::
      [%email @ @ @ ~]
    =/  email  (slav %tas i.t.t.wire)
    =/  =ship  (slav %p i.t.t.t.wire)
    ?.  (~(has by users.srv) [%email email ship])
      `this
    =.  users.srv  (~(put by users.srv) [%email email ship] [~ ~])
    `this(services (~(put by services) i.wire srv))
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--