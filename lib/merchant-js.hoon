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
  let cardIdKey = uuidv4();

  let cardId = null;

  cardBtn.onclick = () => {
    encrypt(JSON.stringify(cardDetails), publicKey).then((msg) => {
      createCard(cardIdKey, msg.encryptedMessage).then((r) => {
        console.log(r);
      });

      setTimeout(async () => {
        cardId = await getCard(cardIdKey);
        console.log(cardId);
      }, 5000);
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
  let payIdKey = uuidv4();

  payBtn.onclick = () => {
    encrypt(JSON.stringify(cvv), publicKey).then((msg) => {
     createPayment(payIdKey, msg.encryptedMessage, cardId, '10.00').then((r) => {
      console.log(r);
     });

      setTimeout(async () => {
        getPayment(payIdKey);
      }, 5000);
    });
  };
  '''
::
++  create-card-function
  %-  trip
  '''
  const getCard = async (cardIdKey) => {
    let r = await fetch('/merchant/card/' + cardIdKey);
    let j = await r.json();
    console.log(j);

    return j.card.id;
  };

  const createCard = async (cardIdKey, msgKey) => {
    let result = await fetch('/merchant/card', {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        idempotencyKey: cardIdKey,
        keyId: 'key1',
        encryptedData: msgKey,
        billingDetails: {
          name: 'Logan Allen',
          city: 'Austin',
          country: 'US',
          'line1': '1800 Enchanted Rock Dr',
          'line2': null,
          district: 'TX',
          postalCode: '78613'
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
  const getPayment = async (payIdKey) => {
    let r = await fetch('/merchant/payment/' + payIdKey);
    let j = await r.json();
    console.log(j);
  };

  const createPayment = async (payIdKey, msgKey, cardId, amount) => {
    let result = await fetch('/merchant/payment', {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        idempotencyKey: payIdKey,
        keyId: 'key1',
        amount: {
          amount: amount,
          currency: 'USD'
        },
        verification: 'cvv', // or cvv
        verificationSuccessUrl: null,
        verificationFailureUrl: null,
        source: {
          id: cardId,
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
