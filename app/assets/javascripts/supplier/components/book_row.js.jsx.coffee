BookRow = React.createClass
  getDefaultProps: ->
    book: {}
    onPriceSave: (payload) ->
      console.log(payload)
    onInternalCodeSave: (payload) ->
      console.log(payload)
    onDelete: (payload) ->
      console.log(payload)

  getInitialState: ->
    price: @props.book.price
    internalCode: @props.book.internal_code

  handleInternalCodeChange: (e) ->
    @setState internalCode: e.target.value

  handleInternalCodeKeyDown: (e) ->
    if e.key == 'Enter'
      @saveInternalCode()
      @refs.internalCodeInput.getDOMNode().blur()

  handlePriceChange: (e) ->
    @setState price: e.target.value

  handlePriceKeyDown: (e) ->
    if e.key == 'Enter'
      @savePrice()
      @refs.priceInput.getDOMNode().blur()

  saveInternalCode: ->
    payload =
      id: @props.book.id
      data:
        internal_code: @state.internalCode
    @props.onInternalCodeSave(payload)
    flash.notice("正在儲存 #{@props.book.name} (#{@props.book.isbn}) 的新內部編號 #{@state.internalCode} ...")

  resetInternalCode: ->
    @props.book.internal_code = '' if !@props.book.internal_code
    @setState internalCode: @props.book.internal_code
    flash.notice("對 #{@props.book.name} (#{@props.book.isbn}) 的更改已取消")

  savePrice: ->
    payload =
      id: @props.book.id
      data:
        price: @state.price
    @props.onPriceSave(payload)
    flash.notice("正在儲存 #{@props.book.name} (#{@props.book.isbn}) 的新售價 NT$ #{@state.price} ...")

  resetPrice: ->
    @setState price: @props.book.price
    flash.notice("對 #{@props.book.name} (#{@props.book.isbn}) 的更改已取消")

  priceDirty: ->
    parseInt(@props.book.price) != parseInt(@state.price)

  internalCodeDirty: ->
    @props.book.internal_code != @state.internalCode

  delete: ->
    if @state.preparedForDelete
      payload =
        id: @props.book.id
      @props.onDelete(payload)
    else
      flash.warning('確定刪除？刪除後同學即無法購買本書，進行中的團購也將無法有新人跟團，但已下訂的訂單將仍然成立！')
      @setState preparedForDelete: true
      setTimeout =>
        @setState preparedForDelete: false
      , 10000

  render: ->
    book = @props.book
    price = @state.price
    internalCode = @state.internalCode
    internalCodeDirty = @internalCodeDirty()
    priceDirty = @priceDirty()

    if @state.preparedForDelete
      deleteAction = `<span>
          確定刪除？
          <a href="#" onClick={this.delete}>刪除</a>
        </span>`
    else
      deleteAction = `<span>
          <a href="#" onClick={this.delete}>刪除</a>
        </span>`

    `<tr>
      <th scope="row">{book.id}</th>
      <td>{book.name}</td>
      <td>{book.isbn}</td>
      <td>
        <input
          ref="internalCodeInput"
          className={classNames({
            'inplace-edit': true,
            'changed': internalCodeDirty
          })}
          value={internalCode}
          onChange={this.handleInternalCodeChange}
          onKeyDown={this.handleInternalCodeKeyDown} />
        <span className={classNames({invisible: !internalCodeDirty})}>
          <button type="button" className="btn btn-default" onClick={this.saveInternalCode}>
            <span className="glyphicon glyphicon-floppy-disk"></span>
          </button>
          <button type="button" className="btn btn-default" onClick={this.resetInternalCode}>
            <span className="glyphicon glyphicon-remove"></span>
          </button>
        </span>
      </td>
      <td>NT$ <input
        ref="priceInput"
        className={classNames({
          'inplace-edit': true,
          'changed': priceDirty
        })}
        type="number"
        value={price}
        onChange={this.handlePriceChange}
        onKeyDown={this.handlePriceKeyDown} />
        <span className={classNames({invisible: !priceDirty})}>
          <button type="button" className="btn btn-default" onClick={this.savePrice}>
            <span className="glyphicon glyphicon-floppy-disk"></span>
          </button>
          <button type="button" className="btn btn-default" onClick={this.resetPrice}>
            <span className="glyphicon glyphicon-remove"></span>
          </button>
        </span>
      </td>
      <td>
        {deleteAction}
      </td>
    </tr>`

window.BookRow = BookRow
