/-  *post, *pipe, *diary, groups, cite, channels
/+  cram
|%
::
++  diary-contents-snippet
  |=  [content=(list verse) lines=@ud]
  ^-  [marl (unit tang)]
  =/  [out=marl num=@ud]
    %+  roll  content
    |=  [=verse out=marl num=@ud]
    ?:  (gth num lines)  [out num]
    ?-  -.verse
        %block   [(snoc out (block-to-manx p.verse)) (add num 1)]
        %inline
      =/  dif  (sub lines num)
      =/  =marl
        (turn (scag dif p.verse) inline-to-manx)
      =/  len  (lent marl)
      =/  =manx
        ;p
          ;*  marl
        ==
      [(snoc out manx) (add num len)]
    ==
  [out ~]
::
++  diary-contents-to-marl
  |=  content=(list verse)
  ^-  [marl (unit tang)]
  :_  ~
  %+  turn  content
  |=  =verse
  ?-  -.verse
      %block   (block-to-manx p.verse)
      %inline
    ;p
      ;*  (turn p.verse inline-to-manx)
    ==
  ==
::
++  li-to-manx
  |=  =listing
  ^-  manx
  ;li  ;*  (listing-to-marl listing)
  ==
::
++  listing-to-marl
  |=  =listing
  ^-  marl
  ?-  -.listing
      %item  `marl`(turn p.listing inline-to-manx)
      %list
    %+  snoc
      (turn r.listing inline-to-manx)
    ?-  p.listing
        %ordered
      ;ol  ;*  (turn q.listing li-to-manx)
      ==
        %unordered
      ;ul  ;*  (turn q.listing li-to-manx)
      ==
        %tasklist
      ;ul  ;*  (turn q.listing li-to-manx)
      ==
    ==
  ==
::
++  block-to-manx
  |=  =block
  ?-  -.block
      %code
    ;pre
      ;code(class "language-{(trip lang.block)}"): {(trip code.block)}
    ==
  ::
      %image
    =/  src  (trip src.block)
    =/  h    (slag 2 (scow %ui height.block))
    =/  w    (slag 2 (scow %ui width.block))
    =/  alt  (trip alt.block)
    ;img(src src, height h, width w, alt alt);
  ::
      %cite
    ;img(src "null", alt "error: cites not working");  :: TODO
  ::
      %header
    ?-  p.block
      %h1  ;h1  ;*  (turn q.block inline-to-manx)
           ==
      %h2  ;h2  ;*  (turn q.block inline-to-manx)
           ==
      %h3  ;h3  ;*  (turn q.block inline-to-manx)
           ==
      %h4  ;h4  ;*  (turn q.block inline-to-manx)
           ==
      %h5  ;h5  ;*  (turn q.block inline-to-manx)
           ==
      %h6  ;h6  ;*  (turn q.block inline-to-manx)
           ==
    ==
  ::
      %listing
    ;div  ;*  (listing-to-marl p.block)
    ==
  ::
      %rule
    ;hr;
  ==
::
++  inline-to-manx
  |=  =inline
  ^-  manx
  ?@  inline  ;span: {(trip inline)}
  ?-  -.inline
      %italics
    ;em  ;*  (turn p.inline inline-to-manx)
    ==
  ::
      %bold
    ;strong  ;*  (turn p.inline inline-to-manx)
    ==
  ::
      %strike
    ;em(style "text-decoration:line-through;")
      ;*  (turn p.inline inline-to-manx)
    ==
  ::
      %blockquote
    ;blockquote  ;*  (turn p.inline inline-to-manx)
    ==
  ::
      %inline-code
    ;code: {(trip p.inline)}
  ::
      %ship
    ;span(class "ship"): {(scow %p p.inline)}
  ::
      %block  ;br;  :: TODO
  ::
      %code
    ;pre
      ;code: {(trip p.inline)}
    ==
  ::
      %tag  ;br;   ::  TODO
  ::
      %link
    ;a(target "_blank", rel "noreferrer", href (trip p.inline))
    ; {(trip q.inline)}
    ==
  ::
      %break
    ;br;
  ::
      %task
    ;br;
  ==
::
++  new-snip
  |=  [=essay:channels size=@ud]
  ^-  [snip=(unit @t) img=(unit @t)]
  ?>  ?=(%diary -.kind-data.essay)
  =/  header-img=(unit @t)  ?:(=('' image.kind-data.essay) ~ `image.kind-data.essay)
  =/  [snippet=(unit @t) img=(unit @t)]
    %+  roll  content.essay
    |=  [=verse snippet=(unit @t) img=_header-img]
    ?:  ?&  ?=(^ snippet)
            ?=(^ img)
        ==
      [snippet img]
    ?-  -.verse
        %inline
      ?^  snippet  [snippet img]
      [`(cat 3 (inline-snip p.verse '' size) '[...]') img]
        %block
      ?+  -.p.verse  [snippet img]
          %image
        ?^  img  [snippet img]
        [snippet `src.p.verse]
          %header
        ?^  snippet  [snippet img]
        [`(cat 3 (inline-snip q.p.verse '' size) '[...]') img]
      ==
    ==
  ?~  img
    [snippet ~]
  ?:  =('' u.img)
    [snippet ~]
  [snippet img]
