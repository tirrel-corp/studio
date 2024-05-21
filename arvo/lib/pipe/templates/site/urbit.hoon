/-  *pipe, diary, groups
/+  *pipe-render
^-  versioned-site-template
:-  %2
|=  sinp=site-inputs
^-  website
|^  =/  [previews=marl pages=website]
      %+  roll  ~(tap by notes.sinp)
      |=  $:  [key=@da =note]
              [previews=marl pages=website]
          ==
      =/  [path=@t pre=manx page=[mime (unit mime) (unit tang)]]
        %:  article-build
            name.sinp
            binding.sinp
            key
            +.note
            quips.note
            channel.sinp
            email.sinp
            width.sinp
            lit.sinp
        ==
      :-  (snoc previews pre)
      (~(put by pages) path [-.page +<.page +>.page ~])
    =/  m  (index-page sinp previews)
    (~(put by pages) '/' [m ~ ~ ~])
::
+$  article-inputs
  $:  name=term
      =binding:eyre
      initial=@da
      =essay:diary
      =quips:diary
      =channel:channel:groups
      email=(unit binding:eyre)
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
      ;+  custom-style
    ==
    ;+  %^  frame  lit.si  width.si
        :*  (header binding.si title.meta.channel.si lit.si)
            %+  snoc
              previews
            (subscribe-box name.si title.meta.channel.si email.si lit.si)
  ==    ==
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
++  subscribe-box
  |=  [book=@tas title=@t email=(unit binding:eyre) lit=?]
  ^-  manx
  ?~  email  ;br;
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
    =action  (spud (weld path.u.email /subscribe))
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
  |=  [when=@da who=@p lit=?]
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
  ^-  [@t manx mime (unit mime) (unit tang)]
  =/  [con=marl err=(unit tang)]  (diary-contents-to-marl content.essay.ai)
  :*  (cat 3 '/' (strip-title title.essay.ai))
      (article-preview ai title.essay.ai)
      (article-page ai con title.essay.ai)
      ~   ::  snippet
      err
  ==
::
++  article-preview
  |=  [ai=article-inputs title=@t]
  ^-  manx
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai)
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
    ;*  %-  zing
    :~  ?:  ?&(=('' image.essay.ai) =(~ img))  ~
        :_  ~
        ;img(src (trip image.essay.ai));
    ::
        ?~  snippet  ~
        :_  ~
        ;p(class (weld "fw4" colors)): {(trip u.snippet)}
    ::
        :_  ~
        (details initial.ai author.essay.ai lit.ai)
    ==
::    ;+  ?:  =('' image.essay.ai)  ;br;
::        ;img(src (trip image.essay.ai));
::    ;+  ?~  snippet  ;br;
::        ;p(class (weld "fw4" colors)): {(trip u.snippet)}
::    ;+  (details initial.ai author.essay.ai lit.ai)
  ==
::
++  twitter-card
  |=  [title=@t description=(unit @t) img=(unit @t)]
  ^-  marl
  =/  studio-img   'https://tirrel.io/assets/stool.svg'
  =/  twitter-img  ?~(img studio-img u.img)
  %-  zing
  :~  :_  ~  ;meta(name "twitter:card", content "summary");
::      ;meta(name "twitter:site", content (trip site));
::      ;meta(name "twitter:creator", content (trip creator));
      :_  ~  ;meta(name "twitter:title", content (trip title));
      ?~  description  ~
      :_  ~  ;meta(name "twitter:description", content (trip u.description));
      :_  ~  ;meta(name "twitter:image", content (trip twitter-img));
  ==
::
++  article-page
  |=  [ai=article-inputs con=marl title=@t]
  ^-  mime
  =/  home-url  (spud path.binding.ai)
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai)
  ::
  :-  [%text %html ~]
  %-  as-octt:mimes:html
  %+  welp  "<!doctype html>"
  %-  en-xml:html
  ;html
    ;head
      ;*  :*  ;meta(charset "utf-8");
        ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
        ;link(rel "stylesheet", href "https://unpkg.com/tachyons@4.12.0/css/tachyons.min.css");
        ;title: {(trip title)} - by {(trip (scot %p author.essay.ai))}
        custom-style
        (twitter-card title.meta.channel.ai snippet img)
      ==
    ==
    ;+  %^  frame  lit.ai  width.ai
    :~  (header binding.ai title.meta.channel.ai lit.ai)
        ?:  =('' image.essay.ai)  ;br;
        ;img(src (trip image.essay.ai));
        ;h1: {(trip title)}
        (details initial.ai author.essay.ai lit.ai)
        ;article(class "w-100")
          ;*  con
        ==
::        ;*  ?~  comments.ai  ;br;
::        ;div(class "pt3 pl3 bt b--gray")
::          ;h4(class "ma0"): Comments
::          ;*  (turn comments.ai |=(p=post (single-comment p lit.ai)))
::        ==
::        (subscribe-box name.ai title.metadatum.association.ai email.ai lit.ai)
    ==
  ==
::
::++  single-comment
::  |=  [p=post lit=?]
::  ^-  manx
::  =/  color
::    ?:  lit
::      " near-black"
::    " whit"
::  =/  deets=tape
::    %-  trip
::    %:  rap  3
::      (print-date time-sent.p)  ' • '
::      (scot %p author.p)
::      ~
::    ==
::  =/  body  (render-contents contents.p)
::  ;div(class "flex flex-column w-100 ml3")
::    ;p(class "gray f7 ma0 mt3", style "margin-block-end: 0;"): {deets}
::    ;p(class (weld "f6 ma0 mt1" color)): {(trip body)}
::  ==
::
::++  render-contents
::  |=  c=(list content)
::  =|  out=@t
::  |-
::  ?~  c  out
::  %=  $
::    c  t.c
::    out  (append-content out i.c)
::  ==
::::
::++  append-content
::  |=  [str=@t c=content]
::  ^-  @t
::  ?-  -.c
::      %text       (cat 3 str text.c)
::      %mention    (cat 3 str (scot %p ship.c))
::      %reference
::    ?-  -.reference.c
::        %group
::      %:  rap  3
::          str
::          (scot %p entity.group.reference.c)
::          '/'
::          name.group.reference.c
::          ~
::      ==
::        %graph
::      %:  rap  3
::          str
::          (scot %p entity.group.reference.c)
::          '/'
::          name.group.reference.c
::          ~
::      ==
::        %app
::      %:  rap  3
::          str
::          (scot %p ship.reference.c)
::          '/'
::          desk.reference.c
::          ~
::      ==
::    ==
::      %url   (cat 3 str url.c)
::      %code  (cat 3 str expression.c)
::  ==
::
++  custom-style
  ^-  manx
  ;style:'''
         a {
           font-weight: 600;
           text-decoration: none;
           cursor: pointer;
         }
         h1 {
           font-size: 2.25rem;
         }
         h2 {
           font-size: 1.875rem;
         }
         h3 {
           font-size: 1.25rem;
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
         article > div > p {
           margin-block-start: 2rem;
           margin-block-end: 2rem;
         }
         '''
--
