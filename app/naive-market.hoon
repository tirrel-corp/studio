/+  default-agent
^-  agent:gall
|_  =bowl:gall
+*  this  .
++  on-init   `this
    def   ~(. (default-agent this %|) bowl)
++  on-save   !>(~)
++  on-load   on-load:def
++  on-poke   on-poke:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
