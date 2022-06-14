|%
+$  from-field     [email=cord name=cord]
+$  content-field  [type=cord value=cord]
+$  personalization-field
  $:  to=(list cord) :: cc'd email addresses
      headers=(map cord cord)
      substitutions=(list [cord cord])
  ==
+$  email
  $:  from=from-field
      subject=cord
      content=(list content-field)
      personalizations=(list personalization-field) :: multiple emails
  ==
::
+$  action
  $%  [%send-email =email]
      [%set-creds api-key=(unit @t) email=(unit @t) ship-url=(unit @t)]
      [%unset-creds api-key=? email=? ship-url=?]
      [%add-list name=term mailing-list=(set @t)]
      [%del-list name=term]
      [%add-recipients name=term mailing-list=(set @t)]
      [%del-recipients name=term mailing-list=(set @t)]
      [%create-campaign-template name=term from=from-field email-sequence=(list [subject=cord content=cord])]
      [%start-campaign name=term template-name=term recipients=(each @t term) interval=@dr]
      [%del-campaign-template name=term]
      [%del-campaign name=term]
  ==
::
+$  update
  $%  $:  %initial
      creds=[(unit @t) (unit @t) (unit @t)]
      ml=(map term mailing-list)
      campaign-templates=(map term campaign-template)
      campaigns=(map term campaign)
    ==
  ==
::
+$  mailing-list  (map @t [token=@uv confirmed=?])
::
+$  campaign-template
  $:  from=from-field
      email-sequence=email-list
  ==
::
+$  campaign
  $:  next-time=@da
      recipients=(each @t term)
      template-name=term
      interval=@dr
      email-history=(list sent-email)
  ==
::
+$  sent-email
  $:  id=@ud
      sent-time=@da
      body=[subject=cord content=cord]
  ==
::
+$  email-list
  (map @ud email-list-item)
::
+$  email-list-item
  $:  prev=(unit @ud)
      next=(unit @ud)
      body=(unit [subject=cord content=cord])
  ==
::
++  email-list-handler
  |_  emails=email-list
  ++  get-first
    ^-  (unit [id=@ud body=[subject=cord content=cord]])
    =|  id=@ud
    |-
    ?~  email=(~(get by emails) id)
      ~
    ?~  body.u.email
      ?~  next.u.email
        ~
      $(id u.next.u.email)
    `[id u.body.u.email]
  ++  get-next
    |=  id=@ud
    ^-  (unit [id=@ud body=[subject=cord content=cord]])
    ?~  cur=(~(get by emails) id)
      ~
    ?~  next.u.cur
      ~
    =.  id  u.next.u.cur
    |-
    ?~  email=(~(get by emails) id)
      ~
    ?~  body.u.email
      ?~  next.u.email
        ~
      $(id u.next.u.email)
    `[id u.body.u.email]
  ++  edit
    |=  [id=@ud subject=cord content=cord]
    ^-  email-list
    ?~  email=(~(get by emails) id)
      emails
    =.  body.u.email  `[subject content]
    (~(put by emails) id u.email)
  ++  del
    |=  id=@ud
    ^-  email-list
    ?~  email=(~(get by emails) id)
      emails
    =.  body.u.email  ~
    (~(put by emails) id u.email)
  ++  ins
    |=  [prev=@ud subject=cord content=cord]
    ^-  email-list
    =/  id  ~(wyt by emails)
    ?~  prev-email=(~(get by emails) prev)
      (~(put by emails) id [~ ~ `[subject content]])
    ?~  next.u.prev-email
      =/  new-prev-email  u.prev-email(next `id)
      =.  emails  (~(put by emails) prev new-prev-email)
      (~(put by emails) id [`prev ~ `[subject content]])
    ?~  next-email=(~(get by emails) u.next.u.prev-email)
      !!
    =/  next  u.next.u.prev-email
    =/  email  [`prev `next `[subject content]]
    =.  next.u.prev-email  `id
    =.  prev.u.next-email  `id
    =.  emails  (~(put by emails) prev u.prev-email)
    =.  emails  (~(put by emails) id email)
    =.  emails  (~(put by emails) next u.next-email)
    emails
  ++  as-list
    ^-  (list [id=@ud body=[cord cord]])
    =/  first=(unit [id=@ud body=[cord cord]])  get-first
    ?~  first  ~
    =/  output=(list [id=@ud body=[cord cord]])  ~[u.first]
    =/  prev=[id=@ud body=[cord cord]]  u.first
    |-
    =/  cur=(unit [id=@ud body=[cord cord]])  (get-next id.prev)
    ?~  cur  output
    $(output (weld output ~[u.cur]), prev u.cur)
  --
--
