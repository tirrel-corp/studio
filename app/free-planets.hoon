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
=|  seller=ship
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  :_  this
  [%pass /eyre %arvo %e %connect [~ /planets] dap.bowl]^~
::
++  on-save   !>(seller)
++  on-load
  |=  old-vase=vase
  `this(seller !<(@p old-vase))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  |^
  ?+    mark  (on-poke:def mark vase)
    %noun     `this(seller !<(@p vase))
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
    ++  handle-post-request
      =*  srv  server
      |=  [headers=header-list:http req=request-line:srv bod=(unit octs)]
      ?~  bod
        `[[400 ~] ~]
      =/  =tape  (trip `@t`q.u.bod)
      =/  password-i  (need (find "&password=" tape))
      =/  email=@t
        %-  crip
        %-  need
        %-  de-urlt:html
        %-  trip
        (cut 3 [6 (sub password-i 6)] (crip tape))
      =/  password=@t
        %-  crip
        %-  need
        %-  de-urlt:html
        %-  trip
        =-  (cut 3 [- (sub (lent tape) -)] (crip tape))
        (add 10 password-i)
      =/  =price:nam
        (need (scry-for %shop (unit price:nam) /price))
      ?>  ?=(%| -.price)
      ?.  (~(has in p.price) password)
        =-  `[[200 ~] ~ -]
        %-  manx-to-octs:srv
        ;html
          ;body: Wrong password!
        ==
      =/  inventory
        (scry-for %shop (set [ship @q]) /inventory/(scot %p seller))
      ?.  (gth ~(wyt in inventory) 0)
        =-  `[[200 ~] ~ -]
        %-  manx-to-octs:srv
        ;html
          ;body: Sorry, we ran out of planets!
        ==
      :_  =-  [[201 ~] ~ -]
          %-  manx-to-octs:srv
          ;html
            ;body: Success, check your email!
          ==
      =-  [%pass /post-req/[eyre-id] %agent [our.bowl %shop] %poke -]~
      :-  %shop-update
      !>  ^-  update:nam
      [%sell-ships seller %|^1 now.bowl email `password]
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      :-  [200 [['content-type' 'text/html'] ~]]
      :-  ~
      %-  manx-to-octs:srv
      ;html.sans-serif.f4
        ;head
          ;meta(charset "utf-8");
          ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
          ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
        ==
        ;body.absolute.w-100.h-100.flex.flex-column.justify-center.items-center
          ;form.mw6.pa2(method "POST", action "/planets")
            ;h3: Want a free planet? Enter your email and a code.
            ;span.w-100.flex.justify-between.items-center.mv3
              ;label.b: Email
              ;input.w-60.ba.pa2(name "email");
            ==
            ;span.w-100.flex.justify-between.items-center.mv3
              ;label.b: Code
              ;input.w-60.ba.pa2(name "password");
            ==
            ;input.w-100.bg-black.white.bn.pv2.ph4.dim.pointer(type "submit");
          ==
        ==
      ==
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
