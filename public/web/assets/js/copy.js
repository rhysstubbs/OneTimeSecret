window.onload = function () {
    var btnCopy = document.querySelector('#btn-copy');
    var copied = 0;

    btnCopy.addEventListener('click', function (event) {
        var link = document.querySelector('#secreturi');
        var range = document.createRange();
        range.selectNode(link);
        window.getSelection().addRange(range);

        try {
            var successful = document.execCommand('copy');
            copied++;
            if (copied == 1) {
                var label = document.createElement("label");
                var labelText = document.createTextNode("Copied!");
                label.appendChild(labelText);
                document.getElementById('url-form').appendChild(label);
            }
            window.getSelection().removeAllRanges();
        } catch (err) {
            alert('Oops, try copying manually!');
        }
    });
};


