## <a name="info-check-spam"></a> If you don't get an email to confirm your visit

Follow these steps if you don't get an email to confirm your visit within 3 working days.

* Check your spam / junk folder on a computer or tablet (rather than a smart phone). If the confirmation email is there, mark it as 'not spam' so that you don't have problems with future emails.
* Contact the prison <%= conditional_text(prison_phone, 'on ', ' or') %> by email at <%= prison_email_link %>. Please don't contact us sooner than 3 working days, as we won't be able to comment on booking requests that are being processed.

## <a name="#info-id-requirements"></a> ID you need for each visit

<%= render partial: 'content/id_requirements' %>

If you have any questions about ID requirements, please contact the prison.

## <a name="#info-cancelling"></a> Changing or cancelling your visit

If you need to change or cancel your visit, please contact us as soon as you can.

<%= conditional_text(prison_phone, '* telephone: ') %>
* email: <%= prison_email_link %>

## <a name="#info-what-to-bring"></a> What to bring

* two forms of ID, one with your address
* a small amount of money for tea and coffee during the visit – you won’t be able to give the prisoner any money
* for more information about what to bring, for example clothes, please see the <%= prison_link(visit) %> page
* if you’re bringing someone else’s child: a letter from that child’s parents giving you permission

## <a name="#info-what-to-expect"></a> What to expect when visiting prison

You will be searched before entering the prison visiting room. Prison staff may check your pockets, pat you down and ask you to go through a metal detector. Dogs may also be used to detect illegal substances.

## <a name="#info-what-not-to-bring"></a> What not to bring

Please do not bring anything restricted or illegal to the prison. For more information about what you are allowed to bring, please see the <%= prison_link(visit) %> page.
