const fs = require('fs');
const path = require('path');

const contentModel = require('../model/adminContentModel');

// ======================================================
// HELPER - DELETE FILE SAFELY
// ======================================================

const deleteFileIfExists = (filePath) => {

    if (!filePath) {
        return;
    }

    try {

        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }

    } catch (error) {

        console.error(
            'Failed to delete file:',
            error
        );
    }
};

// ======================================================
// HELPER - GET UPLOADED IMAGE PATH
// ======================================================

const getUploadedImagePath = (filename) => {

    if (!filename) {
        return null;
    }

    return path.join(
        __dirname,
        '../../uploads/content',
        filename
    );
};

// ======================================================
// HELPER - GET OLD IMAGE PATH FROM DATABASE VALUE
// ======================================================

const getOldImagePath = (image) => {

    if (!image) {
        return null;
    }

    const filename = path.basename(image);

    return getUploadedImagePath(filename);
};

// ======================================================
// HELPER - VALIDATE CONTENT ID
// ======================================================

const isValidId = (id) => {

    return (
        /^\d+$/.test(String(id)) &&
        Number(id) > 0
    );
};

// ======================================================
// CREATE CONTENT
// ======================================================

const createContent = async (req, res) => {

    try {

        const title = req.body?.title;
        const description = req.body?.description;

        // --------------------------------------------------
        // Validate title and description
        // --------------------------------------------------

        if (
            typeof title !== 'string' ||
            !title.trim() ||
            typeof description !== 'string' ||
            !description.trim()
        ) {

            if (req.file) {
                deleteFileIfExists(req.file.path);
            }

            return res.status(400).json({
                success: false,
                message: 'Title and description are required'
            });
        }

        // --------------------------------------------------
        // Validate image
        // --------------------------------------------------

        if (!req.file) {

            return res.status(400).json({
                success: false,
                message: 'Image is required'
            });
        }

        const cleanTitle = title.trim();

        const cleanDescription =
            description.trim();

        const image =
            `/uploads/content/${req.file.filename}`;

        // --------------------------------------------------
        // Create database record
        // --------------------------------------------------

        const result =
            await contentModel.createContent({
                title: cleanTitle,
                image,
                description: cleanDescription
            });

        // --------------------------------------------------
        // Success
        // --------------------------------------------------

        return res.status(201).json({

            success: true,

            message: 'Content created successfully',

            data: {
                id: result.insertId,
                title: cleanTitle,
                image,
                description: cleanDescription
            }

        });

    } catch (error) {

        console.error(
            'Create content error:',
            error
        );

        // --------------------------------------------------
        // Remove uploaded file if database operation fails
        // --------------------------------------------------

        if (req.file) {
            deleteFileIfExists(req.file.path);
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to create content'
        });
    }
};

// ======================================================
// GET ALL CONTENT
// ======================================================

const getAllContent = async (req, res) => {

    try {

        const content =
            await contentModel.getAllContent();

        return res.status(200).json({

            success: true,

            data: content

        });

    } catch (error) {

        console.error(
            'Get all content error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch content'
        });
    }
};

// ======================================================
// GET CONTENT BY ID
// ======================================================

const getContentById = async (req, res) => {

    try {

        const { id } = req.params;

        // --------------------------------------------------
        // Validate ID
        // --------------------------------------------------

        if (!isValidId(id)) {

            return res.status(400).json({
                success: false,
                message: 'Invalid content ID'
            });
        }

        const content =
            await contentModel.getContentById(id);

        // --------------------------------------------------
        // Not found
        // --------------------------------------------------

        if (!content) {

            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        // --------------------------------------------------
        // Success
        // --------------------------------------------------

        return res.status(200).json({

            success: true,

            data: content

        });

    } catch (error) {

        console.error(
            'Get content by ID error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch content'
        });
    }
};

// ======================================================
// UPDATE CONTENT
// ======================================================

