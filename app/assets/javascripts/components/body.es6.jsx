class Body extends React.Component {
  constructor(props){
    super(props);
  }

  render () {
    return (
      <div>
            <AllPlanets />
      </div>
    );
  }
}

Body.propTypes = {
  label: React.PropTypes.string
};
