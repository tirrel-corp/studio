|%
::
+$  resource
  $:  url=@t
      title=(unit @t)
  ==
::
+$  association
  $:  identifier=@t
      label=(unit @t)
  ==
::
+$  reference
  $:  type=?(%shortcut %collapsed %full)
      =association
  ==
::
+$  alternative  (unit @t)
::
+$  flow-content
  $%  [%blockquote children=(list flow-content)]
      [%code lang=(unit @t) meta=(unit @t) value=@t]
      [%heading depth=?(%1 %2 %3 %4 %5 %6) children=(list phrasing-content)]
      [%html-flow value=@t]
      [%list ordered=? start=@ud spread=? children=(list list-content)]
      [%thematic-break ~]
      content
  ==
::
+$  content
  $%  [%definition =association =resource]
      [%paragraph children=(list phrasing-content)]
  ==
::
+$  list-content
      [%list-item spread=? children=(list flow-content)]
::
+$  phrasing-content
  $%  [%link =resource children=(list static-phrasing-content)]
      [%link-reference =reference children=(list static-phrasing-content)]
      static-phrasing-content
  ==
::
+$  static-phrasing-content
  $%  [%break ~]
      [%emphasis children=(list static-phrasing-content)]
      [%html-phrasing value=@t]
      [%image =resource =alternative]
      [%image-reference =reference =alternative]
      [%inline-code value=@t]
      [%strong children=(list static-phrasing-content)]
      [%text value=@t]
  ==
::
+$  mdast
  $%  flow-content
      list-content
      phrasing-content
  ==
::+$  mdast  (list mdast-content)
::
++  parse
  |=  text=@t
  ^-  mdast
  %+  rash  text
  ;~  pose
    flow-parser
  ==
::
++  flow-parser
  ;~  pose
::      code-parser
      heading-parser
      paragraph-parser
      list-parser
      blockquote-parser
      thematic-break-parser
  ==
::
++  code-parser
  %+  cook
  |=  [bod=(list tape)]
  ^-  $>(%code flow-content)
  =|  out=@t
  :^  %code  ~  ~
  |-
  ?~  bod
    out
  %=  $
      bod  t.bod
      out
    ?:  =(out '')
      (crip i.bod)
    (rap 3 out '\0a' (crip i.bod) ~)
  ==
  %-  star
  ;~  pfix
    ;~  pose
      (stun [4 4] ace)
      ;~  plug
        (star ace)
        (jest '\09')
      ==
    ==
    rest
  ==
::
++  heading-parser
  %+  cook
  |=  [depth=tape value=tape]
  ^-  $>(%heading flow-content)
  =/  depth
    ?+  depth  !!
      [@ ~]            %1
      [@ @ ~]          %2
      [@ @ @ ~]        %3
      [@ @ @ @ ~]      %4
      [@ @ @ @ @ ~]    %5
      [@ @ @ @ @ @ ~]  %6
    ==
  [%heading depth [%text (crip value)]^~]
  ;~  plug
    (stun [1 6] hax)
    ;~  pfix
      %-  star
      ;~  pose
        tab
        ace
      ==
      ;~(sfix (star (none " \09\0a")) ;~(plug (star ;~(pose tab ace)) (just '\0a')))
    ==
  ==
::
++  thematic-break-parser
  %+  cold
  [%thematic-break ~]
  %+  ifix
    :-  (stun [0 3] ace)
    ;~(plug (star ace) eol)
  ;~  pose
    ;~(plug tar tar tar)
    ;~(plug hep hep hep)
    ;~(plug cab cab cab)
  ==
::
++  blockquote-parser
  %+  cook
  |=  a=(list static-phrasing-content)
  ^-  $>(%blockquote flow-content)
  :-  %blockquote
  [%paragraph a]^~
  %+  ifix
  [;~(plug (stun [0 3] ace) gar) eol]
  (static-phrasing-parser %txt)
