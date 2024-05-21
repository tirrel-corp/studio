import { useContext, useRef, useState } from 'react';
import { useForm } from 'react-hook-form'
import { useParams, useNavigate } from 'react-router-dom';
import { StoreContext } from '../../../logic/Store';
import { pathToResource, makeFormData } from '../../utils/index';
import { SwitchNotebook } from '../../components/SwitchNotebook';
import LoadOverlay from '../../components/LoadOverlay';
import * as valid from '../../utils/validators';

const SubscriberDetails = props => {
  const { name: siteName, pluginName, pluginType } = useParams();
  const navigate = useNavigate();

  const [newEmail, setNewEmail] = useState('');
  const [free, setFree] = useState(false);

  const [sendConfirm, setSendConfirm] = useState(false);
  const [selectedSubscribers, setSelectedSubscribers] = useState(new Set());
  const [recipients, setRecipients] = useState(new Set());
  const [enableImport, setEnableImport] = useState(false);

  const [loading, setLoading] = useState();
  const [error, setError] = useState();
  const { api, switchboard, auth } = useContext(StoreContext);
  const title = switchboard?.[siteName]?.title;
  const { binding, plugins: myPlugins = {} } = switchboard?.[siteName] || {};
  const sitePath = binding ? `${binding?.hostname}${binding?.path}` : '';
  const byName = new Map(
    Object.entries(myPlugins).map((
      ([path, { name, type }]) => ([name, { name, path, type }])
    )).filter(([_, { type }]) => type === pluginType)
  )
  const [changedVals, setChangedVals] = useState({});

  const saveSubscribers = (subs) => {
    setLoading(true);
    api.poke({
      app: 'auth',
      mark: 'auth-action',
      json: {
        'add-subscribers': {
          name: siteName,
          users: subs
        }
      }
    }).then(() => {
      setLoading(false)
    })
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  }

  const addSubscribers = (subs) => {
    setLoading(true);
    api.poke({
      app: 'auth',
      mark: 'auth-action',
      json: {
        'add-subscribers': {
          name: siteName,
          users: subs
        }
      }
    }).then(() => {
      setNewEmail('');
      setFree(false)
      setRecipients(new Set())
      filePickerRef.current.value = null;
      setLoading(false)
    })
      .catch(err => {
        setLoading(false)
        console.error(err);
        setError(err.message);
      });
  }

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
    if (aDomain && bDomain) return aDomain.localeCompare(bDomain);
    return false;
  }

  const thisMailingList = Object.keys(auth?.services?.[siteName]?.users || {});

  const addUserRef = useRef();
  const importRef  = useRef();
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

  return (

    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{title}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
          <div style={{ minHeight: '50vh' }}>
            {loading && <LoadOverlay />}
            <div className="flex justify-between items-center" style={{ gap: '1rem' }}>
              <h2>Email Configuration</h2>
            </div>
            <form
              className="flex flex-column"
              style={{ gap: '1rem' }}
              onSubmit={(ev) => {
                ev.preventDefault();
                ev.stopPropagation();
                saveSubscribers(changedVals);
              }}
              >
              {siteName && (
                <input type="hidden" name="site-name" value={siteName} />
              )}
              <label className="db mt3" htmlFor="new-email">Mailing List Details</label>
              <div className="flex items-baseline" style={{ gap: 'var(--w0)' }}>
                <button
                  onClick={ev => {
                    ev.preventDefault();
                    ev.stopPropagation();
                    addUserRef.current.showModal();
                  }}>
                  Add New Subscriber
                </button>
                <button
                  className="ma1"
                  onClick={ev => {
                    ev.preventDefault();
                    ev.stopPropagation();
                    importRef.current.showModal();
                  }}>
                  Import CSV
                </button>
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
              <div className="overflow-y-auto" style={{height:'40vh'}}>
                <table className="w-100 center" cellSpacing="0">
                  <thead style={{position: "sticky",  top: "0"}}>
                    <tr>
                      <th className="bg-near-white f6 pb3 bb b--black-20 pr3 tl" style={{position: "sticky",  top: "0"}}>
                        Email Address
                      </th>
                      <th className="bg-near-white f6 pb3 bb b--black-20 pr3 tl" style={{position: "sticky",  top: "0"}}>
                        Paid access
                      </th>
                      <th className="bg-near-white f6 pb3 bb b--black-20 pr3 tl" style={{position: "sticky",  top: "0"}}>
                        Free access
                      </th>
                      <th className="bg-near-white f6 pb3 bb b--black-20 pr3 tl" style={{position: "sticky",  top: "0"}}>
                        On Mailing List
                      </th>
                    </tr>
                  </thead>
                  <tbody> { //className="overflow-auto db w-100" style={{height:'40vh'}}>
                  }
                    {Array.isArray(thisMailingList) && thisMailingList.length ?
                      thisMailingList.map((address, idx) => (
//                        const free = auth?.services?.[siteName]?.users[address].free;

//  const thisMailingList = Object.keys(auth?.services?.[siteName]?.users || {});


                        <tr key={`${address}${idx}`} className="">
                          <td className="pv3 pr3 bb b--black-20">
                            {address}
                          </td>
                          <td className="pv3 pr3 bb b--black-20">
                            <input
                              type="checkbox"
                              disabled={true}
                              defaultChecked={auth?.services?.[siteName]?.users[address]["security-clearance"] &&
                                  !auth?.services?.[siteName]?.users[address].free}

                            />
                          </td>
                          <td className="pv3 pr3 bb b--black-20">
                            <input
                              type="checkbox"
                              defaultChecked={auth?.services?.[siteName]?.users[address].free}
                              onChange={(e) => {
                                setChangedVals({
                                  ...changedVals,
                                  [address]: e.target.checked
                                })
                              }}
                            />
                          </td>
                          <td className="pv3 pr3 bb b--black-20">
                            <input
                              type="checkbox"
                              defaultChecked={auth?.services?.[siteName]?.users[address]["mailing-list"]}
                              disabled={true}
                            />
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
              <div className="flex justify-end pt3" style={{ marginTop: 'auto' }}>
                <button type="submit"
                  disabled={Object.keys(changedVals).length == 0}
                >
                  Save &#10003;
                </button>
              </div>
            </form>
            <dialog ref={importRef} className="gray bg-near-white">
              <div className="flex flex-column">
                <h1>Import CSV</h1>
                <form>
                  <label className="db mt3" htmlFor="add-user-email">Email Address:</label>
                  <input
                    ref={filePickerRef}
                    type="file"
                    accept=".csv,text/csv"
                    name="mailing-list"
                    className="mt1"
                    style={{borderWidth: 'var(--w-4)'}}
                    onChange={onChangeCSV}
                  />
                  <div className="flex">
                    <input
                      type="checkbox"
                      className="ma3"
                      onChange={(e) => setFree(e.target.checked)}
                      checked={free}
                    />
                    <label className="db mt3" htmlFor="add-user-email">Give free paywall access</label>
                  </div>
                </form>
                <div className="flex flex-row-reverse mt4" style={{ gap: '1rem' }}>
                  <button onClick={() => {
                    const subs = Array.from(recipients).reduce((a,c) => {
                      a[c]=free; return a; 
                    }, {});
                    addSubscribers(subs)
                    importRef.current.close()
                  }}>
                    Confirm
                  </button>
                  <button onClick={() =>  {
                    setFree(false)
                    setRecipients(new Set())
                    filePickerRef.current.value = null;
                    importRef.current.close()
                  } }>
                    Cancel
                  </button>
                </div>
              </div>
            </dialog>
            <dialog ref={addUserRef} className="gray bg-near-white">
              <div className="flex flex-column">
                <h1>Add Subscriber</h1>
                <form>
                  <label className="db mt3" htmlFor="add-user-email">Email Address:</label>
                  <input
                    id="email-address"
                    name="email-address"
                    className="mt1"
                    onChange={(e) => setNewEmail(e.target.value)}
                    value={newEmail}
                  />
                  <div className="flex">
                    <input
                      type="checkbox"
                      className="ma3"
                      onChange={(e) => setFree(e.target.checked)}
                      checked={free}
                    />
                    <label className="db mt3" htmlFor="add-user-email">Give free paywall access</label>
                  </div>
                </form>
                <div className="flex flex-row-reverse mt4" style={{ gap: '1rem' }}>
                  <button onClick={() => {
                    addSubscribers({[newEmail]: free})
                    addUserRef.current.close()
                  }}>
                    Confirm
                  </button>
                  <button onClick={() =>  {
                    setFree(false)
                    setNewEmail('')
                    addUserRef.current.close()
                  } }>
                    Cancel
                  </button>
                </div>
              </div>
            </dialog>
          </div>
        </div>
      </div>
    </div>
  );
};

export { SubscriberDetails };
