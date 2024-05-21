
function Col({className, children, ...props}) {
  className = className ? `flex flex-column ${className}` : 'flex flex-column';

  return (
    <div className={className} {...props}>
      {children}
    </div>
  );
}

export { Col };
