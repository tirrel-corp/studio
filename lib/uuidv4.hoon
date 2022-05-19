|%
++  to-uuid
  |=  eny=@
  ^-  @t
  =/  rng  ~(. og eny)
  =^  ran-1  rng
    (rads:rng 0xffff.ffff)
  =^  ran-2  rng
    (rads:rng 0xffff)
  =^  ran-3  rng
    (rads:rng 0xffff)
  =^  ran-4  rng
    (rads:rng 0xffff)
  =^  ran-5  rng
    (rads:rng 0xffff.ffff.ffff)
  %+  rap  3
  :~  (hex ran-1 8)
      '-'
      (hex ran-2 4)
      '-'
      (hex ran-3 4)
      '-'
      (hex ran-4 4)
      '-'
      (hex ran-5 12)
  ==
::
++  hex
  |=  [n=@ l=@]
  =/  s  `@t`(rsh [3 2] (scot %x n))
  =/  m  (met 3 s)
  ?:  =(m l)  s
  ?>  (lth m l)
  (cat 3 (crip (reap (sub l m) '0')) s)
--
