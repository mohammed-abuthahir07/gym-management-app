const contactModel = require('../model/contactModel');

const createContact = async (req, res) => {
    try {
        const {
            name,
            email,
            phone,
            message
        } = req.body;

        // Validation
        if (!name || !email || !message) {
            return res.status(400).json({
                success: false,
                message: 'Name, email and message are required'
            });
        }

        const result = await contactModel.createContact({
            name: name.trim(),
            email: email.trim(),
            phone: phone ? phone.trim() : null,
            message: message.trim()
        });

        return res.status(201).json({
            success: true,
            message: 'Enquiry sent successfully',
            data: {
                id: result.insertId
            }
        });

    } catch (error) {
        console.error('Create contact error:', error);

        return res.status(500).json({
            success: false,
            message: 'Failed to send enquiry'
        });
    }
};

module.exports = {
    createContact
};