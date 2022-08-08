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
++  confirm
  |=  title=@t
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): Confirmed subscribtion to {(trip title)}
    ==
  ==
++  unsubscribe
  |=  title=@t
  ^-  manx
  %-  frame
  ;div(class "vh-100 dt w-100 sans-serif")
    ;div(class "dtc v-mid tc")
      ;h1(class "tc"): Unsubscribed from {(trip title)}
    ==
  ==
--
