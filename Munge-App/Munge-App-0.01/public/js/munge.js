$( document ).ready( function(){
    $( document ).on( 'munge::init', function(){
        /* remove broken images */
        $('img').each( function(){
            if( ! this.src ) {
                $(this).remove();
                return;
            }


            var img = new Image(), orig = this;

            $(img).load( function(){
                /** if it can be loaded, its not pix > 1 **/
                if( img.width > 1 ){
                    $(orig).show();
                }
            });

            img.src = this.src;
            $(orig).hide();
        });

        /* open links from articles in a new window */
        $('.feed-content a').each(function(){
            $(this).attr('target', '_blank');
        });

        // open links from the sidebar
        // trough an ahah request
        $('#sidebar a, .feed-title a').ahah('#sidebar, #content-main');
        $('#feed-heading a').ahah( '#sidebar' );

        $('#feed-heading a').click( function( evt ){
            evt.preventDefault();
            if( $(this).is( '#mark-read' ) ){
                $('#header-read').after( $('.summary.unread').removeClass('unread').remove() );
            }

        });

    });

    $( document ).trigger('munge::init');
});

(function($){
    var clickHandler = function( evt, replaceSelectors, successCallback ){
        evt.preventDefault();

        $.get( $(this).attr('href'), null, function(data){
            var selectors = replaceSelectors.split(',');

            $( replaceSelectors ).each( function( iter, el ){
                for( var i = 0; i < selectors.length; i++ ){
                    if( $( this ).is( selectors[i] ) ){
                        $( this ).html( $(data).find( selectors[i] ).html() );
                    }
                }
            });

            successCallback();
        });
    },
    bindEvents = function( selector, replaceSelectors ){
        $( selector ).each(function() {
            var self = this;

            $(this).one( 'click', function( evt ){
                $( replaceSelectors ).fadeTo(100, 0.7);
                clickHandler.call( self, evt, replaceSelectors, function(){
                    $( replaceSelectors ).fadeTo( 100, 1 );
                    $( document ).trigger('munge::init');
                });
            });
        });
    };

   $.fn.extend({
        ahah: function( replaceSelectors ) {
            bindEvents( this.selector, replaceSelectors );
            return this;
        }
    });
})(jQuery);
