SearchSelect = React.createClass

  getDefaultProps: ->
    asyncSelections: null
    selections: []
    value: null
    className: ''
    searchInputClassName: ''
    selectionClassName: ''
    placeholder: ''
    noResultsText: ''
    onChange: ->

  getInitialState: ->
    value: @props.value
    # searchInputValue: @props.value
    selections: @props.selections

  asyncSelectionsCallback: (selections) ->
    @setState selections: selections

  componentDidMount: ->
    if @props.asyncSelections
      @props.asyncSelections(@state.value, @asyncSelectionsCallback)

  handleSearchInputChange: (e) ->
    value = e.target.value
    @setState searchInputValue: value
    if @props.asyncSelections
      @props.asyncSelections(value, @asyncSelectionsCallback)

  handleSelect: (value, selection) ->
    @props.onChange?(value, selection)
    @setState
      value: value
      selection: selection

  render: ->
    searchRegexp = new RegExp("^(?:\<.+\>)*[^\<]*(#{@state.searchInputValue})", 'img')
    if @state.searchInputValue
      filteredSelections = @state.selections?.filter (selection) ->
        selection.label?.match searchRegexp
    else
      filteredSelections = @state.selections

    selectionsHasActive = false

    selections = filteredSelections.map (selection) =>
      label = selection.label
      if @state.searchInputValue
        label = selection.label?.replace searchRegexp, (full, capture) ->
          pre = full.slice(0, -capture.length)
          return "#{pre}<u>#{capture}</u>"

      selectionClassName = @props.selectionClassName
      if selection.value == @state.value
        selectionsHasActive = true
        selectionClassName += ' active'
        @state.selection = selection

      handleSelect = @handleSelect

      `<div
        key={selection.value}
        className={selectionClassName}
        dangerouslySetInnerHTML={{ __html: label }}
        onClick={handleSelect.bind(null, selection.value, selection)}>
      </div>`

    if !selectionsHasActive && @state.selection
      selection = @state.selection
      label = selection.label
      activeSelection = `<div
        key={selection.value}
        className="active"
        dangerouslySetInnerHTML={{ __html: label }}>
      </div>`
      activeSelections = [activeSelection]
      selections = activeSelections.concat selections

    if !selections || !selections.length
      selections = `<div>
        {this.props.noResultsText}
      </div>`

    `<div className={'search-select ' + this.props.className}>
      <input
        value={this.state.searchInputValue}
        onChange={this.handleSearchInputChange}
        className={this.props.searchInputClassName}
        placeholder={this.props.placeholder}
      />
      <div className="search-select-selections">
        {selections}
      </div>
    </div>`

window.SearchSelect = SearchSelect
