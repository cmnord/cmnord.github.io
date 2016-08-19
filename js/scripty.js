$(document).ready(function() {
  "use strict";

  // Thanks to: https://code.hackmit.org's emoji footer
  //            https://afeld.github.io/emoji-css/'s emojis
  //            http://www.paulgriffiths.net/program/javascript/moreform3.php's preloading images

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

  var BEARS = [
    'ᴥ·　',
    '·ᴥ·　',
    ' ·ᴥ· ',
    '　·ᴥ·',
    '　·ᴥ'
  ];
  
  var WAGGLE_TIME = 1000;
  var b = 3;
  var up = false;
 
  $('#bear').bind('mouseenter', function() {
    this.waggling = setInterval(function() {
      if(up) {b = b + 1;}
      else {b = b - 1;}
      console.log(b);
      $('#bear').text("ʕ" + BEARS[b] + "ʔ");
      if(b == BEARS.length - 1) { up = false; }
      if(b == 0) { up = true; }
    }, WAGGLE_TIME);
  }).bind('mouseleave', function() {
    this.waggling && clearInterval(this.waggling);
  });

}());



