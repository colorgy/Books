ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

LecturerBooks = React.createClass

  getDefaultProps: ->
    code: null

  getInitialState: ->
    step: 1
    prevStep: 1
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
      prevStep: @state.step
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
      prevStep: @state.step
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
        'course[course_book_attributes][0][updater_code]': @props.code
    else
      postData =
        code: @props.code
        org: currentOrgCode
        lecturer: currentLecturerName
        'course[course_book_attributes][0][id]': currentCourse.course_book?[0]?.id
        'course[course_book_attributes][0][book_isbn]': ' '
        'course[course_book_attributes][0][updater_code]': @props.code
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
        bookSelectActive: false
      if data.course_book?[0]?.book_data?.name
        toast.success("已選取 #{data.course_book[0].book_data.name}")
    .fail (data, textStatus, xhr) =>
      @setState bookSavingState: 'faild'

  handleDone: ->
    @setState
      step: 4
      prevStep: @state.step

  handleBack: (step = 1) ->
    @setState
      step: step
      prevStep: @state.step

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

  handleMarkBookRequire: (bookRequire) ->
    if bookRequire
      $.ajax
        method: 'PUT'
        url: "/lecturer-books/courses"
        dataType: 'json'
        data:
          org: @state.orgCode
          lecturer: @state.lecturerName
          'courses[book_required]': bookRequire
    @setState
      step: 5
      prevStep: @state.step

  handleFeedbackTextChange: (e) ->
    @setState feedbackText: e.target.value

  handleComplete: ->
    @handleBack(1)
    if @state.feedbackText?.length
      feedbackText = @state.feedbackText
      $.ajax
        method: 'POST'
        url: "/feedbacks"
        dataType: 'json'
        data:
          'feedback[content]': feedbackText
          'feedback[sent_by]': ''
          'feedback[sent_at]': 'lecturer-books'
      .done (data, textStatus, xhr) =>
        toast.success '回饋已送出！'

      @setState feedbackText: null

  render: ->
    if @state.step == 2 && @state.orgCode
      if @state.prevStep < 2
        pageAnimationName = 'change-page-from-right'
      else
        pageAnimationName = 'change-page-from-left'

      `<ReactCSSTransitionGroup transitionName={pageAnimationName}>
        <div className="l-full-window" key="step-2-container">
          <div className="l-full-window-body">
            <div className="max-width-800px margin-center text-center container">
              <div className="pull-left">
                <a onClick={this.handleBack.bind(this, 1)} className="h1" style={{ opacity: '.5', color: 'white' }}>上一步</a>
              </div>
              <div className="pull-right">
                <a className="h1" style={{ opacity: '.5', color: 'white' }}>　　　</a>
              </div>
              <h1>{this.state.orgCode}</h1>
              <h2>步驟二：請老師輸入您的姓名</h2>

              <Select
                key="select-2"
                options={[]}
                asyncOptions={this.getLecturerSelections}
                onChange={this.handleLecturerSelect}
                placeholder="輸入老師姓名..."
                noResultsText="找不到資料"
                searchPromptText="打個字來尋找老師..."
              />
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>`

    else if @state.step == 3 && @state.orgCode && @state.lecturerName
      coursesNavItems = []
      for key, course of @state.courses
        image = `<div className="steps-step-icon"><ImgPrevError src="https://placeholdit.imgix.net/~text?txtsize=300&txt=?&w=400&h=500" /></div>`
        if course.course_book?[0]?.book_data?.image_url
          url = course.course_book[0].book_data.image_url
          image = `<div className="steps-step-icon"><ImgPrevError src={url} name={course.course_book[0].book_data.name} /></div>`
        bookName = `<i>用書未知</i>`
        if course.course_book?[0]?.book_data?.name
          bookName = "使用：#{course.course_book[0].book_data.name}"
        coursesNavItems.push `<a onClick={this.handleCourseClick.bind(this, course.ucode)} key={course.ucode} className={classNames({ 'steps-step': true, active: (course.ucode == this.state.currentCourseUcode), completed: course.completed })}>
          {image}
          <div className="steps-step-title">{course.name}</div>
          <div className="steps-step-description">{bookName}</div>
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
        # show locked dialog if ...
        if currentCourse?.book_locked
          bookData = currentCourse?.course_book[0]?.book_data || {}
          selectArea = `<div>
            <p>本課的用書已確認並鎖定，如有問題歡迎與我們聯繫。</p>
            <div className="thumbnail" style={{ 'max-width': '180px', 'margin': 'auto' }}>
              <ImgPrevError src={bookData.image_url} name={bookData.name} />
            </div>
            <p className="h4"><span className="nowrap">{bookData.name}<small>，</small></span><span className="nowrap"><small>作者：</small>{bookData.author}<small>，</small></span><span className="nowrap"><small>出版社：</small>{bookData.publisher}</span></p>
            <p className="h4"><small>ISBN：</small>{bookData.isbn}</p>
            <p>&nbsp;</p>
          </div>`
          actions = `<div>
            <a className="btn btn--primary btn--raised btn--success" onClick={this.handleNextCourse}>好</a>
          </div>`
        # show book confirm dialog if ...
        else if !currentCourse?.course_book?.length && currentCourse?.possible_course_book?[0]?.book_data
          bookData = currentCourse.possible_course_book[0].book_data
          selectArea = `<div>
            <p>本系統已紀錄您上學期所使用的教科書，若這學期您也將沿用同一本書，請點選「是」。若老師這學期選用的教科書和上學期不同，請點選「不是」。</p>
            <div className="thumbnail" style={{ 'maxWidth': '180px', 'margin': 'auto' }}>
              <ImgPrevError src={bookData.image_url} name={bookData.name} />
            </div>
            <p className="h4"><span className="nowrap">{bookData.name}<small>，</small></span><span className="nowrap"><small>作者：</small>{bookData.author}<small>，</small></span><span className="nowrap"><small>出版社：</small>{bookData.publisher}</span></p>
            <p className="h4"><small>ISBN：</small>{bookData.isbn}</p>
            <p>&nbsp;</p>
          </div>`
          if nextCourseUcode
            actions = `<div>
              <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookInherit}>是</a>
              &nbsp;
              <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookReject}>不是</a>
            </div>`
          else
            actions = `<div>
              <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookInherit}>是，完成！</a>
              &nbsp;
              <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookReject}>不是</a>
            </div>`
        # show book confirm dialog if ...
        else if currentCourse?.course_book?.length && currentCourse.course_book[0].book_data
          bookData = currentCourse.course_book[0].book_data
          selectArea = `<div>
            <p>本系統已紀錄您這學期將使用的教科書，若確定資料正確，請點選「是」，若不正確請點選「不是」。</p>
            <div className="thumbnail" style={{ 'max-width': '180px', 'margin': 'auto' }}>
              <ImgPrevError src={bookData.image_url} name={bookData.name} />
            </div>
            <p className="h4"><span className="nowrap">{bookData.name}<small>，</small></span><span className="nowrap"><small>作者：</small>{bookData.author}<small>，</small></span><span className="nowrap"><small>出版社：</small>{bookData.publisher}</span></p>
            <p className="h4"><small>ISBN：</small>{bookData.isbn}</p>
            <p>&nbsp;</p>
          </div>`
          if nextCourseUcode
            actions = `<div>
              <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookConfirm}>是</a>
              &nbsp;
              <a className="btn btn--primary btn--raised btn--danger" onClick={this.handleBookReject}>不是</a>
            </div>`
          else
            actions = `<div>
              <a className="btn btn--primary btn--raised btn--success" onClick={this.handleBookConfirm}>是，完成！</a>
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
              noResultsText="在輸入框中輸入這學期將採用的教科書書名、ISBN 或者是作者名，即可查詢並選擇用書。"
              searchInputClassName="form-control"
            />
          </div>
          {bookInfo}
          {savingState}
          <p>&nbsp;</p>
        </div>`

      `<ReactCSSTransitionGroup transitionName="change-page-from-right">
        <div className="l-full-window" key="step-3-container">
          <div className="l-full-window-body">
            <div className="margin-center text-center container">
              <div className="pull-left">
                <a onClick={this.handleBack.bind(this, 2)} className="h1" style={{ opacity: '.5', color: 'white' }}>上一步</a>
              </div>
              <div className="pull-right">
                <a className="h1" style={{ opacity: '.5', color: 'white' }}>　　　</a>
              </div>
              <h1><span className="nowrap">{this.state.orgCode}</span> <span className="nowrap">{this.state.lecturerName}</span> 老師</h1>
              <h2><small>這學期總共有 {coursesNavItems.length} 門課</small></h2>
              <p>請老師就本學期開授的每堂課逐一登錄教科書資訊。</p>
              <div className="row">
                <div className="col-md-3 hidden-sm hidden-xs">
                  <div className="steps steps--vertical steps--sm-arrow width-100 text-left">
                    {coursesNavItems}
                  </div>
                </div>
                <div className="col-md-9">
                  <div key={this.state.currentCourseUcode} className="card bg-white">
                    <h2>{currentCourse && currentCourse.name}</h2>
                    <h3><small>{currentCourse && currentCourse.code}</small></h3>
                    {selectArea}
                    {actions}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>`

    else if @state.step == 4
      `<ReactCSSTransitionGroup transitionName="change-page-from-bottom">
        <div className="l-full-window" key="step-4-container">
          <div className="l-full-window-body">
            <div className="margin-center text-center max-width-800px container">
              <p className="h2">感謝老師提供的資訊，我們收到了！</p>
              <h1><small>對了，</small>老師是否希望同學能夠在上課前即備齊教科書呢？</h1>
              <p>老師是否希望同學能夠在上課前即備齊教科書？我們可以特別標註給同學們知道，好增進老師在學期初的上課效率。</p>
              <a className="btn btn--outline btn--inverse inverse" onClick={this.handleMarkBookRequire.bind(this, true)}>好，盡量在上課前備齊教科書</a>
              &nbsp;
              <a className="btn btn--outline btn--inverse inverse" onClick={this.handleMarkBookRequire.bind(this, false)}>沒關係</a>
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>`

    else if @state.step == 5
      backText = '回到開始頁'
      if @state.feedbackText?.length
        backText = '送出回饋，並回到開始頁'
      `<ReactCSSTransitionGroup transitionName="change-page-from-bottom">
        <div className="l-full-window" key="step-5-container">
          <div className="l-full-window-body">
            <div className="margin-center text-center max-width-800px container">
              <h1>已完成</h1>
              <p>再次感謝老師的協助與參與！</p>
              <textarea value={this.state.feedbackText} onChange={this.handleFeedbackTextChange} className="form-control" placeholder="若老師有任何建議， 歡迎在此留下您的意見，您的寶貴建議和鼓勵是我們成長的動力！" />
              <p>&nbsp;</p>
              <a className="btn btn--outline btn--inverse inverse" onClick={this.handleComplete}>{backText}</a>
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>`

    else
      if @state.prevStep > 3
        pageAnimationName = 'change-page-from-bottom'
      else
        pageAnimationName = 'change-page-from-left'

      `<ReactCSSTransitionGroup transitionName={pageAnimationName} className="l-full-window">
        <div className="l-full-window" key="step-1-container">
          <div className="l-full-window-body">
            <div className="max-width-800px margin-center text-center container">
              <h1>Colorgy Books 課程用書平台</h1>
              <p>老師您好，歡迎使用 Colorgy Books 課程用書平台！非常感謝您撥空至此登錄書籍資料，幫助同學能提早確認及準備上課用書。書籍資料輸入主要有三個步驟，第一步請老師選擇您目前所在的學校。</p>
              <h2>第一步驟：請選擇學校 <small>共三步驟</small></h2>
              <p>&nbsp;</p>
              <Select
                key="select-1"
                options={this.state.orgSelections}
                onChange={this.handleOrgSelect}
                placeholder="輸入學校名稱或簡稱..."
                noResultsText="找不到這間學校"
              />
            </div>
          </div>
        </div>
      </ReactCSSTransitionGroup>`

window.LecturerBooks = LecturerBooks
