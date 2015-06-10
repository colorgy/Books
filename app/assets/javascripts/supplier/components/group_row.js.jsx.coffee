GroupRow = React.createClass
  getDefaultProps: ->
    group: {}
    onShip: (payload) ->
      console.log payload

  getInitialState: ->
    checked: false

  handleClick: ->
    if @state.checked == false
      @select()
    else if @state.checked == true
      @unselect()

  select: ->
    @setState checked: true

  unselect: ->
    @setState checked: false

  selected: ->
    return @state.checked

  deliver: ->
    @props.onShip({ code: @props.group.code })

  render: ->
    group = @props.group

    actions = []

    if @props.group.state == 'ended'
      actions.push `<div className="btn-group">
          <button type="button" onClick={this.deliver}
            className="btn btn-sm btn-primary">
            發送
          </button>
          <button type="button" className="btn btn-sm btn-primary dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
            <span className="caret"></span>
            <span className="sr-only">Toggle Dropdown</span>
          </button>
          <ul className="dropdown-menu dropdown-menu-right" role="menu">
            <li className="disabled"><a href="#">列印出貨單並發送</a></li>
            <li className="divider"></li>
            <li className="disabled"><a href="#">列印出貨單</a></li>
          </ul>
        </div>`

    `<tr>
      <td onClick={this.handleClick}>
        <input type="checkbox" checked={this.state.checked}/>
      </td>
      <th scope="row" onClick={this.handleClick}>{group.code}</th>
      <td>{group.book_name}</td>
      <td>{group.book_isbn}</td>
      <td>{group.book_internal_code}</td>
      <td>{group.orders_count} / {group.unpaid_orders_count}</td>
      <td>NT$ {group.orders_count * group.book_price}</td>
      <td>
        <button type="button" className="btn btn-sm" data-toggle="modal" data-target={'#group-detail' + group.code}>
          查看
        </button>

        <div className="modal fade" id={'group-detail' + group.code} tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div className="modal-dialog">
            <div className="modal-content">
              <div className="modal-header">
                <button type="button" className="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 className="modal-title" id="myModalLabel">
                  {group.code}
                </h4>
              </div>
              <div className="modal-body">
                <h5>訂單資訊</h5>
                <dl className="dl-horizontal">
                  <dt>書籍</dt>
                  <dd>{group.book_name} by {group.author_name} (group.book_isbn)</dd>
                  <dt>內部編號</dt>
                  <dd>{group.book_internal_code}</dd>
                  <dt>數量</dt>
                  <dd>{group.orders_count}</dd>
                </dl>
                <h5>寄件資訊</h5>
                <dl className="dl-horizontal">
                  <dt>收件時間</dt>
                  <dd>{group.pickup_datetime}</dd>
                  <dt>收件地點</dt>
                  <dd>{group.pickup_point}</dd>
                  <dt>收件人電話</dt>
                  <dd>{group.recipient_mobile}</dd>
                  <dt>收件人姓名</dt>
                  <dd>{group.recipient_name}</dd>
                </dl>
                <h5>團購資訊</h5>
                <dl className="dl-horizontal">
                  <dt>團長</dt>
                  <dd>{group.leader_name}</dd>
                  <dt>課程名稱</dt>
                  <dd>{group.course_name}</dd>
                  <dt>授課教師</dt>
                  <dd>{group.course_lecturer_name}</dd>
                </dl>
              </div>
              <div className="modal-footer">
                <button type="button" className="btn btn-default" data-dismiss="modal">關閉</button>
              </div>
            </div>
          </div>
        </div>
      </td>
      <td>
        {actions}
      </td>
    </tr>`

window.GroupRow = GroupRow
