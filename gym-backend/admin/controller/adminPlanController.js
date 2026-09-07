const {
    createPlan,
    findPlanById,
    findPlanByName,
    getAllPlans
} = require('../model/adminPlanModel');

const createAdminPlan = async (req, res) => {
    try {
        const {
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features
        } = req.body;

        // Validate required fields
        if (
            !name ||
            duration_value === undefined ||
            duration_value === null ||
            !duration_unit ||
            price === undefined ||
            price === null
        ) {
            return res.status(400).json({
                success: false,
                message: 'Name, duration value, duration unit and price are required'
            });
        }

        // Validate duration
        if (
            !Number.isInteger(Number(duration_value)) ||
            Number(duration_value) <= 0
        ) {
            return res.status(400).json({
                success: false,
                message: 'Duration value must be a positive integer'
            });
        }

        // Validate duration unit
        const allowedDurationUnits = [
            'DAY',
            'MONTH',
            'YEAR'
        ];

        if (!allowedDurationUnits.includes(duration_unit)) {
            return res.status(400).json({
                success: false,
                message: 'Duration unit must be DAY, MONTH or YEAR'
            });
        }

        // Validate price
        if (
            isNaN(Number(price)) ||
            Number(price) < 0
        ) {
            return res.status(400).json({
                success: false,
                message: 'Price must be a valid non-negative number'
            });
        }

        // Extra features is free text
        if (
            extra_features !== undefined &&
            extra_features !== null &&
            typeof extra_features !== 'string'
        ) {
            return res.status(400).json({
                success: false,
                message: 'Extra features must be text'
            });
        }

        // Check duplicate plan name
        const existingPlan = await findPlanByName(
            name.trim()
        );

        if (existingPlan) {
            return res.status(409).json({
                success: false,
                message: 'A plan with this name already exists'
            });
        }

        // Create plan
        const planId = await createPlan({
            name: name.trim(),
            description: description || null,
            duration_value: Number(duration_value),
            duration_unit,
            price: Number(price),
            extra_features: extra_features
                ? extra_features.trim()
                : null
        });

        // Fetch created plan
        const createdPlan = await findPlanById(planId);

        return res.status(201).json({
            success: true,
            message: 'Plan created successfully',
            plan: createdPlan
        });

    } catch (error) {
        console.error(
            'Create admin plan error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while creating plan'
        });
    }
};

const getPlans = async (req, res) => {
    try {
        const plans = await getAllPlans();

        return res.status(200).json({
            success: true,
            message: 'Plans fetched successfully',
            plans
        });

    } catch (error) {
        console.error(
            'Get plans error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching plans'
        });
    }
};

const getPlan = async (req, res) => {
    try {
        const { id } = req.params;

        const plan = await findPlanById(id);

        if (!plan) {
            return res.status(404).json({
                success: false,
                message: 'Plan not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Plan fetched successfully',
            plan
        });

    } catch (error) {
        console.error(
            'Get plan error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Server error while fetching plan'
        });
    }
};

module.exports = {
    createAdminPlan,
    getPlans,
    getPlan
};