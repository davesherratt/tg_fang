var Body = React.createClass({
    getInitialState() {
        return { planets: [] }
    },
/*
	constructor(props) {
    	super(props);
    	$.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
  	},
*/
	onSortChange(sortName, sortOrder) {
	    if (sortOrder === 'asc') {
	      this.planets.sort(function(a, b) {
	        if (parseInt(a[sortName], 10) > parseInt(b[sortName], 10)) {
	          return 1;
	        } else if (parseInt(b[sortName], 10) > parseInt(a[sortName], 10)) {
	          return -1;
	        }
	        return 0;
	      });
	    } else {
	      this.planets.sort(function(a, b) {
	        if (parseInt(a[sortName], 10) > parseInt(b[sortName], 10)) {
	          return -1;
	        } else if (parseInt(b[sortName], 10) > parseInt(a[sortName], 10)) {
	          return 1;
	        }
	        return 0;
	      });
	    }
	    this.setState({
      		data: this.planets
    	});
    },

    componentDidMount() {
        $.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
    },

    handleUpdate(planet) {
        $.ajax({
                url: `/api/v1/planets/${planet.id}`,
                type: 'PUT',
                data: { planet: planet },
                success: () => {
                    this.updatePlanets(planet);

                }
            })
    },

    updatePlanets(planet) {
        var planets = this.state.planets.filter((i) => { return i.id != planet.id });
        planets.push(planet);

        this.setState({planets: planets });
    },

    render() {
        return (
            <div>
                <AllPlanets onSortChange={ this.onSortChange.bind(this) } { ...this.state } />
            </div>
        )
    }
});