import { useContext } from 'react';
import { Link } from 'react-router-dom';
import { StoreContext } from '../logic/Store';
import { SiteCard } from './components/SiteCard';
import { getContentUrls } from './utils/index';

function Index() {
  const { switchboard, pipe, groups, diary } = useContext(StoreContext);

  const switchboardSites = Object.entries(getContentUrls({ switchboard }));
  const defaultSite = Object.values(switchboard)[0];
  const baseUrl = (window.location.port === '')
    ? `${window.location.protocol}//${window.location.hostname}`
    : `${window.location.protocol}//${window.location.hostname}:${window.location.port}`

  const pipeName = Object.values(defaultSite?.plugins || {})[0]?.name
  const diaryResource = pipe?.flows?.[pipeName]?.resource;
  const diaryString = `diary/~${diaryResource?.ship}/${diaryResource?.name}`

  const group =
    Object.entries(groups || {})
      .reduce((res, [k, v]) => {
        if (Object.keys(v.channels).indexOf(diaryString) !== -1) {
          return k;
        } else {
          return res;
        }
      }, [])

  const groupUrl = `${baseUrl}/apps/groups/groups/${group}`
  const postUrl = (Object.keys(defaultSite?.plugins || {}).length === 1)
    ?  `${groupUrl}/channels/${diaryString}/edit` : groupUrl;

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        {switchboardSites?.length ? (
          <>
            <div className="flex flex-row justify-end items-baseline" style={{ gap: '1rem' }}>
              <div>
          { /*               <Link to="/new" className="top-button mr4">Sell Hosting</Link> */}
                <a target="_blank" href={postUrl} className="top-button mr4">+&nbsp;New Post</a>
                <Link to="/new" className="top-button">+&nbsp;New Site</Link>
                <Link className="ml4 top-button" to="/settings">Settings</Link>
              </div>
            </div>
            <div className="flex flex-column" style={{ gap: '1rem' }}>
              {switchboardSites.map(([site, contentUrl]) => (
                <SiteCard site={site} src={contentUrl?.url} key={site} title={contentUrl?.title}/>
              ))}
            </div>
          </>
        ) : (
          <>
            <div className="tc">
              <h1>welcome to studio</h1>
              <p>start by creating a site</p>
            </div>
            <div className="flex justify-center">
              <Link to="/new" id="first-site">+&nbsp;New Site</Link>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

export { Index };
