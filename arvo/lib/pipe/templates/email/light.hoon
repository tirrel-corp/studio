/-  *pipe, *post
/+  *pipe-render
^-  versioned-email-template
:-  %0
|=  in=email-inputs
^-  [email-mime (unit tang)]
|^  =/  [page=manx err=(unit tang)]  (article-page in)
    :_  err
    :-  title.note.in
    :-  [%text %html ~]
    %-  as-octt:mimes:html
    %-  en-xml:html
    page
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
  ;p
    =style  "font-size: 0.875rem; color: #777777; font-weight: 300"
    ; {t}
  ==
::
++  article-page
  |=  in=email-inputs
  ^-  [manx (unit tang)]
  =/  [con=marl err=(unit tang)]
    (diary-contents-to-marl content.note.in)
  :_  err
  ;div
    ;+  %-  frame
    :*  (header site-binding.in title.meta.channel.in)
        ;h1(style "font-size: 2.25rem; line-height: 1.25;")
          ; {(trip title.note.in)}
        ==
        (details sent.note.in author.note.in)
        (snoc con footer)
    ==
  ==
--
