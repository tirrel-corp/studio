/-  *pipe
/+  pipe-templates-blog-basic,
    pipe-templates-blog-urbit,
    pipe-templates-collection-gallery,
    pipe-templates-collection-linktree,
    pipe-templates-email-light
|%
++  blog-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%basic pipe-templates-blog-basic]
      [%urbit pipe-templates-blog-urbit]
  ==
++  collection-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%gallery pipe-templates-collection-gallery]
      [%linktree pipe-templates-collection-linktree]
  ==
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
