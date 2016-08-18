$(document).ready(function() {
  // code based off of https://code.hackmit.org's emoji footer :D
  // as well as https://afeld.github.io/emoji-css/ for the emojis
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
    return EMOJIS[Math.floor(Math.random() * EMOJIS.length)];
  }
  
  $('#emoji').click( function() {
      $(this).attr("src", "img/" + newemoji() + ".png");
    });

}());
