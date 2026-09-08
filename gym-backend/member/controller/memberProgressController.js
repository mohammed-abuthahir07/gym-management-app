const memberProgressModel = require('../model/memberProgressModel');

// =====================================================
// CREATE PROGRESS
// =====================================================

const createProgress = async (req, res) => {
    try {
        const memberId = req.user.id;

        const {
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes
        } = req.body;

        // Validate date
        if (!progress_date) {
            return res.status(400).json({
                success: false,
                message: 'Progress date is required'
            });
        }

        const progressId = await memberProgressModel.createProgress(
            memberId,
            progress_date,
            weight ?? null,
            body_fat ?? null,
            waist_cm ?? null,
            arms_cm ?? null,
            notes ?? null
        );

        return res.status(201).json({
            success: true,
            message: 'Progress created successfully',
            progress: {
                id: progressId,
                progress_date,
                weight: weight ?? null,
                body_fat: body_fat ?? null,
                waist_cm: waist_cm ?? null,
                arms_cm: arms_cm ?? null,
                notes: notes ?? null
            }
        });

    } catch (error) {
        console.error('Create progress error:', error);

        // Duplicate date
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                success: false,
                message: 'Progress already exists for this date'
            });
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to create progress'
        });
    }
};


// =====================================================
// GET ALL OWN PROGRESS
// =====================================================

const getAllProgress = async (req, res) => {
    try {
        const memberId = req.user.id;

        const progress = await memberProgressModel.getAllProgress(memberId);

        return res.status(200).json({
            success: true,
            message: 'Progress fetched successfully',
            progress
        });

    } catch (error) {
        console.error('Get all progress error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch progress'
        });
    }
};


// =====================================================
// GET SINGLE OWN PROGRESS
// =====================================================

const getProgress = async (req, res) => {
    try {
        const memberId = req.user.id;
        const progressId = req.params.id;

        const progress = await memberProgressModel.getProgressById(
            progressId,
            memberId
        );

        if (!progress) {
            return res.status(404).json({
                success: false,
                message: 'Progress not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Progress fetched successfully',
            progress
        });

    } catch (error) {
        console.error('Get progress error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch progress'
        });
    }
};


// =====================================================
// UPDATE OWN PROGRESS
// =====================================================

const updateProgress = async (req, res) => {
    try {
        const memberId = req.user.id;
        const progressId = req.params.id;

        const {
            progress_date,
            weight,
            body_fat,
            waist_cm,
            arms_cm,
            notes
        } = req.body;

        // Validate date
        if (!progress_date) {
            return res.status(400).json({
                success: false,
                message: 'Progress date is required'
            });
        }

        // First check ownership
        const existingProgress =
            await memberProgressModel.getProgressById(
                progressId,
                memberId
            );

        if (!existingProgress) {
            return res.status(404).json({
                success: false,
                message: 'Progress not found'
            });
        }

        await memberProgressModel.updateProgress(
            progressId,
            memberId,
            progress_date,
            weight ?? null,
            body_fat ?? null,
            waist_cm ?? null,
            arms_cm ?? null,
            notes ?? null
        );

        const updatedProgress =
            await memberProgressModel.getProgressById(
                progressId,
                memberId
            );

        return res.status(200).json({
            success: true,
            message: 'Progress updated successfully',
            progress: updatedProgress
        });

    } catch (error) {
        console.error('Update progress error:', error);

        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(409).json({
                success: false,
                message: 'Progress already exists for this date'
            });
        }

        return res.status(500).json({
            success: false,
            message: 'Failed to update progress'
        });
    }
};


// =====================================================
// DELETE OWN PROGRESS
// =====================================================

const deleteProgress = async (req, res) => {
    try {
        const memberId = req.user.id;
        const progressId = req.params.id;

        // Check ownership first
        const existingProgress =
            await memberProgressModel.getProgressById(
                progressId,
                memberId
            );

        if (!existingProgress) {
            return res.status(404).json({
                success: false,
                message: 'Progress not found'
            });
        }

        await memberProgressModel.deleteProgress(
            progressId,
            memberId
        );

        return res.status(200).json({
            success: true,
            message: 'Progress deleted successfully'
        });

    } catch (error) {
        console.error('Delete progress error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete progress'
        });
    }
};


module.exports = {
    createProgress,
    getAllProgress,
    getProgress,
    updateProgress,
    deleteProgress
};