/+  default-agent, dbug, verb, server, *merchant
|%
+$  card  card:agent:gall
::
+$  state-0  ~
++  provider  ~zod
--
::
=|  state-0
=*  state  -
::
%-  agent:dbug
%+  verb  |
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init  `this
++  on-save  !>(state)
++  on-load
  |=  old-vase=vase
  `this(state !<(~ old-vase))
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?>  (team:title our.bowl src.bowl)
  ?+    mark  (on-poke:def mark vase)
      %circle-ask
    =/  =ask
      !<(ask vase)
    =.  p.ask  our.bowl
    :_  this
    [%pass /ask %agent [provider %circle] %poke [%circle-ask !>(ask)]]^~
  ::
      %noun
    :_  this
    =-  [%pass /master %agent [provider %circle] %watch -]^~
    /master/(scot %p our.bowl)
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  (on-watch:def path)
::
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  :_  this
  ?+    wire  !!
      [%ask ~]
    ~&  [wire sign]
    ~
  ::
      [%master ~]
    ?+    -.sign  ~&  [wire sign]  ~
        %fact
      =/  upd=update
        !<(update q.cage.sign)
      ~&  upd
      ~
    ::
        %kick
      [%pass /master %agent [~zod %circle] %watch /master/(scot %p our.bowl)]^~
    ==
  ==
::
++  on-arvo  on-arvo:def
++  on-peek  on-peek:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
