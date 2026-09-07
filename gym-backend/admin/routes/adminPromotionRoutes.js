const express = require('express');
const router = express.Router();
const { createAdminPromotion, getPromotions, getPromotion, updateAdminPromotion, deleteAdminPromotion} = require('../controller/adminPromotionController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// CREATE PROMOTION
router.post('/', authMiddleware, roleMiddleware('ADMIN'), createAdminPromotion);

// GET ALL PROMOTIONS
router.get('/',authMiddleware, roleMiddleware('ADMIN'), getPromotions);

// GET SINGLE PROMOTION
router.get('/:id', authMiddleware, roleMiddleware('ADMIN'), getPromotion);

// UPDATE PROMOTION
router.put('/:id', authMiddleware, roleMiddleware('ADMIN'), updateAdminPromotion);

// DELETE PROMOTION
router.delete('/:id',authMiddleware,roleMiddleware('ADMIN'),deleteAdminPromotion);

module.exports = router;