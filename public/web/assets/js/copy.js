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

            if (msg.equals('successful')) {
                var label = document.createElement("label");
                var labelText = document.createTextNode("Copied!");
                label.appendChild(labelText);
                document.getElementById('url-form').appendChild(label);
            }

        } catch(err) {
            alert('Oops, try copying manually!');
        }
        window.getSelection().removeAllRanges();
    });
};


