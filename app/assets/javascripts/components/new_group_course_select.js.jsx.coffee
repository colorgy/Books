NewGroupCourseSelect = React.createClass

  getDefaultProps: ->
    value: null

  getInitialState: ->
    courseUCode: null

  getData: (input, callback) ->
    $.ajax
      method: 'GET'
      url: "/courses.json"
      dataType: 'json'
      data:
        q: input
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
    @refs.select.autoloadAsyncOptions()

  render: ->
    value = @props.value?.toString()

    `<div className={classNames({ 'form-group': true })}>
      <label>選擇課程</label>
      <Select className="with-complex-selection" ref="select"
        asyncOptions={this.getData}
        name="group[course_ucode]"
        value={value}
        placeholder="選擇課程"
        filterOption={this.filterOption}
      />
    </div>`

window.NewGroupCourseSelect = NewGroupCourseSelect
