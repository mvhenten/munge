$( document ).ready( function(){
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
    
});