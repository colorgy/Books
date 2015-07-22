ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

CartItemsCashier = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    cartItems: []
    billTypeSelections: []

  getInitialState: ->
    cartItems: @props.cartItems
    loading: false

  componentDidMount: ->
    window.cartItemsCashier = @

  deleteItem: (id) ->
    $.ajax
      method: 'DELETE'
      url: "/cart_items/#{id}"
      dataType: 'json'
    .done (data, textStatus, xhr) =>
      flash.success '項目已刪除！'
      @setState
        cartItems: data
        loading: false
    .fail (data, textStatus, xhr) =>
      @setState
        loading: false

  packageBookCount: 0

  canSubmit: ->
    if @packageBookCount > 0
      return false unless @state.packageRecipientName &&
                          @state.packagePickupAddress &&
                          @state.packagePickupDatetime &&
                          @state.packageRecipientMobile
    return true

  render: ->
    bookCount = 0
    packageBookCount = 0
    totalPrice = 0

    if !@state.cartItems || !@state.cartItems.length
      return `<div>
        沒東西
      </div>`

    cartItems = @state.cartItems.map (item, i) =>
      courseInfo = ''
      if item.course
        courseInfo = "#{item.course.lecturer_name} / #{item.course.name}"
      price = item.item_price * item.quantity
      bookCount += item.quantity
      packageBookCount += item.quantity if item.item_type == 'package'
      totalPrice += price

      deleteItem = @deleteItem

      `<tr key={item.id}>
        <td><img src={item.book.image_url} /></td>
        <td>{item.item_type}</td>
        <td>{item.book.name}</td>
        <td>{item.book.author}</td>
        <td>10</td>
        <td>{courseInfo}</td>
        <td>NT$ {item.item_price}</td>
        <td>{item.quantity}</td>
        <td>NT$ {price}</td>
        <td><a onClick={deleteItem.bind(null, item.id)}>刪除</a></td>
      </tr>`

    @packageBookCount = packageBookCount

    packageDeliverForm = ''

    if packageBookCount > 0
      packageDeliverForm = `<div>
        <div className="col m12 s12">
          <div className="checkout-options-field">
            <div className="checkout-options-field-inner">
              <div className="checkout-options-field-title">
                <div className="total-title">
                  專送包裹－收件資訊
                </div>
              </div>
              <div className="checkout-options-field-body text-center">
                <div className="form-group">
                  <label className="string control-label" htmlFor="group_recipient_name">收件人姓名</label>
                  <input className="string form-control"
                    type="text"
                    valueLink={this.linkState('packageRecipientName')}
                    name="package[recipient_name]" />
                </div>
                <div className="form-group">
                  <label className="string control-label" htmlFor="group_recipient_name">收件地址</label>
                  <input className="string form-control"
                    type="text"
                    valueLink={this.linkState('packagePickupAddress')}
                    name="package[pickup_address]" />
                </div>
                <div className="form-group">
                  <label className="string control-label" htmlFor="group_recipient_name">收件日期</label>
                  <input className="string form-control"
                    type="text"
                    valueLink={this.linkState('packagePickupDatetime')}
                    name="package[pickup_datetime]" />
                </div>
                <div className="form-group">
                  <label className="string control-label" htmlFor="group_recipient_name">收件人手機</label>
                  <input className="string form-control"
                    type="text"
                    valueLink={this.linkState('packageRecipientMobile')}
                    name="package[recipient_mobile]" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>`

    billTypeSelections = @props.billTypeSelections.map (selection, i) =>
      `<p key={'bill-selection-' + selection[1]}>
        <input name="bill[type]" type="radio" id={'payment-convience-' + selection[1]} defaultChecked={i == 0} value={selection[1]} />
        <label htmlFor={'payment-convience-' + selection[1]}>{selection[0]}</label>
      </p>`

    `<div>
      <div className="row row-inner">
        <div className="cart-items-field">
          <p>＃請確認您的購物內容，還有底下的付款方式及發票種類，接著請按 "下一步" ！</p>
          <table className="responsive-table hoverable">
            <thead>
              <tr>
                <th></th>
                <th></th>
                <th>書名</th>
                <th>作者</th>
                <th>版次</th>
                <th>老師 / 課名</th>
                <th>價格</th>
                <th>數量</th>
                <th>小計</th>
                <th>取消</th>
              </tr>
            </thead>
            <tbody>
              {cartItems}
            </tbody>
          </table>
        </div>
      </div>
      <div className="row row-inner">
        <div className="col m8 s12">
          <div className="checkout-options-field">
            <div className="checkout-options-field-inner">
              <div className="checkout-options-field-title">
                <div className="payment-title">
                  付款方式
                </div>
                <div className="reciept-title">
                  發票種類
                </div>
                <div className="clearfix"></div>
              </div>
              <div className="checkout-options-field-body">
                <div className="payment-options">
                  {billTypeSelections}
                </div>
                <div className="reciept-options">
                    <p>
                      <input name="bill[invoice_type]" value="digital" type="radio" id="reciept-e-reciept" defaultChecked="checked" />
                      <label htmlFor="reciept-e-reciept">電子發票</label>
                    </p>
                    <a className="slide-field-trigger" href="#reciept-more">更多..</a>
                    <div className="slide-field" id="reciept-more">
                      <p>
                        <input name="bill[invoice_type]" value="code" type="radio" id="reciept-mobile-phone" />
                        <label htmlFor="reciept-mobile-phone">手機條碼</label>
                      </p>
                      <p>
                        <input name="bill[invoice_type]" value="cert" type="radio" id="reciept-nature-human" />
                        <label htmlFor="reciept-nature-human">自然憑證</label>
                      </p>
                      <p>
                        <input name="bill[invoice_type]" value="uni_num" type="radio" id="reciept-vat" />
                        <label htmlFor="reciept-vat">統一編號</label>
                      </p>
                      <p>
                        <input name="bill[invoice_type]" value="love_code" type="radio" id="reciept-love" />
                        <label htmlFor="reciept-love">愛心號碼</label>
                      </p>
                      <p>
                        <input name="bill[invoice_type]" value="paper" type="radio" id="reciept-paper" />
                        <label htmlFor="reciept-paper">紙本發票</label>
                      </p>
                    </div>
                </div>
                <div className="clearfix"></div>
              </div>
            </div>
          </div>
        </div>
        <div className="col m4 s12">
          <div className="checkout-options-field">
            <div className="checkout-options-field-inner">
              <div className="checkout-options-field-title">
                <div className="total-title">
                  總結
                </div>
              </div>
              <div className="checkout-options-field-body text-center">
                <p>共買了 {bookCount} 本書</p>
                <p>總共 NT {totalPrice}</p>
              </div>
            </div>
          </div>
        </div>
        {packageDeliverForm}
      </div>
      <div className="row">
        <div className="col m12 s12">
          <div className="go-checkout">
            <a className="btn-second btn--large" href="/books">繼續逛</a>
            &nbsp;
            <button type="submit" className={classNames({ 'btn': true, 'btn-highlight': true, 'btn--large': true, 'disabled': !this.canSubmit() })} href="#">下一步</button>
          </div>
        </div>
      </div>
    </div>`

window.CartItemsCashier = CartItemsCashier
