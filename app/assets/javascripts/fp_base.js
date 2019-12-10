;(function($){
    $.fn.extend({
        donetyping: function(callback,timeout){
            timeout = timeout || 2e2; // 1 second default timeout
            var timeoutReference,
                doneTyping = function(el){
                	
                    if (!timeoutReference) return;
                    timeoutReference = null;
                    callback.call(el);
                };
            return this.each(function(i,el){
                var $el = $(el);
                // Chrome Fix (Use keyup over keypress to detect backspace)
                // thank you @palerdot  $el.is(':input')
                $el.is(':input') && $el.on('keyup keypress',function(e){
                    // This catches the backspace button in chrome, but also prevents   change
                    // the event from triggering too premptively. Without this line,
                    // using tab/shift+tab will make the focused element fire the callback.
                    // 有这一句在，汉字输入后不自动查询，暂时去掉
                    // if (e.type=='keyup' && e.keyCode!=8) return;
                    
                    // Check if timeout has been set. If it has, "reset" the clock and
                    // start over again.
                    if (timeoutReference) clearTimeout(timeoutReference);
                    timeoutReference = setTimeout(function(){
                        // if we made it here, our timeout has elapsed. Fire the
                        // callback
                        doneTyping(el);
                    }, timeout);
                }).on('blur',function(){
                    // If we can, fire the event since we're leaving the field
                    //doneTyping(el);
                });
            });
        }
    });
})(jQuery);

function ajax_asynchronous(link){
  $.ajax({
    url: link.replace(/\?/g,"&").replace("&","?"),
    type: "GET",
    dataType: "script"
  });
}
