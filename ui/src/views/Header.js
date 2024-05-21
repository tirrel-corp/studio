import { NavLink } from "react-router-dom";

function Header() {
  return (
    <header className="flex flex-row items-center justify-start b pv3 ph2 ph4-ns silver" style={{ gap: '2rem' }}>
      <div className="flex items-center justify-between w-100">
        <NavLink
          to="/"
          className="no-underline pointer ph1"
        >
          <div className="flex flex-row items-center">
            <img
              height="40px"
              src="https://tirrel.io/assets/stool-alone.svg"
            />
            <span className="f3 fw6 gray ml3" style={{ letterSpacing: '0.03em' }}>
              Urbit Studio
            </span>
          </div>
        </NavLink>

      </div>
    </header>
  );
}

export { Header };

