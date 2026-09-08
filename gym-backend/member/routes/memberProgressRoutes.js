const express = require('express');

const router = express.Router();

const authMiddleware = require('../../middleware/authMiddleware');

const {
    createProgress,
    getAllProgress,
    getProgress,
    updateProgress,
    deleteProgress
} = require('../controller/memberProgressController');


// =====================================================
// MEMBER PROGRESS ROUTES
// =====================================================


// CREATE PROGRESS
// POST /api/member/progress

router.post(
    '/progress',
    authMiddleware,
    createProgress
);


// GET ALL OWN PROGRESS
// GET /api/member/progress

router.get(
    '/progress',
    authMiddleware,
    getAllProgress
);


// GET SINGLE OWN PROGRESS
// GET /api/member/progress/:id

router.get(
    '/progress/:id',
    authMiddleware,
    getProgress
);


// UPDATE OWN PROGRESS
// PUT /api/member/progress/:id

router.put(
    '/progress/:id',
    authMiddleware,
    updateProgress
);


// DELETE OWN PROGRESS
// DELETE /api/member/progress/:id

router.delete(
    '/progress/:id',
    authMiddleware,
    deleteProgress
);


module.exports = router;