$(document).ready(function () {


	$('input[type=radio][name=reciept]').change(function() {
		var reciept_method = $("input[name=reciept]:checked").val();
		if((reciept_method == "統一編號")||(reciept_method=="愛心碼")){

			$(this).parent('label').children('div').addClass('receipt-text-input-show');
		}
		//else if (reciept_method != '共同載具'){
		//	$('.receipt-text-input').removeClass('receipt-text-input-show');
		//}
        if (this.id == 'invoice-co-option') {
            $('.receipt-co-option').addClass('tester');
            $('.reciept-more').children('div').children('label').children('div').removeClass('receipt-text-input-show');

        }
        else if (this.id != 'invoice-co-option') {
        	$('.receipt-co-option').removeClass('tester');

        }
    });

	$('input[type=radio][name=co]').change(function() {
		var co_method =$("input[name=co]:checked").val();
        if (co_method != null) {
        	$('.receipt-co-option').children('div').children('label').children('h4').removeClass('co-css');
            $(this).parent('label').children('h4').addClass('co-css');
            $('.receipt-text-input').removeClass('receipt-text-input-show');
            $('.co-option').parent('label').children('div').removeClass('receipt-text-input-show');
            $(this).parent('label').children('div').addClass('receipt-text-input-show');
        }

    });


	$('.reciept-more-toggle').click(function(){

		$('.reciept-more').addClass('reciept-more-toggleClass');
		$('.reciept-more-toggle').toggle(500);

	});

	$('.checkout__button').click(
		function(){
			$('.checkout__order').addClass('checkout-open');
			$('.checkout__button__number').addClass('checkout__button__number-hide');
		});
	$('.close-button').click(
		function(){
			$('.checkout__order').removeClass('checkout-open');
			$('.checkout__button__number').removeClass('checkout__button__number-hide');
		});

	$( '.modal-toggle' ).hover(
	  function() {
	    $(this).addClass( 'remove-border-radius' );
	    $(this).children('h5').addClass('modal-toggle-h5-hover');
	  }, function() {
	    $(this).removeClass( 'remove-border-radius' );
	    $(this).children('h5').removeClass('modal-toggle-h5-hover');
	  }
	);

	$( 'a.checkout__button' ).hover(
	  function() {
	    $('div.checkout__button__number').addClass( 'checkout__button__number__hover' );
	  }, function() {
	    $('div.checkout__button__number').removeClass( 'checkout__button__number__hover' );
	  });

	$('.input__field').focusin(
		function(){
			$('.input__label').addClass('totop');
		});
	$('.input__field').focusout(
		function(){
			    if( $(this).val().length === 0 ) {
			        $('.input__label').removeClass('totop');
			    }
		});
	$('.push-menu-close').click(function(){
		if ( $( '.push-menu' ).hasClass( "push-menu-active" ) ){
			$('.push-menu').removeClass('push-menu-active');
			}
	})

	$('#push-menu-trigger').click(function(){
		if ( $( '.push-menu' ).hasClass( "push-menu-active" ) ){
			$('.push-menu').removeClass('push-menu-active');
			}
		else{
			$('.push-menu').addClass('push-menu-active');
		}
	})
    $('body').click(function(evt){
    	if ($(evt.target).parents(".push-menu").length==0 && evt.target.class != "push-menu" && evt.target.id != "push-menu-trigger") {
    	$('.push-menu').removeClass('push-menu-active')};
    })
    $( ".faqs-question" ).click(function() {
	  $(this).parent().children('.faqs-answer').slideToggle( 200 );
	  $(this).children("img").toggleClass('faqs-question-img-rotate')
	});
    $('.close-btn').click(function(){
    	$(this).parent().hide(500);
    })

});
