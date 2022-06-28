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
      [%gallery pipe-templates-site-gallery] :: TODO: REMOVE; temporary for testing only
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
  ^-  (mip:mip ?(%blog %collection) term site-template)
  %-  ~(gas by *(mip:mip ?(%blog %collection) term site-template))
  :~  [%blog blog-templates]
      [%collection collection-templates]
  ==
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
