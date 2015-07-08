LecturerBooks = React.createClass

  getInitialState: ->
    step: 1
    orgSelections: []
    orgCode: null
    lecturerName: null
    courses: []
    loading: false
    currentCourseUcode: ''
    bookSelectActive: false

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
      bookSelectActive: false

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
      bookSelectActive: false
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
      bookSelectActive: false

  getBookSelections: (input, callback) ->
    $.ajax
      method: 'GET'
      url: '/lecturer-books/book_data_selections'
      dataType: 'json'
      data:
        q: input
    .done (data, textStatus, xhr) =>
      callback(data)
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
        'course[course_book_attributes][0][book_isbn]': ' '
    $.ajax
      method: 'PUT'
      url: "/lecturer-books/courses/#{currentCourse.ucode}"
      dataType: 'json'
      data: postData
    .done (data, textStatus, xhr) =>
      newCourses = @state.courses
      newCourses[currentCourse.ucode] = data
      newCourses[currentCourse.ucode].completed = true
      @setState
        courses: newCourses
        bookSavingState: 'success'
    .fail (data, textStatus, xhr) =>
      @setState bookSavingState: 'faild'

  handleDone: ->
    @setState step: 4

  handleBack: (step = 1) ->
    @setState step: step

  nextCourseUcode: ->
    currentCourse = @state.courses[@state.currentCourseUcode]
    i = Object.keys(@state.courses).indexOf?(@state.currentCourseUcode)
    Object.keys(@state.courses)[i + 1]

  handleBookReject: ->
    @handleBookSelect(null)
    @setState bookSelectActive: true

  handleBookInherit: ->
    currentCourse = @state.courses[@state.currentCourseUcode]
    @handleBookSelect(currentCourse.possible_course_book[0].book_isbn)
    @handleNextCourse()

  handleBookConfirm: ->
    currentCourse = @state.courses[@state.currentCourseUcode]
    @handleBookSelect(currentCourse.course_book[0].book_isbn)
    @handleNextCourse()

  handleNextCourse: ->
    if @nextCourseUcode()
      @handleCourseClick(@nextCourseUcode())
    else
      @handleDone()

  render: ->
    console.log @state.bookSelectActive, @state.step
    if @state.step == 2 && @state.orgCode
      `<div>
        <div className="pull-left">
          <a onClick={this.handleBack.bind(this, 1)} className="h1" style={{ opacity: '.5', color: 'white' }}>上一步</a>
        </div>
        <div className="pull-right">
          <a className="h1" style={{ opacity: '.5', color: 'white' }}>　　　</a>
        </div>
        <h1>{this.state.orgCode}</h1>
        <h2>步驟二：輸入老師姓名</h2>

        <Select
          key="select-2"
          options={[]}
          asyncOptions={this.getLecturerSelections}
          onChange={this.handleLecturerSelect}
          placeholder="輸入老師姓名..."
          noResultsText="查無此師"
          searchPromptText="打個字來尋找老師..."
        />
      </div>`

    else if @state.step == 3 && @state.orgCode && @state.lecturerName
      coursesNavItems = []
      for key, course of @state.courses
        image = ''
        if course.course_book?[0]?.book_data?.image_url
          url = course.course_book?[0]?.book_data?.image_url
          image = `<div className="steps-step-icon"><img src={url} /></div>`
        coursesNavItems.push `<a onClick={this.handleCourseClick.bind(this, course.ucode)} key={course.ucode} className={classNames({ 'steps-step': true, active: (course.ucode == this.state.currentCourseUcode), completed: course.completed })}>
          {image}
          <div className="steps-step-title">{course.name}</div>
          <div className="steps-step-description">{course.name}</div>
          {(course.ucode == this.state.currentCourseUcode)}
        </a>`

      currentCourse = @state.courses[@state.currentCourseUcode]
      actions = ''
      nextCourseUcode = @nextCourseUcode()
      if nextCourseUcode
        actions = `<a className="btn btn--primary btn--raised" onClick={this.handleNextCourse}>下一本</a>`
      else
        actions = `<a className="btn btn--primary btn--raised" onClick={this.handleDone}>完成！</a>`

      initialCourseBookIsbn = currentCourse?.course_book?[0]?.book_isbn

      savingState = `<i></i>`
      if @state.bookSavingState == 'saving'
        savingState = `<i className="glyphicon glyphicon-refresh spin" style={{ padding: '12px' }}></i>`
      else if @state.bookSavingState == 'success'
        savingState = `<i className="glyphicon glyphicon-ok" style={{ padding: '12px' }}></i>`

      selectArea = ''

      if !@state.bookSelectActive
        # show book confirm dialog if ...
        if !currentCourse?.course_book?.length && currentCourse?.possible_course_book?[0]?.book_data
          bookData = currentCourse.possible_course_book[0].book_data
          selectArea = `<div>
            <p>這學期用的書還是這本嗎？</p>
            <div className="thumbnail" style={{ 'maxWidth': '180px', 'margin': 'auto' }}>
              <img src={bookData.image_url} />
            </div>
            <p>{bookData.name}，作者：{bookData.author}，出版社：{bookData.publisher}</p>
            <p>ISBN：{bookData.isbn}</p>
          </div>`
          actions = `<div>
            <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookInherit}>是</a>
            &nbsp;
            <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookReject}>不是</a>
          </div>`
        else if currentCourse?.course_book?.length && currentCourse.course_book[0].book_data
          bookData = currentCourse.course_book[0].book_data
          selectArea = `<div>
            <p>這門課用的書是這本嗎？</p>
            <div className="thumbnail" style={{ 'max-width': '180px', 'margin': 'auto' }}>
              <img src={bookData.image_url} />
            </div>
            <p>{bookData.name}，作者：{bookData.author}，出版社：{bookData.publisher}</p>
            <p>ISBN：{bookData.isbn}</p>
          </div>`
          actions = `<div>
            <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookConfirm}>是</a>
            &nbsp;
            <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookReject}>不是</a>
          </div>`
        else if currentCourse
          @state.bookSelectActive = true

      # show book selection dialog if ...
      if @state.bookSelectActive
        bookInfo = ''
        if currentCourse?.course_book?[0]?.book_data
          bookData = currentCourse.course_book[0].book_data
          console.log bookData, bookData.image_url
          bookInfo = `<div>
            <p>您選擇了：{bookData.name} ({bookData.isbn})，作者：{bookData.author}，出版社：{bookData.publisher}</p>
          </div>`
        selectArea = `<div>
          <p>請選擇用書～</p>
          <div>
            <SearchSelect
              key="select-3"
              ref="bookSelect"
              value={initialCourseBookIsbn}
              asyncSelections={this.getBookSelections}
              onChange={this.handleBookSelect}
              placeholder="輸入書名、ISBN、作者名來找書..."
              noResultsText="查無此書"
              searchInputClassName="form-control"
            />
          </div>
          {bookInfo}
          {savingState}
          <p>&nbsp;</p>
        </div>`

      `<div>
        <div className="pull-left">
          <a onClick={this.handleBack.bind(this, 2)} className="h1" style={{ opacity: '.5', color: 'white' }}>上一步</a>
        </div>
        <div className="pull-right">
          <a className="h1" style={{ opacity: '.5', color: 'white' }}>　　　</a>
        </div>
        <h1>{this.state.orgCode} {this.state.lecturerName} 老師</h1>
        <h2>這學期總共有 {coursesNavItems.length} 門課</h2>
        <div className="row">
          <div className="col-md-3 hidden-sm hidden-xs">
            <div className="steps steps--vertical steps--sm-arrow width-100">
              {coursesNavItems}
            </div>
          </div>
          <div className="col-md-9">
            <div key={this.state.currentCourseUcode} className="card bg-white">
              <h2>{currentCourse && currentCourse.name}</h2>
              <h3>{currentCourse && currentCourse.code}</h3>
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
        <h1>Colorgy Books 課程用書整理平台</h1>
        <p>歡迎使用！本平台是同學們為了提早確認上課需要用的書籍而架設，您可以點幾下滑鼠打個字來和我們確認上課用書，將資訊事先給同學們提前準備。先從選擇學校開始吧！</p>
        <h2>第一步驟：請選擇學校 <small>共三步驟</small></h2>
        <p>&nbsp;</p>
        <Select
          key="select-1"
          options={this.state.orgSelections}
          onChange={this.handleOrgSelect}
          placeholder="輸入學校名稱或簡稱..."
          noResultsText="查無此校"
        />
      </div>`

window.LecturerBooks = LecturerBooks
