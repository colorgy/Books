GroupTable = React.createClass
  getDefaultProps: ->
    orgs: []
    page: 1
    perPage: 20
    sortBy: 'code'
    groupsState: 'ended'
    APIEndpoint: '/scp/deliver'

  getInitialState: ->
    groupsState: @props.groupsState
    page: @props.page
    perPage: @props.perPage
    sortBy: @props.sortBy
    groups: []
    allChecked: false

  rows: []

  componentDidMount: ->
    @getGroups()

  handleGroupsStateChange: (e) ->
    e.preventDefault()
    target = e.target
    target = target.parentNode if !target.hasAttribute('data-group-state')
    gs = target.getAttribute('data-group-state')
    if gs
      @setState groupsState: gs, ->
        @getGroups()

  handlePerPageChange: (event) ->
    value = event.target.value
    @setState perPage: value, ->
      @getGroups()

  handlePageChange: (payload) ->
    @setState page: payload.page, ->
      @getGroups()

  getGroups: () ->
    @setState loading: true
    groupsState = @state.groupsState
    groupsState = 'not(null)' if groupsState == 'all'
    groupsState = 'not(grouping,ended)' if groupsState == 'processed'
    sortBy = @state.sortBy
    sortBy = "#{@state.sortBy},code" if !sortBy.match(/code/)
    $.ajax
      method: 'GET'
      url: "#{@props.APIEndpoint}.json"
      dataType: 'json'
      data:
        'filter[state]': groupsState
        'page': @state.page
        'per_page': @state.perPage
        'sort': sortBy
      statusCode:
        401: ->
          preventClose.allow()
          location.reload()
    .done (data, textStatus, xhr) =>
      @setState
        groups: data
        loading: false
        paginationLinks: xhr.getResponseHeader('Link')
    .fail (data, textStatus, xhr) =>
      @setState loading: false
      flash.error('資料載入失敗！', [['重試', @getGroups]])

    $.ajax
      method: 'HEAD'
      url: "#{@props.APIEndpoint}.json"
      dataType: 'json'
      data:
        'filter[state]': 'grouping'
    .done (data, textStatus, xhr) =>
      @setState groupingCount: parseInt(xhr.getResponseHeader('X-Items-Count'))

    $.ajax
      method: 'HEAD'
      url: "#{@props.APIEndpoint}.json"
      dataType: 'json'
      data:
        'filter[state]': 'ended'
    .done (data, textStatus, xhr) =>
      @setState pendingCount: parseInt(xhr.getResponseHeader('X-Items-Count'))

    $.ajax
      method: 'HEAD'
      url: "#{@props.APIEndpoint}.json"
      dataType: 'json'
      data:
        'filter[state]': 'not(grouping,ended)'
    .done (data, textStatus, xhr) =>
      @setState processedCount: parseInt(xhr.getResponseHeader('X-Items-Count'))

  ship: (code) ->
    $.ajax
      method: 'PATCH'
      url: "#{@props.APIEndpoint}/#{code}.json"
      dataType: 'json'
      data:
        'event': 'ship'
      statusCode:
        401: ->
          preventClose.allow()
          location.reload()
    .done (data, textStatus, xhr) =>
      flash.success('已標示為發送！')
      @getGroups()
    .fail (data, textStatus, xhr) =>
      @setState loading: false
      flash.error('執行失敗！')

  handleShip: (payload) ->
    @ship payload.code

  checkAll: ->
    if @state.allChecked
      @setState allChecked: false
      for row in @rows
        row?.unselect?()
        console.log row
    else
      @setState allChecked: true
      for row in @rows
        row?.select?()
        console.log row

  render: ->
    data = @state.groups.map ((group) ->
      `<GroupRow key={group.code} group={group}
        onShip={this.handleShip}
        ref={function(node) { this.rows.push(node) }.bind(this)} />`
    ).bind(this)

    paginationLinks = @state.paginationLinks

    loadingOverlay = null
    if @state.loading
      loadingOverlay =
        `<div className="overlay">
          <i className="fa fa-refresh fa-spin"></i>
        </div>`

    @rows = []

    `<section className="content">
      <div className="row">
        <div className="col-md-3">
          <div className="box box-solid">
            <div className="box-header with-border">
              <h3 className="box-title">訂單分類</h3>
              <div className="box-tools">
                <button className="btn btn-box-tool" data-widget="collapse"><i className="fa fa-minus"></i></button>
              </div>
            </div>
            <div className="box-body no-padding">
              <ul className="nav nav-pills nav-stacked">
                <li className={classNames({ 'active': this.state.groupsState == 'grouping' })}><a href="#" onClick={this.handleGroupsStateChange}
                  data-group-state="grouping">
                  <i></i> 尚未確認的訂單
                  <span className="label label-primary pull-right">{this.state.groupingCount}</span>
                </a></li>
                <li className={classNames({ 'active': this.state.groupsState == 'ended' })}><a href="#" onClick={this.handleGroupsStateChange}
                  data-group-state="ended">
                  <i></i> 需要出貨的訂單
                  <span className="label label-primary pull-right">{this.state.pendingCount}</span>
                </a></li>
                <li className={classNames({ 'active': this.state.groupsState == 'processed' })}><a href="#" onClick={this.handleGroupsStateChange}
                  data-group-state="processed">
                  <i></i> 已出貨的訂單
                  <span className="label label-primary pull-right">{this.state.processedCount}</span>
                </a></li>
                <li className={classNames({ 'active': this.state.groupsState == 'all' })}><a href="#" onClick={this.handleGroupsStateChange}
                  data-group-state="all">
                  <i></i> 所有訂單
                </a></li>
              </ul>
            </div>
          </div>
        </div>
        <div className="col-md-9">
          <div className="box box-primary">
            <div className="box-header with-border">
              <h3 className="box-title">訂單</h3>
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
              </div>
            </div>
            <div className="box-body no-padding">
              <div className="mailbox-controls">

                <button onClick={this.checkAll} className="btn btn-default btn-sm checkbox-toggle"><i className="fa fa-square-o"></i></button>

              </div>
              <div className="table-responsive groups">
                <table className="table table-hover table-striped">
                  <thead>
                    <tr>
                      <th></th>
                      <th>
                        團號
                      </th>
                      <th>
                        訂購書名
                      </th>
                      <th>
                        訂購書籍 ISBN
                      </th>
                      <th>
                        書籍內部編號
                      </th>
                      <th>
                        數量
                      </th>
                      <th>
                        營收
                      </th>
                      <th>
                        明細
                      </th>
                      <th>
                        動作
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {data}
                  </tbody>
                </table>
              </div>
            </div>
            <div className="box-footer no-padding">
              <div className="mailbox-controls">
                <button onClick={this.checkAll} className="btn btn-default btn-sm checkbox-toggle"><i className="fa fa-square-o"></i></button>
              </div>
            </div>
            {loadingOverlay}
          </div>
        </div>
      </div>
    </section>`

window.GroupTable = GroupTable
