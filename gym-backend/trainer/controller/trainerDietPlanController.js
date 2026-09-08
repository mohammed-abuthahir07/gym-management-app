const {
    checkMemberAssignedToTrainer,
    createDietPlan,
    getTrainerDietPlans,
    getTrainerDietPlanById
} = require('../model/trainerDietPlanModel');


const assignDietPlan = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const {
            member_id,
            title,
            plan_name,
            daily_calories,
            daily_protein,
            cheat_days_per_week
        } = req.body;


        // Required field validation
        if (
            !member_id ||
            !title ||
            !plan_name ||
            daily_calories === undefined ||
            daily_protein === undefined ||
            cheat_days_per_week === undefined
        ) {
            return res.status(400).json({
                message: 'All diet plan fields are required'
            });
        }


        // Validate calories
        if (
            !Number.isInteger(Number(daily_calories)) ||
            Number(daily_calories) <= 0
        ) {
            return res.status(400).json({
                message: 'Daily calories must be a positive number'
            });
        }


        // Validate protein
        if (
            Number(daily_protein) <= 0
        ) {
            return res.status(400).json({
                message: 'Daily protein must be greater than 0'
            });
        }


        // Validate cheat days
        if (
            !Number.isInteger(Number(cheat_days_per_week)) ||
            Number(cheat_days_per_week) < 0 ||
            Number(cheat_days_per_week) > 7
        ) {
            return res.status(400).json({
                message: 'Cheat days per week must be between 0 and 7'
            });
        }


        // Check member belongs to this trainer
        const member = await checkMemberAssignedToTrainer(
            member_id,
            trainerId
        );

        if (!member) {
            return res.status(404).json({
                message: 'Member not found or not assigned to you'
            });
        }


        // Member must be active
        if (member.status !== 'ACTIVE') {
            return res.status(400).json({
                message: 'Member is not active'
            });
        }


        const dietPlanId = await createDietPlan(
            trainerId,
            member_id,
            title.trim(),
            plan_name.trim(),
            Number(daily_calories),
            Number(daily_protein),
            Number(cheat_days_per_week)
        );


        const dietPlan = await getTrainerDietPlanById(
            dietPlanId,
            trainerId
        );


        return res.status(201).json({
            message: 'Diet plan assigned successfully',
            diet_plan: dietPlan
        });

    } catch (error) {
        console.error('Assign diet plan error:', error);

        return res.status(500).json({
            message: 'Failed to assign diet plan'
        });
    }
};


const getDietPlans = async (req, res) => {
    try {
        const trainerId = req.user.id;

        const plans = await getTrainerDietPlans(trainerId);

        return res.status(200).json({
            count: plans.length,
            diet_plans: plans
        });

    } catch (error) {
        console.error('Get trainer diet plans error:', error);

        return res.status(500).json({
            message: 'Failed to get diet plans'
        });
    }
};


const getDietPlan = async (req, res) => {
    try {
        const trainerId = req.user.id;
        const planId = req.params.id;

        const dietPlan = await getTrainerDietPlanById(
            planId,
            trainerId
        );

        if (!dietPlan) {
            return res.status(404).json({
                message: 'Diet plan not found'
            });
        }

        return res.status(200).json(dietPlan);

    } catch (error) {
        console.error('Get trainer diet plan error:', error);

        return res.status(500).json({
            message: 'Failed to get diet plan'
        });
    }
};


module.exports = {
    assignDietPlan,
    getDietPlans,
    getDietPlan
};