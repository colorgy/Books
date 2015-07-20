ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

AddBookToCart = React.createClass
  mixins: [React.addons.LinkedStateMixin]

  getDefaultProps: ->
    bookID: null
    bookGroups: []
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
    @state.purchaseMethod && @state.quantity && (@state.quantity > 0)

  render: ->
    submitButtonClass = classNames(disabled: !@canSubmit())
    packageSelections = ['true'].map (p, i) =>
      onChange = @handleSelectionChange.bind(this, 'package', null)
      checked = (@state.purchaseMethod == 'package')
      `<p>
        <input id="checkbox-package-buy"
               type="radio"
               onChange={onChange}
               className="with-gap"
               checked={checked} />
        <label htmlFor="checkbox-package-buy">
          直接購買 (單包購買未滿 2 本須負擔 NT$ 100 運費)
        </label>
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
          {group.course_name} --- {group.leader_name} 揪團（{} 截止繳費)
        </label>
      </p>`

    coursesWithNoGroupSelections = @props.bookCoursesWithNoGroup.map (course, i) =>
      `<p key={course.ucode}>
        <input className="with-gap" disabled="disabled" id={'checkbox-' + course.ucode} type="radio" />
        <label htmlFor={'checkbox-' + course.ucode}>
          {course.lecturer_name} 老師 / {course.name} (沒有進行中的團購)
        </label>
      </p>`

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
        <div className="under-line-title">
          <span>選擇跟團</span>
        </div>
        <div className="groups-select-field">
          {groupSelections}
          {coursesWithNoGroupSelections}
        </div>
      </div>
      <div className="buy-field">
        <span style={{ 'font-size': '20px' }}>數量：</span>
        <input style={{ 'width': '60px', 'font-size': '20px' }} type="number" value={this.state.quantity} onChange={this.handleQuantityChange} />
        &nbsp;&nbsp;&nbsp;
        <button className={'btn-highlight btn--large ' + submitButtonClass} id="add-to-cart">放入購物書包</button>
      </div>
    </div>`

window.AddBookToCart = AddBookToCart
