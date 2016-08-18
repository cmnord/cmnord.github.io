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

  // select a new emoji, it never repeats
  var newemoji = function() {
    var old_emoji = document.images['emoji'].src;
    var new_emoji = old_emoji;
    while(new_emoji == old_emoji) {
      new_emoji = emojiArr[Math.floor(Math.random() * EMOJIS.length)].src;
    }
    return new_emoji;
  }
  
  $('#emoji').click( function() {
    $(this).attr("src", newemoji());
  });

}());
