import { Link } from "react-router-dom";

const SiteCard = props => {
  const { site, src, title } = props;
  return (
    <div className="flex flex-row flex-wrap justify-center overflow-hidden pa2 ba br3 shadow-3 bg-near-white" style={{gap: '0.5rem', minHeight: '100px'}}>
      <div className="flex flex-column justify-center ml2" style={{flex: '3', gap: '0.5rem'}}>
        <div>
          {src ? (
            <>
              <a href={src} rel="noopener noreferrer" target="_blank">
                <span>{title}&nbsp;&#10138;</span>
              </a>
              <div className="mt2 f6"><code>{src}</code></div>
            </>
          ) : (
            <span>{title}</span>
          )}
        </div>
        <div className="flex flex-wrap items-center" style={{gap: 'var(--w0)'}}>
          <Link to={`/site/${site}`} className="button small">
            Manage
          </Link>
        </div>
      </div>
      {(src) ? (
        <div
          className="overflow-hidden"
          style={{
            width: 150,
            height: 100
          }}>
          <iframe
            title={site}
            src={src}
            className="ba br3 overflow-y-hidden"
            scrolling="no"
            style={!src ? {visibility: 'hidden', pointerEvents:'none'} : {
              transformOrigin: '0 0',
              transform: 'scale(0.25)',
              width: "600px",
              height: "400px"
            }}
          />
        </div>
      ) : (<br />)
      }
    </div>
  )
};

export { SiteCard };
