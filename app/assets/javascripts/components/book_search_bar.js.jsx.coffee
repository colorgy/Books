BookSearchBar = React.createClass

  getDefaultProps: ->
    value: null

  getInitialState: ->
    options: []
    value: @props.value

  getOptions: ->
    $.ajax
      method: 'GET'
      url: "/books_search_suggestions.json"
      dataType: 'json'
      data:
        q: @state.value
    .done (data, textStatus, xhr) =>
      @setState options: data

  handleChange: (val) ->
    @setState value: val, ->
      @getOptions()


  render: ->

    `<AutocompleteInput name="q" placeholder="搜尋書名、課名、老師名" type="text" options={this.state.options} value={this.state.value} onChange={this.handleChange} />`

window.BookSearchBar = BookSearchBar
