const express = require('express');

const router = express.Router();

const {
    getPublicTrainers
} = require('../controller/publicTrainerController');

router.get(
    '/',
    getPublicTrainers
);

module.exports = router;