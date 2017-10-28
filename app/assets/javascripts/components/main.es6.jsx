class Home extends React.Component {
    render () {
    	return (
        	<h1>Hi</h1>
        );
    }
}

class Main extends React.Component {
	render () {
    	return (
    		<ReactRouter>
				<ReactRouter.Route path="/" component={Home}/>
			</ReactRouter>
		);
	}
}

