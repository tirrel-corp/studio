|%
::  $saga: version synchronisation state
::    %dex: publisher is ahead
::    %lev: we are ahead
::    %chi: full sync
::
+$  saga
  $~  [%lev ~]
  $%  [%dex ver=@ud]
      [%lev ~]
      [%chi ~]
  ==

+$  epic  @ud
--
