const {
    checkMemberAssignedToTrainer,
    createDietPlan,
    getTrainerDietPlans,
    getTrainerDietPlanById,
    updateDietPlan,
    deleteDietPlan
} = require('../model/trainerDietPlanModel');


// Create diet entry
const assignDietPlan = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const {
            member_id,
            diet_day,
            meal_type,
            food_name,
            calories,
            protein,
            notes
        } = req.body;


        // Required fields
        if (
            !member_id ||
            !diet_day ||
            !meal_type ||
            !food_name ||
            calories === undefined ||
            protein === undefined
        ) {
            return res.status(400).json({
                success: false,
                message: 'member_id, diet_day, meal_type, food_name, calories and protein are required'
            });
        }


        // Validate calories
        if (Number(calories) < 0) {
            return res.status(400).json({
                success: false,
                message: 'Calories cannot be negative'
            });
        }


        // Validate protein
        if (Number(protein) < 0) {
            return res.status(400).json({
                success: false,
                message: 'Protein cannot be negative'
            });
        }


        // Validate day
        const validDays = [
            'MONDAY',
            'TUESDAY',
            'WEDNESDAY',
            'THURSDAY',
            'FRIDAY',
            'SATURDAY',
            'SUNDAY'
        ];

        if (!validDays.includes(diet_day)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid diet day'
            });
        }


        // Validate meal
        const validMeals = [
            'BREAKFAST',
            'LUNCH',
            'DINNER'
        ];

        if (!validMeals.includes(meal_type)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid meal type'
            });
        }


        // Check member assignment
        const assigned = await checkMemberAssignedToTrainer(
            member_id,
            trainerId
        );

        if (!assigned) {
            return res.status(403).json({
                success: false,
                message: 'This member is not assigned to you'
            });
        }


        // Create
        const dietPlanId = await createDietPlan(
            trainerId,
            member_id,
            diet_day,
            meal_type,
            food_name,
            calories,
            protein,
            notes
        );


        const dietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );


        return res.status(201).json({
            success: true,
            message: 'Diet plan assigned successfully',
            diet_plan: dietPlan
        });

    } catch (error) {

        console.error('Assign diet plan error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to assign diet plan'
        });
    }
};


// Get trainer diet plans
const getDietPlans = async (req, res) => {
    try {

        const trainerId = req.user.id;

        const dietPlans = await getTrainerDietPlans(trainerId);

        return res.status(200).json({
            success: true,
            count: dietPlans.length,
            diet_plans: dietPlans
        });

    } catch (error) {

        console.error('Get diet plans error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch diet plans'
        });
    }
};


// Get one diet plan
const getDietPlan = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const dietPlanId = req.params.id;

        const dietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );

        if (!dietPlan) {
            return res.status(404).json({
                success: false,
                message: 'Diet plan not found'
            });
        }

        return res.status(200).json({
            success: true,
            diet_plan: dietPlan
        });

    } catch (error) {

        console.error('Get diet plan error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch diet plan'
        });
    }
};


// Update diet plan
const editDietPlan = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const dietPlanId = req.params.id;

        const {
            diet_day,
            meal_type,
            food_name,
            calories,
            protein,
            notes
        } = req.body;


        if (
            !diet_day ||
            !meal_type ||
            !food_name ||
            calories === undefined ||
            protein === undefined
        ) {
            return res.status(400).json({
                success: false,
                message: 'diet_day, meal_type, food_name, calories and protein are required'
            });
        }


        const existingDietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );

        if (!existingDietPlan) {
            return res.status(404).json({
                success: false,
                message: 'Diet plan not found'
            });
        }


        const validDays = [
            'MONDAY',
            'TUESDAY',
            'WEDNESDAY',
            'THURSDAY',
            'FRIDAY',
            'SATURDAY',
            'SUNDAY'
        ];

        const validMeals = [
            'BREAKFAST',
            'LUNCH',
            'DINNER'
        ];


        if (!validDays.includes(diet_day)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid diet day'
            });
        }


        if (!validMeals.includes(meal_type)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid meal type'
            });
        }


        if (Number(calories) < 0 || Number(protein) < 0) {
            return res.status(400).json({
                success: false,
                message: 'Calories and protein cannot be negative'
            });
        }


        await updateDietPlan(
            dietPlanId,
            trainerId,
            diet_day,
            meal_type,
            food_name,
            calories,
            protein,
            notes
        );


        const updatedDietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );


        return res.status(200).json({
            success: true,
            message: 'Diet plan updated successfully',
            diet_plan: updatedDietPlan
        });

    } catch (error) {

        console.error('Update diet plan error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to update diet plan'
        });
    }
};


// Delete diet plan
const removeDietPlan = async (req, res) => {
    try {

        const trainerId = req.user.id;
        const dietPlanId = req.params.id;


        const existingDietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );

        if (!existingDietPlan) {
            return res.status(404).json({
                success: false,
                message: 'Diet plan not found'
            });
        }


        await deleteDietPlan(
            dietPlanId,
            trainerId
        );


        return res.status(200).json({
            success: true,
            message: 'Diet plan deleted successfully'
        });

    } catch (error) {

        console.error('Delete diet plan error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete diet plan'
        });
    }
};


module.exports = {
    assignDietPlan,
    getDietPlans,
    getDietPlan,
    editDietPlan,
    removeDietPlan
};