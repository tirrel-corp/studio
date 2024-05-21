import { useContext, useRef, Fragment } from "react";
import { useNavigate, useParams, Link } from "react-router-dom";
import { StoreContext } from '../../logic/Store';
import { getContentUrls, useCopy } from '../utils/index';

const Site = props => {
  const { name } = useParams();
  const navigate = useNavigate();

  const { groups, pipe, switchboard, api, auth } = useContext(StoreContext);

  const notebooks = Object.fromEntries(
    Object.entries(groups || {})
      .reduce((res, [k, v]) => {
        let chan = Object.entries(v.channels).map(([ck, cv]) => {
          cv.group = k;
          return [ck, cv];
        })
        return res.concat(chan)
      }, []));

  const mySite = switchboard?.[name] || {};
  const myRootUrl = mySite?.binding
    ? `https://${mySite.binding.hostname}${mySite.binding.path}`
    : undefined;
  const previewUrls = getContentUrls({ switchboard });
  const myPreviewUrl = previewUrls[name]?.url;
  const siteTitle = previewUrls[name]?.title;
  const myPlugins = mySite?.plugins || {};
  const hasPipe = Object.entries(myPlugins)
    .some(([_, { type }]) => type === 'pipe');
  const hasMailer = Object.entries(myPlugins)
    .some(([_, { type }]) => type === 'mailer');
  const hasPaywall = Object.entries(myPlugins)
    .some(([, { name }]) => Object.keys(auth?.services).some((e) => e === name))
  const canAddPlugin = !(hasPipe && hasMailer && hasPaywall);

  const dialogRef = useRef();

  const deleteSite = () => {
    const pokeParams = {
      app: 'switchboard',
      mark: 'switchboard-action',
      json: {
        'del-site': {
          name: name
        }
      }
    }

    return api.poke(pokeParams)
      .then(() => navigate('/'))
      .catch(err => console.error(err.message));
  }

  const copyFunc = useCopy(myRootUrl);

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('/')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{`${siteTitle}`}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
          <div>
            <h2>URL</h2>
            <div>
              <a href={myRootUrl} target="_blank" className="no-underline">
                <code>{myRootUrl}</code>
              </a>
              <a onClick={copyFunc} className="button small ml2">
                Copy
              </a>
            </div>
          </div>
          <div>
            <h2>Plugins</h2>
            <ul className="flex flex-column list pl0" style={{ gap: '1rem', minHeight: '10rem' }}>
              {Object.entries(myPlugins).map(([path, { name, type }]) => {
                if (type === 'pipe' && pipe?.flows?.[name]?.resource) {
                  const myResource = pipe?.flows?.[name]?.resource;
                  const myResPath = `diary/~${myResource?.ship}/${myResource?.name}`;
                  const myMeta = notebooks?.[myResPath];
                  const myTitle = myMeta?.meta?.title;
                  const myGroupLink = [
                    '/apps/groups/groups/',
                    myMeta?.group,
                    '/channels/', // need this trailing slash
                    myResPath
                  ].join('');
                  return (
                    <li className="flex flex-row items-center ba br3 pa3 shadow-3 bg-washed-blue" key="1">
                      <div>
                        <h3 className="ma0">
                          {myTitle}
                        </h3>
                        <div><span className="f6">Blog</span></div>
                      </div>
                      <div className="flex" style={{ gap: 'var(--w0)', marginLeft: 'auto' }}>
                        <a href={myGroupLink} rel="noopener noreferrer" target="_blank" className="f6">
                          Go to Notebook&nbsp;&#10138;
                        </a>
                        <Link className="f6" to={`./pipe/${name}`}>
                          Configure
                        </Link>
                      </div>
                    </li>
                  )
                }
                return <Fragment key={path} />;
              })}
              { Object.entries(myPlugins).length > 0 && (
                  <>
                  <li className="flex flex-row items-center ba br3 pa3 shadow-3 bg-washed-blue" key="2">
                    <div>
                      <h3 className="ma0">
                        Subscribers
                      </h3>
                    </div>
                    <div style={{ marginLeft: 'auto' }}>
                      <Link className="f6" to={`./subscribers`}>
                        Configure
                      </Link>
                    </div>
                  </li>
                  <li className="flex flex-row items-center ba br3 pa3 shadow-3 bg-washed-blue" key="3">
                    <div className="flex flex-row justify-between items-center flex-auto">
                      <h3 className="ma0">Paywall</h3>
                      <div className="flex justify-end items-center">
                        {!auth?.kyc && <Link className="f6 mv2 br2 mr2 pa1 b infolink" to="/settings">
                          <p className="ma0">
                            ⚠ Verification required
                          </p>
                        </Link>}
                        <Link className="f6" to={`./paywall`}>
                          Configure
                        </Link>
                      </div>
                    </div>
                  </li>
                </>
              )}
              {canAddPlugin && (
                <li className="flex flex-row items-center ba br3 pa3 shadow-3 bg-washed-blue f6">
                  <Link to="add-plugin/pipe">Add New Blog</Link>
                </li>
              )}
            </ul>
          </div>
          {(myPreviewUrl) ? (
            <div style={{ minHeight: '10rem' }}>
              <h2>Preview</h2>
              <div
                className="overflow-hidden"
                style={{
                  width: 300,
                  height: 200
                }}>
                <iframe
                  title={name}
                  src={myPreviewUrl}
                  width="300"
                  height="200"
                  className="ba br3 overflow-hidden"
                  style={{
                    pointerEvents: 'none',
                    transformOrigin: '0 0',
                    transform: 'scale(0.25)',
                    width: '1200px',
                    height: '800px'
                  }}
                  scrolling="no"
                >
                </iframe>
              </div>
            </div>
          ) : (<br />)
          }
          <div className="flex flex-row justify-end items-center bt pt3" style={{ marginTop: 'auto' }}>
            <div>
            </div>
            <button className="danger"
              onClick={ev => {
                ev.preventDefault();
                ev.stopPropagation();
                dialogRef.current.showModal();
              }}>
              Delete
            </button>
            <dialog ref={dialogRef}>
              <div className="flex flex-column">
                <h1>Confirm Deletion</h1>
                <p>
                  Continuing will delete this site permanently. Are you sure you
                  want to do this?
                </p>
                <div className="flex flex-row-reverse mt4" style={{ gap: '1rem' }}>
                  <button className="danger" onClick={() => deleteSite()}>
                    Confirm Deletion
                  </button>
                  <button onClick={() => dialogRef.current.close()}>
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

export { Site };
