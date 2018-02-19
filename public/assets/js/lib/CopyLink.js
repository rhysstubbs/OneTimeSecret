window.Clipboard = require('clipboard');

var CopyLink = function () {
    this.copyButton = '#btn-copy';

    if (!Clipboard.isSupported() || typeof Clipboard === "undefined") {
        this.hideSelf();
        return;
    }

    $('#btn-copy').on('click', function () {
        this.copy();
    }.bind(this));
};

CopyLink.prototype.copy = function () {
    this.clipboard = new Clipboard(this.copyButton);

    this.clipboard.on('success', function () {
        this.showCopied();
        window.getSelection().removeAllRanges();
    }.bind(this));

    this.clipboard.on('error', function () {
        this.showHelp();
    }.bind(this));
};

CopyLink.prototype.showCopied = function () {
    $('#copy-label').remove();
    const copiedLabel = "<p id='copy-label'>Copied! <i class='fa fa-check'></i></p>";
    $('#url-form').append(copiedLabel);
    $('#link, #secreturi').css("background-color", "#edfaeb");
};

CopyLink.prototype.hideSelf = function () {
    this.copyButton.hide();
};

CopyLink.prototype.showHelp = function () {
    alert('Oops, try copying manually!');
    $("#help").fadeIn();
};


CopyLink.init = function () {
    var copyLink = new CopyLink();
};

module.exports = CopyLink;