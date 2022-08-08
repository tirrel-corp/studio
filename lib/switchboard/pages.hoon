/-  *mailer
|%
++  frame
  |=  inner=manx
  ^-  manx
  ;html
    ;head
      ;title: Not configured
      ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
      ;link(rel "stylesheet", href "https://tirrel.io/assets/css/studio.css");
    ==
    ;body(class "bg-light-gray gray")
      ;+  inner
    ==
  ==
::
++  not-configured
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): This site is being run by ~tirrel studio but has not been configured.
    ==
  ==
::
++  subscribe
  |=  title=@t
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): Subscribed to {(trip title)}, check your email for confirmation
    ==
  ==
::
++  confirm
  |=  title=@t
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): Confirmed subscribtion to {(trip title)}
    ==
  ==
::
++  unsubscribe
  |=  title=@t
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): Unsubscribed from {(trip title)}
    ==
  ==
::
++  confirm-email-body
  |=  [title=@t token=@t pipe=binding:eyre mailer=binding:eyre]
  ^-  (list content-field)
  =/  blog-link=@t
    %:  rap  3
        (need site.pipe)
        (spat path.pipe)
        ~
    ==
  =/  confirm-link=@t
    %:  rap  3
        (need site.mailer)
        (spat path.mailer)
        '/confirm?token='
        token
        ~
    ==
  :_  ~
  :-  'text/html'
  =<  q
  %-  as-octt:mimes:html
  %-  en-xml:html
  ^-  manx
  ;div
    ;a(href (trip blog-link), style "color:black; text-decoration-color:black;")
      ;h1(style "color:black; text-decoration-color:black;"): You've subscribed to {(trip title)}!
    ==
    ;p: Please confirm your subscription, if you did not subscribe you can ignore this email.
    ;a(href (trip confirm-link), style "color:black;"): Confirm Subscription
  ==
--
