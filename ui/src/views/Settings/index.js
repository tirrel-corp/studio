import { useState, useContext, useRef } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { StoreContext } from '../../logic/Store';
import LoadOverlay from '../components/LoadOverlay';
import ConfigurePayoutDetails from './ConfigurePayoutDetails';
import { formatUsd } from "../utils/index";

export default function UserSettings() {
    const dialogRef = useRef(0);
    const [loading, setLoading] = useState(false);
    const [showConfigureDetails, setShowConfigureDetails] = useState(false);
    const { api, auth } = useContext(StoreContext);
    const navigate = useNavigate()

    const earnings = auth?.["payout-status"]?.earnings.cents / 100;
    const forwardId = (passbaseId) => {
        api.poke({
            app: "auth",
            mark: "auth-action",
            json: {
                "forward-id": passbaseId
            }
        }).catch(err => {
            console.error(err);
        });
    }

    const triggerPayout = () => {
        api.poke({
            app: "auth",
            mark: "auth-action",
            json: {
                "trigger-payout": auth?.["payout-status"]?.earnings
            }
        }).catch(err => {
            console.error(err);
        });
    }
    return <div className="w-100 h-100 flex flex-column justify-center items-center">
        {loading && <LoadOverlay />}
        <div className="pt4 h-100 flex flex-column justify-start" style={{ width: 'calc(min(80ch, 95%))', gap: '2rem' }}>
            <div className="flex flex-row justify-start items-center" style={{ gap: '1rem' }}>
                <button onClick={() => navigate('../')}>
                    &#8592;&nbsp;Back
                </button>
                <h1 className="ma0">Settings</h1>
            </div>
            <hr className="w-100" />
            <div className="flex flex-column pa4 ba br3 shadow-3 bg-near-white mb2" style={{ gap: '1rem', minHeight: '50vh' }}>
            </div>
        </div>
    </div>
}
