ImgPrevError = React.createClass

  getDefaultProps: ->
    src: null
    name: '?'
    className: ''

  getInitialState: ->
    src: @props.src

  handleError: ->
    @setState src: "https://placeholdit.imgix.net/~text?txtsize=100&txt=#{this.props.name}&w=400&h=500"

  render: ->

    `<img src={this.state.src} name={this.props.name} className={this.props.className} width={this.props.width} height={this.props.height} onError={this.handleError} />`

window.ImgPrevError = ImgPrevError
