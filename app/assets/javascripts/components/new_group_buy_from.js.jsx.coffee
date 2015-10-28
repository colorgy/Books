NewGroupBuyFrom = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    course_ucode: null
    book_isbn: null

  getInitialState: ->
    course_ucode: @props.course_ucode
    book_isbn: @props.book_isbn
    quantity: 20

  getBookData: (input, callback) ->
    $.ajax
      method: 'GET'
      url: "/book_datas.json"
      dataType: 'json'
      data:
        q: input
    .done (data, textStatus, xhr) =>
      console.log data
      options = data.map (book) ->
        value: book.isbn.toString()
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

  getCourseData: (input, callback) ->
    $.ajax
      method: 'GET'
      url: "/courses.json"
      dataType: 'json'
      data:
        q: input
        no_book: true
    .done (data, textStatus, xhr) =>
      console.log data
      options = data.map (course) ->
        value: course.ucode
        label: `<div className="complex-selection">
            <div className="complex-selection-info">
              <span className="complex-selection-label">
                授課教師
              </span>
              <span className="complex-selection-name">
                {course.lecturer_name}
              </span>
            </div>
            <div className="complex-selection-info">
              <span className="complex-selection-label">
                課程名稱
              </span>
              <span className="complex-selection-name">
                {course.name}
              </span>
            </div>
          </div>`
      callback null, options: options
    .fail (data, textStatus, xhr) =>
      callback 'error', options: []

  filterOption: ->
    true

  componentDidMount: ->
    @refs.bookSelect.autoloadAsyncOptions()
    @refs.courseSelect.autoloadAsyncOptions()

  canSubmit: ->
    @state.course_name && @state.book_isbn && @state.quantity > 10 && @state.mobile && @state.mobile.length >= 10

  handleSubmit: ->
    return true if @canSubmit()
    return false

  handleCourseUcodeChange: (val) ->
    @setState course_ucode: val

  handleBookISBNChange: (val) ->
    @setState book_isbn: val

  render: ->

    `<div>
      <div className={classNames({ 'form-group': true })}>
        <label>輸入課程名稱 (請填寫課程名稱與授課教師)</label>
        <input name="group_buy_form[course_name]" className="form-control" valueLink={this.linkState('course_name')} />
      </div>
      <div className={classNames({ 'form-group': true })}>
        <label>選擇書籍</label>
        <Select className="with-complex-selection" ref="bookSelect"
          asyncOptions={this.getBookData}
          name="group_buy_form[book_isbn]"
          value={this.state.book_isbn}
          placeholder="搜尋書籍"
          filterOption={this.filterOption}
          onChange={this.handleBookISBNChange}
        />
      </div>
      <div className={classNames({ 'form-group': true })}>
        <label>訂書數量</label>
        <input name="group_buy_form[quantity]" className="form-control" type="number" valueLink={this.linkState('quantity')} />
      </div>
      <div className={classNames({ 'form-group': true })}>
        <label>訂購人手機 (必填)</label>
        <input name="group_buy_form[mobile]" className="form-control" valueLink={this.linkState('mobile')} />
      </div>
      <p>
        找不到書嗎？請<a href="https://www.facebook.com/pages/Colorgy/1529686803975150" target="_blank">向我們回報</a>！
      </p>
      <input type="submit" name="commit" value="確定送出" onClick={this.handleSubmit} className={classNames({ 'btn': true, 'btn--large': true, 'disabled': !this.canSubmit() })} />
    </div>`

window.NewGroupBuyFrom = NewGroupBuyFrom