/-  *pipe, diary, groups, channels
/+  *pipe-render
^-  versioned-site-template
:-  %0
|=  sinp=site-inputs
^-  website
|^  =/  [previews=marl pages=website]
      %+  roll  ~(tap by posts.sinp)
      |=  $:  [key=@da post=(unit post:channels)]
              [previews=marl pages=website]
          ==
      ?~  post  [previews pages]
      =/  [path=@t pre=manx page=[mime (unit paywall-snip) (unit tang)]]
        %:  article-build
            name.sinp
            binding.sinp
            key
            +>.u.post
            replies.u.post
            channel.sinp
            headline.sinp
            profile-img.sinp
            header-img.sinp
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
      =essay:channels
      =replies:channels
      =channel:channel:groups
      headline=@t
      profile-img=@t
      header-img=@t
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
      ;link(rel "stylesheet", href "https://cdn.jsdelivr.net/npm/water.css@2/out/water.css");
      ;+  custom-style
    ==
    ;+  %-  frame
        :~  (header-index binding.si title.meta.channel.si headline.si profile-img.si header-img.si)
            ;div(style "display: flex; flex-direction: column; align-items:center; width:100%")
              ;div(style "display: flex; flex-direction: row; flex-wrap: wrap; gap: 2rem; max-width:1200px; padding-left: 3em; padding-right: 3em")
                ;*  previews
              ==
            ==
  ==    ==
::
++  frame
  |=  m=marl
  ^-  manx
  ;body(style "padding:0; margin:0; max-width: unset")
     ;div(style "width: 100%; height: 100%; max-width: unset; margin-bottom:6rem")
       ;*  m
     ==
  ==
::
++  header-index
  |=  [=binding:eyre title=@t headline=@t profile-img=@t header-img=@t]
  ^-  manx
  =/  home-url  (spud path.binding)
  ;div(style "margin-bottom: 2em; width: 100%; object-fit:cover;")
    ;img(src (trip header-img), style "height:350px; width: 100%; object-fit:cover");
    ;div(style "width:100%; display: flex; flex-direction:column; align-items:center; position:relative; top: -48px")
      ;img(src (trip profile-img), style "height:80px; width: 80px; border-radius: 50px; border: 4px solid white; object-fit:cover;");

      ;a(href "{home-url}")
        ;h2(style "margin: 0"): {(trip title)}
      ==
      ;p(style "margin-bottom:0; margin-top:2rem"): {(trip headline)}
    ==
  ==
::
++  header
  |=  [=binding:eyre title=@t headline=@t profile-img=@t header-img=@t]
  ^-  manx
  =/  home-url  (spud path.binding)
  ;div(style "margin-bottom: 2em")
    ;a(href "{home-url}")
      ;h3: {(trip title)}
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
  ;p(style "margin-block-start: 0em; margin-block-end: 2em; border-bottom: 1px solid lightgray; padding-block-end:2em"): {t}