const updateContent = async (req, res) => {

    try {

        const { id } = req.params;

        const title = req.body?.title;

        const description =
            req.body?.description;

        // --------------------------------------------------
        // Validate ID
        // --------------------------------------------------

        if (!isValidId(id)) {

            if (req.file) {
                deleteFileIfExists(req.file.path);
            }

            return res.status(400).json({
                success: false,
                message: 'Invalid content ID'
            });
        }

        // --------------------------------------------------
        // Validate title and description
        // --------------------------------------------------

        if (
            typeof title !== 'string' ||
            !title.trim() ||
            typeof description !== 'string' ||
            !description.trim()
        ) {

            if (req.file) {
                deleteFileIfExists(req.file.path);
            }

            return res.status(400).json({
                success: false,
                message: 'Title and description are required'
            });
        }

        // --------------------------------------------------
        // Find existing content
        // --------------------------------------------------

        const existingContent =
            await contentModel.getContentById(id);

        if (!existingContent) {

            if (req.file) {
                deleteFileIfExists(req.file.path);
            }

            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        const cleanTitle = title.trim();

        const cleanDescription =
            description.trim();

        // --------------------------------------------------
        // Keep old image by default
        // --------------------------------------------------

        let image =
            existingContent.image;

        // --------------------------------------------------
        // New image uploaded
        // --------------------------------------------------

        if (req.file) {

            const newImage =
                `/uploads/content/${req.file.filename}`;

            const oldImagePath =
                getOldImagePath(
                    existingContent.image
                );

            // --------------------------------------------------
            // Update database first
            // --------------------------------------------------

            const result =
                await contentModel.updateContent(
                    id,
                    {
                        title: cleanTitle,
                        image: newImage,
                        description: cleanDescription
                    }
                );

            // --------------------------------------------------
            // Verify database update
            // --------------------------------------------------

            if (result.affectedRows === 0) {

                deleteFileIfExists(
                    req.file.path
                );

                return res.status(404).json({
                    success: false,
                    message: 'Content not found'
                });
            }

            image = newImage;

            // --------------------------------------------------
            // Delete old image only after DB success
            // --------------------------------------------------

            if (
                oldImagePath &&
                oldImagePath !== req.file.path
            ) {

                deleteFileIfExists(
                    oldImagePath
                );
            }

        } else {

            // --------------------------------------------------
            // No new image
            // Keep old image
            // --------------------------------------------------

            const result =
                await contentModel.updateContent(
                    id,
                    {
                        title: cleanTitle,
                        image,
                        description: cleanDescription
                    }
                );

            if (result.affectedRows === 0) {

                return res.status(404).json({
                    success: false,
                    message: 'Content not found'
                });
            }
        }

        // --------------------------------------------------
        // Success
        // --------------------------------------------------

        return res.status(200).json({

            success: true,

            message: 'Content updated successfully',

            data: {
                id: Number(id),
                title: cleanTitle,
                image,
                description: cleanDescription
            }

        });

    } catch (error) {

        console.error(
            'Update content error:',
            error
        );

        // --------------------------------------------------
        // Remove new uploaded file if DB update failed
        // --------------------------------------------------

        if (req.file) {
            deleteFileIfExists(req.file.path);
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to update content'
        });
    }
};

// ======================================================
// DELETE CONTENT
// ======================================================

const deleteContent = async (req, res) => {

    try {

        const { id } = req.params;

        // --------------------------------------------------
        // Validate ID
        // --------------------------------------------------

        if (!isValidId(id)) {

            return res.status(400).json({
                success: false,
                message: 'Invalid content ID'
            });
        }

        // --------------------------------------------------
        // Find existing content
        // --------------------------------------------------

        const existingContent =
            await contentModel.getContentById(id);

        if (!existingContent) {

            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        // --------------------------------------------------
        // Delete database record
        // --------------------------------------------------

        const result =
            await contentModel.deleteContent(id);

        if (result.affectedRows === 0) {

            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        // --------------------------------------------------
        // Delete physical image
        // --------------------------------------------------

        if (existingContent.image) {

            const imagePath =
                getOldImagePath(
                    existingContent.image
                );

            deleteFileIfExists(imagePath);
        }

        // --------------------------------------------------
        // Success
        // --------------------------------------------------

        return res.status(200).json({

            success: true,

            message: 'Content deleted successfully'

        });

    } catch (error) {

        console.error(
            'Delete content error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to delete content'
        });
    }
};

// ======================================================
// EXPORT
// ======================================================

module.exports = {
    createContent,
    getAllContent,
    getContentById,
    updateContent,
    deleteContent
};