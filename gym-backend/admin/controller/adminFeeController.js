const {
    createFee,
    getAllFees,
    getMemberFeeHistory,
    getFeeById,
    updateFee,
    deleteFee,
    getCurrentMonthFeeStatus
} = require('../model/adminFeeModel');


// Create Fee
const createAdminFee = async (req, res) => {
    try {
        const {
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        } = req.body;

        if (
            !member_id ||
            !member_name ||
            !member_email ||
            !fee_amount ||
            !fee_date ||
            !fee_month ||
            !fee_year ||
            !payment_status
        ) {
            return res.status(400).json({
                success: false,
                message: 'Required fee fields are missing'
            });
        }

        if (Number(fee_amount) < 0) {
            return res.status(400).json({
                success: false,
                message: 'Fee amount cannot be negative'
            });
        }

        const feeId = await createFee(
            member_id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        );

        return res.status(201).json({
            success: true,
            message: 'Fee created successfully',
            fee_id: feeId
        });

    } catch (error) {
        console.error('Create admin fee error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to create fee'
        });
    }
};


// Get all fees
const getAdminFees = async (req, res) => {
    try {
        const fees = await getAllFees();

        return res.status(200).json({
            success: true,
            count: fees.length,
            fees
        });

    } catch (error) {
        console.error('Get admin fees error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch fees'
        });
    }
};


// Get one member's complete fee history
const getAdminMemberFeeHistory = async (req, res) => {
    try {
        const { memberId } = req.params;

        const fees = await getMemberFeeHistory(memberId);

        return res.status(200).json({
            success: true,
            member_id: Number(memberId),
            count: fees.length,
            fees
        });

    } catch (error) {
        console.error('Get member fee history error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch member fee history'
        });
    }
};


// Get one fee
const getAdminFee = async (req, res) => {
    try {
        const { id } = req.params;

        const fee = await getFeeById(id);

        if (!fee) {
            return res.status(404).json({
                success: false,
                message: 'Fee not found'
            });
        }

        return res.status(200).json({
            success: true,
            fee
        });

    } catch (error) {
        console.error('Get admin fee error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch fee'
        });
    }
};


// Update fee
const updateAdminFee = async (req, res) => {
    try {
        const { id } = req.params;

        const {
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        } = req.body;

        if (
            !member_name ||
            !member_email ||
            !fee_amount ||
            !fee_date ||
            !fee_month ||
            !fee_year ||
            !payment_status
        ) {
            return res.status(400).json({
                success: false,
                message: 'Required fee fields are missing'
            });
        }

        if (Number(fee_amount) < 0) {
            return res.status(400).json({
                success: false,
                message: 'Fee amount cannot be negative'
            });
        }

        const existingFee = await getFeeById(id);

        if (!existingFee) {
            return res.status(404).json({
                success: false,
                message: 'Fee not found'
            });
        }

        const affectedRows = await updateFee(
            id,
            member_name,
            member_email,
            fitness_goal,
            fee_amount,
            fee_date,
            fee_month,
            fee_year,
            payment_status
        );

        if (affectedRows === 0) {
            return res.status(400).json({
                success: false,
                message: 'Fee was not updated'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Fee updated successfully'
        });

    } catch (error) {
        console.error('Update admin fee error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to update fee'
        });
    }
};


// Delete fee
const deleteAdminFee = async (req, res) => {
    try {
        const { id } = req.params;

        const existingFee = await getFeeById(id);

        if (!existingFee) {
            return res.status(404).json({
                success: false,
                message: 'Fee not found'
            });
        }

        await deleteFee(id);

        return res.status(200).json({
            success: true,
            message: 'Fee deleted successfully'
        });

    } catch (error) {
        console.error('Delete admin fee error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete fee'
        });
    }
};

const getAdminCurrentMonthFeeStatus = async (req, res) => {
    try {
        const members = await getCurrentMonthFeeStatus();

        const currentMonth = new Date().toLocaleString('en-US', {
            month: 'long'
        }).toUpperCase();

        const currentYear = new Date().getFullYear();

        const paidCount = members.filter(
            member => member.payment_status === 'PAID'
        ).length;

        const unpaidCount = members.filter(
            member => member.payment_status === 'UNPAID'
        ).length;

        return res.status(200).json({
            success: true,
            month: currentMonth,
            year: currentYear,
            total_members: members.length,
            paid: paidCount,
            unpaid: unpaidCount,
            members
        });

    } catch (error) {
        console.error(
            'Get admin current month fee status error:',
            error
        );

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month fee status'
        });
    }
};


module.exports = {
    createAdminFee,
    getAdminFees,
    getAdminMemberFeeHistory,
    getAdminFee,
    updateAdminFee,
    deleteAdminFee,
    getAdminCurrentMonthFeeStatus
};