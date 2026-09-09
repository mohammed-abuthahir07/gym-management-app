const {
    getMemberFees,
    getMemberFeeById,
    getCurrentMonthFeeStatus,
    getMemberPaidFeeHistory
} = require('../model/memberFeeModel');

// Get logged-in member's complete fee history
const getMyFees = async (req, res) => {
    try {
        const memberId = req.user.id;

        const fees = await getMemberFees(memberId);

        return res.status(200).json({
            success: true,
            count: fees.length,
            fees
        });

    } catch (error) {
        console.error('Get member fees error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch fee history'
        });
    }
};


// Get one fee
const getMyFee = async (req, res) => {
    try {
        const memberId = req.user.id;
        const feeId = req.params.id;

        const fee = await getMemberFeeById(feeId, memberId);

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
        console.error('Get member fee error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch fee details'
        });
    }
};


const getMyCurrentMonthFeeStatus = async (req, res) => {
    try {
        const memberId = req.user.id;

        const fee = await getCurrentMonthFeeStatus(memberId);

        const currentMonth = new Date().toLocaleString('en-US', {
            month: 'long'
        });

        const currentYear = new Date().getFullYear();

        // No fee record for current month
        if (!fee) {
            return res.status(200).json({
                success: true,
                month: currentMonth,
                year: currentYear,
                payment_status: 'UNPAID',
                paid: false,
                fee: null
            });
        }

        // Fee exists and is PAID
        if (fee.payment_status === 'PAID') {
            return res.status(200).json({
                success: true,
                month: currentMonth,
                year: currentYear,
                payment_status: 'PAID',
                paid: true,
                fee
            });
        }

        // Fee exists but is UNPAID
        return res.status(200).json({
            success: true,
            month: currentMonth,
            year: currentYear,
            payment_status: 'UNPAID',
            paid: false,
            fee
        });

    } catch (error) {
        console.error('Get current month fee status error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month fee status'
        });
    }
};

const getMyPaidFeeHistory = async (req, res) => {
    try {
        const memberId = req.user.id;

        const fees = await getMemberPaidFeeHistory(memberId);

        return res.status(200).json({
            success: true,
            count: fees.length,
            fees
        });

    } catch (error) {
        console.error('Get member paid fee history error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch paid fee history'
        });
    }
};


module.exports = {
    getMyFees,
    getMyFee,
    getMyCurrentMonthFeeStatus,
    getMyPaidFeeHistory
};