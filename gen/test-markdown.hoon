/+  markdown-test
:-  %say
|=  $:  ^
        $:  which=$@(%all [start=@ud num=@ud])
            print=?(~ [%show-all ~] [%success ~] [%fail ~])
        ==
        ~
    ==
:-  %noun
=/  [success=? fail=?]
  ?-  print
    ~              [%.n %.n]
    [%show-all ~]  [%.y %.y]
    [%success ~]   [%.y %.n]
    [%fail ~]      [%.n %.y]
  ==
(run-tests:markdown-test which success fail)
