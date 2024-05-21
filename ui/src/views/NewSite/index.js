import { useContext, useRef, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { StoreContext } from '../../logic/Store';
import { isValidURL, isValidPath, useKeydown, makeStringSafe } from '../utils/index';
import * as valid from '../utils/validators';

const emptyConfig = {
  name: "",
  domain: "",
  path: "",
};

const NewSite = props => {
  const { api, switchboard } = useContext(StoreContext);
  const navigate = useNavigate();

  /* state to be committed when the form is submitted */
  const [siteConfig, setSiteConfig] = useState(emptyConfig);

  /* local/temporary state */
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState();

  const [name, setName] = useState("");
  const [domain, setDomain] = useState(window.location.hostname);
  const [path, setPath] = useState("");

  // whether the user should be blocked from progressing. when the warning
  // dialog opens, we should make them wait for a second before they can proceed
  const [preventProgress, setPreventProgress] = useState(false);

  const dialogRef = useRef();

  const nameValid = name.length > 0;
  const domainValid = isValidURL(domain);
  const pathValid = isValidPath(path);

  const choseThisDomain =
    domain.toLowerCase() === window.location.hostname.toLowerCase();
  const choseRootPath = path.length === 1;
  const SHOW_BIG_ASS_WARNING = choseThisDomain && choseRootPath

  const addSite = (siteConfig) => {
    setLoading(true);
    const { name, domain, path } = siteConfig;
    const safeName = makeStringSafe(name);
    api.poke({
      app: 'switchboard',
      mark: 'switchboard-action',
      json: {
        'add-site': {
          name: safeName,
          host: domain,
          path: path || '/',
          title: name,
        }
      }
    }).then(() => setLoading(false))
      .then(() => navigate(`/site/${safeName}/add-plugin/pipe`))
      .catch(err => {
        console.error(err);
        setError(err);
      });
  }

  const [state, prev, next] = (() => {
    if (!siteConfig.name) {
      return [
        "ConfigureName",
        undefined,
        (nameValid
          ? () => {
            setSiteConfig(prev => ({ ...prev, name }));
            setDomain(window.location.hostname);
            setPath(`/${makeStringSafe(name)}`);
          }
          : undefined),
      ];
    }
    if (!siteConfig.domain) {
      return [
        "ConfigurePath",
        () => {
          setName(siteConfig.name);
          setSiteConfig(emptyConfig);
          setDomain("");
          setPath("");
        },
        (!(domainValid && pathValid)
          ? undefined
          : () => {
            if (SHOW_BIG_ASS_WARNING && !dialogRef.current.open) {
              dialogRef.current.showModal();
              setPreventProgress(true);
              setTimeout(() => setPreventProgress(false), 5000);
            } else if (preventProgress) {
              return;
            } else {
              setSiteConfig(prev => ({ ...prev, domain, path }))
              dialogRef.current.close();
            }
          }
        )
      ];
    }
    return [
      "Deploy",
      () => {
        setDomain(siteConfig.domain);
        setPath(siteConfig.path);
        setSiteConfig(prev => ({ ...prev, domain: "", path: "" }));
      },
      () => addSite(siteConfig),
    ];
  })();

  useKeydown('Enter', next);

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../')}>
            &#215;&nbsp;Cancel
          </button>
          <h1 className="ma0">Site Launcher</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ minHeight: '50vh' }}>
          {state === "ConfigureName" && (
            <>
              <h2>What is the title of your site?</h2>
              <form className="flex flex-column" style={{ gap: "1rem" }}>
                <div>
                  <label htmlFor="name" className="db f5 fw4">Title</label>
                  <input
                    className={`mt1 ${!nameValid ? 'b--red' : ''}`}
                    id="name"
                    type="text"
                    placeholder="Mars Review of Books"
                    onChange={ev => setName(ev.target.value)}
                    value={name}
                  />
                </div>
              </form>
            </>
          )}
          {state === "ConfigurePath" && (
            <>
              <h2>
                Choose a domain and path
              </h2>
              <form className="flex flex-column" style={{ gap: "1rem" }}>
                <div>
                  <label className="db f5 fw4">Name</label>
                  <p>
                    <code>{siteConfig.name}</code>
                  </p>
                </div>
                <div>
                  <p>
                    You can use any domain you prefer, so long as the domain
                    is configured to point to your Urbit ship. Need help?&nbsp;
                    <a
                      href="https://crypto4dummiez.substack.com/p/custom-domain-for-your-planet"
                      rel="noopener noreferrer"
                      target="_blank"
                    >
                      Check out this post on setting up a custom domain.
                    </a>
                  </p>
                  <label htmlFor="domain" className="db f5 fw4">Domain</label>
                  <input
                    className={`mt1 ${!domainValid ? 'b--red' : ''}`}
                    id="domain"
                    type="text"
                    placeholder={window.location.hostname}
                    onChange={ev => setDomain(ev.target.value)}
                    value={domain}
                  />
                </div>
                <div>
                  <p>
                    The path, under your domain, where your site will be
                    hosted. Must begin with a <code>/</code>.
                  </p>
                  <section className="pa3 warning">
                    This can be any valid path, but we recommend using
                    a subpath like <code>/my-site</code> rather than the root
                    path, unless you're sure you know what you're doing. If you
                    bind the root path, you may be unable to access your ship.
                  </section>
                  <label htmlFor="path" className="db f5 fw4 mt3">Path</label>
                  <input
                    className={`mt1 ${!pathValid ? 'b--red' : ''}`}
                    id="path"
                    type="text"
                    placeholder={`/${makeStringSafe(siteConfig.name)}`}
                    pattern={valid.pathPattern}
                    onChange={ev => setPath(ev.target.value)}
                    value={path}
                  />
                </div>
              </form>
            </>
          )}
          {state === "Deploy" && (
            <>
              <h2>Confirm New Site Configuration</h2>
              <div>
                <h3>Name:</h3>
                <p><code>{siteConfig.name}</code></p>
              </div>
              <div>
                <h3>Domain and Path:</h3>
                <p>{siteConfig.domain}{siteConfig.path}</p>
              </div>
              <div className="mt4 mb4 ba br3 pa3 shadow-3 near-black bg-washed-green">
                <p>
                  Once you've confirmed these settings, your site will be
                  deployed. You'll be taken to the plugin configuration page to
                  choose some content for your new site.
                </p>
              </div>
            </>
          )}
          <div className="flex flex-row justify-between items-end pt3" style={{ marginTop: 'auto' }}>
            <button onClick={prev} disabled={!prev}>
              &#8592;&nbsp;Back
            </button>
            <button onClick={next} disabled={!next}>
              Next&nbsp;&#8594;
            </button>
          </div>
        </div>
      </div>
      <dialog ref={dialogRef}>
        <div className="flex flex-column">
          <h1>Danger</h1>
          <section className="pa3 danger">
            <p className="f3 b">
              IF YOU PROCEED, YOU MAY BE UNABLE TO ACCESS YOUR SHIP.
            </p>
          </section>
          <p>
            You've configured your Studio site to be hosted at the root
            path&nbsp; <code>/</code> of the domain <code>{domain}</code>,
            which points to your urbit ship. This is dangerous: proceeding may
            make it impossible to access your ship's web interface.
          </p>
          <p>
            You can avoid this danger by going back, and configuring a
            different path for your Studio site.
          </p>
          <div className="mt4 flex justify-between">
            <button onClick={() => {
              dialogRef.current.close();
              setPreventProgress(false);
            }}>
              Go back
            </button>
            <button
              className="danger"
              onClick={next}
              disabled={preventProgress}>
              {preventProgress
                ? "Proceed at your own risk (wait 5s)"
                : "Proceed at your own risk"
              }
            </button>
          </div>
        </div>
      </dialog>
    </div>
  )
};

export { NewSite };
