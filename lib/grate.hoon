/-  *pipe, auth
/+  server
|_  [page=webpage =path req=request:http our=ship now=time]  :: include prefix
::
++  open
  =/  req-line=request-line:server
    %-  parse-request-line:server
    url.req
  |^
  ^-  [(list card:agent:gall) simple-payload:http]
  =/  action-arg=(unit @t)
   (get-header:http 'action' args.req-line)
  ?+    method.req  !!
      %'GET'
    ?:  ?&  ?=(^ action-arg)
            =(%login u.action-arg)
        ==
      ?~  email-hed=(get-header:http 'email' args.req-line)
        `(error 'missing email field')
      `(login-page u.email-hed)
    =*  service  auth.page
    :-  ~
    ?~  service
      ::  ~&  %no-auth
      (content page)
    ?~  cookie=(get:coo header-list.req)
      ::  ~&  %no-cookie
      request-email-page
    ?.  (validate:coo -.u.cookie +.u.cookie u.service)
      ::  ~&  %invalid-cookie
      request-email-page
    (content page)
  ::
      %'POST'
    ?:  ?&  ?=(^ action-arg)
            =(%login u.action-arg)
        ==
      ::  login post
      ?>  ?=(^ auth.page)
      =*  service  u.auth.page
      ?~  body.req
        `(error 'null body')
      ?~  parsed=(rush q.u.body.req yquy:de-purl:html)
        `(error 'body failed to parse')
      ?~  code-bod=(get-header:http 'code' u.parsed)
         `(error 'missing code field')
      ?~  email-hed=(get-header:http 'email' args.req-line)
         `(error 'missing email field')
      ?~  email=(de-urlt:html (trip u.email-hed))
         `(error 'invalid email')
      =/  user=(unit user:auth)
        %^  scry-for  %auth  (unit user:auth)
        /user/[service]/email/(crip u.email)
      ?~  user
         `(error 'missing user')
      ?~  access-code.u.user
         `(error 'missing access code')
      ?.  =((rsh [3 2] (scot %q u.access-code.u.user)) u.code-bod)
        `[[401 ~] ~]
      =-  `[[303 -] ~]
      ^-  header-list:http
      :~  ['set-cookie' (generate:coo (crip u.email) u.access-code.u.user)]
          ['location' (spat site.req-line)]
      ==
    ::  request email post
    ?>  ?=(^ auth.page)
    =*  service  u.auth.page
    ?~  body.req
      `(error 'empty body')
    ?~  parsed=(rush q.u.body.req yquy:de-purl:html)
      `(error 'failed to parse')
    ?~  email=(get-header:http 'email' u.parsed)
      `(error 'missing email')
    :-  =-  [%pass /auth %agent [our %auth] %poke -]^~
        :-  %auth-update
        !>  ^-  update:auth
        [%ask-access service email+u.email]
    =-  [[303 -] ~]
    =/  email-segment=@t  (crip (en-urlt:html (trip u.email)))
    ['location' (rap 3 (spat site.req-line) '?action=login&email=' email-segment ~)]^~
  ==
  ::
  ++  error
    |=  msg=@t
    ^-  simple-payload:http
    =/  =manx
      ;p: {(trip msg)}
    :_  `(manx-to-octs:server manx)
    [400 [['content-type' 'text/html'] ~]]
  ::
  ++  content
    |=  wag=webpage
    ^-  simple-payload:http
    [[200 [['content-type' 'text/html'] ~]] `q.dat.wag]
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
        ;form.mw6.pa2.flex.flex-column(method "POST", action "#")
          ;h3.w-70-ns.w-100: Want to view the post? Enter your email.
          ;input.w-100.ba.bw1.pa2.br2.mb3(name "email", placeholder "me@example.com");
          ;input.w-60.bg-black.br2.white.bn.pv2.ph4.dim.pointer(type "submit");
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
        ;form.mw6.pa5-ns.pa2.flex.flex-column(method "POST", action "#")
          ;h3.w-70-ns.w-100: Please enter the code we emailed to {(trip email)}.
          ;input.w-100.ba.bw1.pa2.br2.mb3(name "code", placeholder "tacryt-socryp");
          ;input.w-60.bg-black.br2.white.bn.pv2.ph4.dim.pointer(type "submit");
        ==
      ==
    ==
  --
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
    |=  [email=@t code=@q service=@tas]
    ^-  ?
    =/  user=(unit user:auth)
      %^  scry-for  %auth  (unit user:auth)
      /user/[service]/email/[email]
    ?~  user
      ::  ~&  %no-such-user
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
      ::  ~&  %no-cookie
      ~
    ?~  cookies=(rush u.cookie-hed cock:de-purl:html)
      ::  ~&  %null-cookie
      ~
    ?~  auth=(get-header:http studio-auth-cookie u.cookies)
      ::  ~&  %no-studio-cookie
      ~
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
