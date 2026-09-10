const express = require('express');

const router = express.Router();

const {
    getPublicPlans
} = require('../controller/publicPlansController');

router.get(
    '/',
    getPublicPlans
);

module.exports = router;