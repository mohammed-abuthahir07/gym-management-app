const express = require('express');

const router = express.Router();
const { createAdminChallenge, getChallenges, getChallenge, updateAdminChallenge, deleteAdminChallenge} = require('../controller/adminChallengesController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// CREATE CHALLENGE
router.post('/',authMiddleware,roleMiddleware('ADMIN'),createAdminChallenge);

// GET ALL CHALLENGES
router.get('/', authMiddleware, roleMiddleware('ADMIN'), getChallenges);

// GET SINGLE CHALLENGE
router.get('/:id', authMiddleware, roleMiddleware('ADMIN'), getChallenge);

// UPDATE CHALLENGE
router.put('/:id', authMiddleware, roleMiddleware('ADMIN'), updateAdminChallenge);

// DELETE CHALLENGE
router.delete( '/:id', authMiddleware, roleMiddleware('ADMIN'), deleteAdminChallenge);

module.exports = router;