class Main extends React.Component {
  render () {
    return (
      <div>
        <div>Label: {this.props.label}</div>
      </div>
    );
  }
}

Main.propTypes = {
  label: React.PropTypes.string
};
