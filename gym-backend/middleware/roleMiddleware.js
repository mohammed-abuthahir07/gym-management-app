const roleMiddleware = (...allowedRoles) => {
    return (req, res, next) => {
        try {

            // Check whether authentication middleware
            // has already identified the user
            if (!req.user) {
                return res.status(401).json({
                    success: false,
                    message: 'Authentication required'
                });
            }


            // Check user's role
            if (!allowedRoles.includes(req.user.role)) {
                return res.status(403).json({
                    success: false,
                    message: 'Access denied'
                });
            }


            // User has permission
            next();

        } catch (error) {

            console.error('Role authorization error:', error);

            return res.status(500).json({
                success: false,
                message: 'Server error during authorization'
            });
        }
    };
};

module.exports = roleMiddleware;