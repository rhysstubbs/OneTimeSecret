HelpToggler = function () {

    $('#btn-issue').click(function () {
        if (!$("#help").is(":visible")) {
            $("#help").fadeIn();
        } else {
            $("#help").fadeOut();
        }
        return false;
    });

};

module.exports = HelpToggler;