const {
    getCurrentMonthRevenue,
    getCurrentYearRevenue,
    getTotalRevenue,
    getCurrentMonthCheckIns,
    getCurrentYearCheckIns,
    getCurrentMonthUnpaidMembers
} = require('../model/adminReportModel');


// ==========================================
// CURRENT MONTH REVENUE
// ==========================================

const getAdminCurrentMonthRevenue = async (req, res) => {
    try {
        const revenue = await getCurrentMonthRevenue();

        const month = new Date()
            .toLocaleString('en-US', { month: 'long' })
            .toUpperCase();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            revenue
        });

    } catch (error) {
        console.error('Current month revenue error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month revenue'
        });
    }
};


// ==========================================
// CURRENT YEAR REVENUE
// ==========================================

const getAdminCurrentYearRevenue = async (req, res) => {
    try {
        const revenue = await getCurrentYearRevenue();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            year,
            revenue
        });

    } catch (error) {
        console.error('Current year revenue error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current year revenue'
        });
    }
};


// ==========================================
// TOTAL REVENUE
// ==========================================

const getAdminTotalRevenue = async (req, res) => {
    try {
        const revenue = await getTotalRevenue();

        return res.status(200).json({
            success: true,
            revenue
        });

    } catch (error) {
        console.error('Total revenue error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch total revenue'
        });
    }
};


// ==========================================
// CURRENT MONTH CHECK-INS
// ==========================================

const getAdminCurrentMonthCheckIns = async (req, res) => {
    try {
        const members = await getCurrentMonthCheckIns();

        const totalCheckInDays = members.reduce(
            (total, member) => total + Number(member.check_in_days),
            0
        );

        const month = new Date()
            .toLocaleString('en-US', { month: 'long' })
            .toUpperCase();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            total_check_in_days: totalCheckInDays,
            members
        });

    } catch (error) {
        console.error('Current month check-ins error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month check-ins'
        });
    }
};


// ==========================================
// CURRENT YEAR CHECK-INS
// ==========================================

const getAdminCurrentYearCheckIns = async (req, res) => {
    try {
        const members = await getCurrentYearCheckIns();

        const totalCheckInDays = members.reduce(
            (total, member) => total + Number(member.check_in_days),
            0
        );

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            year,
            total_check_in_days: totalCheckInDays,
            members
        });

    } catch (error) {
        console.error('Current year check-ins error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current year check-ins'
        });
    }
};


// ==========================================
// CURRENT MONTH UNPAID MEMBERS
// ==========================================

const getAdminCurrentMonthUnpaid = async (req, res) => {
    try {
        const members = await getCurrentMonthUnpaidMembers();

        const month = new Date()
            .toLocaleString('en-US', { month: 'long' })
            .toUpperCase();

        const year = new Date().getFullYear();

        return res.status(200).json({
            success: true,
            month,
            year,
            count: members.length,
            members
        });

    } catch (error) {
        console.error('Current month unpaid members error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch current month unpaid members'
        });
    }
};


module.exports = {
    getAdminCurrentMonthRevenue,
    getAdminCurrentYearRevenue,
    getAdminTotalRevenue,
    getAdminCurrentMonthCheckIns,
    getAdminCurrentYearCheckIns,
    getAdminCurrentMonthUnpaid
};