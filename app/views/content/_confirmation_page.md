## <a name="info-check-spam"></a> If you don't get an email to confirm your visit

Follow these steps if you don't get an email to confirm your visit within 3 working days.

* Check your spam / junk folder on a computer or tablet (rather than a smart phone). If the confirmation email is there, mark it as 'not spam' so that you don't have problems with future emails.
* Contact the prison <%= conditional_text(prison_phone, 'on ', ' or') %> by email at <%= prison_email_link %>. Please don't contact us sooner than 3 working days, as we won't be able to comment on booking requests that are being processed.

## <a name="#info-id-requirements"></a> ID you need for each visit

<%= render partial: 'content/id_requirements', locals: { output_format: :html } %>

If you have any questions about ID requirements, please contact the prison.

## <a name="#info-cancelling"></a> Changing or cancelling your visit

If you need to change or cancel your visit, please contact us as soon as you can.

<%= conditional_text(prison_phone, '* telephone: ') %>
* email: <%= prison_email_link %>
