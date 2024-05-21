::  [tirrel]: lib/jog.hoon
::
::  +jog: a mold builder for ordered maps of sets, the ordered map
::  equivalent of a jug.
::
::  +jo: a treap with specified horiziontal order, where the values are
::  sets
::
|%
++  jog
  |*  [key=mold value=mold]
  |=  ord=$-([key key] ?)
  |=  a=*
  =/  b  ;;((tree [key=key val=(set value)]) a)
  ?>  (apt:((on key (set value)) ord) b)
  b
::
++  jo
  |*  [key=mold val=mold]
  =>  |%
      +$  item  [key=key val=(set val)]
      --
  |=  compare=$-([key key] ?)
  |%
  ++  hit   ((on key (set val)) compare)
  ++  del                                               ::  del key-val pair
    |=  [a=(tree item) b=key c=val]
    ^+  a
    ?~  d=(~(del in (get a b)) c)
      +:(del:hit a b)
    (put:hit a b d)
  ::
  ++  dif                                               ::  dif key-set pair
    |=  [a=(tree item) b=key c=(set val)]
    ^+  a
    ?~  d=(~(dif in (get a b)) c)
      +:(del:hit a b)
    (put:hit a b d)
  ::
  ++  gas                                               ::  concatenate
    |=  [a=(tree item) b=(list (pair key (set val)))]
    |-  ^+  a
    ?~  b  a
    $(b t.b, a (put:hit a p.i.b q.i.b))
  ::
  ++  get                                               ::  gets set by key
    |=  [a=(tree item) b=key]
    ^-  (set val)
    ?~(c=(get:hit a b) ~ u.c)
  ::
  ++  has                                               ::  existence check
    |=  [a=(tree item) b=key c=val]
    ^-  ?
    (~(has in (get a b)) c)
  ::
  ++  put                                               ::  add key-val pair
    |=  [a=(tree item) b=key c=val]
    ^+  a
    (put:hit a b (~(put in (get a b)) c))
  ::
  ++  uni                                               ::  add key-set pair
    |=  [a=(tree item) b=key c=(set val)]
    ^+  a
    (put:hit a b (~(uni in (get a b)) c))
  --
--
