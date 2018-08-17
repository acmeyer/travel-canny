//= require jquery
//= require rails-ujs
//= require turbolinks
//= require bootstrap

document.addEventListener("turbolinks:load", function() {
  $("td.clickable").click(function() {
    var link = $(this).parent('tr').attr("data-link");
    Turbolinks.visit(link);
  });
});
