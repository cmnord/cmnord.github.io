// code based off of https://code.hackmit.org's emoji footer :)
(function() {
  var interval = 3000;

  // uniform int from [min, max)
  var uniform = function(min, max) {
    return min + Math.floor(Math.random() * (max - min));
  };
    
  var update = function() {
    var sym = document.getElementById('symbol');
    //dingbats are from 0x2700 to 0x27bf
    var symbol = String.fromCharCode(uniform(0x2700, 0x27c0));
    sym.innerHTML = symbol;
  };

  setInterval(update, interval);

}());
