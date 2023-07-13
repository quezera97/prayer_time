String joinedTextPrivacyPolicy(){
  var lineOne = 'We value your privacy and we have a simple policy:';
  var lineTwo = 'We do not collect any personal information from our users.';
  var lineThree = 'We do not require you to create an account, and we do not store any data on our servers.';
  var lineFour = 'By using our app, you agree to the terms of this privacy policy.';
  var lineFive = 'If you have any questions or concerns, please contact us at support@example.com';

  var joinedText = '$lineOne\n\n\n$lineTwo\n\n$lineThree\n\n\n$lineFour\n\n$lineFive';

  return joinedText;
}