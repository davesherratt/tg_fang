class Home extends React.Component {
  constructor(props){
    super(props);
  }

  render () {
    return (
	      <Router>
	      	<IndexRoute component={Main} />
	        <Route path="/" component={Main}>
	        </Route>
	      </Router>
    );
  }
}

Home.propTypes = {
  label: React.PropTypes.string
};

export default Home;  