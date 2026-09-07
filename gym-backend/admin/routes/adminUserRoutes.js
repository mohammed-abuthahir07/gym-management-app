const express = require('express');
const router = express.Router();
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');
const { getMembers, getMember, deleteMember, getTrainers, getTrainer, deleteTrainer, assignTrainer, removeTrainer} = require('../controller/adminUserController');


// =====================================================
// MEMBER ROUTES
// =====================================================

// GET ALL MEMBERS
// GET /api/admin/members
router.get('/members', authMiddleware, roleMiddleware('ADMIN'), getMembers);

// GET SINGLE MEMBER
// GET /api/admin/members/:id
router.get('/members/:id', authMiddleware, roleMiddleware('ADMIN'), getMember);

// DELETE / DEACTIVATE MEMBER
// DELETE /api/admin/members/:id
router.delete('/members/:id', authMiddleware, roleMiddleware('ADMIN'), deleteMember);

// =====================================================
// TRAINER ROUTES
// =====================================================

// GET ALL TRAINERS
// GET /api/admin/trainers
router.get('/trainers',authMiddleware,roleMiddleware('ADMIN'),getTrainers);

// GET SINGLE TRAINER
// GET /api/admin/trainers/:id
router.get('/trainers/:id',authMiddleware,roleMiddleware('ADMIN'),getTrainer);

// DELETE / DEACTIVATE TRAINER
// DELETE /api/admin/trainers/:id
router.delete('/trainers/:id',authMiddleware,roleMiddleware('ADMIN'),deleteTrainer);

// =====================================================
// MEMBER ↔ TRAINER ASSIGNMENT
// =====================================================

// ASSIGN TRAINER
// PUT /api/admin/members/:id/trainer
router.put('/members/:id/trainer',authMiddleware,roleMiddleware('ADMIN'),assignTrainer);

// REMOVE TRAINER
// DELETE /api/admin/members/:id/trainer
router.delete('/members/:id/trainer',authMiddleware,roleMiddleware('ADMIN'),removeTrainer);

module.exports = router;