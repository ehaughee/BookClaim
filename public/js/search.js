$(document).ready(function() {
    Handlebars.registerHelper('join', function(arr) {
        return new Handlebars.SafeString(
            arr.join(", ")
        );
    });

    Handlebars.registerHelper("debug", function(optionalValue) {
        console.log("Current Context");
        console.log("====================");
        console.log(this);

        if (optionalValue) {
            console.log("Value");
            console.log("====================");
            console.log(optionalValue);
        }
    });

    $('#btnSearch').button();

    $("#btnSearch").click(function() {
        $(this).button('loading');
        var query = $("input.search-query").val();

        if (query == '') {
            alert('Your search was blank');
            $("input.search-query").focus();
            $(this).button('reset');
            return false;
        }

        $.getJSON('/search',
            { q: query },
            function(data) {

                var template = Handlebars.compile($("#booklist-template").html());
                Handlebars.registerPartial("book", $("#book-partial").html());

                var list = $("#searchResults ul.thumbnails");
                if (list.length > 0)
                    list.remove();

                if (data.error) {
                    console.log(data);
                    $("#searchResults").append("<div class='ul thumbnails'>Error</div>");
                }
                else {
                    $("#searchResults").append(template(data));
                }

                $("#btnSearch").button('reset');
            }
        );
    });
});