#= require rails.validations
#= require rails.validations.simple_form

(->
  ClientSideValidations.callbacks.form.fail = (form, eventData) ->
    # window.form = form
    # window.eventData = eventData
    firstError = form?.find('.has-error')?.first()
    firstError?.find('input')?.focus()
    firstError?.addClass('animated shake')
    setTimeout( =>
      firstError?.removeClass('animated shake')
    , 1000)

  ClientSideValidations.formBuilders['SimpleForm::FormBuilder']['wrappers']['vertical_form'] =
    ClientSideValidations.formBuilders['SimpleForm::FormBuilder']['wrappers']['default']
  ClientSideValidations.formBuilders['SimpleForm::FormBuilder']['wrappers']['horizontal_form'] =
    ClientSideValidations.formBuilders['SimpleForm::FormBuilder']['wrappers']['default']
).call(this)
