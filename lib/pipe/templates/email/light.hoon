/-  *pipe, *post, store=graph-store, metadata-store
/+  *pipe-render, cram
^-  email-template
|=  in=email-inputs
^-  (each email tang)
|^  =/  title=content  (snag 0 contents.post.in)
    ?>  ?=(%text -.title)
    =/  page=(each manx tang)  (article-page in)
    ?:  ?=(%| -.page)
      [%.n p.page]
    :-  %.y
    :-  text.title
    :-  [%text %html ~]
    %-  as-octt:mimes:html
    %-  en-xml:html
    p.page
::
++  frame
  |=  m=marl
  ^-  manx
  ;div
     ;div
       =style  "max-width: 44rem; color: #111111; width: 90%;"
       ;*  m
     ==
  ==
::
++  header
  |=  [site-binding=(unit binding:eyre) title=@t]
  ^-  manx
  ?~  site-binding
    ;div
      =style  "border-bottom: 1px solid #aaaaaa; margin-bottom: 2rem;"
      ;h1
        =style  "color: #000000; font-size: 1.5rem; line-height: 1.25;"
        ; {(trip title)}
      ==
    ==
  =/  home-url
    (trip (cat 3 (need site.u.site-binding) (spat path.u.site-binding)))
  ;div
    =style  "border-bottom: 1px solid #aaaaaa; margin-bottom: 2rem;"
    ;a(href "{home-url}", class "link", style "text-decoration: none")
      ;h1
        =style  "color: #000000; font-size: 1.5rem; line-height: 1.25;"
        ; {(trip title)}
      ==
    ==
  ==
::
++  footer
  ^-  manx
  ;div
    =style  "border-top: 1px solid #aaaaaa; margin-top: 2rem;"
    ;a
      =href   "%unsubscribe-callback%"
      =style  "font-size: 0.875rem; color: #777777; font-weight: 300"
      ; Unsubscribe
    ==
  ==
::
++  details
  |=  [when=@da who=@p]
  =/  t=tape
    %-  trip
    %:  rap  3
      (print-date when)  ' • '
      (scot %p who)
      ~
    ==
  ;p ::(class "f6 gray fw3 sans-serif", style "margin-block-end: 0;"): {t}
    =style  "font-size: 0.875rem; color: #777777; font-weight: 300"
    ; {t}
  ==
::
++  article-page
  |=  in=email-inputs
  ^-  (each manx tang)
  =/  con=(each marl tang)
    (contents-to-marl (slag 1 contents.post.in))
  ?:  ?=(%| -.con)
    [%.n p.con]
  =/  title=content  (snag 0 contents.post.in)
  ?>  ?=(%text -.title)
  :-  %.y
  ;div
    ;+  %-  frame
    :*  (header site-binding.in title.metadatum.association.in)
        ;h1(style "font-size: 2.25rem; line-height: 1.25;")
          ; {(trip text.title)}
        ==
        (details time-sent.post.in author.post.in)
        (snoc p.con footer)
    ==
  ==
--
