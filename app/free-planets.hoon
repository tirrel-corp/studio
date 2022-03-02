::  free-planets [tirrel]: example of a site that allows giving free
::  planets away if you know the password
::
::
/-  *nmi
/+  default-agent, dbug, verb, server
|%
+$  card  card:agent:gall
--
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this
++  on-save   !>(~)
++  on-load
  |=  old-vase=vase
  `this
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
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
    |=  [eyre-id=@ta =inbound-request:eyre]
    |^
    ^-  [(list card) simple-payload:http]
    =/  req-line=request-line:server
      %-  parse-request-line:server
      url.request.inbound-request
    =*  req-head  header-list.request.inbound-request
    =*  req-body  body.request.inbound-request
    ?+    method.request.inbound-request  `not-found:gen:server
      %'GET'   `(handle-get-request req-head req-line)
      %'POST'  (handle-post-request req-head req-line req-body)
    ==
    ::
    +$  partial-action
      $%  [%initiate-sale who=ship sel=selector:nam]
          [%complete-sale token=cord]
      ==
    ::
    ++  handle-post-request
      =*  srv  server
      |=  [headers=header-list:http req=request-line:srv bod=(unit octs)]
      ?~  bod
        `[[400 ~] ~]
      ?~  maybe-json=(de-json:html q.u.bod)
        `[[400 ~] ~]
      =/  act=(each partial-action tang)
        (mule |.((dejs u.maybe-json)))
      ?:  ?=(%| -.act)
        `[[400 ~] ~]
      :_  [[201 ~] `(json-to-octs:srv s+'example-data')]
      =-  [%pass /post-req/[eyre-id] %agent [our.bowl %shop] %poke -]~
      :-  %shop-update
      !>(~)
      ::!>(`update:nam`[%sell-ships who.info.tx sel.info.tx time email ~])
    ::
    ++  dejs
      =,  dejs:format
      |^
      %-  of
      :~  [%initiate-sale init-sale]
          [%complete-sale so]
      ==
      ::
      ++  init-sale
        %-  ot
        :~  who+(su ;~(pfix sig fed:ag))
            sel+selector
        ==
      ::
      ++  selector
        |=  jon=json
        ^-  selector:nam
        ?>  ?=(^ jon)
        ?+  -.jon  !!
          %n  [%| (ni jon)]
          %a  [%& ((as (su ;~(pfix sig fed:ag))) jon)]
        ==
      --
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      ?.  ?=(^ ext.req)        not-found:gen:srv
      :-  [200 [['content-type' 'text/html'] ~]]
      :-  ~
      %-  manx-to-octs:srv
      *manx
    --
  ::
  ++  scry-for
    |*  [dap=term =mold =path]
    .^  mold
      %gx
      (scot %p our.bowl)
      dap
      (scot %da now.bowl)
      (snoc `^path`path %noun)
    ==
  --
::
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?:  ?=([%eyre %bound *] sign-arvo)
    ~?  !accepted.sign-arvo
      [dap.bowl "bind rejected!" binding.sign-arvo]
    [~ this]
  (on-arvo:def wire sign-arvo)
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?:  ?=([%http-response *] path)
    `this
  (on-watch:def path)
::
++  on-peek  on-peek:def
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
