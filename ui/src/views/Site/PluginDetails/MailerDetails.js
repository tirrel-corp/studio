import { useContext, useRef, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { StoreContext } from '../../../logic/Store';
import { pathToResource, makeFormData } from '../../utils/index';
import { SwitchNotebook } from '../../components/SwitchNotebook';
import LoadOverlay from '../../components/LoadOverlay';
import * as valid from '../../utils/validators';

const MailerDetails = props => {
  const { name: siteName, pluginName, pluginType } = useParams();
  const navigate = useNavigate();

  const [newEmail, setNewEmail] = useState('');
  const [sendConfirm, setSendConfirm] = useState(false);
  const [selectedSubscribers, setSelectedSubscribers] = useState(new Set());
  const [recipients, setRecipients] = useState(new Set());
  const [enableImport, setEnableImport] = useState(false);

  const [loading, setLoading] = useState();
  const [error, setError] = useState();
  const { api, switchboard, mailer } = useContext(StoreContext);
  const currentApiKey = mailer?.creds?.['api-key'];
  const currentSenderEmail = mailer?.creds?.email;
  const { binding, plugins: myPlugins = {} } = switchboard?.[siteName] || {};
  const sitePath = binding ? `${binding?.hostname}${binding?.path}` : '';
  const byName = new Map(
    Object.entries(myPlugins).map((
      ([path, { name, type }]) => ([name, { name, path, type }])
    )).filter(([_, { type }]) => type === pluginType)
  )

  const importCSV = (rec, conf) => {
    setLoading(true);
    api.poke({
      app: 'mailer',
      mark: 'mailer-action',
      json: {
        'add-recipients': {
          name: pluginName,
          list: Array.from(rec),
          confirm: !conf,
        }
      }
    }).then(() => setLoading(false))
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  };

  const exportCSV = (rec) => {
    var value = "Email\n" + rec.join('\n');
    var a = window.document.createElement('a');
    a.href = window.URL.createObjectURL(new Blob([value], { type: 'text/csv' }));
    a.download = 'mailing-list.csv';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  }

  const thisPlugin = byName.get(pluginName);
  const domainSort = (a, b) => {
    const aDomain = a.split("@")[1];
    const bDomain = b.split("@")[1];
    return aDomain.localeCompare(bDomain);
  }

  const thisMailingList = (mailer?.['mailing-lists']?.[pluginName] || []).sort().sort(domainSort);

  const dialogRef = useRef();
  const filePickerRef = useRef();

  const onChangeCSV = ev => {
    ev.target.files[0].text()
      .then(text => text.split(/[\n\r]+/))
      .then(lines => lines.filter(line => line !== ''))
      .then(lines => {
        // Get the column index where each line has an email address. 
        // For a substack export, the first row enumerates the values in that
        // column, so we search for the index of a string like "email".
        const [headingLine, ...contentLines] = lines;
        const headings = headingLine.split(',');
        const emailColumnIndex = headings.findIndex(head => /^email$/i.test(head));
        if (emailColumnIndex !== -1) {
          return [emailColumnIndex, contentLines];
        }
        // If there's no heading, look for an index in the first content line
        const [first] = contentLines;
        const emailContentIndex = first
          .split(',')
          .findIndex(val => valid.email.test(val));
        if (emailContentIndex === -1) {
          throw new Error('Could not find an email column in the given CSV.');
        }
        return [emailContentIndex, contentLines];
      }).then(([idx, lines]) => lines
        .map(line => line.split(','))
        .map(vals => vals[idx])
      ).then(addresses => {
        setRecipients(
          new Set(addresses.filter(addr => valid.email.test(addr)))
        );
        setEnableImport(true);
      }).catch(err => setError(err.message));
  };

  const deletePlugin = () => {
    const threadParams = {
      inputMark: 'json',
      outputMark: 'json',
      threadName: 'remove-mailer-plugin',
      desk: 'studio',
      body: {
        'site-name': siteName,
        'plugin-name': pluginName,
        'sub-path': thisPlugin.path,
      },
    };
    setLoading(true)
    api.thread(threadParams)
      .then(() => navigate('../'))
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  };

  const addRecipients = (adrs, conf) => {
    setLoading(true)
    api.poke({
      app: 'mailer',
      mark: 'mailer-action',
      json: {
        'add-recipients': {
          name: pluginName,
          list: [adrs],
          confirm: !conf
        }
      }
    }).then(() => setLoading(false))
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  };

  const delRecipients = (adrs) => {
    setLoading(true)
    api.poke({
      app: 'mailer',
      mark: 'mailer-action',
      json: {
        'del-recipients': {
          name: pluginName,
          list: [adrs]
        }
      }
    }).then(() => setLoading(false))
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  };

  const setCreds = (params) => {
    setLoading(true)
    api.poke({
      app: 'mailer',
      mark: 'mailer-action',
      json: {
        'set-creds': {
          "api-key": params['api-key'] || null,
          "email": params.email || null,
          "ship-url": null,
        }
      }
    }).then(() => navigate('../'))
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  };

  return (
    <div style={{ minHeight: '50vh' }}>
      {loading && <LoadOverlay />}
      <div className="flex justify-between items-center" style={{ gap: '1rem' }}>
        <h2>Email Configuration</h2>
        <button className="danger" onClick={(ev) => {
          ev.preventDefault();
          ev.stopPropagation();
          dialogRef.current.showModal();
        }}>
          &#215;&nbsp;Delete
        </button>
      </div>
      <form
        className="flex flex-column"
        style={{ gap: '1rem' }}
        onSubmit={ev => {
          ev.preventDefault();
          ev.stopPropagation();
          const toSubmit = makeFormData(ev.target);
          setCreds({ ...toSubmit });
        }}>
        <p>
          Configure the sending email for your mailing list. This address will
          appear in the "sender" field of your emails. (You'll need to
          follow SendGrid's process to&nbsp;
          <a
            href="https://docs.sendgrid.com/ui/sending-email/senders#adding-a-sender"
            rel="noopener noreferrer"
            target="_blank">
            add and verify a sender
          </a>
          &nbsp;before you can send emails.)
        </p>
        <div className="flex flex-row justify-between items-start">
          <div>
            <label htmlFor="email" className="db">Origin Email</label>
            <input type="email" name="email" className="mt2" />
          </div>
          <div className="tr light-silver">
            <div><span className="f5">Current Origin Email</span></div>
            {currentSenderEmail && (
              <div><code>{currentSenderEmail}</code></div>
            )}
          </div>
        </div>
        <p>
          Set the API key for your SendGrid account. If you don't have an
          API key, you can&nbsp;
          <a
            href="https://docs.sendgrid.com/ui/account-and-settings/api-keys#creating-an-api-key"
            rel="noopener noreferrer"
            target="_blank"
          >
            create one in SendGrid.
          </a>
        </p>
        <div className="flex flex-row justify-between items-start">
          <div>
            <label htmlFor="api-key" className="db">SendGrid API Key</label>
            <input
              type="text"
              name="api-key"
              pattern={valid.sgApiKeyPattern}
              className="mt2"
            />
          </div>
          <div className="tr light-silver">
            <div><span className="f5">Current API Key</span></div>
            {currentApiKey && currentApiKey.length && (
              <div><code>{`SG.[...]${currentApiKey.slice(-4)}`}</code></div>
            )}
          </div>
        </div>
        {siteName && (
          <input type="hidden" name="site-name" value={siteName} />
        )}
        <label className="db mt3" htmlFor="new-email">Mailing List Details</label>
        <div className="flex items-baseline" style={{ gap: 'var(--w0)' }}>
          <input
            type="email"
            id="new-email"
            placeholder="new@subscrib.er"
            value={newEmail}
            onChange={ev => {
              ev.preventDefault();
              ev.stopPropagation();
              setNewEmail(ev.target.value);
            }}
          />
          <button
            disabled={!newEmail}
            onClick={ev => {
              ev.preventDefault();
              ev.stopPropagation();
              setNewEmail('');
              addRecipients(newEmail, sendConfirm);
            }}>
            Add New Subscriber
          </button>
        </div>
        <div className="flex items-end" style={{ gap: 'var(--w1)' }}>
          <input
            ref={filePickerRef}
            type="file"
            accept=".csv,text/csv"
            name="mailing-list"
            className="mt pa2"
            style={{ borderWidth: 'var(--w-4)' }}
            onChange={onChangeCSV}
          />
          <button
            disabled={!enableImport}
            className="ma1"
            onClick={ev => {
              ev.preventDefault();
              ev.stopPropagation();
              importCSV(recipients, sendConfirm);
            }}>
            Import CSV
          </button>
        </div>
        <div>
          <input
            className="mr2"
            type="checkbox"
            id="confirm"
            name="confirm"
            onChange={ev => {
              setSendConfirm(!sendConfirm);
            }}
          />
          <label htmlFor="confirm">Send Confirmation Email?</label>
        </div>
        <div className="overflow-y-auto pa2 ba ba1 br2" style={{ flexBasis: '20vh', maxHeight: '30vh' }}>
          <table className="w-100">
            <tbody>
              {Array.isArray(thisMailingList) && thisMailingList.length ?
                thisMailingList.map((address, idx) => (
                  <tr key={`${address}${idx}`}>
                    <td>
                      {address}
                    </td>
                    <td className="flex justify-end">
                      <button
                        onClick={ev => {
                          ev.preventDefault();
                          ev.stopPropagation();
                          delRecipients(address);
                        }}>
                        Remove
                      </button>
                    </td>
                  </tr>
                )) : (
                  <div className="flex justify-center items-center">
                    <p className="f3">
                      This mailing list is currently empty.
                    </p>
                  </div>
                )}
            </tbody>
          </table>
        </div>
        <div>
          <button
            className="ma1"
            disabled={thisMailingList.length === 0}
            onClick={ev => {
              ev.preventDefault();
              ev.stopPropagation();
              exportCSV(thisMailingList);
            }}>
            Export CSV
          </button>
        </div>
        <div className="flex justify-end pt3" style={{ marginTop: 'auto' }}>
          <button type="submit">
            Save &#10003;
          </button>
        </div>
      </form>
      <dialog ref={dialogRef}>
        <div className="flex flex-column">
          <h1>Confirm Deletion</h1>
          <p>
            Continuing will delete this plugin permanently. Are you sure you
            want to do this?
          </p>
          <div className="flex flex-row-reverse mt4" style={{ gap: '1rem' }}>
            <button className="danger" onClick={() => deletePlugin()}>
              Confirm Deletion
            </button>
            <button onClick={() => dialogRef.current.close()}>
              Cancel
            </button>
          </div>
        </div>
      </dialog>
    </div>
  );
};

export { MailerDetails };
