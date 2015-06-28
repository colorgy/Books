LecturerBooks = React.createClass

  getInitialState: ->
    step: 1
    orgSelections: []
    orgCode: null
    lecturerName: null
    courses: []
    loading: false
    currentCourseUcode: ''

  componentDidMount: ->
    @getOrgSelections()

  getOrgSelections: () ->
    @setState loading: true
    $.ajax
      method: 'GET'
      url: '/lecturer-books/organization_selections'
      dataType: 'json'
    .done (data, textStatus, xhr) =>
      @setState
        orgSelections: data
        loading: false
    .fail (data, textStatus, xhr) =>
      @setState loading: false

  handleOrgSelect: (value) ->
    @setState
      orgCode: value
      step: 2

  getLecturerSelections: (input, callback) ->
    $.ajax
      method: 'GET'
      url: '/lecturer-books/lecturer_selections'
      dataType: 'json'
      data:
        q: input
        org: @state.orgCode
    .done (data, textStatus, xhr) =>
      callback(null, { options: data })
    .fail (data, textStatus, xhr) =>

  handleLecturerSelect: (value) ->
    @setState
      lecturerName: value
      step: 3
    , =>
      @getCourses()

  getCourses: () ->
    @setState loading: true
    $.ajax
      method: 'GET'
      url: '/lecturer-books/courses'
      dataType: 'json'
      data:
        org: @state.orgCode
        lecturer: @state.lecturerName
    .done (data, textStatus, xhr) =>
      @setState
        courses: data
        loading: false
        currentCourseUcode: Object.keys(data)[0]
    .fail (data, textStatus, xhr) =>
      @setState loading: false

  handleCourseClick: (ucode) ->
    @setState
      currentCourseUcode: ucode
      currentCourseBookIsbn: null
      bookSavingState: null

  getBookSelections: (input, callback) ->
    $.ajax
      method: 'GET'
      url: '/lecturer-books/book_data_selections'
      dataType: 'json'
      data:
        q: input
    .done (data, textStatus, xhr) =>
      callback(null, { options: data })
    .fail (data, textStatus, xhr) =>

  handleBookSelect: (isbn) ->
    currentCourse = @state.courses[@state.currentCourseUcode]
    currentOrgCode = @state.orgCode
    currentLecturerName = @state.lecturerName
    @setState
      bookSavingState: 'saving'
    if isbn
      postData =
        org: currentOrgCode
        lecturer: currentLecturerName
        'course[course_book_attributes][0][id]': currentCourse.course_book?[0]?.id
        'course[course_book_attributes][0][book_isbn]': isbn
    else
      postData =
        org: currentOrgCode
        lecturer: currentLecturerName
        'course[course_book_attributes][0][id]': currentCourse.course_book?[0]?.id
        'course[course_book_attributes][0][book_known]': false
    $.ajax
      method: 'PUT'
      url: "/lecturer-books/courses/#{currentCourse.ucode}"
      dataType: 'json'
      data: postData
    .done (data, textStatus, xhr) =>
      newCourses = @state.courses
      newCourses[currentCourse.ucode] = data
      @setState
        courses: newCourses
        bookSavingState: 'success'
      @refs.bookSelect?.autoloadAsyncOptions?()
    .fail (data, textStatus, xhr) =>
      @setState bookSavingState: 'faild'

  handleDone: ->
    @setState step: 4

  handleBack: ->
    @setState step: 1

  render: ->
    if @state.step == 2 && @state.orgCode
      `<div>
        <h1>{this.state.orgCode}</h1>
        <h2>步驟二：輸入老師姓名</h2>

        <Select
          options={[]}
          asyncOptions={this.getLecturerSelections}
          onChange={this.handleLecturerSelect}
          placeholder="輸入老師姓名..."
          noResultsText="查無此師"
        />
      </div>`

    else if @state.step == 3 && @state.orgCode && @state.lecturerName
      coursesNavItems = []
      for key, course of @state.courses
        coursesNavItems.push `<a onClick={this.handleCourseClick.bind(this, course.ucode)} key={course.ucode} className={classNames({ 'steps-step': true, active: (course.ucode == this.state.currentCourseUcode) })}>
          <div className="title">{course.name}</div>
          <div className="description">{course.name}</div>
          {(course.ucode == this.state.currentCourseUcode)}
        </a>`

      currentCourse = @state.courses[@state.currentCourseUcode]
      i = Object.keys(@state.courses).indexOf?(@state.currentCourseUcode)
      window.aa = @state.courses
      console.log i
      nextCourseUcode = Object.keys(@state.courses)[i + 1]
      console.log nextCourseUcode

      actions = ''
      if nextCourseUcode
        actions = `<a className="btn btn--primary btn--raised" onClick={this.handleCourseClick.bind(this, nextCourseUcode)}>下一本</a>`
      else
        actions = `<a className="btn btn--primary btn--raised" onClick={this.handleDone}>完成！</a>`

      initialCourseBookIsbn = currentCourse?.course_book?[0]?.book_isbn

      savingState = `<i></i>`
      if @state.bookSavingState == 'saving'
        savingState = `<i className="glyphicon glyphicon-refresh spin pull-right" style={{ padding: '12px' }}></i>`
      else if @state.bookSavingState == 'success'
        savingState = `<i className="glyphicon glyphicon-ok pull-right" style={{ padding: '12px' }}></i>`

      selectArea = ''
      # show book confirm dialog if ...
      if currentCourse?.possible_course_book?.length && !currentCourse?.course_book?.length
        selectArea = `<p>這學期用的書還是這本嗎？</p>`
        actions = `<div>
          <a className="btn btn--primary btn--raised btn--success" onClick={function() { this.handleBookSelect(currentCourse.possible_course_book[0].book_isbn); this.handleCourseClick(nextCourseUcode) }.bind(this)}>是</a>
          &nbsp;
          <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookSelect.bind(this, null)}>不是</a>
        </div>`
      # show book selection dialog if ...
      else
        selectArea = `<div>
          <p>請選擇用書～</p>
          <p>
            {savingState}
            <Select
              ref="bookSelect"
              value={initialCourseBookIsbn}
              options={[]}
              asyncOptions={this.getBookSelections}
              onChange={this.handleBookSelect}
              placeholder="輸入書名、ISBN、作者名來找書..."
              noResultsText="查無此書"
            />
          </p>
          <p>&nbsp;</p>
        </div>`

      `<div>
        <h1>{this.state.orgCode} {this.state.lecturerName} 老師</h1>
        <h2>這學期總共有 {coursesNavItems.length} 門課</h2>
        <div className="row">
          <div className="col-md-3">
            <div className="steps steps--vertical steps--sm-arrow">
              {coursesNavItems}
            </div>
          </div>
          <div className="col-md-9">
            <div key={this.state.currentCourseUcode} className="card bg-white">
              <h2>{currentCourse && currentCourse.name}</h2>
              {selectArea}
              {actions}
            </div>
          </div>
        </div>
      </div>`

    else if @state.step == 4
      `<div>
        <h1>已完成</h1>
        <p>感謝您的參與！</p>
        <a className="btn btn--outline btn--inverse inverse" onClick={this.handleBack}>回去</a>
      </div>`

    else
      `<div>
        <h1>歡迎使用 Colorgy Books 課程用書整理平台！</h1>
        <p>&nbsp;</p>
        <h2>第一步驟：請選擇學校 <small>共三步驟</small></h2>
        <p>&nbsp;</p>
        <Select
          options={this.state.orgSelections}
          onChange={this.handleOrgSelect}
          placeholder="輸入學校名稱或簡稱..."
          noResultsText="查無此校"
        />
      </div>`

window.LecturerBooks = LecturerBooks
