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
  cardBtn.onclick = () => {
    encrypt("4007400000000007", "111", publicKey).then((msg) => {
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
  payBtn.onclick = () => {
    encrypt("4007400000000007", "111", publicKey).then((msg) => {
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
        keyId: null,
        encryptedData: msgKey,
        billingDetails: {
          country: 'USA',
          district: 'TX',
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
        keyId: null,
        amount: {
          amount: '10.00',
          currency: 'USD'
        },
        verification: 'none', // or cvv
        verificationSuccessUrl: null,
        verificationFailureUrl: null,
        source: {
          id: 'asdf',
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
  const encrypt = async (num, cvv, publicKey) => {
    let keyId = "key1";

    let decodedPublicKey = await openpgp.readKey({ armoredKey: atob(publicKey) });
    let cardDetails = {
      number: num,
      cvv: cvv
    };
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
