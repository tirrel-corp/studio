/-  *pipe, magic
/+  server
|_  [page=(unit webpage) =path req=request:http our=ship now=time]  :: include prefix
::
++  open
  |^
  ^-  [(list card:agent:gall) simple-payload:http]
  ?:  =(path /login)
    ?~  page  !!
    !!
  ?~  page  !!
  ?+    method.req  !!
      %'GET'
    :-  ~
    ?~  auth.u.page
      ~&  %no-auth
      [[200 [['content-type' 'text/html'] ~]] `q.dat.u.page]
    ?~  cookie=(get:coo header-list.req)
      request-email-page
    ?.  (validate:coo u.cookie)
      request-email-page
    [[200 [['content-type' 'text/html'] ~]] `q.dat.u.page]
  ::
      %'POST'
    ?:  =(/login path)
      post-login
    post-content
  ==
  ::
  ++  post-content
    ^-  [(list card:agent:gall) simple-payload:http]
    =/  service  %blog
    ?~  body.req
      `[[400 ~] ~]
    ?~  parsed=(rush q.u.body.req yquy:de-purl:html)
      `[[400 ~] ~]
    ?~  email=(get-header:http 'email' u.parsed)
      `[[400 ~] ~]
    :-  =-  [%pass /magic %agent [our %magic] %poke -]^~
        :-  %magic-update
        !>  ^-  update:magic
        [%ask-access service email+u.email]
    =-  [[303 -] ~]
    =/  email-segment=@t  (crip (en-urlt:html (trip u.email)))
    ['location' (cat 3 '/login?email=' email-segment)]^~
  ::
  ++  post-login
    ^-  [(list card:agent:gall) simple-payload:http]
    =/  service  %blog
    ?~  body.req
      `[[400 ~] ~]
    ?~  parsed=(rush q.u.body.req yquy:de-purl:html)
      `[[400 ~] ~]
    ?~  code-bod=(get-header:http 'code' u.parsed)
       `[[400 ~] ~]
    =/  req-line=request-line:server
      %-  parse-request-line:server
      url.req
    ?~  email-hed=(get-header:http 'email' args.req-line)
       `[[400 ~] ~]
    ?~  email=(de-urlt:html (trip u.email-hed))
      `[[400 ~] ~]
    =/  user=(unit user:magic)
      %^  scry-for  %magic  (unit user:magic)
      /user/[service]/email/(crip u.email)
    ?~  user
      `[[400 ~] ~]
    ?~  access-code.u.user
      `[[400 ~] ~]
    ?.  =((rsh [3 2] (scot %q u.access-code.u.user)) u.code-bod)
      `[[401 ~] ~]
    =-  `[[303 -] ~]
    ^-  header-list:http
    :~  ['set-cookie' (generate:coo (crip u.email) u.access-code.u.user)]
        ['location' '/content']
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
        ;form.mw6.pa2(method "POST", action (trip (spat path)))
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
  --
::
::
++  coo
  |%
  ++  studio-auth-cookie  (cat 3 'studio-auth-' (scot %p our))
  ::
  ++  generate
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
  ++  validate
    |=  [email=@t code=@q]
    ^-  ?
    =/  service  %blog
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
  ++  get
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
  --
::
++  scry-for
  |*  [dap=term =mold =^path]
  .^  mold
    %gx
    (scot %p our)
    dap
    (scot %da now)
    (snoc `^^path`path %noun)
  ==
--
