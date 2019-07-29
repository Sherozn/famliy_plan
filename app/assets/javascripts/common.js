
function ajax_asynchronous_post_with_data(link, data) {
  $.ajax({
    url: link.replace(/\?/g,"&").replace("&","?"),
    type: "POST",
    dataType: "script",
    data: data
  });
}

function ajax_asynchronous_post(link) {
  $.ajax({
    url: link.replace(/\?/g,"&").replace("&","?"),
    type: "POST",
    dataType: "script"
  });
}

function ajax_asynchronous(link){
  $.ajax({
    url: link.replace(/\?/g,"&").replace("&","?"),
    type: "GET",
    dataType: "script"
  });
}

function monitor_load(){
  var remote_url = null;
  window.url = null;
  window.reduction = 30;
  $(document).ready(function() {
    $(window).scroll(function() {
      if($(document).scrollTop() >= ($(document).height() - $(window).height() - window.reduction) && window.current_page <= window.total_pages && window.mark && window.total_pages != 1) {
        window.load.after('<div class="loa_img15"><img src="/assets/loading00.gif"></div>');
        window.mark = false;
        window.current_page += 1;
        if(window.url == null){
          remote_url = window.location.href+"?page="+window.current_page;
        }else {
          remote_url = window.url+"?page="+window.current_page;
        }
        ajax_asynchronous(remote_url.replace(/\?/g,"&").replace("&","?"));
      }
    });
  });
}

function pop_content(content){
  var modal_str = '<div id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" class="modal fade">' + content + '</div>';
  var pop_modal = $(modal_str);
  alert(pop_modal);
  $('body').append(pop_modal);
  pop_modal.modal('show');
}