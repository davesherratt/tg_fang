class AllPlanets extends React.Component {
  	constructor(props) {
	    super(props);

	    this.state = {
	      sortName: [],
	      sortOrder: [],
	      data: []
	    };
	    this.onSortChange = this.onSortChange.bind(this);
	    this.cleanSort = this.cleanSort.bind(this);
  	}

    componentDidMount() {
        $.getJSON('/api/v1/planets.json', (response) => { this.setState({ data: response }) });
    }

  	onSortChange(name, order) {
	    const sortName = [];
	    const sortOrder = [];

	    for (let i = 0; i < this.state.sortName.length; i++) {
	      if (this.state.sortName[i] !== name) {
	        sortName.push(this.state.sortName[i]);
	        sortOrder.push(this.state.sortOrder[i]);
	      }
	    }

	    sortName.push(name);
	    sortOrder.push(order);
	    this.setState({
	      sortName,
	      sortOrder
	    });
  	}

  	niceNumber(cell, row) {
    	return cell.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	coords(cell, row){
		return row.x + ':' + row.y + ':' + row.z;
	}

  	cleanSort() {
	    this.setState({
	      sortName: [],
	      sortOrder: []
	    });
  	}

  	render() {
	    const options = {
	      sortName: this.state.sortName,
	      sortOrder: this.state.sortOrder,
	      onSortChange: this.onSortChange,
	      sizePerPage: 100
	    };
	    return (
	      <div>
	        <BootstrapTable data={ this.state.data } options={ options } multiColumnSort={ 2 } hover={ true } pagination>
				<TableHeaderColumn dataField="id" isKey={true} hidden>Planet ID</TableHeaderColumn>
				<TableHeaderColumn dataField="score_rank" dataSort={ true }>Rank</TableHeaderColumn>
				<TableHeaderColumn dataField="x" dataFormat={this.coords}>Coords</TableHeaderColumn>
				<TableHeaderColumn dataField="rulername">Ruler Name</TableHeaderColumn>
				<TableHeaderColumn dataField="planetname">Planet Name</TableHeaderColumn>
				<TableHeaderColumn dataField="race" dataSort={ true }>Race</TableHeaderColumn>
				<TableHeaderColumn dataField="size" dataFormat={this.niceNumber} dataSort={ true }>Size</TableHeaderColumn>
				<TableHeaderColumn dataField="score" dataFormat={this.niceNumber} dataSort={ true }>Score</TableHeaderColumn>
				<TableHeaderColumn dataField="value" dataFormat={this.niceNumber} dataSort={ true }>Value</TableHeaderColumn>
				<TableHeaderColumn dataField="name" dataSort={ true }>Alliance</TableHeaderColumn>
				<TableHeaderColumn dataField="nick">Nick</TableHeaderColumn>
	        </BootstrapTable>
	      </div>
	    );
  	}
}