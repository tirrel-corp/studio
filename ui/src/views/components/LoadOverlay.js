import LoadingSpinner from "./icons/LoadingSpinner";

export default function LoadOverlay() {
    return (
        <div className="fixed flex flex-column justify-center items-center top-0 left-0"
            style={{
                background: "rgba(0,0,0,0.25)",
                zIndex: "9999",
                width: "100vw",
                height: "100vh"
            }}>
            <LoadingSpinner />
        </div>
    )
}