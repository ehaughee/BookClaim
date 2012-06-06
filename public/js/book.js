$(document).ready(function() {
    $("#claim_modal").modal({
        keyboard: true,
        backdrop: true,
        show: false
    });

    $(".book_submit").click(function() {
        var id = this.dataset.bookId;
        $("#modal" + id).modal('show');

        return false;
    });
});
