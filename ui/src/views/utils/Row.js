
function Row({className, children, ...props}) {
  className = className ? `flex ${className}` : 'flex';

  return (
    <div className={className} {...props}>
      {children}
    </div>
  );
}

export { Row };
