::  auth [tirrel]: example use case
::
/-  magic
/+  default-agent, dbug, verb, server
|%
+$  card  card:agent:gall
++  service  %example
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
        ?~  bod     `[[400 ~] ~]
        =/  parsed=(unit (list [key=@t value=@t]))
          (rush q.u.bod yquy:de-purl:html)
        ?~  parsed  `[[400 ~] ~]
        =/  email=(unit @t)
          (get-header:http 'email' u.parsed)
        ?~  email   `[[400 ~] ~]
        :-  =-  [%pass /magic %agent [our.bowl %magic] %poke -]^~
            :-  %magic-update
            !>  ^-  update:magic
            [%ask-access service email+u.email]
        =-  [[303 -] ~]
        =/  email-segment=@t  (crip (en-urlt:html (trip u.email)))
        ['location' (cat 3 '/content/login?email=' email-segment)]^~
      ::
          [%content %login ~]
        ?~  bod
          `[[400 ~] ~]
        ~&  bod
        =/  parsed=(unit (list [key=@t value=@t]))
          (rush q.u.bod yquy:de-purl:html)
        ~&  parsed
        ?~  parsed
          `[[400 ~] ~]
        =/  code-bod=(unit @t)
          (get-header:http 'code' u.parsed)
        ?~  code-bod
           `[[400 ~] ~]
        =/  email-hed=(unit @t)
          (get-header:http 'email' args.req)
        ?~  email-hed
           `[[400 ~] ~]
        =/  email  (de-urlt:html (trip u.email-hed))
        ~&  email
        ?~  email
          `[[400 ~] ~]
        =/  user=(unit user:magic)
          %^  scry-for  %magic  (unit user:magic)
          /user/[service]/email/(crip u.email)
        ~&  user
        ?~  user
          `[[400 ~] ~]
        ?~  access-code.u.user
          `[[400 ~] ~]
        ?.  =((rsh [3 2] (scot %q u.access-code.u.user)) u.code-bod)
          `[[401 ~] ~]
        =-  `[[303 -] ~]
        ^-  header-list:http
        :~  ['set-cookie' (gen-cookie (crip u.email) u.access-code.u.user)]
            ['location' '/content']
        ==
      ==
    ::
    ++  studio-auth-cookie  (cat 3 'studio-auth-' (scot %p our.bowl))
    ::
    ++  gen-cookie
      |=  [email=@t code=@q]
      ^-  @t
      %+  rap  3
      :~  studio-auth-cookie
          '='
          email
          '|'
          `@t`(rsh [3 2] (scot %q code))
          ::';max-age=604800'  ::  XX: currently one week
      ==
    ::
    ++  handle-get-request
      =*  srv  server
      |=  [hed=header-list:http req=request-line:srv]
      ^-  simple-payload:http
      ?+    site.req  [[404 ~] ~]
          [%content ~]
        ?~  cookie=(get-cookie hed)
          request-email-page
        ?.  (validate-cookie u.cookie)
          request-email-page
        content-page
      ::
          [%content %login ~]
        =/  cookie  (get-cookie hed)
        =/  email=(unit @t)
          (get-header:http 'email' args.req)
        ?^  cookie
          ?:  (validate-cookie u.cookie)
            [[302 ['location' '/content']^~] ~]
          ?~  email
            [[302 ['location' '/content']^~] ~]
          (login-page (need email))
        ?~  email
          [[302 ['location' '/content']^~] ~]
        (login-page (need email))
      ==
    ::
    ++  validate-cookie
      |=  [email=@t code=@q]
      ^-  ?
      =/  user=(unit user:magic)
        %^  scry-for  %magic  (unit user:magic)
        /user/[service]/email/[email]
      ?~  user
        ~&  %no-such-user
        %.n
      ?~  access-code.u.user
        %.n
      ?.  =(u.access-code.u.user code)
        %.n
      %.y
    ::
    ++  get-cookie
      |=  hed=header-list:http
      ^-  (unit [email=@t code=@q])
      ?~  cookie-hed=(get-header:http 'cookie' hed)
        ~&  %no-cookie
        ~
      ?~  cookies=(rush u.cookie-hed cock:de-purl:html)
        ~&  %null-cookie
        ~
      ?~  auth=(get-header:http studio-auth-cookie u.cookies)
        ~&  %no-studio-cookie
        ~
      ~&  cookie+u.auth
      ?~  index=(find "|" (trip u.auth))
        ~
      =/  trimmed  (trim u.index (trip u.auth))
      =/  code=@q  (slav %q (cat 3 '.~' (rsh [3 1] (crip q.trimmed))))
      `[(crip p.trimmed) code]
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
          ;form.mw6.pa2(method "POST", action "#")
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
