/-  *pipe, *post, store=graph-store, metadata-store
/+  *pipe-render, cram
^-  $-(site-inputs website)
|=  sinp=site-inputs
^-  website
|^  %-  ~(gas by *website)
    :-  (index-page sinp)
    %+  turn  posts.sinp
    |=  [initial=@da =post]
    %:  article-page
        name.sinp
        binding.sinp
        initial
        post
        association.sinp
    ==
::
+$  article-inputs
  $:  name=term
      =binding:eyre
      initial=@da
      =post
      =association:metadata-store
  ==
::
++  index-page
  |=  si=site-inputs
  ^-  [path mime]
  =/  home-url  (spud path.binding.si)
  :-  /
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
    ;+  %-  frame
    :*  (header binding.si title.metadatum.association.si)
        %+  turn  posts.si
        |=  [initial=@da =post]
        ^-  manx
        %:  article-preview
            name.si
            binding.si
            initial
            post
            association.si
        ==
    ==
  ==
::
++  frame
  |=  m=marl
  ^-  manx
  ;body(class "w-100 h-100 flex flex-column items-center near-black bg-white")
     ;div
       =class  "pa1 pv3-ns w-100 mw6"
       ;*  m
     ==
  ==
::
++  header
  |=  [=binding:eyre title=@t]
  ^-  manx
  =/  home-url  (spud path.binding)
  ;div(class "mb5 flex justify-between items-center")
    ;a(href "{home-url}", class "link black")
      ;h3: {(trip title)}
    ==
::    ;a(id "subscribe-button", class "fw4 ph3 pv2 white bg-near-black pointer br2"): Subscribe
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
++  article-preview
  |=  ai=article-inputs
  ^-  manx
  =/  title=content  (snag 0 contents.post.ai)
  ?>  ?=(%text -.title)
  =/  snippet=(unit @t)  (snip contents.post.ai)
  =/  url=tape
    %-  trip
    ?~  path.binding.ai
      (cat 3 '/' (strip-title text.title))
    (rap 3 (spat path.binding.ai) '/' (strip-title text.title) ~)
  ;a(class "db link mb5 near-black", href url)
    ;h3(class "black"): {(trip text.title)}
    ;+  ?~  snippet  *manx
        ;p(class "fw4 dark-gray"): {(trip u.snippet)}
    ;+  (details initial.ai author.post.ai)
  ==
::
++  article-page
  |=  ai=article-inputs
  ^-  [path mime]
  =/  home-url  (spud path.binding.ai)
  ::
  =/  title=content  (snag 0 contents.post.ai)
  ?>  ?=(%text -.title)
  :-  /(strip-title text.title)
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
      ;title: {(trip text.title)} • by {(trip (scot %p author.post.ai))}
      ;+  custom-style
    ==
    ;+  %-  frame
    :~  (header binding.ai title.metadatum.association.ai)
        ;h1: {(trip text.title)}
        (details initial.ai author.post.ai)
        ;article(class "w-100")
          ;*  (contents-to-marl (slag 1 contents.post.ai))
        ==
::        ;form(id "subscribe", method "post", class "db w-100 flex flex-column items-center br3 bw2 ba b--near-black pa2 mb4")
::          ;p(style "margin-block-end: 0;"): Subscribe to {(trip title.metadatum.association.ai)}:
::          ;input(name "email-address", class "db pa2 input-reset ba b--near-black mv3 br2", type "email", placeholder "your@email.com");
::          ;button(id "subscribe-button", type "submit", class "mb3 db fw4 ph3 pv2 bg-near-black white pointer br2 bn"): Sign Up
::        ==
    ==
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
           color: rgb(0,177,113);
           text-decoration: none;
           cursor: pointer;
         }
         h1 {
           font-size: 2.25rem;
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
