window.onload = function () {
    var btnCopy = document.querySelector('#btn-copy');
    btnCopy.addEventListener('click', function (event) {
        var link = document.querySelector('#secreturi');
        var range = document.createRange();
        range.selectNode(link);
        window.getSelection().addRange(range);
        try {
            var successful = document.execCommand('copy');
            var msg = successful ? 'successful' : 'unsuccessful';
            console.log('Copy email command was ' + msg);
        } catch(err) {
            alert('Oops, try copying manually!');
        }
        window.getSelection().removeAllRanges();
    });
};


