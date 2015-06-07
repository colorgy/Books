NewBookModal = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    id: 'newBookModal'
    orgs: []
    defaultOrgCode: 'public'
    onCreateBook: (payload) ->
      console.log payload

  getInitialState: ->
    isbn: ''
    price: 1000
    internalCode: ''
    validate: false
    orgCode: @props.defaultOrgCode

  handlePriceChange: (price) ->
    @setState price: parseInt(price)

  handleISBNChange: (isbn) ->
    @setState isbn: isbn

  handleOrgChange: (orgCode) ->
    @setState orgCode: orgCode

  reset: ->
    @setState @getInitialState()

  getBookData: (input, callback) ->
    $.ajax
      method: 'GET'
      url: "/book_datas.json"
      dataType: 'json'
      data:
        q: input
    .done (data, textStatus, xhr) =>
      options = data.map (book) ->
        value: book.isbn
        label: `<div className="complex-selection">
            <img src={book.image_url} />
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

  createBook: ->
    @setState validate: true, ->
      if @isbnHasError()
        flash.error('您所選的書籍是無效的！')
      else if @priceHasError()
        flash.error('請輸入有效的價格！')
      else
        @props.onCreateBook
          data:
            isbn: @state.isbn
            price: @state.price
            internal_code: @state.internalCode
            organization_code: @state.orgCode
        flash.info('儲存中...')

  isbnHasError: ->
    return false unless @state.validate
    !@state.isbn

  priceHasError: ->
    return false unless @state.validate
    !parseInt(@state.price)

  render: ->
    priceValueLink =
      value: @state.price
      requestChange: @handlePriceChange

    isbnHasError = @isbnHasError()
    priceHasError = @priceHasError()

    publicOrgSelection = [{ value: 'public', label: '公開' }]
    orgSelections = publicOrgSelection.concat @props.orgs.map (org) ->
      { value: org.code, label: "#{org.short_name} (#{org.code}) 專屬" }

    `<div className="modal fade" id={this.props.id} tabIndex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
      <div className="modal-dialog">
        <div className="modal-content">
          <div className="modal-header">
            <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 className="modal-title" id="myModalLabel">
              新書上架
            </h4>
          </div>
          <div className="modal-body">
            <div className="form-group">
              <label htmlFor="price-input">上架至</label>
              <Select
                value={this.state.orgCode}
                onChange={this.handleOrgChange}
                options={orgSelections}
                clearable={false}
              />
            </div>
            <div className={classNames({ 'form-group': true, 'has-error': isbnHasError })}>
              <label htmlFor="price-input">選擇書籍</label>
              <Select className="with-complex-selection"
                asyncOptions={this.getBookData}
                onChange={this.handleISBNChange}
                value={this.state.isbn}
                placeholder="搜尋書籍"
              />
            </div>
            <div className={classNames({ 'form-group': true, 'has-error': priceHasError })}>
              <label htmlFor="price-input">價格</label>
              <div className="input-group">
                <span className="input-group-addon">NT$ </span>
                <input type="number"
                  className="form-control"
                  id="price-input"
                  valueLink={priceValueLink}
                  placeholder="" />
              </div>
            </div>
            <div className="form-group">
              <label htmlFor="internal-code-input">內部編號</label>
              <input className="form-control"
                id="internal-code-input"
                valueLink={this.linkState('internalCode')}
                placeholder="" />
            </div>
          </div>
          <div className="modal-footer">
            <button type="button" className="btn btn-default" data-dismiss="modal">取消</button>
            <button type="button" className="btn btn-primary" onClick={this.createBook}>上架新書</button>
          </div>
        </div>
      </div>
    </div>`

window.NewBookModal = NewBookModal
