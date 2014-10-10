var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res) {
  res.render('index', { title: 'EthicalBay' });
});

router.get('/join', function(req, res) {
  res.render('sign-up_form', {});
});

module.exports = router;