::
++  list-item-parser
  %+  cook
  |=  a=(list static-phrasing-content)
  ^-  $>(%paragraph flow-content)
  [%paragraph a]
  %+  ifix
  [(star ace) eol]
  (static-phrasing-parser %txt)
::
++  list-parser
  ;~  pose
    list-parser-ol
    list-parser-ul
  ==
::
++  list-parser-ul
  %+  cook
  |=  a=(list flow-content)
  ^-  $>(%list flow-content)
  :*  %list
      %.n
      0  %.n
      %+  turn  a
      |=  b=flow-content
      [%list-item %.n b^~]
  ==
::      [%list ordered=? start=@ud spread=? children=(list list-content)]
::      [%list-item spread=? children=(list flow-content)]
  %-  star
  ;~  pfix
    (star ace)
    ;~  pfix
      ;~  pose
        ;~  plug
          ;~(pose hep lus tar)
          ace
        ==
      ==
      list-item-parser
    ==
  ==
::
++  list-parser-ol
  %+  cook
  |=  a=(list flow-content)
  ^-  $>(%list flow-content)
  :*  %list
      %.y
      0  %.n
      %+  turn  a
      |=  b=flow-content
      [%list-item %.n b^~]
  ==
  %-  star
  ;~  pfix
    (star ace)
    ;~  pfix
      ;~  plug
        dem
        dot
        ace
      ==
      list-item-parser
    ==
  ==
::++  rest  ;~(sfix (star (nust '\0a')) (just '\0a'))
::
::++  paragraph-parser
::  %+  cook
::  |=  lines=(list tape)
::  ^-  $>(%paragraph flow-content)
::  :-  %paragraph
::  =/  len  (lent lines)
::  =/  i    1
::  =|  output=(list phrasing-content)
::  |-
::  ?~  lines  (flop output)
::  %=  $
::      output
::    ?:  =(i len)
::      [[%text (crip i.lines)] output]
::    [[%text (cat 3 (crip i.lines) '\0a')] output]
::  ::
::    i  +(i)
::    lines  t.lines
::  ==
::  (star ;~(pfix (star ace) rest))
++  paragraph-parser
  %+  cook
  |=  a=(list static-phrasing-content)
  ^-  $>(%paragraph flow-content)
  [%paragraph a]
  %+  ifix
  [(stun [0 3] ace) eol]
  (static-phrasing-parser %txt)
::
++  emphasis-parser
  ;~  pose
    %+  cook
    |=  [b=static-phrasing-content c=(list static-phrasing-content)]
    ^-  (list static-phrasing-content)
    [b c]
    ;~  plug
      %+  cook
      |=  a=(list static-phrasing-content)
      [%emphasis a]
      ;~  pose
        %+  ifix  [tar tar]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %tar)
        %+  ifix  [cab cab]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %cab)
      ==
    ::
      %+  knee  *(list static-phrasing-content)
      |.  (static-phrasing-parser %txt)
    ==
  ::
    %+  cook
    |=  $:  a=(list static-phrasing-content)
            b=static-phrasing-content
            c=(list static-phrasing-content)
        ==
    ^-  (list static-phrasing-content)
    (weld a [b c])
    ;~  plug
      %+  cook
      |=  a=tape
      [%text (crip a)]^~
      (plus (none "*_"))
    ::
      %+  cook
      |=  a=(list static-phrasing-content)
      [%emphasis a]
      ;~  pose
        %+  ifix  [tar tar]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %tar)
        %+  ifix  [cab cab]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %cab)
      ==
    ::
      %+  knee  *(list static-phrasing-content)
      |.  (static-phrasing-parser %txt)
    ==
  ==
