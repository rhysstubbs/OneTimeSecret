// ------------------------------------------------------------------------------------------------------
// VENDOR LIBRARIES


// ------------------------------------------------------------------------------------------------------
// SITE COMPONENTS
require('./lib/main.js');
require('./lib/plugins.js');
require('./lib/passgen-template.js');
var CopyLink = require('./lib/CopyLink.js');

(function ($) {

    $(document).on('ready', function () {
        window.page = new Page();
    });

    // ------------------------------------------------------------------------------------------------------
    // COMMON PAGE FUNCTIONALITY
    Page = function () {

        CopyLink.init();

        $("#help").hide();

        $('#btn-issue').click(function () {
            if (!$("#help").is(":visible")) {
                $("#help").fadeIn();
            } else {
                $("#help").fadeOut();
            }
            return false;
        });

        $('#createSecret').submit(function (ev) {
            if (!$.trim($('#input-textarea').val())) {
                ev.preventDefault();
                if (!$('#no-text-warning').length) {
                    var warning = document.createElement("p");
                    warning.setAttribute("id", "no-text-warning");
                    var warningText = document.createTextNode("Oops! You did not provide anything to share");
                    warning.appendChild(warningText);
                    document.getElementById('one').appendChild(warning);
                }
            }
        });
    }

})(jQuery);
