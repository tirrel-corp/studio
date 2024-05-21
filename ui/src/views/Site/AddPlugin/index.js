import { useContext, useEffect, useState } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { StoreContext } from '../../../logic/Store';

const AddPlugin = props => {
  const { name } = useParams();
  const navigate = useNavigate();
  const { auth, switchboard } = useContext(StoreContext);
  const [paywallStep, setPaywallStep] = useState(0)
  const hasPublication = Object.values(switchboard?.[name]?.plugins || {})
    .some(({ type }) => type === 'pipe');

  const hasMailer = Object.values(switchboard?.[name]?.plugins || {})
    .some(({ type }) => type === 'mailer');

  useEffect(() => {
    const lastSessionPublication = Object.keys(auth?.services || {}).find((authBlog) => {
      return Object.values(switchboard?.[name]?.plugins || {}).find((plugin) => plugin.name === authBlog)
    });

    if (lastSessionPublication) {
      setPaywallStep(2)
    } else {
      setPaywallStep(1)
    }
  }, [auth])

  const paywallInfo = [
    { href: 'publication', description: 'Set up a payment gate for your studio blog.' },
    { href: 'publication', description: 'Set up a payment gate for your studio blog.' }
  ]

  return (
    <div className="w-100 h-100 flex flex-column justify-center items-center">
      <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
        <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
          <button onClick={() => navigate('../../')}>
            &#8592;&nbsp;Back
          </button>
          <h1 className="ma0">{name}</h1>
        </div>
        <hr className="w-100" />
        <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
          <h2>Add New Plugin</h2>

          {hasPublication ? (
            <div className="ba br3 pa3 bg-light-gray silver b--silver">
              <h3>Blog</h3>
              <p>
                Publish one of your Urbit notebooks as a blog.
                <br /><br />
                <em>
                  Studio doesn't currently support configuring more than one
                  blog per site.
                </em>
              </p>
            </div>
          ) : (
            <div className="ba br3 pa3 bg-washed-blue">
              <h3><Link to="./pipe">Blog</Link></h3>
              <p>Publish one of your Urbit notebooks as a blog.</p>
            </div>
          )}
          {hasPublication && paywallStep == 1 ? (
            <div className="ba br3 pa3 bg-washed-blue">
              <h3><Link to={`./paywall/${paywallInfo[paywallStep].href}`}>Paywalls</Link></h3>
              <p>{paywallInfo[paywallStep].description}</p>
            </div>
          ) : (
            <div className="ba br3 pa3 bg-light-gray silver b--silver">
              <h3>Paywalls</h3>
              <p>
                Set up a payment gate for your studio blog.
                <br /><br />
                <em>{
                  hasPublication
                    ? "You already have a paywall configured."
                    : "A paywall requires an existing Blog plugin."
                }</em>
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export { AddPlugin };
