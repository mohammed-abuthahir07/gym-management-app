const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const router = express.Router();

const {
    createContent,
    getAllContent,
    getContentById,
    updateContent,
    deleteContent
} = require('../controller/adminContentController');

const authMiddleware = require('../../middleware/authMiddleware');
const roleMiddleware = require('../../middleware/roleMiddleware');

// ======================================================
// UPLOAD DIRECTORY
// ======================================================

const uploadDirectory = path.join(
    __dirname,
    '../../uploads/content'
);

if (!fs.existsSync(uploadDirectory)) {
    fs.mkdirSync(uploadDirectory, {
        recursive: true
    });
}

// ======================================================
// MULTER STORAGE
// ======================================================

const storage = multer.diskStorage({

    destination: (req, file, cb) => {
        cb(null, uploadDirectory);
    },

    filename: (req, file, cb) => {

        const extension = path
            .extname(file.originalname || '')
            .toLowerCase();

        const uniqueName =
            `${Date.now()}-${Math.round(Math.random() * 1000000000)}${extension}`;

        cb(null, uniqueName);
    }

});

// ======================================================
// SUPPORTED IMAGE EXTENSIONS
// ======================================================
//
// These are common image formats.
//
// ======================================================

const allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.jpe',
    '.jfif',
    '.png',
    '.webp',
    '.gif',
    '.bmp',
    '.tif',
    '.tiff',
    '.ico',
    '.avif',
    '.heic',
    '.heif'
];

// ======================================================
// IMAGE FILE FILTER
// ======================================================
//
// Flutter/mobile clients sometimes send:
// application/octet-stream
//
// Therefore we check BOTH:
// 1. MIME type
// 2. File extension
//
// ======================================================

const fileFilter = (req, file, cb) => {

    const mimeType = (
        file.mimetype || ''
    ).toLowerCase();

    const extension = path
        .extname(file.originalname || '')
        .toLowerCase();

    const isImageMime =
        mimeType.startsWith('image/');

    const isAllowedExtension =
        allowedImageExtensions.includes(extension);

    const isGenericBinary =
        mimeType === 'application/octet-stream';

    // --------------------------------------------------
    // Accept proper image MIME types
    // --------------------------------------------------

    if (isImageMime) {
        return cb(null, true);
    }

    // --------------------------------------------------
    // Accept Flutter/mobile generic binary MIME
    // when the filename is an image
    // --------------------------------------------------

    if (
        isGenericBinary &&
        isAllowedExtension
    ) {
        return cb(null, true);
    }

    // --------------------------------------------------
    // Also accept known image extensions
    // --------------------------------------------------

    if (isAllowedExtension) {
        return cb(null, true);
    }

    // --------------------------------------------------
    // Reject everything else
    // --------------------------------------------------

    return cb(
        new Error(
            'Only image files are allowed. Supported formats: JPG, JPEG, PNG, WEBP, GIF, BMP, TIFF, ICO, AVIF, HEIC and HEIF.'
        )
    );
};

// ======================================================
// MULTER CONFIGURATION
// ======================================================

const upload = multer({

    storage,

    fileFilter,

    limits: {
        fileSize: 5 * 1024 * 1024,
        files: 1
    }

});

// ======================================================
// MULTER ERROR HANDLER
// ======================================================
//
// Instead of returning an HTML error page,
// return JSON to Flutter/Postman.
//
// ======================================================

const uploadImage = (req, res, next) => {

    upload.single('image')(req, res, (error) => {

        if (error) {

            console.error(
                'Content image upload error:',
                error
            );

            return res.status(400).json({
                success: false,
                message: error.message || 'Image upload failed'
            });
        }

        next();
    });
};

// ======================================================
// CREATE CONTENT
// ======================================================
//
// POST
// /api/admin/content
//
// multipart/form-data
//
// title       -> Text
// description -> Text
// image       -> File
//
// ======================================================

router.post(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    uploadImage,
    createContent
);

// ======================================================
// GET ALL CONTENT
// ======================================================

router.get(
    '/',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getAllContent
);

// ======================================================
// GET CONTENT BY ID
// ======================================================

router.get(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    getContentById
);

// ======================================================
// UPDATE CONTENT
// ======================================================
//
// image is optional.
//
// If image is not provided,
// existing image remains.
//
// ======================================================

router.put(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    uploadImage,
    updateContent
);

// ======================================================
// DELETE CONTENT
// ======================================================

router.delete(
    '/:id',
    authMiddleware,
    roleMiddleware('ADMIN'),
    deleteContent
);

// ======================================================
// EXPORT
// ======================================================

module.exports = router;