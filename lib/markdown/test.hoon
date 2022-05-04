/+  *markdown
/*  test-json  %json  /lib/markdown/test/json
|%
++  run-tests
  |=  [which=?(%all [start=@ud num=@ud]) show-success=? show-failure=?]
  ?>  ?=(%a -.test-json)
  =/  segment=(list json)
    ?:  ?=(%all which)  p.test-json
    (scag num.which (slag start.which p.test-json))
  =|  num-passed=@ud
  =|  num-failed=@ud
  =|  total=@ud
  |-
  =*  loop  $
  ?~  segment
    ~?  >    (gth num-passed 0)  "{<num-passed>}/{<total>} tests succeeded"
    ~?  >>>  (gth num-failed 0)  "{<num-failed>}/{<total>} tests failed"
    %done
  =/  success=?  (run-test i.segment show-success show-failure)
  %=  loop
    num-failed  ?.(success +(num-failed) num-failed)
    num-passed  ?:(success +(num-passed) num-passed)
    total       +(total)
    segment     t.segment
  ==
::
++  run-test
  |=  [jon=json show-success=? show-failure=?]
  ^-  ?
  ?>  ?=(%o -.jon)
  =/  input=@t
    =+  (~(got by p.jon) 'markdown')
    ?>  ?=(%s -.-)  p.-
  =/  expected=@t
    =/  hl  (~(got by p.jon) 'html')
    ?>  ?=(%s -.hl)
    =/  clean=(each tape tang)
      (mule |.((en-xml:html (need (de-xml:html p.hl)))))
    ?:  ?=(%| -.clean)  p.hl
    (crip p.clean)
  =/  section=@t
    =+  (~(got by p.jon) 'section')
    ?>  ?=(%s -.-)  p.-
  =/  example=@ta
    =+  (~(got by p.jon) 'example')
    ?>  ?=(%n -.-)  p.-
  =/  parse-output  (mule |.((parse input)))
  ?:  ?=(%| -.parse-output)
    ~?  >>>  show-failure  'parser crashed'
    ~?  >>>  show-failure  `@t`(rap 3 'input:  "' input '"' ~)
    ~?  >>>  show-failure  `@t`(cat 3 'expected:  ' expected)
    ~?  >>   show-failure
      '------------------------------------------------------------------------'
    %.n
  =/  render-output   (mule |.((render p.parse-output)))
  ?:  ?=(%| -.render-output)
    ~?  >>>  show-failure  'renderer crashed'
    ~?  >>>  show-failure  `@t`(rap 3 'input:  "' input '"' ~)
    ~?  >>>  show-failure  'parse-output'^p.parse-output
    ~?  >>>  show-failure  `@t`(cat 3 'expected:  ' expected)
    ~?  >>   show-failure
      '------------------------------------------------------------------------'
    %.n
  =/  html-result
    ?:  =('\0a' (end 3 (swp 3 expected)))
      (cat 3 (crip (en-xml:html p.render-output)) '\0a')
    (crip (en-xml:html p.render-output))
  ?.  =(html-result expected)
    ~?  >>>  show-failure  'bad result'
    ~?  >>>  show-failure  `@t`(rap 3 'input:  "' input '"' ~)
    ~?  >>>  show-failure  `@t`(cat 3 'result:  ' html-result)
    ~?  >>>  show-failure  `@t`(cat 3 'expected:  ' expected)
    ~?  >>   show-failure
      '------------------------------------------------------------------------'
    %.n
  ~?  >  show-success  'success'
  ~?  >  show-success  `@t`(rap 3 'input:  "' input '"' ~)
  ~?  >  show-success  `@t`(cat 3 'expected:  ' expected)
  ~?  >>   show-success
    '------------------------------------------------------------------------'
  %.y
--
