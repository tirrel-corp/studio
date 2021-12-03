/-  *pipe
|%
::
++  state-0-to-1
  |=  s=state-0
  ^-  state-1
  |^
  %=  s
    -  %1
  ::
      flows
    %-  ~(run by flows.s)
    |=  f=flow-0
    ^-  flow
    :*  resource.f
        index.f
        (upgrade-site site.f)
        email.f
    ==
  ==
  ::
  ++  upgrade-site
    |=  old=(unit [t=term b=binding:eyre])
    ^-  (unit [term binding:eyre ?])
    ?~  old  ~
    `[t.u.old b.u.old %.n]
  --
--
