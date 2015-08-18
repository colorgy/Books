NewGroupBookSelect = React.createClass

  getDefaultProps: ->
    value: null

  getInitialState: ->
    isbn: null

  getData: (input, callback) ->
    $.ajax
      method: 'GET'
      url: "/books.json"
      dataType: 'json'
      data:
        q: input
    .done (data, textStatus, xhr) =>
      console.log data
      options = data.map (book) ->
        value: book.id.toString()
        label: `<div className="complex-selection">
            <ImgPrevError src={book.image_url} name={book.name} />
            <div className="complex-selection-info">
              <span className="complex-selection-label">
                書名
              </span>
              <span className="complex-selection-name">
                {book.name}
              </span>
            </div>
            <div className="complex-selection-info">
              <span className="complex-selection-label">
                作者
              </span>
              <span className="complex-selection-name">
                {book.author}
              </span>
            </div>
            <div className="complex-selection-info">
              <span className="complex-selection-label">
                ISBN
              </span>
              <span className="complex-selection-name">
                {book.isbn}
              </span>
            </div>
          </div>`
      callback null, options: options
    .fail (data, textStatus, xhr) =>
      callback 'error', options: []

  filterOption: ->
    true

  componentDidMount: ->
    @refs.select.autoloadAsyncOptions()

  render: ->
    value = @props.value?.toString()

    `<div className={classNames({ 'form-group': true })}>
      <label>選擇書籍</label>
      <Select className="with-complex-selection" ref="select"
        asyncOptions={this.getData}
        name="group[book_id]"
        value={value}
        placeholder="搜尋書籍"
        filterOption={this.filterOption}
      />
    </div>`

window.NewGroupBookSelect = NewGroupBookSelect
