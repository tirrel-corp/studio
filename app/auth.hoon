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
      ?+    site.req  `[[404 ~] ~]
          [%content ~]
        ?~  bod
          `[[400 ~] ~]
        =/  parsed=(unit (list [key=@t value=@t]))
          (rush q.u.bod yquy:de-purl:html)
        ?~  parsed
          `[[400 ~] ~]
        =/  email=(unit @t)
          (get-header:http 'email' u.parsed)
        ?~  email
           `[[400 ~] ~]
        =-  `[[303 -] ~]
        ['location' (cat 3 '/content/login?email=' u.email)]^~
      ::
          [%content %login ~]
        ?~  bod
          `[[400 ~] ~]
        =/  parsed=(unit (list [key=@t value=@t]))
          (rush q.u.bod yquy:de-purl:html)
        ?~  parsed
          `[[400 ~] ~]
        =/  email=(unit @t)
          (get-header:http 'email' u.parsed)
        ?~  email
           `[[400 ~] ~]
        =-  `[[303 -] ~]
        ^-  header-list:http
        ::  TODO: make a real cookie that looks like
        ::  logan@tirrel.io|~something-something
        ::  and add a max-age
        :~  ['set-cookie' (cat 3 studio-auth-cookie '=true;')]
            ['location' '/content']
        ==
      ==
    ::
    ++  studio-auth-cookie  (cat 3 'studio-auth-' (scot %p our.bowl))
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      ~&  req
      ?+    site.req  [[404 ~] ~]
          [%content ~]
        ?~  cookie=(get-cookie hed)
          request-email-page
        =*  email  -.u.cookie
        =*  code   +.u.cookie
        =/  user=(unit user:magic)
          %^  scry-for  %magic  (unit user:magic)
          /user/example-auth/email/[email]
        ?~  user
          ~&  %no-such-user
          request-email-page
        ?.  =(access-code.u.user code)
          request-email-page
        content-page
      ::
          [%content %login ~]
        =/  cookie  (get-cookie hed)
        ?^  cookie
          [[302 ['location' '/content']^~] ~]
        =/  email=(unit @t)
          (get-header:http 'email' args.req)
        ?~  email
          [[302 ['location' '/content']^~] ~]
        (login-page (need email))
      ==
    ::
    ++  get-cookie
      |=  hed=header-list:http
      ^-  (unit [email=@t code=@t])
      ?~  cookie-hed=(get-header:http 'cookie' hed)
        ~&  %no-cookie
        ~
      ?~  cookies=(rush u.cookie-hed cock:de-purl:html)
        ~&  %null-cookie
        ~
      ?~  auth=(get-header:http studio-auth-cookie u.cookies)
        ~&  %no-studio-cookie
        ~
      ?~  index=(find "|" (trip u.auth))
        ~
      =/  trimmed  (trim u.index (trip u.auth))
      `[(crip p.trimmed) (crip q.trimmed)]
    ::
    ++  login-page
      =*  srv  server
      |=  email=@t
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
            ;h3: Please enter the code we sent to your email.
            ;p: {(trip email)}
            ;span.w-100.flex.justify-between.items-center.mv3
              ;label.b: Access Code
              ;input.w-60.ba.pa2(name "code");
            ==
            ;input.w-100.bg-black.white.bn.pv2.ph4.dim.pointer(type "submit");
          ==
        ==
      ==
    ::
    ++  request-email-page
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
    ::
    ++  content-page
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
          ;p: Secret article!
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
