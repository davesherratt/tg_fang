class Main extends React.Component {
  constructor(props){
    super(props);
  }

  render () {
    return (
      <div>
			<Header />
			<Body />
      </div>
    );
  }
}

Main.propTypes = {
  label: React.PropTypes.string
};
