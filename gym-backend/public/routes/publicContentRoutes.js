const express = require('express');

const router = express.Router();

const {
    getPublicContent
} = require('../controller/publicContentController');

router.get(
    '/',
    getPublicContent
);

module.exports = router;