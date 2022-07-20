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
        %:  gallery-build
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
      (~(put by pages) path [-.page +.page ~]) :: create post pages
    =/  m  (index-page sinp previews) :: create index page
    (~(put by pages) '/' [m ~ ~])
::
+$  gallery-inputs
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
      ;+  custom-style
    ==
    ;+  %^  frame  lit.si  width.si
        :*  (header binding.si title.metadatum.association.si lit.si)
            previews
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
      ;div(class "grid")
        ;*  m
      ==
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
  ;div(class "w-100")
    ;a(href "{home-url}", class (weld "link" colors))
      ;h3: {(trip title)}
    ==
    ;hr;
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
++  gallery-build
  |=  gi=gallery-inputs
  ^-  [@t manx mime (unit tang)]
  =/  [con=marl err=(unit tang)]  (contents-to-marl (slag 1 contents.post.gi))
  =/  title=content  (snag 0 contents.post.gi)
  ?>  ?=(%text -.title)
  :*  (cat 3 '/' (strip-title text.title))
      (image-preview gi text.title)
      (single-image-page gi con text.title)
      err
  ==
::
++  image-preview
  |=  [gi=gallery-inputs title=@t]
  ^-  manx
  ?>  ?=([[%text @] $%([%url @] [%reference *]) ~] contents.post.gi)
  =*  link  i.t.contents.post.gi
  =/  colors
    ?:  lit.gi
      " near-black"
    " white"
  ?.  ?=([%url @] link)  
    =/  ref=reference  +.i.t.contents.post.gi
    =/  hrf
      ?-    -.ref
          %graph
        (trip (rap 3 'web+urbitgraph://' (scot %p entity.group.ref) '/' name.group.ref ~))
          %group
        (trip (rap 3 'web+urbitgraph://' (scot %p entity.group.ref) '/' name.group.ref ~))
          %app
        (trip (rap 3 'web+urbitgraph://' (scot %p ship.ref) '/' desk.ref (join '/' path.ref)))
      ==
    ;a(class (weld "item" colors), target "_blank", href hrf)
        ;p(class "item"): {(trip title)}
    ==

  ;a(class (weld "item" colors), target "_blank", href (trip +.link))
    ;p: {(trip title)}
  ==
::
++  single-image-page
  |=  [gi=gallery-inputs con=marl title=@t]
  ^-  mime
  =/  home-url  (spud path.binding.gi)
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
      ;title: {(trip title)} - by {(trip (scot %p author.post.gi))}
      ;+  custom-style
    ==
    ;+  %^  frame  lit.gi  width.gi
    :~  (header binding.gi title.metadatum.association.gi lit.gi)
        ;h1(class "w-100"): {(trip title)}
        (details initial.gi author.post.gi lit.gi)
        ;article(class "w-100")
          :: replace with image content
          ;img@"https://dachus-tiprel.nyc3.digitaloceanspaces.com/dachus-tiprel/2022.6.27..05.10.30-8E158540-7488-4B8E-A734-1EBF3AEECE67.jpeg";
        ==
    ==
  ==
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
         .grid {
           display: flex;
           flex-direction: column;
           column-gap: 0.25rem;
           align-items: center;
           text-align: center;
         }
         .item {
           flex: 1 1 30%;
           max-width: 33%;
         }
         '''
--
