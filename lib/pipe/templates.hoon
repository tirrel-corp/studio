/-  *pipe
/+  mip, :: for some reason exposing this breaks everything
    pipe-templates-site-basic,
    pipe-templates-site-urbit,
    pipe-templates-site-gallery,
    pipe-templates-site-linktree,
    pipe-templates-email-light
|%
++  site-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%basic pipe-templates-site-basic]
      [%urbit pipe-templates-site-urbit]
  ==
++  blog-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%basic pipe-templates-site-basic]
      [%urbit pipe-templates-site-urbit]
  ==
++  collection-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%gallery pipe-templates-site-gallery]
      [%linktree pipe-templates-site-linktree]
  ==
++  site-templates-2
  ::  I think this is a fine way of doing this but I had some trouble
  ::  basically just triyng to do a bunch of ~(put bi a) calls in a row and not sure why that's wrong
  ^-  (mip:mip ?(%blog %collection) term site-template)
  =|  a=(mip:mip ?(%blog %collection) term site-template)
  %-  ~(gas by a)
  :~  [%blog blog-templates]
      [%collection collection-templates]
  ==
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
