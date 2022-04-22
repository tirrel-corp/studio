/-  *pipe, *post, store=graph-store, metadata-store
/+  *pipe-render, cram
^-  $-(site-inputs website)
|=  sinp=site-inputs
^-  website
|^  =/  [previews=marl pages=website]
      %+  roll  posts.sinp
      |=  $:  [initial=@da =post comments=(list post)]
              [previews=marl pages=website]
          ==
      =/  [path=@t pre=manx page=[mime (unit tang)]]
        %:  article-build
            name.sinp
            binding.sinp
            initial
            post
            comments
            association.sinp
            email.sinp
            width.sinp
            lit.sinp
        ==
      :-  (snoc previews pre)
      (~(put by pages) path [-.page +.page ~])
    =/  m  (index-page sinp previews)
    (~(put by pages) '/' [m ~ ~])
::
+$  article-inputs
  $:  name=term
      =binding:eyre
      initial=@da
      =post
      comments=(list post)
      =association:metadata-store
      email=?
      width=?(%1 %2 %3)
      lit=?
  ==
::
++  index-page
  |=  [si=site-inputs previews=marl]
  ^-  mime
  =/  home-url  (spud path.binding.si)
  :-  [%text %html ~]
  %-  as-octt:mimes:html
  %+  welp  "<!doctype html>"
  %-  en-xml:html
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
      ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
      ;link(rel "preconnect", href "https://fonts.googleapis.com");
      ;link(rel "preconnect", href "https://fonts.gstatic.com", crossorigin "true");
      ;link(href "https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap", rel "stylesheet");
      ;title: {(trip title.metadatum.association.si)}
      ;+  custom-style
    ==
    ;+  %^  frame  lit.si  width.si
    :*  (header binding.si title.metadatum.association.si lit.si)
        %+  snoc
          previews
        (subscribe-box name.si title.metadatum.association.si email.si lit.si)
    ==
  ==
::
++  frame
  |=  [lit=? width=?(%1 %2 %3) m=marl]
  ^-  manx
  =/  colors
    ?:  lit
      " near-black bg-white"
    " white bg-near-black"
  =/  wid
    ?-  width
      %1  " mw5"
      %2  " mw6"
      %3  " mw7"
    ==
  ;body(class (weld "w-100 h-100 flex flex-column items-center" colors))
     ;div
       =class  (weld "pa1 pv3-ns w-100" wid)
       ;*  m
     ==
  ==
::
++  header
  |=  [=binding:eyre title=@t lit=?]
  ^-  manx
  =/  colors
    ?:  lit
      " near-black"
    " white"
  =/  home-url  (spud path.binding)
  ;div(class "mb5")
    ;a(href "{home-url}", class (weld "link" colors))
      ;h3: {(trip title)}
    ==
  ==
::
::
++  subscribe-box
  |=  [book=@tas title=@t email=? lit=?]
  ^-  manx
  ?.  email  ;br;
  =/  borders
    ?:  lit
      " b--near-black"
    " b--white"
  =/  btn-color
    ?:  lit
      " bg-near-black white"
    " bg-white near-black"
  ;form
    =id  "subscribe"
    =method  "post"
    =action  "/mailer/subscribe"
    =class   (weld "db w-100 flex flex-column items-center br3 bw2 ba pa2 mb4" borders)
    ;p(style "margin-block-end: 0;"): Subscribe to {(trip title)}
    ;input(name "book", type "hidden", value "{(trip book)}");
    ;input
      =name   "who"
      =class  (weld "db pa2 input-reset ba mv3 br3" borders)
      =type   "email"
      =placeholder  "your@email.com"
    ;
    ==
    ;button
      =id     "subscribe"
      =type   "submit"
      =class  (weld "mb3 db fw4 ph3 pv2 pointer bt3 bn" btn-color)
    ; Subscribe
    ==
  ==
