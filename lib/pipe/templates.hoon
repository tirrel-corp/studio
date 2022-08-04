/-  *pipe
/+  pipe-templates-site-basic,
    pipe-templates-site-urbit,
    pipe-templates-email-light
|%
++  site-templates
  ^-  (map term versioned-site-template)
  %-  ~(gas by *(map term versioned-site-template))
  :~  [%basic pipe-templates-site-basic]
      [%urbit pipe-templates-site-urbit]
  ==
++  email-templates
  ^-  (map term versioned-email-template)
  %-  ~(gas by *(map term versioned-email-template))
  :~  [%light pipe-templates-email-light]
  ==
--
