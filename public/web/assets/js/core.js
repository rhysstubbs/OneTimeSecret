//= require jquery-1.10.2.min.js

(function ($) {

    $(document).ready(function () {

        var copied = 0;

        $('#btn-copy').click(function (ev) {
            var link = document.querySelector('#secreturi');
            var range = document.createRange();
            range.selectNode(link);
            window.getSelection().removeAllRanges();
            window.getSelection().addRange(range);

            try {
                var successful = document.execCommand('copy');
                if (successful) {
                    if (copied === 0) {
                        var label = document.createElement("label");
                        label.setAttribute("id", "copy-label");
                        var labelText = document.createTextNode("Copied!");
                        label.appendChild(labelText);
                        var checkSymbol = document.createElement("i");
                        checkSymbol.setAttribute("class", "fa fa-check");
                        document.getElementById('url-form').appendChild(label);
                        label.appendChild(checkSymbol);
                        $('#link, #secreturi').css("background-color", "#edfaeb");
                    }
                    window.getSelection().removeAllRanges();
                    copied++;
                }
            } catch (err) {
                alert('Oops, try copying manually!');
            }
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

    }

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
