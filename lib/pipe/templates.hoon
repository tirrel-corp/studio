/-  *pipe
/+  pipe-templates-site-basic,
    pipe-templates-site-urbit,
    pipe-templates-email-light
|%
++  site-templates
  ^-  (map term site-template)
  %-  ~(gas by *(map term site-template))
  :~  [%basic pipe-templates-site-basic]
      [%urbit pipe-templates-site-urbit]
  ==
++  email-templates
  ^-  (map term email-template)
  %-  ~(gas by *(map term email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