::
++  strong-parser
  ;~  pose
    %+  cook
    |=  [b=static-phrasing-content c=(list static-phrasing-content)]
    ^-  (list static-phrasing-content)
    [b c]
    ;~  plug
      %+  cook
      |=  a=(list static-phrasing-content)
      [%emphasis a]
      ;~  pose
        %+  ifix  [(jest '**') (jest '**')]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %tartar)
        %+  ifix  [(jest '__') (jest '__')]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %cabcab)
      ==
    ::
      %+  knee  *(list static-phrasing-content)
      |.  (static-phrasing-parser %txt)
    ==
  ::
    %+  cook
    |=  $:  a=(list static-phrasing-content)
            b=static-phrasing-content
            c=(list static-phrasing-content)
        ==
    ^-  (list static-phrasing-content)
    (weld a [b c])
    ;~  plug
      %+  cook
      |=  a=tape
      [%text (crip a)]^~
      (plus (none "*_"))
    ::
      %+  cook
      |=  a=(list static-phrasing-content)
      [%emphasis a]
      ;~  pose
        %+  ifix  [(jest '**') (jest '**')]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %tartar)
        %+  ifix  [(jest '__') (jest '__')]
        %+  knee  *(list static-phrasing-content)
        |.  (static-phrasing-parser %cabcab)
      ==
    ::
      %+  knee  *(list static-phrasing-content)
      |.  (static-phrasing-parser %txt)
    ==
  ==
