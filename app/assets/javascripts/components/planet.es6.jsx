function handleErrors(response) {
    if (!response.ok) {
        throw Error(response.statusText);
    }
    return response;
}

class Planet extends React.Component {
  	constructor(props) {
	    super(props);

	    this.state = {
	      sortName: [],
	      sortOrder: [],
	      data: [],
	      rowCount: []
	    };
	    this.rowCount = 0;
	    this.onSortChange = this.onSortChange.bind(this);
	    this.cleanSort = this.cleanSort.bind(this);
  	}

    componentDidMount() {
    	this.setState({ rowCount: 0 })
    	fetch("/api/v1/planets.json")
	    .then(handleErrors)
	    .then(response => response.json())
	    .then(data => { 
	    	this.setState({ data: data.json }) 
	    } )
	    .catch(error => console.log(error) );

        /*$.getJSON('/api/v1/planets.json', (response) => { this.setState({ datad: response }) });
	    console.log(this.state.datad);*/
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


	round(cell, row){
		return Math.round(cell * 100) / 100
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
	        	<TableHeaderColumn row='0' width='10%' colSpan='4'>Universe Rank</TableHeaderColumn>
        		<TableHeaderColumn row='0' colSpan='11'></TableHeaderColumn>
        		<TableHeaderColumn row='0' colSpan='3'>Growth</TableHeaderColumn>
        		<TableHeaderColumn row='0' width='10%' colSpan='2'>Intel</TableHeaderColumn>
				<TableHeaderColumn dataField="id" isKey={true} hidden>Planet ID</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="score_rank" dataSort={ true }>Score</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="value_rank" dataSort={ true }>Value</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="size_rank" dataSort={ true }>Size</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="xp_rank" dataSort={ true }>XP</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="x">X</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="y">Y</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="z">Z</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="rulername">Ruler</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="planetname">Planet</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="race" dataSort={ true }>Race</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="size" dataFormat={this.niceNumber} dataSort={ true }>Size</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="value" dataFormat={this.niceNumber} dataSort={ true }>Value</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="score" dataFormat={this.niceNumber} dataSort={ true }>Score</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="ratio" dataFormat={this.round}>Ratio</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="xp" dataFormat={this.niceNumber} dataSort={ true }>XP</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="size_growth_pc" dataFormat={this.round} dataSort={ true }>Size</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="value_growth_pc" dataFormat={this.round} dataSort={ true }>Value</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="score_growth_pc" dataFormat={this.round} dataSort={ true }>Score</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="name" dataSort={ true }>Alliance</TableHeaderColumn>
				<TableHeaderColumn row='1' dataField="nick">Nick</TableHeaderColumn>
	        </BootstrapTable>
	      </div>
	    );
  	}
}