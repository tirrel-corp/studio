import { useNavigate } from "react-router-dom"
import { BillingDetailsForm } from '../Site/AddPlugin/Paywall/BillingDetailsForm.js';
import { useState, useContext } from "react";
import { StoreContext } from '../../logic/Store';
import LoadOverlay from "../components/LoadOverlay";


export default function ConfigurePayoutDetails({ }) {
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState();
    const { api, auth } = useContext(StoreContext);
    // const [payoutType, setPayoutType] = useState('usdc');
    const payoutType = "usdc";
    const [usdcAddr, setUsdcAddr] = useState('');
    const [wireDetails, setWireDetails] = useState({});
    const navigate = useNavigate();
    const valid = (payoutType === "usdc" && /^(0x)?[0-9a-f]{40}$/i.test(usdcAddr) || payoutType === "wire" && Object.keys(wireDetails).length > 0);

    const publication = Object.keys(auth?.services)[0];
    const submitPayoutInfo = () => {
       let body =  {
            "add-payout": {
                ...(payoutType === "usdc" && { usdc: usdcAddr }),
                ...(payoutType === "wire" && {
                    wire: {
                        accountNumber: wireDetails.account,
                        routingNumber: wireDetails.route,
                        billingDetails: {
                            name: wireDetails.name,
                            city: wireDetails.city,
                            country: "US",
                            line1: wireDetails.line1,
                            line2: wireDetails.line2,
                            district: wireDetails.district,
                            postalCode: wireDetails.postalCode
                        },
                        bankDetails: {
                            name: null,
                            city: null,
                            country: "US",
                            line1: null,
                            line2: null,
                            district: null,
                        }
                    }
                })
            }
        }
        setLoading(true)
        api.poke({
            app: "auth",
            mark: "auth-action",
            json: body
        }).then(() => setLoading(false))
            .then(() => navigate("../.."))
            .catch(err => {
                setLoading(false)
                console.error(err);
                setError(err);
            });

    };
    return (
        <div className="flex-auto min-h-0 flex flex-column justify-between">
            {loading && <LoadOverlay />}
            <div>
                <p>Payouts are currently available in USDC.</p>
            </div>
            {/* <div className="w-100">
                <p>How would you like to receive payouts?</p>
                <select
                    id="payout-type"
                    className="w-100 mb4"
                    name="payout-type"
                    onChange={ev => setPayoutType(ev.target.value)}
                    style={{ maxWidth: "16ch" }}
                >
                    <option value="usdc" key="usdc">USDC</option>
                    <option value="wire" key="wire">Bank wire</option>
                </select>
            </div> */}
            {(payoutType === "wire") && (
                <>
                    {Object.keys(wireDetails).length === 0 ? <div>
                        <BillingDetailsForm
                            onSubmit={bd => {
                                setWireDetails(bd)
                            }}
                        />
                    </div>
                        : <>
                            <p className="ma0 mb2">Account ending in {wireDetails.account.slice(-4)}</p>
                            <button style={{ width: 'fit-content' }} className="pointer" onClick={() => setWireDetails({})}>Change information</button>
                        </>}
                </>
            )}
            {(payoutType === "usdc") && (
                <div>
                    <label htmlFor="address" className="db">Ethereum Address:</label>
                    <input
                        type="text"
                        name="address"
                        onChange={(e) => setUsdcAddr(e.target.value)}
                        className="mt2"
                        value={usdcAddr}
                    />
                </div>
            )}
            <div className="flex justify-between mt4">
                <button
                    disabled={!valid}
                    onClick={() => submitPayoutInfo()}
                >
                    Submit
                </button>
            </div>
        </div>
    )
}
