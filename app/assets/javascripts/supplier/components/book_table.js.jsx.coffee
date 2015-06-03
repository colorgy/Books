BookTable = React.createClass
  componentDidMount: ->
    # $(React.findDOMNode(@refs.orgSelector)).select2()
  handleOrgChange: (e) ->
    console.log e
    console.log 'aa'

  render: ->
    options = [
        { value: 'one', label: 'One OOner' },
        { value: 'two', label: 'Two' }
    ]
    `<div className="box box-default">
      <div className="box-header with-border">
        <div className="box-title">
          <Select
              name="form-field-name"
              value="one"
              options={options}
          />
        </div>
      </div>
      <div className="box-body">
        <table className="table">
          <thead>
            <tr>
              <th>#</th>
              <th>First Name</th>
              <th>Last Name</th>
              <th>Username</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <th scope="row">1</th>
              <td>Mark</td>
              <td>Otto</td>
              <td>@mdo</td>
            </tr>
            <tr>
              <th scope="row">2</th>
              <td>Jacob</td>
              <td>Thornton</td>
              <td>@fat</td>
            </tr>
            <tr>
              <th scope="row">3</th>
              <td>Larry</td>
              <td>the Bird</td>
              <td>@twitter</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>`

window.BookTable = BookTable
