$(document).ready(function() {
  // code based off of https://code.hackmit.org's emoji footer :D
  // as well as https://afeld.github.io/emoji-css/ for the emojis
  // as well as http://www.paulgriffiths.net/program/javascript/moreform3.php for preloading images!
  // click the bird
  var EMOJIS = [
    'chicken',
    'penguin',
    'baby_chick',
    'bird',
    'egg'
  ];

  var emojiArr = new Array(EMOJIS.length);
  for(var i = 0; i < EMOJIS.length; i++) {
    emojiArr[i] = new Image(60, 60);
    emojiArr[i].src = "img/" + EMOJIS[i] + ".png";
  }

  // select a new emoji
  var newemoji = function() {
    return emojiArr[Math.floor(Math.random() * EMOJIS.length)].src;
  }
  
  $('#emoji').click( function() {
      $(this).attr("src", newemoji());
    });

}());
