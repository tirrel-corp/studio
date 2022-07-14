/-  *pipe
/+  pipe-templates-site-basic,
    pipe-templates-site-urbit,
    pipe-templates-site-gallery,
    pipe-templates-site-linktree,
    pipe-templates-email-light
|%
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
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
