class Home extends React.Component {
  constructor(props){
    super(props);
  }

  render () {
    return (
    	<div>
    		<Header/>
    	</div>
    );
  }
}

Home.propTypes = {
  label: React.PropTypes.string
};
