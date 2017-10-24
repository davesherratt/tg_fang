var Planet = React.createClass({
    getInitialState() {
        return {editable: false}
    },

    render() {
        return (
            <div>
                {this.props.planet.planetname}
                {this.props.planet.rulername}
            </div>
        )
    }
});