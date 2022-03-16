::  auth [tirrel]: example use case
::
/-  magic
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
++  on-init
  :_  this
  [%pass /eyre %arvo %e %connect [~ /content] dap.bowl]^~
::
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
    ++  handle-post-request
      =*  srv  server
      |=  [headers=header-list:http req=request-line:srv bod=(unit octs)]
      ^-  [(list card) simple-payload:http]
      ?~  bod
        `[[400 ~] ~]
      =/  parsed=(unit (list [key=@t value=@t]))
        (rush q.u.bod yquy:de-purl:html)
      ?~  parsed
        `[[400 ~] ~]
      =/  email=(unit @t)
        (get-header:http 'email' u.parsed)
      ~&  email
      =-  `[[303 -] ~]
      ^-  header-list:http
      :~  ['set-cookie' (cat 3 studio-auth-cookie '=true;')]
          ['location' '/content']
      ==
    ::
    ++  studio-auth-cookie  (cat 3 'studio-auth-' (scot %p our.bowl))
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      =/  cookie-hed=(unit @t)
        (get-header:http 'cookie' hed)
      ?~  cookie-hed
        ~&  %no-cookie
        login-page
      ?~  cookies=(rush u.cookie-hed cock:de-purl:html)
        ~&  %null-cookie
        login-page
      ?~  auth=(get-header:http studio-auth-cookie u.cookies)
        ~&  %no-studio-cookie
        login-page
      :-  [200 ['content-type' 'text/html']^~]
      :-  ~
      %-  manx-to-octs:srv
      ;html.sans-serif.f4
        ;head
          ;meta(charset "utf-8");
          ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
          ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
        ==
        ;body.absolute.w-100.h-100.flex.flex-column.justify-center.items-center
          ;p: Secret article!
        ==
      ==

    ::
    ++  login-page
      =*  srv  server
      ^-  simple-payload:http
      :-  [200 ['content-type' 'text/html']^~]
      :-  ~
      %-  manx-to-octs:srv
      ;html.sans-serif.f4
        ;head
          ;meta(charset "utf-8");
          ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
          ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
        ==
        ;body.absolute.w-100.h-100.flex.flex-column.justify-center.items-center
          ;form.mw6.pa2(method "POST", action "/content")
            ;h3: Want to view the article? Enter your email.
            ;span.w-100.flex.justify-between.items-center.mv3
              ;label.b: Email
              ;input.w-60.ba.pa2(name "email");
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
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
