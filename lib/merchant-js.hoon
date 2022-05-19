/+  *merchant
|_  public-key=(unit @t)
::
++  pk-var-definition
  %-  trip
  %+  rap  3
  :~  'let publicKey = "'
      (need public-key)
      '";'
  ==
::
++  card-button
  %-  trip
  '''
  let cardBtn = document.querySelector("#card-btn");
  let cardDetails = {
    number: "4007400000000007",
    cvv: "111"
  };
  cardBtn.onclick = () => {
    encrypt(JSON.stringify(cardDetails), publicKey).then((msg) => {
     createCard(msg.encryptedMessage).then((r) => {
       console.log(r);
     });
    });
  };
  '''
::
++  pay-button
  %-  trip
  '''
  let payBtn = document.querySelector("#pay-btn");
  let cvv = {
    cvv: "111"
  };

  payBtn.onclick = () => {
    encrypt(JSON.stringify(cvv), publicKey).then((msg) => {
     createPayment(msg.encryptedMessage).then((r) => {
      console.log(r);
     });
    });
  };
  '''
::
++  create-card-function
  %-  trip
  '''
  const createCard = async (msgKey) => {
    let result = await fetch('/merchant/card', {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        idempotencyKey: uuidv4(),
        keyId: 'key1',
        encryptedData: msgKey,
        billingDetails: {
          name: '',
          city: '',
          country: 'US',
          'line1': '',
          'line2': null,
          district: 'TX',
          postalCode: ''
        },
        expMonth: 12,
        expYear: 2023
      })
    });
    return result.json();
  };
  '''
::
++  create-payment-function
  %-  trip
  '''
  const createPayment = async (msgKey) => {
    let result = await fetch('/merchant/payment', {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        idempotencyKey: uuidv4(),
        keyId: 'key1',
        amount: {
          amount: '10.00',
          currency: 'USD'
        },
        verification: 'cvv', // or cvv
        verificationSuccessUrl: null,
        verificationFailureUrl: null,
        source: {
          id: 'uuid',
          type: 'card'
        },
        description: null,
        encryptedData: msgKey,
        channel: null
      })
    });
    return result.json();
  };
  '''
::
++  encrypt-function
  %-  trip
  '''
  const encrypt = async (str, publicKey) => {
    let keyId = "key1";

    let decodedPublicKey = await openpgp.readKey({ armoredKey: atob(publicKey) });
    let message = await openpgp.createMessage({ text: JSON.stringify(cardDetails) });
    return openpgp.encrypt({
      message,
      encryptionKeys: decodedPublicKey
    }).then((cipherText) => {
      return {
        encryptedMessage: btoa(cipherText),
        keyId
      };
    });
  };
  '''
--