::
++  image-parser
  %+  cook
  |=  [a=tape b=tape c=(list tape)]
  ^-  (list static-phrasing-content)
  :_  ~
  :+  %image
    :-  (crip b)
    ?~(c ~ `(crip i.c))
  ?~  a  ~
  `(crip a)
  ;~  pfix
    zap
    ;~  plug
      (ifix [sel ser] (star (nust ']')))
      ;~  pfix  pal
        ;~  sfix
          ;~  plug
            (star (none ") "))
            %+  stun  [0 1]
            ;~  pfix  (star ace)
              %+  ifix  [doq doq]
              (star (nust '"'))
            ==
          ==
          ;~(plug (star ace) par)
        ==
      ==
    ==
  ==
::
++  link-parser
  %+  cook
  |=  [a=tape b=tape c=(list tape)]
  ^-  (list phrasing-content)
  :_  ~
  :+  %link
    [(crip b) ?~(c ~ `(crip i.c))]
  ?~  a  ~
  [%text (crip a)]^~
  ;~  plug
    (ifix [sel ser] (star (nust ']')))
    ;~  pfix  pal
      ;~  sfix
        ;~  plug
          (star (none ") "))
          %+  stun  [0 1]
          ;~  pfix  (star ace)
            %+  ifix  [doq doq]
            (star (nust '"'))
          ==
        ==
        ;~(plug (star ace) par)
      ==
    ==
  ==
::
++  static-phrasing-parser
  |=  mod=?(%txt %tar %cab %tartar %cabcab)
  ?+  mod  !!
      %txt
    ;~  pose
      image-parser
::      link-parser
      emphasis-parser
::      strong-parser
    ::
      %+  cook
      |=  a=tape
      ^-  (list static-phrasing-content)
      [%text (crip a)]^~
      (star (nust '\0a'))
    ==
  ::
      %tar
    %+  cook
    |=  a=tape
    ^-  (list static-phrasing-content)
    [%text (crip a)]^~
    (no-wrapping-space '*')
  ::
      %cab
    %+  cook
    |=  a=tape
    ^-  (list static-phrasing-content)
    [%text (crip a)]^~
    (no-wrapping-space '*')
  ::
  ==
::
++  no-wrapping-space
  |=  =char
  %+  cook  |=(a=tape a)
  ;~  pose
    %+  cook
    |=  a=(list @t)
    ^-  tape
    a
    (stun [1 2] (none [char ' ' ~]))
  ::
    %+  cook
    |=  [a=@t b=tape c=@t]
    ^-  tape
    (welp [a b] [c ~])
    ;~  plug
      (none [char ' ' ~])
      (star (nust char))
      (none [char ' ' ~])
    ==
  ==
::++  static-phrasing-parser
::  %+  cook
::  |=  a=*  ::a=(list tape)
::  a
::::  ;~  pose
::::    (ifix [tar tar] (star (nust '*')))
::::    (star ;~(pfix (stun [0 3] ace) rest))
::::  ==
::::
::  %-  star
::  %+  ifix
::  [(stun [0 3] ace) eol]
::  %+  knee  **  |.
::  ;~  pose
::    emphasis-parser
::    (star (nust '\0a'))   :: whole line as text
::    (easy ~)
::  ==
::
::++  emphasis-parser
::  ;~  plug
::    static-phrasing-parser
::    %+  knee  **  |.
::    ;~  pose
::      (ifix [cab cab] (nust '_'))
::      (ifix [tar tar] (nust '*'))
::    ==
::    static-phrasing-parser
::  ==
::
++  render
  |=  node=mdast
  ^-  manx
  ~|  -.node
  ?+  -.node  !!
      %code
    ;pre
      ;code
      ; {(trip value.node)}
      ==
    ==
  ::
      %list
    (render-flow-content node)
  ::
      %paragraph
    (render-flow-content node)
  ::
      %heading
    (render-heading node)
  ::
      %thematic-break
    (render-flow-content node)
  ==
::
++  render-phrasing-content
  |=  node=phrasing-content
  ^-  manx
  ?+  -.node  !!
      %text
    [[%$ [%$ (trip value.node)] ~] ~]
  ::
      %emphasis
    ;em
      ;*  (turn children.node render-phrasing-content)
    ==
      %image
    :_  ~
    :-  %img
    %-  zing
    :~  [%src (trip url.resource.node)]^~
        ?~  alternative.node  ~
        [%alt (trip u.alternative.node)]^~
        ?~  title.resource.node  ~
        [%title (trip u.title.resource.node)]^~
    ==
  ::
  ==
::
++  render-flow-content
  |=  node=flow-content
  ?+  -.node  !!
      %code
    ;pre
      ;code
      ; {(trip value.node)}
      ==
    ==
  ::
      %list
    ?:  ordered.node
      ;ol
        ;*  (turn children.node render-list-content)
      ==
    ;ul
      ;*  (turn children.node render-list-content)
    ==
  ::
      %paragraph
    ;p
      ;*  (turn children.node render-phrasing-content)
    ==
  ::
      %thematic-break
    ;hr;
  ==
::
++  render-list-content
  |=  node=list-content
  ^-  manx
  ;li
    ;*  (turn children.node render-flow-content)
  ==
::
++  render-heading
  |=  node=flow-content
  ?>  ?=(%heading -.node)
  ?-  depth.node
      %1
    ;h1
      ;*  (turn children.node render-phrasing-content)
    ==
      %2
    ;h2
      ;*  (turn children.node render-phrasing-content)
    ==
      %3
    ;h3
      ;*  (turn children.node render-phrasing-content)
    ==
      %4
    ;h4
      ;*  (turn children.node render-phrasing-content)
    ==
      %5
    ;h5
      ;*  (turn children.node render-phrasing-content)
    ==
      %6
    ;h6
      ;*  (turn children.node render-phrasing-content)
    ==
  ==
::
::  helpers
::
++  eol  (just '\0a')
++  tab  (just '\09')
::
::  rest: consume rest of line
::
++  rest  ;~(sfix (star (nust '\0a')) (just '\0a'))
::
::  nust: oppose of just, match anything except the given cord
::
++  nust
  |=  daf=char
  |=  tub=nail
  ^-  (like char)
  ?~  q.tub
    (fail tub)
  ?:  =(daf i.q.tub)
    (fail tub)
  (next tub)
::
::  none: same as nust, but compare with multiple characters
::
++  none
  |=  daf=(list char)
  |=  tub=nail
  ^-  (like char)
  ?~  q.tub
    (fail tub)
  ?^  (find [i.q.tub ~] daf)
    (fail tub)
  (next tub)
--
