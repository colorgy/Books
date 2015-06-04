BookTable = React.createClass
  getDefaultProps: ->
    orgCode: 'public'
    page: 1
    perPage: 20
    APIEndpoint: '/scp/books.json'
    orgs: []

  getInitialState: ->
    orgCode: @props.orgCode
    page: @props.page
    perPage: @props.perPage
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

  getBooks: () ->
    @setState loading: true
    orgCode = @state.orgCode
    orgCode = 'null()' if orgCode == 'public'
    $.ajax
      method: 'GET'
      url: @props.APIEndpoint
      dataType: 'json'
      data:
        'filter[organization_code]': orgCode
        'page': @state.page
        'per_page': @state.perPage
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

  render: ->
    orgCode = @state.orgCode

    loadingOverlay = null
    if @state.loading
      loadingOverlay =
        `<div className="overlay">
          <i className="fa fa-refresh fa-spin"></i>
        </div>`

    data = @state.books.map (book) ->
      `<tr key={book.id}>
        <th scope="row">{book.id}</th>
        <td>{book.name}</td>
        <td>{book.isbn}</td>
        <td>{book.isbn}</td>
        <td>{book.price}</td>
      </tr>`
    if data.length
      dataTable =
        `<table className="table">
          <thead>
            <tr>
              <th>#</th>
              <th>書名</th>
              <th>ISBN</th>
              <th>內部編號</th>
              <th>售價</th>
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
          &nbsp;
          <a className="btn btn-default">
            <span className="glyphicon glyphicon-plus"></span>
            上架新書
          </a>
          &nbsp;
          <div className="has-feedback">
            <input type="text" className="form-control" placeholder="Search..."/>
            <span className="glyphicon glyphicon-search form-control-feedback"></span>
          </div>
        </div>
      </div>
      <div className="box-body">
        {dataTable}
      </div>
      {loadingOverlay}
    </div>`

window.BookTable = BookTable
