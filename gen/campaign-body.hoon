:-  %say
|=  *
:-  %noun
=/  subject=cord  'Email Campaign'
=/  content-1=cord
  %-  crip
  %-  en-xml:html
  ;div
    ;h1: Email #1!
    ;p: This is the first email
  ==
=/  content-2=cord
  %-  crip
  %-  en-xml:html
  ;div
    ;h1: Email #2!
    ;p: This is the second email
  ==
=/  content-3=cord
  %-  crip
  %-  en-xml:html
  ;div
    ;h1: Email #3!
    ;p: This is the final email
  ==
:~  [subject content-1]
  [subject content-2]
  [subject content-3]
==