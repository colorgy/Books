ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

AddBookToCart = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    book: null
    bookGroups: []
    bookCourses: []
    bookCoursesWithNoGroup: []

  getInitialState: ->
    quantity: 1
    purchaseMethod: null
    courseUCode: null
    groupCode: null

  handleQuantityChange: (e) ->
    value = e.target.value
    vaild = e.target.validity.valid
    return unless vaild
    value = 1 if !!value && value < 1
    @setState quantity: value

  handleSelectionChange: (purchaseMethod, code) ->
    switch purchaseMethod
      when 'package'
        @setState
          purchaseMethod: 'package'
          groupCode: null
      when 'group'
        @setState
          purchaseMethod: 'group'
          groupCode: code

  canSubmit: ->
    if @state.processing
      false
    else if (@state.purchaseMethod == 'package')
      if @props.book.course_required
        @state.courseUCode && @state.purchaseMethod && @state.quantity && (@state.quantity > 0)
      else
        @state.purchaseMethod && @state.quantity && (@state.quantity > 0)
    else
      @state.purchaseMethod && @state.quantity && (@state.quantity > 0)

  submit: ->
    return unless @canSubmit()
    @setState processing: true
    itemType = @state.purchaseMethod
    quantity = @state.quantity
    courseUCode = @state.courseUCode
    switch itemType
      when 'package'
        itemCode = @props.book.id
      when 'group'
        itemCode = @state.groupCode
    $.ajax
      method: 'POST'
      url: "/cart_items.json"
      dataType: 'json'
      data:
        'cart_item[item_type]': itemType
        'cart_item[item_code]': itemCode
        'cart_item[quantity]': quantity
        'cart_item[course_ucode]': courseUCode
    .done (data, textStatus, xhr) =>
      @setState processing: false
      flash.success('已加入購物書包！選完需要的書籍，按下右上角的「前往結帳」就可以下訂囉。')
      # @reset()
    .fail (data, textStatus, xhr) =>
      @setState processing: false
      flash.alert('糟糕，發生錯誤了！')
      window.location.reload() if (xhr == 'Unauthorized')

  handleCourseChange: (courseUCode) ->
    @setState courseUCode: courseUCode

  reset: ->
    @setState
      quantity: 1
      purchaseMethod: null
      courseUCode: null
      groupCode: null

  render: ->
    book = @props.book
    submitButtonClass = classNames(disabled: !@canSubmit())
    packageSelections = ['true'].map (p, i) =>
      onChange = @handleSelectionChange.bind(this, 'package', null)
      checked = (@state.purchaseMethod == 'package')
      options = ''
      note = ''
      if book.behalf
        note = ' (將由協辦單位處理交付)'
      if checked && @props.book.course_required
        bookCourses = @props.bookCourses
        handleCourseChange = @handleCourseChange
        courseUCode = @state.courseUCode
        options = `<div>
            <p>請先選擇課程再加入購物書包。</p>
            <AddToCartCourseSelect defaultCourses={bookCourses} onChange={handleCourseChange} value={courseUCode} />
            <small>找不到課嗎？<a href={'/user_course_books/new?book_isbn=' + book.isbn}>回報更多使用這本書的課程</a>。</small>
          </div>`

      `<p>
        <input id="checkbox-package-buy"
               type="radio"
               onChange={onChange}
               className="with-gap hide"
               checked={checked} />
        <label htmlFor="checkbox-package-buy" className="hide">
          直接購買 {note}
        </label>
        {options}
      </p>`

    groupSelections = @props.bookGroups.map (group, i) =>
      onChange = this.handleSelectionChange.bind(this, 'group', group.code)
      checked = (@state.purchaseMethod == 'group' && @state.groupCode == group.code)
      `<p key={group.code}>
        <input id={'checkbox-group-' + group.code}
               type="radio"
               onChange={onChange}
               className="with-gap"
               checked={checked} />
        <label htmlFor={'checkbox-group-' + group.code}>
          {group.course_lecturer_name} 老師 / {group.course_name} --- {group.leader_name} 揪的團（{group.deadline} 截止繳費)
        </label>
      </p>`

    coursesWithNoGroupSelections = @props.bookCoursesWithNoGroup.map (course, i) =>
      newGroupHref = "/groups/new?book_id=#{book.id}&course_ucode=#{course.ucode}"
      `<p key={course.ucode}>
        <input className="with-gap" disabled="disabled" id={'checkbox-' + course.ucode} type="radio" />
        <label htmlFor={'checkbox-' + course.ucode}>
          {course.lecturer_name} 老師 / {course.name} (沒有進行中的團購，<a href={newGroupHref} target="_blank">立即揪團！</a>)
        </label>
      </p>`

    if groupSelections.length || coursesWithNoGroupSelections.length
      groupTitle =
        `<div className="under-line-title">
          <span>選擇跟團</span>
        </div>`
    else
      groupTitle = ''

    `<div>
      <div className="package-field">
        <div className="under-line-title">
          <span>包裹專送</span>
        </div>
        <div className="package-select-field">
          {packageSelections}
        </div>
      </div>
      <div className="group-field">
        {groupTitle}
        <div className="groups-select-field">
          {groupSelections}
          {coursesWithNoGroupSelections}
        </div>
      </div>
      <div className="buy-field text-align-right">
        <span style={{ 'font-size': '20px' }}>數量：</span>
        <input style={{ 'width': '60px', 'font-size': '20px' }} type="number" value={this.state.quantity} onChange={this.handleQuantityChange} />
        &nbsp;&nbsp;&nbsp;
        <button
          onClick={this.submit}
          className={'btn-highlight btn--large ' + submitButtonClass}
          id="add-to-cart">
          放入購物書包
        </button>
      </div>
    </div>`

