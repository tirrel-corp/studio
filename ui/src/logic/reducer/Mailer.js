
const MailerReducer = (state, update) => {
  if (typeof update.data !== 'object') { return state; }
  let key = Object.keys(update.data)[0];
  let val  = update.data[key];
  if (update.app !== 'mailer') return state;

  switch (key) {
    case 'initial':
      state = val;
      break;
    case 'creds':
      state.creds = val;
      break;
    case 'lists':
      state['mailing-lists'] = val;
      break;
    default:
      break;
  }
  return state;
}

export { MailerReducer };
