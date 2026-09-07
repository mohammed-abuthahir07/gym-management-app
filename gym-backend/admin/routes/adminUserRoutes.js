const express = require('express');

const router = express.Router();
const { getMembers, getMember, deleteMember, getTrainers, getTrainer, deleteTrainer} = require('../controller/adminUserController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ======================================
// MEMBERS
// ======================================

// GET ALL MEMBERS
router.get('/members', authMiddleware, roleMiddleware('ADMIN'), getMembers);

// GET SINGLE MEMBER
router.get( '/members/:id', authMiddleware, roleMiddleware('ADMIN'), getMember);

// DELETE / DEACTIVATE MEMBER
router.delete('/members/:id', authMiddleware, roleMiddleware('ADMIN'), deleteMember);


// ======================================
// TRAINERS
// ======================================

// GET ALL TRAINERS
router.get('/trainers', authMiddleware, roleMiddleware('ADMIN'), getTrainers);

// GET SINGLE TRAINER
router.get( '/trainers/:id', authMiddleware,roleMiddleware('ADMIN'),getTrainer);

// DELETE / DEACTIVATE TRAINER
router.delete('/trainers/:id',authMiddleware,roleMiddleware('ADMIN'), deleteTrainer);

module.exports = router;