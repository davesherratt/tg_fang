var Body = React.createClass({
/*
    getInitialState() {
        return { data: [] }
    },

	constructor(props) {
    	super(props);
    	$.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
  	},

	onSortChange(sortName, sortOrder) {
	    if (sortOrder === 'asc') {
	      this.data.sort(function(a, b) {
	        if (parseInt(a[sortName], 10) > parseInt(b[sortName], 10)) {
	          return 1;
	        } else if (parseInt(b[sortName], 10) > parseInt(a[sortName], 10)) {
	          return -1;
	        }
	        return 0;
	      });
	    } else {
	      this.data.sort(function(a, b) {
	        if (parseInt(a[sortName], 10) > parseInt(b[sortName], 10)) {
	          return -1;
	        } else if (parseInt(b[sortName], 10) > parseInt(a[sortName], 10)) {
	          return 1;
	        }
	        return 0;
	      });
	    }
	    this.setState({
      		data: this.data
    	});
    },

    componentDidMount() {
        $.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
    },
*/
    render() {
        return (
            <div>
                <AllPlanets />
            </div>
        )
    }
});
