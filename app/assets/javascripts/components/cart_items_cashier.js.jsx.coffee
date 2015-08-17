ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

CartItemsCashier = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    cartItems: []
    billTypeSelections: []

  getInitialState: ->
    cartItems: @props.cartItems
    loading: false
    step: 1

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
    if @state.billType
      return true
    else
      return false

  handleBillTypeChange: (v) ->
    @setState billType: v

  handlePackagePickupDatetimeChange: (e) ->
    @setState packagePickupDatetime: e.target.value

  nextStep: ->
    step = @state.step + 1
    @setState step: step, ->
      $(window).scrollTop(0)
      now = (new Date())
      nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000)
      nextWeek = (new Date('2015/09/07')) if nextWeek < (new Date('2015/09/07'))
      $('.datepicker').pickadate
        format: 'yyyy-mm-dd'
        selectMonths: true
        selectYears: 2
        min: nextWeek

  prevStep: ->
    step = @state.step - 1
    @setState step: step, ->
      $(window).scrollTop(0)

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
        <td><ImgPrevError src={item.book.image_url} name={item.book.name} /></td>
        <td>{item.human_item_type}</td>
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
    packageAdditionalItemsForm = ''

    if packageBookCount > 0
      totalPrice += @props.packageShippingFee if packageBookCount <= @props.packageRShippingFeeMinI
      packageAdditionalItems = @props.packageAdditionalItems.map (item, i) =>
        totalPrice += item.price if @state['packageAdditionalItems' + item.id]
        self = this
        `<div key={'p-a-item' + item.id} className="col m3 s6">
          <input name={'package[additional_items][' + item.id + ']'} type="checkbox" id={'p-a-item' + item.id} checkedLink={self.linkState('packageAdditionalItems' + item.id)} />
          <label htmlFor={'p-a-item' + item.id}><img src={item.external_image_url} />我想多用 NT$ {item.price} 來購買 {item.name} (<a href={item.url} target="_blank">簡介</a>)</label>
        </div>`
      packageDeliverForm =
        `<div className="checkout-options-field">
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
                <label className="string control-label" htmlFor="group_recipient_name">預計收件日期/時間</label>
                <input className="string form-control datepicker packagePickupDatetime"
                  type="text"
                  value={this.state.packagePickupDatetime}
                  onChange={this.handlePackagePickupDatetimeChange}
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
        </div>`

      packageAdditionalItemsForm =
        `<div className="checkout-options-field">
          <div className="checkout-options-field-inner">
            <div className="checkout-options-field-title">
              <div className="total-title">
                專送包裹－加價購
              </div>
            </div>
            <div className="checkout-options-field-body add-buy row">
              <p></p>
              {packageAdditionalItems}
            </div>
          </div>
        </div>`

    self = this
    billTypeSelections = @props.billTypeSelections.map (selection, i) =>
      `<p key={'bill-selection-' + selection[1]}>
        <input name="bill[type]" onClick={self.handleBillTypeChange.bind(null, selection[1])} type="radio" id={'payment-convience-' + selection[1]} value={selection[1]} />
        <label htmlFor={'payment-convience-' + selection[1]}>{selection[0]}</label>
      </p>`

    if @props.billTypeFeeEquations?[@state.billType]
      n = totalPrice
      totalPrice = eval(@props.billTypeFeeEquations?[@state.billType])

    totalPrice = parseInt(totalPrice)

    if @state.step == 1

      `<div>
        <div className="row row-inner">
          <div className="cart-items-field">
            <p>請確認您的購物內容，接著請按「下一步」！</p>
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
            {packageAdditionalItemsForm}
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
        </div>
        <div className="row">
          <div className="col m12 s12">
            <div className="go-checkout">
              <a className="btn-second btn--large" key="a" href="/books">上一步</a>
              &nbsp;
              <a className="btn-second btn-highlight btn--large" onClick={this.nextStep}>下一步</a>
            </div>
          </div>
        </div>
      </div>`

    else

      `<div>
        <div className="row row-inner">
          <div className="cart-items-field">
            <p>請選擇付款方式，接著請按「下一步」！</p>
            <table className="responsive-table hoverable" style={{ display: 'none' }}>
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
          <div className="col m12 s12" style={{ display: 'none' }}>
            {packageAdditionalItems}
          </div>
          <div className="col m12 s12">
            {packageDeliverForm}
          </div>
        </div>
        <div className="row">
          <div className="col m12 s12">
            <div className="go-checkout">
              <a className="btn-second btn--large" key="b" href="#" onClick={this.prevStep}>上一步</a>
              &nbsp;
              <button type="submit" className={classNames({ 'btn': true, 'btn-highlight': true, 'btn--large': true, 'disabled': !this.canSubmit() })} href="#">下一步，確認訂單</button>
            </div>
          </div>
        </div>
      </div>`

  componentDidMount: ->
    now = (new Date())
    nextWeek = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000)
    nextWeek = (new Date('2015/09/07')) if nextWeek < (new Date('2015/09/07'))
    $('.datepicker').pickadate
      format: 'yyyy-mm-dd'
      selectMonths: true
      selectYears: 2
      min: nextWeek

    setInterval =>
      @setState packagePickupDatetime: $('.packagePickupDatetime').val()
    , 500

window.CartItemsCashier = CartItemsCashier
