Validator = function () {

    $('#createSecret').on('submit', function (event) {

        if(!$.trim($('#input-textarea').val())) {
            event.preventDefault();

            if (!$('#no-text-warning').length) {
                $('#one').append("<p id='no-text-warning'>Oops! You did not provide anything to share</p>")
            }
        }

    });

};

module.exports = Validator;