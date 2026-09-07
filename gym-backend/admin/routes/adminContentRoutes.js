const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const router = express.Router();
const { createContent, getAllContent, getContentById, updateContent, deleteContent} = require('../controller/adminContentController');
const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');


// ========================================
// MULTER CONFIGURATION
// ========================================

const uploadDirectory = path.join( __dirname, '../../uploads/content');


// Create folder if it doesn't exist
if (!fs.existsSync(uploadDirectory)) {
    fs.mkdirSync(uploadDirectory, {
        recursive: true
    });
}


const storage = multer.diskStorage({

    destination: (req, file, cb) => {
        cb(null, uploadDirectory);
    },
    filename: (req, file, cb) => {
        const uniqueName =
            Date.now() +
            '-' +
            Math.round(Math.random() * 1000000000) +
            path.extname(file.originalname);

        cb(null, uniqueName);
    }

});


const fileFilter = (req, file, cb) => {

    const allowedTypes = [
        'image/jpeg',
        'image/jpg',
        'image/png',
        'image/webp'
    ];


    if (allowedTypes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error(
            'Only JPG, JPEG, PNG and WEBP images are allowed'
        ));
    }
};


const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024
    }
});


// ========================================
// CREATE CONTENT
// ========================================

router.post('/', authMiddleware, roleMiddleware('ADMIN'), upload.single('image'), createContent);

// ========================================
// GET ALL CONTENT
// ========================================

router.get('/',authMiddleware,roleMiddleware('ADMIN'),getAllContent);

// ========================================
// GET CONTENT BY ID
// ========================================

router.get('/:id', authMiddleware, roleMiddleware('ADMIN'), getContentById);

// ========================================
// UPDATE CONTENT
// ========================================

router.put('/:id',authMiddleware,roleMiddleware('ADMIN'),upload.single('image'),updateContent);

// ========================================
// DELETE CONTENT
// ========================================

router.delete('/:id',authMiddleware,roleMiddleware('ADMIN'),deleteContent);


module.exports = router;