::
++  details
  |=  [when=@da who=@p]
  ^-  manx
  =/  t=tape
    %-  trip
    %:  rap  3
      (print-date when)  ' • '
      (scot %p who)
      ~
    ==
  ;p(class "gray fw4", style "margin-block-end: 0;"): {t}
::
++  article-build
  |=  ai=article-inputs
  ^-  [@t manx mime (unit tang)]
  =/  [con=marl err=(unit tang)]  (contents-to-marl (slag 1 contents.post.ai))
  =/  title=content  (snag 0 contents.post.ai)
  ?>  ?=(%text -.title)
  :*  (cat 3 '/' (strip-title text.title))
      (article-preview ai text.title)
      (article-page ai con text.title)
      err
  ==
::
++  article-preview
  |=  [ai=article-inputs title=@t]
  ^-  manx
  =/  snippet=(unit @t)  (snip contents.post.ai)
  =/  url=tape
    %-  trip
    ?~  path.binding.ai
      (cat 3 '/' (strip-title title))
    (rap 3 (spat path.binding.ai) '/' (strip-title title) ~)
  =/  colors
    ?:  lit.ai
      " near-black"
    " white"
  ;a(class (weld "db link mb5" colors), href url)
    ;h3(class colors): {(trip title)}
    ;+  ?~  snippet  *manx
        ;p(class (weld "fw4" colors)): {(trip u.snippet)}
    ;+  (details initial.ai author.post.ai)
  ==
::
++  article-page
  |=  [ai=article-inputs con=marl title=@t]
  ^-  mime
  =/  home-url  (spud path.binding.ai)
  ::
  :-  [%text %html ~]
  %-  as-octt:mimes:html
  %+  welp  "<!doctype html>"
  %-  en-xml:html
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
      ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
      ;link(rel "preconnect", href "https://fonts.googleapis.com");
      ;link(rel "preconnect", href "https://fonts.gstatic.com", crossorigin "true");
      ;link(href "https://fonts.googleapis.com/css2?family=Inter:wght@400;700;800&display=swap", rel "stylesheet");
      ;title: {(trip title)} • by {(trip (scot %p author.post.ai))}
      ;+  custom-style
    ==
    ;+  %^  frame  lit.ai  width.ai
    :~  (header binding.ai title.metadatum.association.ai lit.ai)
        ;h1: {(trip title)}
        (details initial.ai author.post.ai)
        ;article(class "w-100")
          ;*  con
        ==
        ;*  ?~  comments.ai  ;br;
        ;div(class "pt3 pl3 bt b--gray")
          ;h4(class "ma0"): Comments
          ;*  (turn comments.ai single-comment)
        ==
        (subscribe-box name.ai title.metadatum.association.ai email.ai lit.ai)
    ==
  ==
::
++  single-comment
  |=  p=post
  ^-  manx
  =/  deets=tape
    %-  trip
    %:  rap  3
      (print-date time-sent.p)  ' • '
      (scot %p author.p)
      ~
    ==
  =/  body  (snag 0 contents.p)
  ?>  ?=(%text -.body)
  ;div(class "flex flex-column w-100 ml3")
    ;p(class "gray f7 ma0 mt3", style "margin-block-end: 0;"): {deets}
    ;p(class "f6 ma0 mt1"): {(trip text.body)}
  ==
::
++  custom-style
  ^-  manx
  ;style:'''
         body {
           font-family: Inter, -apple-system, sans-serif;
         }
         a {
           font-weight: 600;
           text-decoration: none;
           cursor: pointer;
         }
         h1 {
           font-size: 2rem;
           font-weight: 800;
         }
         h2 {
           font-size: 1.875rem;
         }
         h3 {
           font-size: 1.25rem;
           font-weight: 600;
         }
         h4 {
           font-size: 1rem;
           font-weight: 600;
           line-height: 1.625;
         }
         p {
           font-size: 1rem;
           line-height: 1.625;
         }
         article > div > * {
           margin-block-start: 2rem;
           margin-block-end: 2rem;
         }
         '''
--
