BookRow = React.createClass
  getDefaultProps: ->
    book: {}
    onPriceSave: (payload) ->
      console.log(payload)

  getInitialState: ->
    price: @props.book.price
    internalCode: @props.book.internal_code

  handleInternalCodeChange: (e) ->
    @setState internalCode: e.target.value

  handlePriceChange: (e) ->
    @setState price: e.target.value

  savePrice: ->
    payload =
      id: @props.book.id
      price: @state.price
    @props.onPriceSave(payload)
    console.log @props.aaa
    console.log @props.onPriceSave
    flash.notice("正在儲存 #{@props.book.name} (#{@props.book.isbn}) 的新售價 NT$ #{@state.price} ...")

  resetPrice: ->
    @setState price: @props.book.price
    flash.notice("對 #{@props.book.name} (#{@props.book.isbn}) 的更改已取消")

  priceDirty: ->
    parseInt(@props.book.price) != parseInt(@state.price)

  internalCodeDirty: ->
    @props.book.internal_code != @state.internalCode

  render: ->
    book = @props.book
    price = @state.price
    internalCode = @state.internal_code
    priceDirty = @priceDirty()

    savePrice = null
    if @priceDirty()
      savePrice =
        `<span><button type="button" className="btn btn-default"  onClick={this.savePrice}><span className="glyphicon glyphicon-floppy-disk"></span></button>
        <button type="button" className="btn btn-default" onClick={this.resetPrice}><span className="glyphicon glyphicon-remove"></span></button></span>`

    `<tr>
      <th scope="row">{book.id}</th>
      <td>{book.name}</td>
      <td>{book.isbn}</td>
      <td><input
        className={classNames({
          'inplace-edit': true,
          'changed': false
        })}
        value={internalCode}
        onChange={this.handleInternalCodeChange} />
      </td>
      <td>NT$ <input
        className={classNames({
          'inplace-edit': true,
          'changed': priceDirty
        })}
        type="number"
        value={price}
        onChange={this.handlePriceChange} />
      {savePrice}</td>
    </tr>`

window.BookRow = BookRow
