BookTable = React.createClass
  getDefaultProps: ->
    orgCode: 'public'
    page: 1
    perPage: 20
    sortBy: 'internal_code'
    APIEndpoint: '/scp/books'
    orgs: []

  getInitialState: ->
    orgCode: @props.orgCode
    page: @props.page
    perPage: @props.perPage
    sortBy: @props.sortBy
    loading: false
    books: []

  componentDidMount: ->
    @getBooks()

  handleOrgChange: (orgCode) ->
    @setState orgCode: orgCode, ->
      @getBooks() if orgCode

  handlePageChange: (payload) ->
    @setState page: payload.page, ->
      @getBooks()

  handlePerPageChange: (event) ->
    value = event.target.value
    @setState perPage: value, ->
      @getBooks()

  handleSortChange: (event) ->
    sortBy = $(event.target).attr('data-sort-by')
    sortBy = "-#{sortBy}" if @state.sortBy == sortBy
    @setState sortBy: sortBy, ->
      @getBooks()

  getBooks: () ->
    @setState loading: true
    orgCode = @state.orgCode
    orgCode = 'null()' if orgCode == 'public'
    sortBy = @state.sortBy
    sortBy = "#{@state.sortBy},isbn" if !sortBy.match(/isbn/)
    $.ajax
      method: 'GET'
      url: "#{@props.APIEndpoint}.json"
      dataType: 'json'
      data:
        'filter[organization_code]': orgCode
        'page': @state.page
        'per_page': @state.perPage
        'sort': sortBy
      statusCode:
        401: ->
          location.reload()
    .done (data, textStatus, xhr) =>
      @setState
        books: data
        loading: false
        paginationLinks: xhr.getResponseHeader('Link')
    .fail (data, textStatus, xhr) =>
      @setState loading: false
      flash.error('資料載入失敗！', [['重試', @getBooks]])

  saveBookPrice: (payload) ->
    preventClose.prevent()
    $.ajax
      method: 'PATCH'
      url: "#{@props.APIEndpoint}/#{payload.id}.json"
      dataType: 'json'
      data:
        book:
          'price': payload.price
      statusCode:
        401: ->
          location.reload()
    .done (data, textStatus, xhr) =>
      preventClose.preventEnd()
      books = @state.books
      for book, index in books
        if book.id == data.id
          books[index] = data
          break
      window.data = data
      window.bs = books
      @setState
        books: books
      flash.success('success')
    .fail (data, textStatus, xhr) =>
      console.log data
      flash.error('儲存失敗！')

  render: ->
    orgCode = @state.orgCode
    sortBy = @state.sortBy || ''

    loadingOverlay = null
    if @state.loading
      loadingOverlay =
        `<div className="overlay">
          <i className="fa fa-refresh fa-spin"></i>
        </div>`

    data = @state.books.map ((book) ->
      `<BookRow key={book.id} book={book} onPriceSave={this.saveBookPrice} />`
    ).bind(this)

    if data.length
      dataTable =
        `<table className="table table-hover">
          <thead>
            <tr>
              <th>#</th>
              <th>
                 書名
              </th>
              <th className={classNames({
                  'clickable': true,
                  'sort-by-asc': sortBy == 'isbn',
                  'sort-by-desc': sortBy.substr(1) == 'isbn'
                })}
                onClick={this.handleSortChange}
                data-sort-by="isbn">
                 ISBN
              </th>
              <th className={classNames({
                  'clickable': true,
                  'sort-by-asc': sortBy == 'internal_code',
                  'sort-by-desc': sortBy.substr(1) == 'internal_code'
                })}
                onClick={this.handleSortChange}
                data-sort-by="internal_code">
                 內部編號
              </th>
              <th className={classNames({
                  'clickable': true,
                  'sort-by-asc': sortBy == 'price',
                  'sort-by-desc': sortBy.substr(1) == 'price'
                })}
                onClick={this.handleSortChange}
                data-sort-by="price">
                 售價
              </th>
            </tr>
          </thead>
          <tbody>
            {data}
          </tbody>
        </table>`
    else
      dataTable =
        `<div className="panel-body">
          <center>
            <br/><br/><br/>
            <p>所選的範圍內沒有書籍！</p>
            <br/><br/><br/>
          </center>
        </div>`

    paginationLinks = @state.paginationLinks

    publicOrgSelection = [{ value: 'public', label: '公開' }]
    orgSelections = publicOrgSelection.concat @props.orgs.map (org) ->
      { value: org.code, label: "#{org.short_name} (#{org.code}) 專屬" }

    `<div className="box box-default">
      <div className="box-header with-border">
        <div className="box-title">
          <Select
            value={orgCode}
            onChange={this.handleOrgChange}
            options={orgSelections}
          />
        </div>
        <div className="box-tools main pull-right">
          <nav>
            <LinkPagination linkString={paginationLinks} onClick={this.handlePageChange} />
          </nav>
          &nbsp;&nbsp;
          <span className="box-tools-text">
            每頁顯示：
          </span>
          <div className="has-feedback">
            <select className="form-control"
              onChange={this.handlePerPageChange}
              value={this.state.perPage}>
              <option>10</option>
              <option>20</option>
              <option>25</option>
              <option>50</option>
              <option>100</option>
              <option>500</option>
              <option>1000</option>
            </select>
          </div>
          &nbsp;&nbsp;
          <a className="btn btn-default">
            <span className="glyphicon glyphicon-plus"></span>
            上架新書
          </a>
          &nbsp;&nbsp;
        </div>
      </div>
      <div className="box-body">
        {dataTable}
      </div>
      {loadingOverlay}
    </div>`

window.BookTable = BookTable
