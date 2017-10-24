var ReactBsTable = window.BootstrapTable;

var AllPlanets = React.createClass({
	autobind: false,
	getInitialState() {
        return { 
			data: [],
			sortName: undefined,
			sortOrder: undefined
        }
    },

    componentDidMount() {
        $.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
    },

	coords(cell, row){
		return row.x + ':' + row.y + ':' + row.z;
	},

	niceNumber(cell, row) {
    	return cell.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	},

    onSortChange(sortName, sortOrder) {
	    console.info('onSortChange', arguments);
	    this.setState({
	      sortName,
	      sortOrder
	    });
  	},

    render() {
	    const options = {
	      sortName: this.state.sortName,
	      sortOrder: this.state.sortOrder,
	      onSortChange: this.onSortChange.bind(this)
	    };
    	return (
	        <BootstrapTable ref='table' data={ this.state.data }
						remote={ true }
						 options={ options }
						hover={ true }>
				<TableHeaderColumn dataField="id" isKey={true} hidden>Planet ID</TableHeaderColumn>
				<TableHeaderColumn dataField="score_rank">Rank</TableHeaderColumn>
				<TableHeaderColumn dataField="x" dataFormat={this.coords}>Coords</TableHeaderColumn>
				<TableHeaderColumn dataField="rulername">Ruler Name</TableHeaderColumn>
				<TableHeaderColumn dataField="planetname">Planet Name</TableHeaderColumn>
				<TableHeaderColumn dataField="race">Race</TableHeaderColumn>
				<TableHeaderColumn dataField="size" dataFormat={this.niceNumber} dataSort={ true }>Size</TableHeaderColumn>
				<TableHeaderColumn dataField="score" dataFormat={this.niceNumber}>Score</TableHeaderColumn>
				<TableHeaderColumn dataField="name">Alliance</TableHeaderColumn>
			</BootstrapTable>
		)
    }
});
