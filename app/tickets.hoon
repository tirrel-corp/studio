/-  circle
/+  default-agent, dbug, verb, server
|%
+$  card  card:agent:gall
::
+$  ticket
  $:  token=@uv
      used=?
      =ticket-class
  ==
::
+$  ticket-class  ?(%1 %2 %3)
::
++  price
  ^-  (map ticket-class amount:circle)
  %-  ~(gas by *(map ticket-class amount:circle))
  :~  1+[20 0 'USD']
  ==
::
+$  state-0
  $:  tickets=(map @uv ticket)
  ==
++  provider  ~bus  :: hardcode tirrel gateway moon
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    mjs   ~(. merchant-js public-key)
::
++  on-init
  :_  this
  :~  [%pass /eyre %arvo %e %connect [~ /merchant] dap.bowl]
      =-  [%pass - %agent [provider %gateway] %watch -]
      /master/(scot %p our.bowl)
  ==
::
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  :_  this(state !<(state-0 old-vase))
  ~
::  =-  [%pass - %agent [provider %gateway] %watch -]^~
::  /master/(scot %p our.bowl)
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  (on-poke:def mark vase)
  ::
      %noun
    :_  this
    =-  [%pass - %agent [provider %gateway] %watch -]^~
    /master/(scot %p our.bowl)
  ::
      %handle-http-request
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    =|  sim=simple-payload:http
    =^  cards  sim
      (handle-http-request eyre-id inbound-request)
    :_  this
    %+  weld  cards
    (give-simple-payload:app:server eyre-id sim)
  ==
  ::
  ++  handle-http-request
    |=  [eyre-id=@ta req=inbound-request:eyre]
    ^-  [(list card) simple-payload:http]
    =/  req-line  (parse-request-line:server url.request.req)
    ?+  site.req-line  `not-found:gen:server
        [%redeem ~]
      :: XX replace these  not-founds with a page that directs back to main page
      ?~  b64tok=(get-header:http 'token' args.req-line)
        `not-found:gen:server
      ?~  token=(~(de base64:mimes:html | &) u.b64tok)
        `not-found:gen:server
      ?~  ticket=(~(get by tickets) q.u.token)
        `not-found:gen:server
      ?:  used.u.ticket
        `not-found:gen:server
      =/  success=manx
        ;div: ticket valid!
      =.  used.u.ticket  %.y
      =.  tickets  (~(put by tickets) q.u.token u.ticket)
      `(manx-response:gen:server success)
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  (on-watch:def path)
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?.  ?=([%master @ ~] wire)
    (on-agent:def wire sign)
  ?+    -.sign  (on-agent:def wire sign)
      %fact
    =+  !<(upd=update:circle q.cage.sign)
    ?.  ?=(%payment -.upd)
      `this
    =/  token=@uv  (shas 'salt' id.q.upd)
    ?-  type.q.upd
        %payment
      ?:  %.y  ::=(amount.q.upd (~(got by price) %1))
        =/  =ticket  [token %.n %1]
        =.  tickets  (~(put by tickets) token ticket)
        `this
      `this
    ::
        %refund  `this(tickets (~(del by tickets) token))
        %cancel  `this(tickets (~(del by tickets) token))
    ==
  ::
      %kick
    :_  this
    =-  [%pass - %agent [provider %gateway] %watch -]^~
    /master/(scot %p our.bowl)
  ==
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?:  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl "bind rejected!" binding.sign-arvo]
    [~ this]
  (on-arvo:def wire sign-arvo)
::
++  on-peek  on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
