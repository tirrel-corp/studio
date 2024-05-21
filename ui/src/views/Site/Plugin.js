import { useContext } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { StoreContext } from '../../logic/Store';
import { PipeDetails } from './PluginDetails/PipeDetails'
import { MailerDetails } from './PluginDetails/MailerDetails'
import { PaywallDetails } from './PluginDetails/PaywallDetails';

const Plugin = props => {
  const { name: siteName, pluginType } = useParams();
  const navigate = useNavigate();

  const { api, switchboard } = useContext(StoreContext);
  const { binding, plugins: myPlugins = {} } = switchboard?.[siteName] || {};
  const sitePath = binding ? `${binding?.hostname}${binding?.path}` : '';

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{siteName}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
          {pluginType === 'pipe' && <PipeDetails />}
          {pluginType === 'mailer' && <MailerDetails />}
          {pluginType === 'paywall' && <PaywallDetails />}
        </div>
      </div>
    </div>
  );
};

export { Plugin };
