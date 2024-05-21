::  auth [tirrel]: user database and login system
::
/-  mailer, paywall, pipe, switchboard
/+  *auth, default-agent, dbug, verb, switchboard, *constants
::
::
|%
+$  card  $+(card card:agent:gall)
+$  state-2
  $+  state-2
  $:  services=services-2
      kyc=_|
      passbase-id=(unit [@t id-status])
      pending=(unit [price payout-status])
      payout-status=(unit payout-status)
      payout-info=(unit payout-brief)
      earnings=price
  ==
::
+$  state-3
  $+  state-3
  $:  =services
      kyc=_|
      passbase-id=(unit [@t id-status])
      pending=(unit [price payout-status])
      payout-status=(unit payout-status)
      payout-info=(unit payout-brief)
      earnings=price
  ==
+$  versioned-state
  $%  [%0 *]
      [%1 *]
      [%2 state-2]
      [%3 state-3]
  ==
--
::
=|  [%3 state-3]
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  =/  poke-wire  /up/(scot %p our.bowl)
  =/  =action:paywall  [%register-client our.bowl]
  :_  this
  [%pass poke-wire %agent [controller %paywall] %poke %paywall-action !>(action)]~
::
++  on-save   !>(state)
::
++  on-load
  |=  old-vase=vase
  =/  old-state  !<(versioned-state old-vase)
  =/  new-state=[%3 state-3]
    ?-  -.old-state
        %0  [%3 *state-3]
    ::
        %1  [%3 *state-3]
    ::
        %2
      =/  new-services=^services
        %-  ~(run by services.old-state)
        |=  s=service-2
        ^-  service
        =/  new-pricing=pricing
          %-  ~(run by pricing.s)
          |=  p=price
          ^-  [price (list @t)]
          [p ~]
        :*  users.s
            access-duration.s
            new-pricing
            title.s
            copy.s
            url.s
            shipping.s
        ==
      :*  %3
          new-services
          kyc.old-state
          passbase-id.old-state
          pending.old-state
          payout-status.old-state
          payout-info.old-state
          earnings.old-state
      ==
    ::
        %3  old-state
    ==
  :_  this(state new-state)
  ::
  =/  cards=(list card)
    %+  turn  ~(tap by services.new-state)
    |=  [name=@tas s=service]
    ^-  card
    =/  service-wire  /up/(scot %p our.bowl)/[name]
    =/  register=action:paywall
      [%register-service [our.bowl name] url.s pricing.s title.s copy.s shipping.s]
    [%pass service-wire %agent [controller %paywall] %poke %paywall-action !>(register)]
  =/  client-wire  /up/(scot %p our.bowl)
  =/  client-act=action:paywall  [%register-client our.bowl]
  %+  welp
    :~  [%pass client-wire %agent [controller %paywall] %poke %paywall-action !>(client-act)]
        [%pass /on-load %arvo %b %wait now.bowl]
    ==
  cards
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  ?|  (moon:switchboard our.bowl src.bowl)
          (moon:switchboard controller src.bowl)
      ==
  |^
  ?+    mark  (on-poke:def mark vase)
      %auth-action
    =^  cards  state
      (auth-action !<(action vase))
    [cards this]
  ==
  ::
  ++  auth-action
    |=  act=action
    ^-  (quip card _state)
    ?-  -.act
        %forward-id
      ~&  forward-id+p.act
      =/  poke-wire  /forward-id
      =/  =action:paywall
        [%passbase-id our.bowl p.act]
      =.  passbase-id  `[p.act %pending]
      :_  state
      [%pass poke-wire %agent [controller %paywall] %poke %paywall-action !>(action)]^~
    ::
        %add-payout
      =.  payout-status  `%pending
      =/  poke-wire  /add-payout
      =/  =action:paywall
        [%add-payout our.bowl p.act]
      :_  state
      [%pass poke-wire %agent [controller %paywall] %poke %paywall-action !>(action)]^~
    ::
        %trigger-payout
      ?>  (gte cents.earnings cents.q.act)
      =/  poke-wire  /trigger-payout
      =/  =action:paywall
        [%trigger-payout our.bowl q.act]
      :_  state
      [%pass poke-wire %agent [controller %paywall] %poke %paywall-action !>(action)]^~
    ::
        %add-service
      ?:  (~(has by services) p.act)  `state
      =/  poke-wire  /up/(scot %p our.bowl)/[p.act]
      =/  register=action:paywall
        [%register-service [our.bowl p.act] url.q.act pricing.q.act title.q.act copy.q.act shipping.q.act]
      :_  state(services (~(put by services) p.act q.act))
      :~  [%give %fact /all^~ %auth-update !>(act)]
          [%pass poke-wire %agent [controller %paywall] %poke %paywall-action !>(register)]
      ==
    ::
        %mod-details
      =/  srv=service   (~(got by services) p.act)
      =.  pricing.srv   q.act
      ~&  mod-details+pricing.srv
      =.  title.srv     r.act
      =.  copy.srv      s.act
      =.  shipping.srv  t.act
      =/  details=action:paywall
        [%set-details [our.bowl p.act] pricing.srv title.srv copy.srv shipping.srv]
      :_  state(services (~(put by services) p.act srv))
      :~  [%give %fact /all^~ %auth-update !>(act)]
          [%pass / %agent [controller %paywall] %poke %paywall-action !>(details)]
      ==
    ::
        %del-service
      ?.  (~(has by services) p.act)  `state
      :_  state(services (~(del by services) p.act))
      =/  wipe=action:paywall
        [%wipe-service [our.bowl p.act]]
      =/  leave-wire  /up/(scot %p our.bowl)/[p.act]
      :~  [%give %fact /all^~ %auth-update !>(act)]
          [%pass / %agent [controller %paywall] %poke %paywall-action !>(wipe)]
          [%pass leave-wire %agent [controller %paywall] %leave ~]
      ==
    ::
        %mod-access-duration
      =/  srv=service  (~(got by services) p.act)
      =.  access-duration.srv  q.act
      :-  [%give %fact /all^~ %auth-update !>(act)]^~
      state(services (~(put by services) p.act srv))
    ::
        %add-subscribers
      ~&  %add-subscribers
      =/  srv=service  (~(got by services) p.act)
      =.  users.srv
        %+  roll  ~(tap by q.act)
        |=  [[email=@t free=?] out=_users.srv]
        =/  new-user=user
          =/  old-user  (~(get by out) [%email email])
          ?~  old-user  [~ ~ free free %.y]
          [access-code.u.old-user expiry-date.u.old-user free free %.y]
        (~(put by out) [%email email] new-user)
      =/  add-users=action:paywall
        [%add-subscribers [our.bowl p.act] q.act]
      :_  state(services (~(put by services) p.act srv))
      :~  [%give %fact /all^~ %auth-update !>(act)]
          [%pass / %agent [controller %paywall] %poke %paywall-action !>(add-users)]
      ==
    ::
        %add-user
      =/  srv=service  (~(got by services) p.act)
      ?<  (~(has by users.srv) q.act)
      =.  users.srv  (~(put by users.srv) q.act r.act)
      :-  [%give %fact /all^~ %auth-update !>(act)]^~
      state(services (~(put by services) p.act srv))
    ::
        %del-user
      =/  srv=service  (~(got by services) p.act)
      ?>  (~(has by users.srv) q.act)
      =.  users.srv  (~(del by users.srv) q.act)
      :-  [%give %fact /all^~ %auth-update !>(act)]^~
      state(services (~(put by services) p.act srv))
    ::
        %set-access
      ~&  act
      =/  srv=service  (~(got by services) p.act)
      =.  users.srv
        ?^  usr=(~(get by users.srv) q.act)  users.srv
        (~(put by users.srv) q.act [~ ~ %.n %.n %.y])
      =/  usr=user     (~(got by users.srv) q.act)
      =/  new-cod=@q   token.act
      =/  new-exp=(unit @da)
        ?~  access-duration.srv  ~
        `(add now.bowl u.access-duration.srv)
      =.  users.srv  (~(put by users.srv) q.act [`new-cod new-exp security-clearance.usr free.usr mailing-list.usr])
      :_  state(services (~(put by services) p.act srv))
      =/  serial-id=path
        ?@  q.act
          /ship/(scot %p q.act)
        /email/[p.q.act]
      =/  new-wire=wire
        ^-  wire  ^-  (list @)
        %-  zing
        :~  /[p.act]
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
          :~  /[p.act]
              serial-id
              /(scot %q u.cod)
          ==
        [%pass old-wire %arvo %b %rest u.exp]^~
      =/  set-new-timer
        ?~  new-exp  ~
        [%pass new-wire %arvo %b %wait u.new-exp]^~
      (zing ~[del-old-timer set-new-timer])
    ::
        %ask-access
      =/  srv=service  (~(got by services) p.act)
      =/  usr=user     (~(got by users.srv) q.act)
      =/  new-cod      `@q`(rsh [3 60] eny.bowl)
      =/  new-exp=(unit @da)
        ?~  access-duration.srv  ~
        `(add now.bowl u.access-duration.srv)
      =.  users.srv  (~(put by users.srv) q.act [`new-cod new-exp security-clearance.usr free.usr mailing-list.usr])
      :_  state(services (~(put by services) p.act srv))
      =/  serial-id=path
        ?@  q.act
          /ship/(scot %p q.act)
        /email/[p.q.act]
      =/  new-wire=wire
        ^-  wire  ^-  (list @)
        %-  zing
        :~  /[p.act]
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
          :~  /[p.act]
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
          ?@  q.act
            ~  ::  TODO: send DM?
          (send-email p.q.act new-cod)^~
      ==
    ==
  ::
  ++  send-email
    |=  [email=@tas cod=@q]
    ^-  card
    =-  [%pass /email/[email] %agent [our.bowl %mailer] %poke -]
    :-  %mailer-action
    !>  ^-  action:mailer
    [%send-email (make-email email cod)]
  ::
  ++  make-email
    |=  [address=@tas cod=@q]
    ^-  email:mailer
    =/  pers=personalization-field:mailer
        [[address]~ ~ ~ ~ ~]
    :*  `from-field:mailer`['logan@tirrel.io' '~tirrel']
        `cord`'Your Studio login code'
        `(list content-field:mailer)`(email-body cod)^~
        `(list personalization-field:mailer)`~[pers]
    ==
  ::
  ++  email-body
    |=  cod=@q
    ^-  content-field:mailer
    :-  'text/html'
    =<  q
    %-  as-octt:mimes:html
    %-  en-xml:html
    ^-  manx
    ;div
      ;p: Your Studio login code is: {(trip (rsh [3 2] (scot %q cod)))}
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?.  ?=([%behn %wake *] sign-arvo)
    (on-arvo:def wire sign-arvo)
  ?:  ?=([%on-load ~] wire)
    =/  x  .^(update:switchboard %gx /(scot %p our.bowl)/switchboard/(scot %da now.bowl)/full/switchboard-update)
    ?>  ?=(%full -.x)
    =/  name=(unit term)
      %+  roll  ~(tap by sites.x)
      |=  [[n=@t s=site:switchboard] out=(unit term)]
      ?:  =(0 ~(wyt by plugins.s))
        ~
      =/  p=plugin-state:switchboard  +:(snag 0 ~(tap by plugins.s))
      `name.p
    :_  this
    ?~  name  ~
    =/  =action:pipe  [%build u.name]
    [%pass / %agent [our.bowl %pipe] %poke %pipe-action !>(action)]~
  ::
  ?~  wire  !!
  ?.  (~(has by services) i.wire)
    `this
  =/  srv  (~(got by services) i.wire)
  ?+    t.wire  !!
      [%ship @ @ ~]
    =/  =ship  (slav %p i.t.t.wire)
    ?~  user=(~(get by users.srv) ship)
      `this
    =.  users.srv  (~(put by users.srv) ship [~ ~ security-clearance.u.user free.u.user mailing-list.u.user])
    `this(services (~(put by services) i.wire srv))
  ::
      [%email @ @ ~]
    =/  email  `@tas`i.t.t.wire
    ?~  user=(~(get by users.srv) [%email email])
      `this
    =.  users.srv  (~(put by users.srv) [%email email] [~ ~ security-clearance.u.user free.u.user mailing-list.u.user])
    `this(services (~(put by services) i.wire srv))
  ==
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  |^
  ?+    path  (on-peek:def path)
      [%x %user @ %token @ ~]
    :^  ~  ~  %noun
    !>  ^-  (unit (pair email=@tas user))
    =/  token=@q  (slav %q i.t.t.t.t.path)
    (find-token token i.t.t.path)
  ::
      [%x %user @ ?(%email %ship) @ ~]
    :^  ~  ~  %noun
    !>  ^-  (unit user)
    ?~  srv=(~(get by services) i.t.t.path)
      ~
    ?:  ?=(%token i.t.t.t.path)
      !!
    ?:  ?=(%email i.t.t.t.path)
      (~(get by users.u.srv) [%email i.t.t.t.t.path])
    (~(get by users.u.srv) (slav %p i.t.t.t.t.path))
  ::
  ==
  ++  find-token
    |=  [token=@q service=@tas]
    ^-  (unit [@tas user])
    =/  srv  (~(get by services) service)
    ?~  srv  ~
    %+  roll  ~(tap by users.u.srv)
    |=  [[=id =user] out=(unit [@tas user])]
    ?^  out  out
    ?:  =([~ token] access-code.user)
      ?>  ?=(%email -.id)
      `[p.id user]
    out
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (moon:switchboard our.bowl src.bowl)
  ?+    path  (on-watch:def path)
      [%all ~]
    :_  this
    =/  kyc=update     [%set-kyc kyc]
    =/  cards=(list card)
      :-  [%give %fact ~ %auth-update !>(kyc)]
      %+  turn  ~(tap by services)
      |=  [p=@tas q=service]
      ^-  card
      =-  [%give %fact ~ %auth-update -]
      !>  ^-  update
      [%add-service p q]
    =/  payout=update  [%payout-status payout-status payout-info earnings pending]
    :_  cards
    [%give %fact ~ %auth-update !>(payout)]
  ==
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+  -.sign  (on-agent:def wire sign)
      %kick
    :_  this
    [%pass wire %agent [controller %paywall] %watch wire]~
  ::
      %poke-ack  :: poke ack from paywall app
    ?.  ?=([%up @ *] wire)
      `this
    :_  this
    [%pass wire %agent [controller %paywall] %watch wire]~
  ::
      %fact
    ?>  ?=(%paywall-update -.cage.sign)
    ?+  wire  !!
        [%up @ @ ~]
      =/  ship  (slav %p i.t.wire)
      =/  name  i.t.t.wire
      =/  =update:paywall  !<(update:paywall q.cage.sign)
      ~&  [%fact update]
      ?+  -.update  `this
      ::
::          %initial-service
::        ?~  service=(~(get by services) name)
::          `this
::        =.  users.u.service
::          %-  ~(rep by users.service.update)
::          |=  [[email=@t access-until=(unit @da)] out=(map id user)]
::          =/  u=user
::            :+  ~  ~
::            ?=(^ access-until)
::          (~(put by out) [%email email] u)
::        `this(services (~(put by services) name u.service))
      ::
          %subscription-status
        ?~  service=(~(get by services) name)
          `this
        =/  has-clearance  ?=(^ da.update)
        =/  new-user=user
          ?~  user=(~(get by users.u.service) [%email email.update])
            [~ ~ has-clearance free.update mailing-list.update]
          [access-code.u.user expiry-date.u.user has-clearance free.update mailing-list.update]
        =.  users.u.service
          (~(put by users.u.service) [%email email.update] new-user)
        =.  services  (~(put by services) name u.service)
        `this
      ==
    ::
        [%up @ ~]
      =/  ship  (slav %p i.t.wire)
      =/  =update:paywall  !<(update:paywall q.cage.sign)
      ?+  -.update  `this
          %payout-info
        =.  payout-status  status.update
        =.  payout-info    brief.update
        =.  earnings       earnings.update
        =.  pending        pending.update
        =/  upd=^update  [%payout-status payout-status payout-info earnings pending]
        :_  this
        [%give %fact /all^~ %auth-update !>(upd)]^~
      ::
          %kyc-status
        =.  kyc  kyc.update
        =/  upd=^update  [%set-kyc kyc.update]
        :_  this
        [%give %fact /all^~ %auth-update !>(upd)]^~
      ::
          %initial-client
        =.  kyc     kyc.client-data.update
        =.  payout-status  payout-status.client-data.update
        =.  payout-info    payout-info.client-data.update
        `this
      ::
          %passbase-status
        =.  passbase-id  `[id.update id-status.update]
        =.  kyc  ?=(%approved id-status.update)
        =/  upd=^update  [%set-kyc kyc]
        :_  this
        [%give %fact /all^~ %auth-update !>(upd)]^~
      ==
    ==
  ==
::
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
