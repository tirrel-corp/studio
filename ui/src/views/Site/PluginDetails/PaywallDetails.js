import LoadOverlay from "../../components/LoadOverlay";
import { useRef, useState, useContext } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { StoreContext } from '../../../logic/Store';
import { formatUsd } from "../../utils/index"

const PaywallDetails = props => {
  const { name, pluginName } = useParams();
  const [loading, setLoading] = useState(false);
  const { api, switchboard, auth, pipe, diary } = useContext(StoreContext);
  const siteTitle = switchboard?.[name]?.title;
  const navigate = useNavigate();
  const [title, setTitle] = useState(auth?.services?.[name]?.title || "");
  const [price, setPrice] = useState();
  const [priceLabel, setPriceLabel] = useState('');
  const [copy, setCopy] = useState(auth?.services?.[name]?.copy || []);
  const [incomingCopy, setIncomingCopy] = useState('');
  const [edit, setEdit] = useState(false);
  const [copyBuffer, setCopyBuffer] = useState({});


  const pricing = auth?.services?.[name]?.pricing || {};
  const shipping = auth?.services?.[name]?.shipping || false;

  let pipeNames =
    Object.values(switchboard?.[name]?.plugins || {}).map((v) => {
      return v.name;
    })

  const stripTitle = (str) => {
    let res = "/";
    str = str.toLowerCase();
    for (var i = 0; i < str.length; i++) {

      let code = str.charCodeAt(i);
      if (  (code >= 'a'.charCodeAt() && code <= 'z'.charCodeAt()) ||
            (code >= 'A'.charCodeAt() && code <= 'Z'.charCodeAt()) ||
            (code >= '0'.charCodeAt() && code <= '9'.charCodeAt()) ||
            str.charAt(i) == '.' ||
            str.charAt(i) == '-' ||
            str.charAt(i) == '~' ||
            str.charAt(i) == '_' ) {
        res += str.charAt(i);
      } else if (str.charAt(i) == ' ') {
        res += '-';
      }
    }
    return res;
  }

  const diaryNames = pipeNames.map((name) => {
    let flow = pipe?.flows?.[name]
    let res = flow?.resource;
    return {name: `~${res.ship}/${res.name}`, flow: flow, pipeName: name}
  });

  let diaryPosts = {}
  diaryNames.forEach(({name, flow, pipeName}) => {

    let diaryObj = Object.fromEntries(
      Object.keys(diary?.[name] || []).map((k) => {
        diary[name][k].diary = name;
        diary[name][k].flow = flow;
        diary[name][k].pipeName = pipeName;
        let title = diary[name][k].essay.title;
        let path = stripTitle(title)
        if (flow.auth["per-subpath"][path]) {
          diary[name][k].paywalled = true;
        } else {
          diary[name][k].paywalled = false;
        }
        return [k, diary[name][k]];
      })
    )
    diaryPosts = {
      ...diaryPosts,
      ...diaryObj,
    }
  });

  const checkAuthRule = (check, post) => {
    setLoading(true);
    let path = stripTitle(post.essay.title);
    let paywall = post.flow.auth["per-subpath"];
    if (check) {
      paywall[path] = name;
    } else {
      delete paywall[path];
    }
    api.poke({
      app: "pipe",
      mark: "pipe-action",
      json: {
        "edit": {
          name: post.pipeName,
          edits: [{
            "auth-rule": {
              "per-subpath": paywall
            }
          }]
        }
      }
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const checkShipping = (check) => {
    setLoading(true);
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: {
        "mod-details": {
          name: name,
          pricing,
          title: auth?.services?.[name]?.title || name,
          copy,
          shipping: check
        }
      }
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const addPriceTier = () => {
    setLoading(true);
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: {
        "mod-details": {
          name: name,
          pricing: {
            ...pricing,
            [priceLabel]: {
              price: {
                cents: Math.round(price * 100),
                currency: "USD",
              },
              copy: [],
            }
          },
          title: auth?.services?.[name]?.title || name,
          copy,
          shipping,
        }
      }
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const delCopyLine = (pricing, label, copyLine) => {
    setLoading(true);
    let id = pricing[label].copy.indexOf(copyLine);
    pricing[label].copy.splice(id, 1);

    let body = {
        "mod-details": {
          name: name,
          pricing: {
            ...pricing,
          },
          title: auth?.services?.[name]?.title || name,
          copy,
          shipping,
        }
    }
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: body,
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const addCopyLine = (pricing, label, copyBuffer) => {
    setLoading(true);
    let body = {
        "mod-details": {
          name: name,
          pricing: {
            ...pricing,
            [label]: {
              price: pricing[label].price,
              copy: pricing[label].copy.concat(copyBuffer[label]),
            }
          },
          title: auth?.services?.[name]?.title || name,
          copy,
          shipping,
        }
    }
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: body,
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const removePriceTier = (k) => {
    delete pricing[k]
    setLoading(true);
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: {
        "mod-details": {
          name: name,
          pricing,
          title: auth?.services?.[name]?.title || name,
          copy,
          shipping,
        }
      }
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
}

  const modifyDetails = () => {
    setLoading(true);
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: {
        "mod-details": {
          name: name,
          price: {
            cents: price * 100,
            currency: "USD"
          },
          title: auth?.services?.[name]?.title || name,
          copy
        }
      }
    }).then(() => {
      setLoading(false)
      setEdit(true)
      setTimeout(() => setEdit(false), 5000)
    })
      .catch((err) => {
        setLoading(false);
        console.error(err);
      })
  }

  const deletePlugin = () => {
    setLoading(true)
    api.poke({
      app: "auth",
      mark: "auth-action",
      json: {
        "del-service": name
      }
    }).then(() => setLoading(false))
      .then(() => navigate("../"))
      .catch(err => {
        setLoading(false);
        console.error(err);
      });
  }

  const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
  });

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{siteTitle}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>


          <div className="flex flex-column justify-between" style={{ gap: '1rem', minHeight: '50vh' }}>
            {loading && <LoadOverlay />}
            <div>
              <div className="flex justify-between items-center" style={{ gap: '1rem' }}>
                <h2>Paywall Configuration</h2>
              </div>
            </div>
            <div>

              {auth?.services?.[name] && (
                <div className="flex w-100 mb4">
                  <p className="mv0 mr2">Require shipping details</p>
                  <input
                    type="checkbox"
                    defaultChecked={shipping}
                    onChange={(e) => {
                      checkShipping(e.target.checked);
                    }}
                  />
                </div>
              )}

              <h2>Pricing</h2>
              {Object.keys(pricing).length > 0 ? (
                <table className="w-100 center mb4" cellSpacing="0">
                  <thead>
                    <tr>
                      <th className="f6 tl bb b--black-20">
                        Tier Label
                      </th>
                      <th className="f6 tl bb b--black-20">
                        Tier Price
                      </th>
                      <th className="f6 tl bb b--black-20">
                      </th>
                      <th className="f6 tl bb b--black-20">
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                { Object.keys(pricing).map((k, i) => (
                    <tr>
                      <td className="tl bb b--black-20 pv3">
                        <div className="flex flex-column">
                          <p className="mv1 b ml1">{k}</p>
                          { pricing[k].copy.map((c, i) => (
                            <div className="flex flex-row w-100 justify-between">
                              <p className="ml1 mv1">{c}</p>
                               <button className="pa1 ma1 w3"
                                 onClick={(e) => {delCopyLine(pricing, k, c)}}
                               >Del</button>
                            </div>
                          ))}
                         <div className="flex w-100 justify-between">
                           <input className="ma1 pa1 w-80"
                             onChange={(e) => {
                               setCopyBuffer({...copyBuffer, [k]: e.target.value});
                             }}
                           />
                           <button className="pa1 ma1 w3"
                             onClick={(e) => {addCopyLine(pricing, k, copyBuffer)}}
                           >Add</button>
                         </div>
                        </div>
                      </td>
                      <td className="tl bb b--black-20">
                        {formatter.format(pricing[k].price.cents/100)}
                      </td>
                      <td className="tr bb b--black-20">
                        <button
                          onClick={(e) => {removePriceTier(k)}}
                        >
                          Remove
                        </button>
                      </td>
                    </tr>
                  )) }
                  </tbody>
                </table>
              ): (
                <p>Your publication is currently free</p>
              )}
              <p className="ma0" style={{gap: '0rem'}}>Add price tier:</p>
              <div className="flex flex-column">
                <div className="flex">
                  <div className="flex flex-column">
                    <p style={{gap: '0rem'}}>Tier label:</p>
                    <input
                      className="mr2 w5"
                      onChange={(e) => setPriceLabel(e.target.value)}
                      value={priceLabel}
                    />
                  </div>
                  <div className="flex flex-column">
                    <p>Tier price:</p>
                    <input
                      className="w4"
                      onChange={(e) => {
                        setPrice(e.target.value)
                      }}
                      value={price}
                      style={{maxWidth:"10ch"}}
                    />
                  </div>
                </div>
                <button  className="w3 mt2"
                  onClick={(e) => {
                    addPriceTier();
                  }}
                >
                  Add
                </button>
              </div>
            </div>
            <div>
              <h2>Configure Posts</h2>
              <div className="overflow-y-auto" style={{minHeight:'20vh', maxHeight:'50vh'}}>
                <table className="w-100 center" cellSpacing="0">
                  <thead style={{position: "sticky", top: "0"}}>
                    <tr>
                      <th className="bg-near-white f6 pb3 bb b--black-20 tl" style={{position: "sticky", top: "0"}}>
                        Notebook
                      </th>
                      <th className="bg-near-white f6 pb3 bb b--black-20 tl" style={{position: "sticky", top: "0"}}>
                        Post
                      </th>
                      <th className="bg-near-white f6 pb3 bb b--black-20 tl" style={{position: "sticky", top: "0"}}>
                        Paywalled
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    { Object.values(diaryPosts).length > 0 ?
                      Object.values(diaryPosts).map((post, i) => (
                      <tr key={i}>
                        <td className="pv3 pr3 bb b--black-20">
                          {post.diary.split('/')[1]}
                        </td>
                        <td className="pv3 pr3 bb b--black-20">
                          {post.essay.title}
                        </td>
                        <td className="pv3 pr3 bb b--black-20">
                          <input
                            type="checkbox"
                            defaultChecked={post.paywalled && (Object.keys(pricing).length > 0)}
                            onChange={(e) => {
                              checkAuthRule(e.target.checked, post);
                            }}
                            disabled={Object.keys(pricing).length === 0}
                          />
                        </td>
                      </tr>
                    )) : (
                      <></>
                    )}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};




export { PaywallDetails };
