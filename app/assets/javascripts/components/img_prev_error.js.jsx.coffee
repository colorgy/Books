ImgPrevError = React.createClass

  getDefaultProps: ->
    src: null
    name: '?'

  getInitialState: ->
    src: @props.src

  handleError: ->
    @setState src: "https://placeholdit.imgix.net/~text?txtsize=300&txt=#{this.props.name}&w=400&h=500"

  render: ->

    `<img src={this.state.src} name={this.props.name} onError={this.handleError} />`

window.ImgPrevError = ImgPrevError
