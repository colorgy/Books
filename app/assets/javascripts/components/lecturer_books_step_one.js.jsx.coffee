LecturerBooksStepOne = React.createClass

  getInitialState: ->
    step: 1
    orgCode: null
    lecturerName: null
    courses: []

  render: ->
    if @state.step == 2 && @state.orgCode
    else if @state.step == 3 && @state.orgCode && @state.lecturerName
    else
      `<div>
        <h1>歡迎使用 Colorgy Books 課程用書整理平台！</h1>
      </div>`

window.LecturerBooksStepOne = LecturerBooksStepOne
