// ------------------------------------------------------------------------------------------------------
// VENDOR LIBRARIES


// ------------------------------------------------------------------------------------------------------
// SITE COMPONENTS
require('./lib/main');
require('./lib/plugins');
require('./lib/passgen-template');
var CopyLink = require('./lib/CopyLink');
var Validator = require('./lib/FormValidator');
var HelpToggler = require('./lib/HelpToggler');

(function ($) {

    $(document).on('ready', function () {
        window.page = new Page();

        $("#help").hide();
    });

    // ------------------------------------------------------------------------------------------------------
    // COMMON PAGE FUNCTIONALITY
    Page = function () {

        CopyLink.init();

        Validator();

        HelpToggler();

    }

})(jQuery);
