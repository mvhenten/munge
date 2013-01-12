$( document ).ready( function(){
    /* remove broken images */
    $('img').each( function(){ if( ! this.src ) { $(this).remove(); } });
    
    /* open links from articles in a new window */
    $('.feed-content a').each(function(){
        $(this).attr('target', '_blank');
    });
    
});