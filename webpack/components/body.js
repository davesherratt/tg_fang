class Body extends React.Component {
  constructor(props){
    super(props);
  }

  render () {
    return (
      <div>
            <Planets />
      </div>
    );
  }
}

Body.propTypes = {
  label: React.PropTypes.string
};
