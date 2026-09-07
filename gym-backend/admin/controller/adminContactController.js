const adminContactModel = require('../model/adminContactModel');


// GET ALL CONTACTS
const getAllContacts = async (req, res) => {
    try {
        const contacts = await adminContactModel.getAllContacts();

        return res.status(200).json({
            success: true,
            data: contacts
        });

    } catch (error) {
        console.error('Get contacts error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch contact enquiries'
        });
    }
};


// GET SINGLE CONTACT
// When Admin opens it, status becomes READ
const getContactById = async (req, res) => {
    try {
        const { id } = req.params;

        const contact = await adminContactModel.getContactById(id);

        if (!contact) {
            return res.status(404).json({
                success: false,
                message: 'Contact enquiry not found'
            });
        }

        // Change NEW → READ when Admin opens the enquiry
        if (contact.status === 'NEW') {
            await adminContactModel.markContactAsRead(id);
            contact.status = 'READ';
        }

        return res.status(200).json({
            success: true,
            data: contact
        });

    } catch (error) {
        console.error('Get contact by ID error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to fetch contact enquiry'
        });
    }
};


// DELETE CONTACT
const deleteContact = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await adminContactModel.deleteContact(id);

        if (result.affectedRows === 0) {
            return res.status(404).json({
                success: false,
                message: 'Contact enquiry not found'
            });
        }

        return res.status(200).json({
            success: true,
            message: 'Contact enquiry deleted successfully'
        });

    } catch (error) {
        console.error('Delete contact error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to delete contact enquiry'
        });
    }
};


module.exports = {
    getAllContacts,
    getContactById,
    deleteContact
};