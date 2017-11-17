(function ($) {

    $(document).ready(function () {

       window.page = new Page();

        var copied = 0;

        if (typeof Clipboard === "undefined") {
            console.log("Not Supported.");
            $('#btn-copy').hide();
        } else if (Clipboard.isSupported()) {
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

    // ----------------------------------------------------------------------------------------------------
    // COMMON PAGE FUNCIONALITY
    Page = function () {
        var heightGroups = new EqualHeightGroups();
    };

    // ------------------------------------------------------------------------------------------------------
    // EQUAL HEIGHT GROUPS
    EqualHeightGroups = function (wrap, opts) {
        this.opts = $.extend({}, EqualHeightGroups.defaults, opts || {});
        this.wrap = wrap || $('body');

        if (!this.wrap.find('[data-height-group]').length) return;

        var groups = {};

        this.wrap.find('[data-height-group]').each(function () {

            var groupId = $(this).attr('data-height-group');
            if (groups.hasOwnProperty(groupId)) return;

            groups[groupId] = $('[data-height-group="' + groupId + '"]');

        });

        this.groups = groups;

        $(window).on('load resize', $.proxy(this.onResize, this));
        this.onResize();

    }

    EqualHeightGroups.defaults = {};

    EqualHeightGroups.prototype.processGroup = function (groupId) {
        var group = this.groups[groupId].height('auto'),
            lines = {};

        group.each(function (i, el) {
            var cPos = $(el).offset().top + '';
            if (!lines.hasOwnProperty(cPos)) lines[cPos] = [];
            lines[cPos].push(el);
        });

        for (var p in lines) {
            var line = $(lines[p]).map(function () {
                return $(this).toArray();
            });
            var maxHeight = Math.max.apply(null, line.map(function () {
                return $(this).height();
            }).get());
            line.height(maxHeight);
        }
    }

    EqualHeightGroups.prototype.onResize = function () {
        if (this.throttleResize == true) {
            this.resizeAttempts++;
            return;
        }

        for (var p in this.groups) {
            this.processGroup(p);
        }

        this.throttleResize = true;
        this.resizeAttempts = 0;
        clearTimeout(this.resizeTimeout || null);
        setTimeout($.proxy(function () {
            this.throttleResize = false;
            if (this.resizeAttempts > 0) {
                this.onResize();
            }
        }, this), 500);
    }

})(jQuery);
