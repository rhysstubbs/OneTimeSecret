/**
 * Imports for Sass styling.
 * Minified version -> assets/dist/app.min.css
 */
require('../scss/screen.scss');
require('../../../node_modules/font-awesome/scss/font-awesome.scss');

/**
 * Core Javascript/Jquery functionality
 * Minified version -> assets/dist/app.bundle.min.js
 */
require('../../../node_modules/jquery/dist/jquery.js');
window.Clipboard = require('../../../node_modules/clipboard/dist/clipboard.js');
require('../../../node_modules/jquery-placeholder/jquery.placeholder.js');
require('./lib/main.js');
require('./lib/plugins.js');
require('./lib/passgen-template.js');


(function ($) {

    $(document).on('ready', function () {

        var copied = 0;

        if (!Clipboard.isSupported() || typeof Clipboard === "undefined") {
            $('#btn-copy').hide();
	} else {
            $('#btn-copy').click(function () {
                try {
                    var clipboard = new Clipboard('#btn-copy');
                    clipboard.on('success', function () {
                        if (copied === 0) {
                            var label = document.createElement("p");
                            label.setAttribute("id", "copy-label");
                            var labelText = document.createTextNode("Copied!");
                            label.appendChild(labelText);
                            var checkSymbol = document.createElement("i");
                            checkSymbol.setAttribute("class", "fa fa-check");
                            $('#url-form').append(label);
                            label.appendChild(checkSymbol);
                            $('#link, #secreturi').css("background-color", "#edfaeb");
                        }
                        window.getSelection().removeAllRanges();
                        copied++;
                    });
                } catch (err) {
                    alert('Oops, try copying manually!');
                    $("#help").show();
                }
            });
        }

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
    });

    // ------------------------------------------------------------------------------------------------------
    // COMMON PAGE FUNCIONALITY
    Page = function () {

    }

})(jQuery);
