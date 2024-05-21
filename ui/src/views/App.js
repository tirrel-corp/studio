import { useReducer, useEffect } from 'react';
import { Outlet } from "react-router-dom";
import { StoreContext, initialStore } from '../logic/Store';
import { Reducer } from '../logic/Reducer';
import { Subscribe } from '../logic/Subscribe';
import { Header } from './Header';

function App() {
  const [store, setStore] = useReducer(Reducer, initialStore);
  useEffect(() => {
    setStore({
      api: Subscribe(setStore)
    })
  }, []);

  return (
    <div className="sans-serif gray bg-light-gray w-100 flex flex-column justify-start items-stretch" style={{minHeight: '100vh'}}>
      <Header />
      <div className="w-100 pa2-ns" style={{ height: "calc(100% - 3rem)" }}>
        <div className="h-100 w-100 br2-ns bg-light-gray overflow-y-auto">
          <StoreContext.Provider value={store}>
            <Outlet/>
          </StoreContext.Provider>
        </div>
      </div>
    </div>
  );
}

export { App };