::
++  article-build
  |=  ai=article-inputs
  ^-  [@t manx mime (unit paywall-snip) (unit tang)]
  =/  [con=marl err=(unit tang)]   (diary-contents-to-marl content.essay.ai)
  =/  [snip=marl err=(unit tang)]  (diary-contents-snippet content.essay.ai 5)
  ?>  ?=(%diary -.kind-data.essay.ai)
  :*  (cat 3 '/' (strip-title title.kind-data.essay.ai))
      (article-preview ai title.kind-data.essay.ai)
      (article-page ai con title.kind-data.essay.ai)
      `[(article-head ai snip title.kind-data.essay.ai) (article-body ai snip title.kind-data.essay.ai)]
      err
  ==
::
++  article-preview
  |=  [ai=article-inputs title=@t]
  ^-  manx
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai 200)
  =/  url=tape
    %-  trip
    ?~  path.binding.ai
      (cat 3 '/' (strip-title title))
    (rap 3 (spat path.binding.ai) '/' (strip-title title) ~)
  ?>  ?=(%diary -.kind-data.essay.ai)
  =/  date  (print-date initial.ai)
  ;a(href url, style "color: unset; text-decoration:unset; width: 357px; display: block; background-color: rgba(255,255,255,0.25); border-radius: 10px 10px 10px 10px;", class "preview")
    ;div(href url, style "flex-direction: column; display: flex")
    ;*  %-  zing
    :~  ?:  =('' image.kind-data.essay.ai)
          :_  ~
          ;img(src "https://tirrel.io/assets/stool-gray.png", style "object-fit:cover; width: 100%; height: 60%; border-radius:10px 10px 0 0");
        :_  ~
        ;img(src (trip image.kind-data.essay.ai), style "object-fit:cover; width: 100%; height: 60%; border-radius:10px 10px 0 0; overflow: hidden");
    ::
        :_  ~
        ;div(style "padding-left: 0.5em; padding-right: 0.5em; display: flex; flex-direction:column; height: 40%")
          ;div
            ;h2(style "margin-block-end: 0.25em; margin-block-start: 0.5em"): {(trip title)}
            ;p(style "margin-block-start: 0.25em;"): {(trip date)}
          ==
          ;p(style "margin-block-start: 0em"): {(scow %p author.essay.ai)}
        ==
      ==
    ==
  ==
::
++  twitter-card
  |=  [title=@t description=(unit @t) img=(unit @t)]
  ^-  marl
  =/  studio-img   'https://tirrel.io/assets/stool.svg'
  =/  twitter-img  ?~(img studio-img u.img)
  %-  zing
  :~  :_  ~  ;meta(name "twitter:card", content "summary_large_image");
::      ;meta(name "twitter:site", content (trip site));
::      ;meta(name "twitter:creator", content (trip creator));
      :_  ~  ;meta(name "twitter:title", content (trip title));
      ?~  description  ~
      :_  ~  ;meta(name "twitter:description", content (trip u.description));
      :_  ~  ;meta(name "twitter:image", content (trip twitter-img));
      :_  ~  ;meta(name "og:title", content (trip title));
      ?~  description  ~
      :_  ~  ;meta(name "og:description", content (trip u.description));
      :_  ~  ;meta(name "og:image", content (trip twitter-img));
  ==
::
++  article-page
  |=  [ai=article-inputs con=marl title=@t]
  ^-  mime
  :-  [%text %html ~]
  %-  as-octt:mimes:html
  %+  welp  "<!doctype html>"
  %-  en-xml:html
  (article-manx ai con title)
::
++  article-manx
  |=  [ai=article-inputs con=marl title=@t]
  =/  home-url  (spud path.binding.ai)
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai 200)
  ^-  manx
  ;html
    ;head
      ;*  (article-head ai con title)
    ==
    ;+  %-  frame
      :_  ~
      ;div(style "max-width: 800px; margin: auto;")
        ;*  (article-body ai con title)
      ==
  ==
++  article-head
  |=  [ai=article-inputs con=marl title=@t]
  ^-  marl
  =/  home-url  (spud path.binding.ai)
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai 200)
  :*  ;meta(charset "utf-8");
    ;meta(name "viewport", content "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0");
    ;link(rel "stylesheet", href "https://cdn.jsdelivr.net/npm/water.css@2/out/water.css");
    ;title: {(trip title)} - by {(trip (scot %p author.essay.ai))}
    custom-style
    (twitter-card title.meta.channel.ai snippet img)
  ==
++  article-body
  |=  [ai=article-inputs con=marl title=@t]
  ^-  marl
  ?>  ?=(%diary -.kind-data.essay.ai)
  =/  home-url  (spud path.binding.ai)
  =/  [snippet=(unit @t) img=(unit @t)]  (new-snip essay.ai 200)
  :~  (header binding.ai title.meta.channel.ai headline.ai profile-img.ai header-img.ai)
      ?:  =('' image.kind-data.essay.ai)  ;br;
      ;img(src (trip image.kind-data.essay.ai), style "object-fit:cover; width: 100%; border-radius:5px");
      ;h1: {(trip title)}
      (details initial.ai author.essay.ai)
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
  =/  font-file=(unit @t)  (~(get by style-vars.sinp) 'font')
  =/  font-str=@t
    ?~  font-file
      'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfMZhrib2Bg-4.ttf'
    u.font-file
  =.  style-vars.sinp  (~(del by style-vars.sinp) 'font')
  =/  css-vars=wain
    %+  turn  ~(tap by style-vars.sinp)
    |=  [k=@t v=@t]
    (rap 3 k ': ' v ';' ~)
  =/  font-import=wain
    :~  '@font-face {'
          'font-family: \'imported-font\';'
          (rap 3 'src: url(\'' font-str '\');' ~)
        '}'
    ==
  =/  css-str
    %-  of-wain:format
    %+  weld  font-import
    :*  'body { font-family: \'imported-font\' }'
::        '.preview:hover { border: 2px solid black; }'
        ':root {'
        (snoc css-vars '}')
    ==
  ;style: {(trip css-str)}
::
--
