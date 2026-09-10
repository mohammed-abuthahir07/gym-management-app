const express = require('express');

const router = express.Router();

const {
    getPublicPromotions
} = require('../controller/publicPromotionController');

router.get(
    '/',
    getPublicPromotions
);

module.exports = router;