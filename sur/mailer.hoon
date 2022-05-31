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
      email-sequence=(list [subject=cord content=cord])
  ==
::
+$  campaign
  $:  next-time=@da
      index=@ud
      recipients=(each @t term)
      template-name=term
      interval=@dr
  ==
--
