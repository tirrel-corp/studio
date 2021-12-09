/-  *pipe, *post, store=graph-store, metadata-store
/+  *pipe-render, cram
^-  $-(site-inputs website)
|=  sinp=site-inputs
^-  website
|^  %-  ~(gas by *website)
    :-  (index-page sinp)
    %+  turn  posts.sinp
    |=  [initial=@da =post comments=(list post)]
    %:  article-page
        name.sinp
        binding.sinp
        initial
        post
        comments
        association.sinp
        email.sinp
    ==
::
+$  article-inputs
  $:  name=term
      =binding:eyre
      initial=@da
      =post
      comments=(list post)
      =association:metadata-store
      email=?
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
        %-  snoc
        :_  (subscribe-box name.si title.metadatum.association.si email.si)
        %+  turn  posts.si
        |=  [initial=@da =post comments=(list post)]
        ^-  manx
        %:  article-preview
            name.si
            binding.si
            initial
            post
            comments
            association.si
            email.si
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
  ==
::
++  subscribe-box
  |=  [book=@tas title=@t email=?]
  ^-  manx
  ?.  email  ;br;
  ;form
    =id  "subscribe"
    =method  "post"
    =action  "/mailer/subscribe"
    =class   "db w-100 flex flex-column items-center br3 bw2 ba b--near-black pa2 mb4"
    ;p(style "margin-block-end: 0;"): Subscribe to {(trip title)}
    ;input(name "book", type "hidden", value "{(trip book)}");
    ;input
      =name   "who"
      =class  "db pa2 input-reset ba b-near-black mv3 br3"
      =type   "email"
      =placeholder  "your@email.com"
    ;
    ==
    ;button
      =id     "subscribe"
      =type   "submit"
      =class  "mb3 db fw4 ph3 pv2 bg-near-black white pointer bt3 bn"
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
        ;*  ?~  comments.ai  ;br;
        ;div(class "pt3 pl3 bt b--gray")
          ;h4(class "ma0"): Comments
          ;*  (turn comments.ai single-comment)
        ==
        (subscribe-box name.ai title.metadatum.association.ai email.ai)
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
