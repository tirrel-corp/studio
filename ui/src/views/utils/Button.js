function Button({ children, onClick, disabled = false }) {
  return (
    <button
      className="input-reset button-reset bn bg-inherit pointer pa0"
      onClick={onClick}
      disabled={disabled}>
      {children}
    </button>
  );
}

export { Button };
