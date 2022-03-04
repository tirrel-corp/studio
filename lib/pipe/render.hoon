/-  *post, *pipe
/+  cram
|%
++  lorem-ipsum
  ^-  site-inputs
  :*  %lorem
      [~ /]
      :~  :*  ~2021.11.3
          :*  ~zod
              ~
              ~2021.11.3
              :~  [%text 'Ut enim ad minim veniam']
                  :-  %text
                  '''
                  Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed
                  do eiusmod tempor incididunt ut labore et dolore magna aliqua.
                  Ut enim ad minim veniam, quis nostrud exercitation ullamco
                  laboris nisi ut aliquip ex ea commodo consequat. Duis aute
                  irure dolor in reprehenderit in voluptate velit esse cillum
                  dolore eu fugiat nulla pariatur. Excepteur sint occaecat
                  cupidatat non proident, sunt in culpa qui officia deserunt
                  mollit anim id est laborum.
                  '''
                  :-  %text
                  '''
                  Sed ut perspiciatis unde omnis iste natus error sit voluptatem
                  accusantium doloremque laudantium, totam rem aperiam, eaque
                  ipsa quae ab illo inventore veritatis et quasi architecto
                  beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem
                  quia voluptas sit aspernatur aut odit aut fugit, sed quia
                  consequuntur magni dolores eos qui ratione voluptatem sequi
                  nesciunt. Neque porro quisquam est, qui dolorem ipsum quia
                  dolor sit amet, consectetur, adipisci velit, sed quia non
                  numquam eius modi tempora incidunt ut labore et dolore magnam
                  aliquam quaerat voluptatem. Ut enim ad minima veniam, quis
                  nostrum exercitationem ullam corporis suscipit laboriosam,
                  nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum
                  iure reprehenderit qui in ea voluptate velit esse quam nihil
                  molestiae consequatur, vel illum qui dolorem eum fugiat quo
                  voluptas nulla pariatur?
                  '''
              ==
              ~
              ~
            ==
            ~
          ==
          :*  ~2022.2.12
          :*  ~zod
              ~
              ~2022.2.12
              :~  [%text 'At vero eos']
                  :-  %text
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
                  :-  %text
                  'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?'
              ==
              ~
              ~
            ==
            ~
          ==
      ==
      :-  [~zod %foo]
      :*  'Lorem Ipsum'
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit'
          0x0
          ~2021.3.11
          ~zod
          [%empty ~]
          ''
          %.n
          %.n
          %$
      ==
      %.n
      %.n
      %1
      %.n
      0x0
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
  ?:  (lte (met 3 u.first) 180)
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
