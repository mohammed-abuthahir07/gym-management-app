const {
    createPromotion,
    findPromotionById,
    findPromotionByCode,
    getAllPromotions,
    updatePromotion,
    deletePromotion
} = require('../model/adminPromotionModel');

const validatePromotionData = async (
    {
        title,
        code,
        discount,
        discount_type,
        start_date,
        end_date
    },
    currentId = null
) => {
    if (
        !title ||
        !code ||
        discount === undefined ||
        discount === null ||
        !discount_type ||
        !start_date ||
        !end_date
    ) {
        return 'Title, code, discount, discount type, start date and end date are required';
    }

    if (!title.trim()) {
        return 'Title cannot be empty';
    }

    if (!code.trim()) {
        return 'Promotion code cannot be empty';
    }

    const allowedDiscountTypes = [
        'PERCENTAGE',
        'FIXED'
    ];

    if (!allowedDiscountTypes.includes(discount_type)) {
        return 'Discount type must be PERCENTAGE or FIXED';
    }

    if (
        isNaN(Number(discount)) ||
        Number(discount) < 0
    ) {
        return 'Discount must be a valid non-negative number';
    }

    if (
        discount_type === 'PERCENTAGE' &&
        Number(discount) > 100
    ) {
        return 'Percentage discount cannot exceed 100';
    }

    const startDate = new Date(start_date);
    const endDate = new Date(end_date);

    if (
        isNaN(startDate.getTime()) ||
        isNaN(endDate.getTime())
    ) {
        return 'Invalid start date or end date';
    }

    if (endDate <= startDate) {
        return 'End date must be after start date';
    }

    const existingPromotion =
        await findPromotionByCode(
            code.trim().toUpperCase()
        );

    if (
        existingPromotion &&
        String(existingPromotion.id) !== String(currentId)
    ) {
        return 'A promotion with this code already exists';
    }

    return null;
};


// CREATE PROMOTION
const createAdminPromotion = async (req, res) => {
    try {
        const {
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date
        } = req.body;

        const validationError =
            await validatePromotionData({
                title,
                code,
                discount,
                discount_type,
                start_date,
                end_date
            });

        if (validationError) {
            return res.status(400).json({
                success: false,
                message: validationError
            });
        }

        const promotionId =
            await createPromotion({
                title: title.trim(),
                code: code.trim().toUpperCase(),
                description: description
                    ? description.trim()
                    : null,
                discount: Number(discount),
                discount_type,
                start_date,
                end_date
            });

        const createdPromotion =
            await findPromotionById(
                promotionId
            );

        return res.status(201).json({
            success: true,
            message: 'Promotion created successfully',
            promotion: createdPromotion
        });

    } catch (error) {
        console.error(
            'Create promotion error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while creating promotion'
        });
    }
};


// GET ALL PROMOTIONS
const getPromotions = async (req, res) => {
    try {
        const promotions =
            await getAllPromotions();

        return res.status(200).json({
            success: true,
            message: 'Promotions fetched successfully',
            promotions
        });

    } catch (error) {
        console.error(
            'Get promotions error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching promotions'
        });
    }
};


// GET SINGLE PROMOTION
const getPromotion = async (req, res) => {
    try {
        const { id } = req.params;

        const promotion =
            await findPromotionById(id);

        if (!promotion) {
            return res.status(404).json({
                success: false,
                message: 'Promotion not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Promotion fetched successfully',
            promotion
        });

    } catch (error) {
        console.error(
            'Get promotion error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching promotion'
        });
    }
};


// UPDATE PROMOTION
const updateAdminPromotion = async (req, res) => {
    try {
        const { id } = req.params;

        const {
            title,
            code,
            description,
            discount,
            discount_type,
            start_date,
            end_date,
            status
        } = req.body;

        // Check promotion exists
        const existingPromotion =
            await findPromotionById(id);

        if (!existingPromotion) {
            return res.status(404).json({
                success: false,
                message: 'Promotion not found'
            });
        }

        // Validate data
        const validationError =
            await validatePromotionData(
                {
                    title,
                    code,
                    discount,
                    discount_type,
                    start_date,
                    end_date
                },
                id
            );

        if (validationError) {
            return res.status(400).json({
                success: false,
                message: validationError
            });
        }

        // Validate status
        const promotionStatus =
            status || existingPromotion.status;

        if (
            !['ACTIVE', 'INACTIVE']
                .includes(promotionStatus)
        ) {
            return res.status(400).json({
                success: false,
                message: 'Status must be ACTIVE or INACTIVE'
            });
        }

        await updatePromotion(
            id,
            {
                title: title.trim(),
                code: code.trim().toUpperCase(),
                description: description
                    ? description.trim()
                    : null,
                discount: Number(discount),
                discount_type,
                start_date,
                end_date,
                status: promotionStatus
            }
        );

        const updatedPromotion =
            await findPromotionById(id);

        return res.status(200).json({
            success: true,
            message: 'Promotion updated successfully',
            promotion: updatedPromotion
        });

    } catch (error) {
        console.error(
            'Update promotion error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while updating promotion'
        });
    }
};


// DELETE PROMOTION
const deleteAdminPromotion = async (req, res) => {
    try {
        const { id } = req.params;

        // Check promotion exists
        const existingPromotion =
            await findPromotionById(id);

        if (!existingPromotion) {
            return res.status(404).json({
                success: false,
                message: 'Promotion not found'
            });
        }

        await deletePromotion(id);

        return res.status(200).json({
            success: true,
            message: 'Promotion deleted successfully'
        });

    } catch (error) {
        console.error(
            'Delete promotion error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while deleting promotion'
        });
    }
};


module.exports = {
    createAdminPromotion,
    getPromotions,
    getPromotion,
    updateAdminPromotion,
    deleteAdminPromotion
};