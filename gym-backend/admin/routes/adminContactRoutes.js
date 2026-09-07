const express = require('express');

const router = express.Router();

const { getAllContacts, getContactById, deleteContact} = require('../controller/adminContactController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// Only ADMIN can view all enquiries
router.get('/', authMiddleware, roleMiddleware('ADMIN'),getAllContacts);

// Only ADMIN can view one enquiry
// Opening it changes NEW → READ
router.get('/:id',authMiddleware, roleMiddleware('ADMIN'), getContactById);

// Only ADMIN can delete an enquiry
router.delete('/:id',authMiddleware,roleMiddleware('ADMIN'),deleteContact);


module.exports = router;