AddToCartCourseSelect = React.createClass

  getDefaultProps: ->
    value: null
    defaultCourses: []
    onChange: (payload) ->
      console.log payload

  getInitialState: ->
    courseUCode: null

  getData: (input, callback) ->
    if !input || !input.length || true
      options = @props.defaultCourses.map (course) ->
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
      options.push
        value: 'other'
        label: `<div className="complex-selection">
            其他
          </div>`
      callback null, options: options
    # else
    #   $.ajax
    #     method: 'GET'
    #     url: "/courses.json"
    #     dataType: 'json'
    #     data:
    #       q: input
    #   .done (data, textStatus, xhr) =>
    #     options = data.map (course) ->
    #       value: course.ucode
    #       label: `<div className="complex-selection">
    #           <div className="complex-selection-info">
    #             <span className="complex-selection-label">
    #               授課教師
    #             </span>
    #             <span className="complex-selection-name">
    #               {course.lecturer_name}
    #             </span>
    #           </div>
    #           <div className="complex-selection-info">
    #             <span className="complex-selection-label">
    #               課程名稱
    #             </span>
    #             <span className="complex-selection-name">
    #               {course.name}
    #             </span>
    #           </div>
    #         </div>`
    #     callback null, options: options
    #   .fail (data, textStatus, xhr) =>
    #     callback 'error', options: []

  filterOption: ->
    true

  componentDidMount: ->
    @refs.select.autoloadAsyncOptions()
    setTimeout( =>
      @refs.select.autoloadAsyncOptions()
    , 50)

  handleSelectChange: (d) ->
    @setState select: d
    if d != 'other'
      @props.onChange(d)

  handleCLNChange: (e) ->
    @setState cln: e.target.value, =>
      @props.onChange("#{@state.cln} #{@state.cn}")

  handleCNChange: (e) ->
    @setState cn: e.target.value, =>
      @props.onChange("#{@state.cln} #{@state.cn}")

  render: ->
    value = @props.value?.toString()
    otherCourseInput = ''
    window.s = @refs.select
    if (@state.select == 'other')
      otherCourseInput = `<div className="row" style={{ marginTop: 12 }}>
          <div className="col m12">
            <p>請直接填寫課程資訊：</p>
          </div>
          <div className="col m6">
            <input placeholder="老師姓名" className="form-control" onChange={this.handleCLNChange} />
          </div>
          <div className="col m6">
            <input placeholder="課程名稱" className="form-control" onChange={this.handleCNChange} />
          </div>
        </div>`

    `<div>
      <Select ref="select" className="with-complex-selection" ref="select"
        asyncOptions={this.getData}
        value={value}
        placeholder="您是為哪門課買書呢？"
        filterOption={this.filterOption}
        onChange={this.handleSelectChange}
      />
      {otherCourseInput}
    </div>`


window.AddBookToCart = AddBookToCart
