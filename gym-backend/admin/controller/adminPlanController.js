const {
    createPlan,
    findPlanById,
    findPlanByName,
    findPlanByNameExceptId,
    getAllPlans,
    updatePlan,
    deletePlan
} = require('../model/adminPlanModel');


// ======================================================
// CREATE PLAN
// ======================================================

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
                message:
                    'Name, duration value, duration unit and price are required'
            });
        }


        const trimmedName = String(name).trim();


        if (!trimmedName) {
            return res.status(400).json({
                success: false,
                message: 'Plan name is required'
            });
        }


        // Validate duration
        if (
            !Number.isInteger(Number(duration_value)) ||
            Number(duration_value) <= 0
        ) {
            return res.status(400).json({
                success: false,
                message:
                    'Duration value must be a positive integer'
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
                message:
                    'Duration unit must be DAY, MONTH or YEAR'
            });
        }


        // Validate price
        if (
            isNaN(Number(price)) ||
            Number(price) < 0
        ) {
            return res.status(400).json({
                success: false,
                message:
                    'Price must be a valid non-negative number'
            });
        }


        // Validate description
        if (
            description !== undefined &&
            description !== null &&
            typeof description !== 'string'
        ) {
            return res.status(400).json({
                success: false,
                message: 'Description must be text'
            });
        }


        // Validate extra features
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


        // Check duplicate name
        const existingPlan = await findPlanByName(
            trimmedName
        );


        if (existingPlan) {
            return res.status(409).json({
                success: false,
                message:
                    'A plan with this name already exists'
            });
        }


        // Create
        const planId = await createPlan({
            name: trimmedName,
            description:
                description && description.trim()
                    ? description.trim()
                    : null,
            duration_value: Number(duration_value),
            duration_unit,
            price: Number(price),
            extra_features:
                extra_features && extra_features.trim()
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
            message:
                'Server error while creating plan'
        });
    }
};


// ======================================================
// GET ALL PLANS
// ======================================================

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
            message:
                'Server error while fetching plans'
        });
    }
};


// ======================================================
// GET SINGLE PLAN
// ======================================================

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
            message:
                'Server error while fetching plan'
        });
    }
};


// ======================================================
// UPDATE PLAN
// ======================================================

const updateAdminPlan = async (req, res) => {
    try {
        const { id } = req.params;


        // Find existing plan
        const existingPlan = await findPlanById(id);


        if (!existingPlan) {
            return res.status(404).json({
                success: false,
                message: 'Plan not found'
            });
        }


        const {
            name,
            description,
            duration_value,
            duration_unit,
            price,
            extra_features,
            status
        } = req.body;


        // Keep existing values when omitted
        const updatedName =
            name !== undefined
                ? String(name).trim()
                : existingPlan.name;


        const updatedDescription =
            description !== undefined
                ? (
                    description === null ||
                    description === ''
                        ? null
                        : String(description).trim()
                )
                : existingPlan.description;


        const updatedDurationValue =
            duration_value !== undefined
                ? Number(duration_value)
                : Number(existingPlan.duration_value);


        const updatedDurationUnit =
            duration_unit !== undefined
                ? duration_unit
                : existingPlan.duration_unit;


        const updatedPrice =
            price !== undefined
                ? Number(price)
                : Number(existingPlan.price);


        const updatedExtraFeatures =
            extra_features !== undefined
                ? (
                    extra_features === null ||
                    extra_features === ''
                        ? null
                        : String(extra_features).trim()
                )
                : existingPlan.extra_features;


        const updatedStatus =
            status !== undefined
                ? status
                : existingPlan.status;


        // Validate name
        if (!updatedName) {
            return res.status(400).json({
                success: false,
                message: 'Plan name is required'
            });
        }


        // Validate duration
        if (
            !Number.isInteger(updatedDurationValue) ||
            updatedDurationValue <= 0
        ) {
            return res.status(400).json({
                success: false,
                message:
                    'Duration value must be a positive integer'
            });
        }


        // Validate duration unit
        const allowedDurationUnits = [
            'DAY',
            'MONTH',
            'YEAR'
        ];


        if (!allowedDurationUnits.includes(updatedDurationUnit)) {
            return res.status(400).json({
                success: false,
                message:
                    'Duration unit must be DAY, MONTH or YEAR'
            });
        }


        // Validate price
        if (
            isNaN(updatedPrice) ||
            updatedPrice < 0
        ) {
            return res.status(400).json({
                success: false,
                message:
                    'Price must be a valid non-negative number'
            });
        }


        // Validate description
        if (
            description !== undefined &&
            description !== null &&
            typeof description !== 'string'
        ) {
            return res.status(400).json({
                success: false,
                message: 'Description must be text'
            });
        }


        // Validate extra features
        if (
            extra_features !== undefined &&
            extra_features !== null &&
            typeof extra_features !== 'string'
        ) {
            return res.status(400).json({
                success: false,
                message:
                    'Extra features must be text'
            });
        }


        // Validate status
        const allowedStatuses = [
            'ACTIVE',
            'INACTIVE'
        ];


        if (!allowedStatuses.includes(updatedStatus)) {
            return res.status(400).json({
                success: false,
                message:
                    'Status must be ACTIVE or INACTIVE'
            });
        }


        // Check duplicate name
        const duplicatePlan =
            await findPlanByNameExceptId(
                updatedName,
                id
            );


        if (duplicatePlan) {
            return res.status(409).json({
                success: false,
                message:
                    'A plan with this name already exists'
            });
        }


        // Update
        await updatePlan({
            id,
            name: updatedName,
            description: updatedDescription,
            duration_value: updatedDurationValue,
            duration_unit: updatedDurationUnit,
            price: updatedPrice,
            extra_features: updatedExtraFeatures,
            status: updatedStatus
        });


        // Fetch updated plan
        const updatedPlan = await findPlanById(id);


        return res.status(200).json({
            success: true,
            message: 'Plan updated successfully',
            plan: updatedPlan
        });

    } catch (error) {
        console.error(
            'Update admin plan error:',
            error
        );

        return res.status(500).json({
            success: false,
            message:
                'Server error while updating plan'
        });
    }
};


// ======================================================
// DELETE PLAN - PERMANENT DELETE
// ======================================================

const deleteAdminPlan = async (req, res) => {
    try {
        const { id } = req.params;


        // Check plan exists
        const existingPlan = await findPlanById(id);


        if (!existingPlan) {
            return res.status(404).json({
                success: false,
                message: 'Plan not found'
            });
        }


        // PERMANENT DELETE
        const result = await deletePlan(id);


        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Plan not found'
            });
        }


        return res.status(200).json({
            success: true,
            message: 'Plan deleted permanently'
        });

    } catch (error) {
        console.error(
            'Delete admin plan error:',
            error
        );


        return res.status(500).json({
            success: false,
            message:
                'Server error while deleting plan'
        });
    }
};


module.exports = {
    createAdminPlan,
    getPlans,
    getPlan,
    updateAdminPlan,
    deleteAdminPlan
};