::
++  inline-snip
  |=  [i=(list inline) str=@t max=@ud]
  ^-  @t
  ~|  str
  =/  siz  (^met 3 str)
  ?:  (gth siz max)
    str
  %+  roll  i
  |=  [i=inline out=_str]
  ~|  out
  =/  siz  (^met 3 out)
  ?:  (gth siz max)
    out
  ?@  i  (combine out i max)
  ?-  -.i
      %italics       (inline-snip p.i out max)
      %bold          (inline-snip p.i out max)
      %strike        (inline-snip p.i out max)
      %blockquote    (inline-snip p.i out max)
      %inline-code   (combine out p.i max)
      %ship          (combine out (scot %p p.i) max)
      %block         (combine out q.i max)
      %code          (combine out p.i max)
      %tag           (combine out p.i max)
      %link          (combine out q.i max)
      %break         out
      %task          out
  ==
::
++  combine
  |=  [a=@t b=@t max=@ud]
  ^-  @t
  ~|   [a b]
  =/  as  (^met 3 a)
  =/  bs  (^met 3 b)
  ?.  (gth (add as bs) max)
    (rap 3 a ' ' b ~)
  %:  rap  3  a  ' '
      (end [3 (sub (add as bs) max)] b)  ~
  ==
::
++  snip
  |=  contents=(list content)
  ^-  (unit @t)
  ?~  contents
    ~
  ?~  t.contents
    ~
  =/  first=(unit @t)
    %+  roll  ;;((list content) t.contents)
    |=  [c=content out=(unit @t)]
    ?:  ?=(%text -.c)
      `text.c
    out
  ?~  first  ~
  ?:  (lte (^met 3 u.first) 180)
    `u.first
  `(cat 3 (end [3 180] u.first) '...')
::
++  print-date
  |=  d=@da
  ^-  @t
  =/  date   (yore d)
  =/  month  (end [3 3] (crip (snag (dec m.date) mon:yu:chrono:userlib)))
  %:  rap  3
    month
    ' '
    (scot %ud d.t.date)
    ', '
    (rsh [3 2] (scot %ui y.date))
    ~
  ==
::
++  en-url-strip  :: url-encode, stripping strange characters
  |=  tep=tape
  ^-  tape
  %-  zing
  %+  murn  tep
  |=  tap=char
  =+  xen=|=(tig=@ ?:((gte tig 10) (add tig 55) (add tig '0')))
  ?:  ?|  &((gte tap 'a') (lte tap 'z'))
          &((gte tap 'A') (lte tap 'Z'))
          &((gte tap '0') (lte tap '9'))
          =('.' tap)
          =('-' tap)
          =('~' tap)
          =('_' tap)
      ==
    `[tap ~]
  ?:  ?|  =(' ' tap)
      ==
    `['-' ~]
  ~
::
++  strip-title
  |=  title=cord
  (crip (en-url-strip (cass (trip title))))
::
++  title-to-url
  |=  title=cord
  ^-  path
  [(strip-title title) ~]
::
++  contents-to-marl
  |=  contents=(list content)
  ^-  [marl (unit tang)]
  %+  roll  contents
  |=  [=content m=marl t=(unit tang)]
  =/  [hym=manx err=(unit tang)]  (content-to-manx content)
  ?^  t  :: TODO maybe collect all errors rather than just the first one
    [(snoc m hym) t]
  [(snoc m hym) err]
::
++  reference-to-manx
  |=  r=reference
  ^-  manx
  ?-  -.r
      %graph  :: just redirect to the group for now
    =/  url
      %:  rap  3
        'web+urbitgraph://group/'
        (scot %p entity.group.r)  '/'
        name.group.r
        ~
      ==
    ;a(href (trip url))
    ; {<entity.group.r>}/{(trip name.group.r)}
    ==
  ::
      %group
    =/  url
      %:  rap  3
        'web+urbitgraph://group/'
        (scot %p entity.group.r)  '/'
        name.group.r
        ~
      ==
    ;a(href (trip url))
    ; {<entity.group.r>}/{(trip name.group.r)}
    ==
  ::
      %app
    =/  url
      %:  rap  3
        'web+urbitgraph://'
        (scot %p ship.r)  '/'
        desk.r
        (spat path.r)
        ~
      ==
    ;a(href (trip url))
    ; {<ship.r>}/{(trip desk.r)}
    ==
  ==
::
++  content-to-manx
  |=  =content
  ^-  [manx (unit tang)]
  ?-  -.content
    %text       (text-to-manx text.content)
    %mention    (text-to-manx (scot %p ship.content))
    %url        [(url-to-manx url.content) ~]
    %code       (text-to-manx expression.content)
    %reference  [(reference-to-manx reference.content) ~]
  ==
+$  mode
  $~  %def
  $?  %def
      %code
  ==
::
++  text-preprocess  :: jank as fuck
  |=  text=@t
  |^
  ^-  @t
  =.  text  (strip-leading-space text)
  =/  mod  (rap 3 ';>\0a' text '\0a\0a' ~)
  =/  lines  (to-wain:format mod)
  =/  [full=wain =mode]
    %+  roll  lines
    |=  [line=@t full=wain flag=mode]
    ?-  flag
    ::  default mode
        %def
      ::  detect ``` and switch to %code mode
      =/  tics=(unit tape)
        %+  rush  line
        ;~(pfix ;~(plug (star ace) (jest '```') (star ace)) (star next))
      ?^  tics
        =.  full  (snoc full '```')
        ?~  u.tics
          [full %code]
        =/  pars  (need (rush (crip u.tics) reformat-space))
        [(snoc full pars) %code]
      ::  detect # and switch to %header mode
      =/  hed
        %+  rush  line
        ;~(plug (stun [0 3] ace) (stun [1 6] hax) (plus ace) (star next))
      ?^  hed
        [(snoc (snoc full line) '') %def]
      ::  detect and reformat lists
      =/  nlist=(unit tape)
        %+  rush  line
        ;~(pfix ;~(plug (stun [0 3] ace) dem dot ace) (star next))
      ?^  nlist
        [(snoc full (cat 3 '+ ' (crip u.nlist))) %def]
      =/  llist=(unit tape)
        %+  rush  line
        ;~(pfix ;~(plug (stun [0 3] ace) lus ace) (star next))
      ?^  llist
        [(snoc full (cat 3 '- ' (crip u.llist))) %def]
      [(snoc full line) %def]
    ::  handle backticks
        %code
      =/  tics
        %+  rush  line
        ;~(sfix (star (not-char '`')) ;~(plug (jest '```') (star ace)))
      ?~  tics
        =/  pars  (need (rush line reformat-space))
        [(snoc full pars) flag]
      =?  full  ?=(^ u.tics)
        (snoc full (crip u.tics))
      [(snoc full '```') %def]
    ==
  (of-wain:format full)
  ::
  ++  reformat-space
    %+  cook
    |=(t=tape (cat 3 '    ' (crip t)))
    ;~(pfix (star ace) (star next))
  ::
  ++  not-char
    |=  daf=char
    |=  tub=nail
    ^-  (like char)
    ?~  q.tub
      (fail tub)
    ?:  =(daf i.q.tub)
      (fail tub)
    (next tub)
  --
