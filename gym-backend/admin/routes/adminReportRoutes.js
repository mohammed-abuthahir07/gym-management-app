const express = require('express');
const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

const {
    getAdminCurrentMonthRevenue,
    getAdminCurrentYearRevenue,
    getAdminTotalRevenue,
    getAdminCurrentMonthCheckIns,
    getAdminCurrentYearCheckIns,
    getAdminCurrentMonthUnpaid
} = require('../controller/adminReportController');


// Current month revenue
router.get(
    '/report/current-month-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentMonthRevenue
);


// Current year revenue
router.get(
    '/report/current-year-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentYearRevenue
);


// Total revenue
router.get(
    '/report/total-revenue',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminTotalRevenue
);


// Current month check-ins
router.get(
    '/report/current-month-checkins',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentMonthCheckIns
);


// Current year check-ins
router.get(
    '/report/current-year-checkins',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentYearCheckIns
);


// Current month unpaid members
router.get(
    '/report/current-month-unpaid',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAdminCurrentMonthUnpaid
);


module.exports = router;