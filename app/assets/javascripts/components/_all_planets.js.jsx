var ReactBsTable = window.BootstrapTable;
function coords(cell, row){
		return row.x + ':' + row.y + ':' + row.z;
}

var AllPlanets = React.createClass({

    render() {
    	return (
	        <BootstrapTable data={ this.props.data }
                      remote={ true }
                      hover={ true }
                      options={ {
			defaultSortName: 'score_rank',
			defaultSortOrder: 'desc'
    	} }
                      pagination>
				<TableHeaderColumn dataField="id" isKey={true} hidden>Product ID</TableHeaderColumn>
				<TableHeaderColumn dataField="score_rank" data dataSort>Rank</TableHeaderColumn>
				<TableHeaderColumn dataField="x" dataFormat={coords}>Coords</TableHeaderColumn>
				<TableHeaderColumn dataField="rulername">Ruler Name</TableHeaderColumn>
				<TableHeaderColumn dataField="planetname">Planet Name</TableHeaderColumn>
				<TableHeaderColumn dataField="race" dataSort>Race</TableHeaderColumn>
				<TableHeaderColumn dataField="size" dataSort>Size</TableHeaderColumn>
				<TableHeaderColumn dataField="score" dataSort>Score</TableHeaderColumn>
				<TableHeaderColumn dataField="name" dataSort>Alliance</TableHeaderColumn>
			</BootstrapTable>
		)
    }
});