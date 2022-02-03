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
  ^-  (each marl tang)
  %+  roll  contents
  |=  [=content out=(each marl tang)]
  ?:  ?=(%| -.out)  out
  =/  hym=(each manx tang)  (content-to-manx content)
  ?:  ?=(%& -.hym)
    [%.y (snoc p.out p.hym)]
  [%.n p.hym]
::
++  content-to-manx
  |=  =content
  ^-  (each manx tang)
  ?-  -.content
    %text       (text-to-manx text.content)
    %mention    (text-to-manx (scot %p ship.content))
    %url        [%.y (url-to-manx url.content)]
    %code       (text-to-manx expression.content)
    %reference  [%.n ~]
  ==
::
++  text-preprocess  :: jank as fuck
  |=  text=@t
  ^-  @t
  =/  mod  (rap 3 ';>\0a' text '\0a\0a' ~)
  =/  lines  (to-wain:format mod)
  =/  [full=wain flag=?]
    %+  roll  lines
    |=  [line=@t full=wain flag=_|]
    =/  tics  (rush line ;~(plug (star ace) tic tic tic (star ace)))
    ?:  !flag
      ?~  tics
        [(snoc full line) |]
      [(snoc full '```') &]
    ?~  tics
      =/  pars
        %+  rush  line
        %+  cook
          |=(t=tape (cat 3 '    ' (crip t)))
        ;~(pfix (star ace) (star prn))
      ?~  pars
        [full flag]
      [(snoc full u.pars) flag]
    [(snoc full '```') |]
  (of-wain:format full)
::
++  text-to-manx
  |=  text=@t
  ^-  (each manx tang)
  ?:  =('' text)
    :-  %.y
    ;br;
  =/  p  (text-preprocess text)
  (mule |.(elm:(static:cram (ream p))))
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