::
++  strip-leading-space
  |=  a=@t
  ^-  @t
  |-
  ?:  ?|  =(' ' (end [3 1] a))
          =('\0a' (end [3 1] a))
      ==
    $(a (rsh [3 1] a))
  a
::
++  text-to-manx
  |=  text=@t
  ^-  [manx (unit tang)]
  ?:  =('' text)
    [;br; ~]
  =/  p  (text-preprocess text)
  =/  q  (mule |.(elm:(static:cram (ream p))))
  ?:  ?=(%& -.q)
    [p.q ~]
  :_  `p.q
  ;p(style "white-space: pre-wrap"): {(trip text)}
::
++  url-to-manx
  |=  url=@t
  ^-  manx
  =/  link-type  (get-link-type url)
  ?-  -.link-type
    %anchor  (render-anchor url)
    %image   (render-image url)
    %audio   (render-audio-link url)
    %video   (render-video-link url)
  ==
::
++  get-link-type
  |=  url=cord
  ^-  [tag=?(%anchor %image %audio %video) type=@t]
  =/  image-ext
    $?  %jpg  %img  %png  %gif  %tiff  %jpeg  %webp  %webm  %svg
    ==
  =/  audio-ext
    $?  %mp3  %wav  %ogg  %m4a
    ==
  =/  video-ext
    $?  %mov  %mp4  %ogv
    ==
  ::
  =/  purl=(unit purl:eyre)  (de-purl:html url)
  ?~  purl  [%anchor '']
  ?+  p.q.u.purl  [%anchor '']
    [~ image-ext]  [%image (cat 3 'image/' +.p.q.u.purl)]
    [~ audio-ext]  [%audio (cat 3 'audio/' +.p.q.u.purl)]
    [~ video-ext]  [%video (cat 3 'video/' +.p.q.u.purl)]
  ==
::
++  render-anchor
  |=  url=@t
  ^-  manx
  =/  turl  (trip url)
  ;a(href turl): {turl}
::
++  render-image
  |=  url=@t
  ^-  manx
  ;img(src (trip url), width "100%");
::
++  render-audio
  |=  [type=@t url=@t]
  ^-  manx
  ;audio(controls ~, src (trip url));
::
++  render-video
  |=  [type=@t url=@t]
  ^-  manx
  ;video(controls ~)
    ;source(src (trip url), type (trip type));
  ==
::
++  render-audio-link
  |=  url=@t
  ^-  manx
  ;a(href (trip url)): Click here to listen
::
++  render-video-link
  |=  url=@t
  ^-  manx
  ;a(href (trip url)): Click here to watch
--
