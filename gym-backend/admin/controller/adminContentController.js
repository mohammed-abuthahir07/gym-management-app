const fs = require('fs');
const path = require('path');

const contentModel = require('../model/adminContentModel');


// ========================================
// CREATE CONTENT
// ========================================

const createContent = async (req, res) => {
    try {

        const {
            title,
            description
        } = req.body;

        if (!title || !description) {

            // Delete uploaded image if validation fails
            if (req.file) {
                fs.unlinkSync(req.file.path);
            }

            return res.status(400).json({
                success: false,
                message: 'Title and description are required'
            });
        }


        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: 'Image is required'
            });
        }


        const image = `/uploads/content/${req.file.filename}`;


        const result = await contentModel.createContent({
            title: title.trim(),
            image,
            description: description.trim()
        });


        return res.status(201).json({
            success: true,
            message: 'Content created successfully',
            data: {
                id: result.insertId,
                title: title.trim(),
                image,
                description: description.trim()
            }
        });

    } catch (error) {

        console.error('Create content error:', error);

        // Remove uploaded image if database operation fails
        if (req.file) {
            try {
                fs.unlinkSync(req.file.path);
            } catch (fileError) {
                console.error('Failed to remove uploaded image:', fileError);
            }
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to create content'
        });
    }
};


// ========================================
// GET ALL CONTENT
// ========================================

const getAllContent = async (req, res) => {
    try {

        const content = await contentModel.getAllContent();

        return res.status(200).json({
            success: true,
            data: content
        });

    } catch (error) {

        console.error('Get all content error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch content'
        });
    }
};


// ========================================
// GET CONTENT BY ID
// ========================================

const getContentById = async (req, res) => {
    try {

        const { id } = req.params;

        const content = await contentModel.getContentById(id);

        if (!content) {
            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }

        return res.status(200).json({
            success: true,
            data: content
        });

    } catch (error) {

        console.error('Get content by ID error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch content'
        });
    }
};


// ========================================
// UPDATE CONTENT
// ========================================

const updateContent = async (req, res) => {
    try {

        const { id } = req.params;

        const {
            title,
            description
        } = req.body;


        if (!title || !description) {

            if (req.file) {
                fs.unlinkSync(req.file.path);
            }

            return res.status(400).json({
                success: false,
                message: 'Title and description are required'
            });
        }


        const existingContent = await contentModel.getContentById(id);

        if (!existingContent) {

            if (req.file) {
                fs.unlinkSync(req.file.path);
            }

            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }


        // If Admin uploads a new image
        let image = existingContent.image;

        if (req.file) {

            image = `/uploads/content/${req.file.filename}`;


            // Delete old image
            const oldImagePath = path.join(
                __dirname,
                '../../',
                existingContent.image
            );

            if (fs.existsSync(oldImagePath)) {
                fs.unlinkSync(oldImagePath);
            }
        }


        await contentModel.updateContent(id, {
            title: title.trim(),
            image,
            description: description.trim()
        });


        return res.status(200).json({
            success: true,
            message: 'Content updated successfully'
        });

    } catch (error) {

        console.error('Update content error:', error);

        if (req.file) {
            try {
                fs.unlinkSync(req.file.path);
            } catch (fileError) {
                console.error('Failed to remove uploaded image:', fileError);
            }
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to update content'
        });
    }
};


// ========================================
// DELETE CONTENT
// ========================================

const deleteContent = async (req, res) => {
    try {

        const { id } = req.params;

        const existingContent = await contentModel.getContentById(id);

        if (!existingContent) {
            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }


        const result = await contentModel.deleteContent(id);


        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Content not found'
            });
        }


        // Delete image from server
        if (existingContent.image) {

            const imagePath = path.join(
                __dirname,
                '../../',
                existingContent.image
            );

            if (fs.existsSync(imagePath)) {
                fs.unlinkSync(imagePath);
            }
        }


        return res.status(200).json({
            success: true,
            message: 'Content deleted successfully'
        });

    } catch (error) {

        console.error('Delete content error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete content'
        });
    }
};


module.exports = {
    createContent,
    getAllContent,
    getContentById,
    updateContent,
    deleteContent
};