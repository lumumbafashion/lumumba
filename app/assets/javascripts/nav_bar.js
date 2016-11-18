$(document).ready(function(){
  var $navBar = $('.landing');

  // on scroll
  $(window).scroll(function () {
    //// get scroll position from top of the page
    var scrollPos = $(this).scrollTop();
    if (scrollPos >= 80) {
      $navBar.addClass('fixer');
      $('.before-scroll').show();
      $('.alert-scroll-under').hide();
    } else {
      $navBar.removeClass('fixer');
      $('.before-scroll').hide();
      $('.alert-scroll-under').show();
    }
  });
});
