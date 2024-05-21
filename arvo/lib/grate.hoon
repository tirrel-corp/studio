/-  *pipe, auth
/+  server, constants
/*  post-message-js  %js  /lib/grate-js/js
/*  iframe-css       %css  /lib/grate-css/css
|_  [page=webpage =path req=request:http our=ship now=time]  :: include prefix
::
++  open
  =/  req-line=request-line:server
    %-  parse-request-line:server
    url.req
  ~&  req-line+req-line
  |^
  ^-  [(list card:agent:gall) simple-payload:http]
  ?>  ?=(%'GET' method.req)
  =*  service  auth.page
  =/  token=(unit @t)  (get-header:http 'token' args.req-line)
  =/  login=(unit @t)  (get-header:http 'login' args.req-line)
  :-  ~
  ~&  service
  ?~  service
    (content page)
  ?:  ?=(^ token)
    ~&  %has-token
    ::?~  email
    ::  ~&  %no-email
    ::  not-found:gen:server
    ::~&  %has-email
    ?~  uauth=(validate:coo ~ (slav %q (cat 3 '.~' u.token)) u.service)
      ~&  %auth-failed
      paywall-page
    ~&  %auth-dope
    =-  [[303 -] ~]
    :~  ['set-cookie' (generate:coo email.u.uauth (slav %q (cat 3 '.~' u.token)))]
        ['location' (spat site.req-line)]
    ==
  ?~  cookie=(get:coo header-list.req)
    paywall-page
  ?~  uauth=(validate:coo [~ -.u.cookie] +.u.cookie u.service)
    paywall-page
  ?.  security-clearance.user.u.uauth
    paywall-page
  (content page)
  ::
  ++  error
    |=  msg=@t
    ^-  simple-payload:http
    ~&  error+msg
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
  ++  paywall-page
    =*  srv  server
    ^-  simple-payload:http
    :-  [200 ['content-type' 'text/html']^~]
    :-  ~
    ::  TODO What should this hard-coded benjamin.urbit.studio:3000
    ::  thing be replaced with?  Some sort of ~tirrel domain?
    =/  base=tape      studio-iframe-base-url:constants
    =/  ship=tape      (scow %p our)
    =/  serv=tape      (trip (need auth.page))
    %-  manx-to-octs:srv
    ?~  snip.page  *manx  :: TODO, better solution requires more integration between auth app and templates
    ;html
      ;head
        ;*  head.u.snip.page
      ==
      ;body
        ;div
          ;*  (snoc body.u.snip.page paywall-body)
        ==
      ==
    ==
  ::
  ++  paywall-body
    ^-  manx
    =/  base=tape      studio-iframe-base-url:constants
    =/  ship=tape      (scow %p our)
    =/  serv=tape      (trip (need auth.page))
    ;div(class "mb7 container mt2", style "margin-top: 2em")
      ;iframe(src "{base}/login/{ship}/{serv}", class "embed");
      ;script: window.ship = {(zing "\"" (trip (scot %p our)) "\"" ~)};
      ;script: {(trip post-message-js)}
      ;style: {(trip iframe-css)}
    ==
  ::
  ++  paywall-page-old
    =*  srv  server
    ^-  simple-payload:http
    :-  [200 ['content-type' 'text/html']^~]
    :-  ~
    ::  TODO What should this hard-coded benjamin.urbit.studio:3000
    ::  thing be replaced with?  Some sort of ~tirrel domain?
    =/  base=tape      studio-iframe-base-url:constants
    =/  ship=tape      (scow %p our)
    =/  serv=tape      (trip (need auth.page))
    %-  manx-to-octs:srv
    ;html.sans-serif.f4
      ;head
        ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
        ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
      ==
      ;body
        ;div(class "container")
          ;div(class "item");
          ;iframe(src "{base}/login/{ship}/{serv}", class "embed");
          ;div(class "item");
        ==
        ;script: window.ship = {(zing "\"" (trip (scot %p our)) "\"" ~)};
        ;script: {(trip post-message-js)}
        ;style
          ; 
          ; html, body {
          ;     height: 100%;
          ; }
          ; body {
          ;     margin: 0;
          ; }
          ; .container {
          ;     height: 100%;
          ;     padding: 0;
          ;     margin: 0;
          ;     display: flex;
          ;     align-items: center;
          ;     justify-content: center;
          ;     flex-direction: column;
          ; }
          ; .row {
          ;     width: auto;
          ;     border: 1px solid blue;
          ; }
          ; .embed {
          ;     background-color: #ffffff;
          ;     padding: 5px;
          ;     width: 80%;
          ;     height: 80%;
          ;     margin: 10px;
          ;     line-height: 20px;
          ;     color: white;
          ;     font-weight: bold;
          ;     font-size: 2em;
          ;     text-align: center;
          ; }
          ; .item {
          ;     background-color: #ffffff;
          ;     padding: 5px;
          ;     width: 20px;
          ;     height: 20px;
          ;     margin: 10px;
          ;     line-height: 20px;
          ;     color: white;
          ;     font-weight: bold;
          ;     font-size: 2em;
          ;     text-align: center;
          ; }
        ==
      ::;script
      ::  ;
      ::  ;
      ::  ; window.addEventListener("load", ee =>
      ::  ;   document
      ::  ;     .getElementById("theframe")
      ::  ;     .addEventListener("message", e => console.log(e))
      ::  ; );
      ::  ;
      ::==
        :: window.onLoad(e => ("message", e => alert(JSON.stringify(e.data))); window.postMessage("asdf", '*'); window.postMessage("asdf", '*');
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
        ';Path=/'
        ::';max-age=604800'  ::  XX: currently one week
    ==
  ::
  ++  find-token
    |=  [token=@q =service:auth]
    ^-  (unit (pair email=@tas user:auth))
    =/  pairs  ~(tap by users.service)
    |-
    ?~  pairs  ~
    =+  [=id:auth =user:auth]=i.pairs
    =/  new-pairs        `(list (pair id:auth user:auth))`t.pairs
    ?@  id                           $(pairs new-pairs)
    ?~  access-code.user             $(pairs new-pairs)
    ?:  =(token u.access-code.user)  $(pairs new-pairs)
    `[p.id user]
  ::
  ::++  validate
  ::  |=  [email=@t code=@q service=@tas]
  ::  ^-  (unit [email=@t user=user:auth])
  ::  =/  user=(unit user:auth)
  ::    %^  scry-for  %auth  (unit user:auth)
  ::    `^path`/user/[service]/email/[email]
  ::  ?~  user
  ::    ::  ~&  %no-such-user
  ::    ~
  ::  ?~  access-code.u.user
  ::    ~
  ::  ?.  =(u.access-code.u.user code)
  ::    ~
  ::  `[email u.user]
  ::
  ::  TODO Validate that email matches before returning
  ++  validate
    |=  [email=(unit @t) code=@q service=@tas]
    ^-  (unit [email=@tas =user:auth])
    =/  token=@tas  (scot %q code)
    =/  pax  `^path`/user/[service]/token/[token]
    .^  (unit [@tas user:auth])
        [%gx (scot %p our) %auth (scot %da now) (snoc pax %noun)]
    ==
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
