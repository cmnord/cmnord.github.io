$(document).ready(function() {
  // code based off of https://code.hackmit.org's emoji footer :D
  // click the bird
  var EMOJIS = [
    'chicken',
    'penguin',
    'baby_chick',
    'bird',
    'egg'
  ];

  // select a new emoji
  var newemoji = function() {
    return 'em-' + EMOJIS[Math.floor(Math.random() * EMOJIS.length)];
  }
  
  $('#emoji').click( function() {
      $(this).attr("class", 'em ' + newemoji());
    });

}());
