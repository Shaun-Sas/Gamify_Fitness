const jwt = require('jsonwebtoken');

const authorize = (req, res, next) => {
    const authHeader = req.header('Authorization');
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401);
        return next(new Error('Authorization header must be provided and start with Bearer'));
    }

    const token = authHeader.replace('Bearer ', '');
    if (!token) {
        res.status(401);
        return next(new Error('Authentication token must be provided'));
    }

    try {
        const decoded = jwt.verify(token, process.env.TOKEN_SECRET || "test-screte");
        req.user = decoded;
        next();
    } catch (error) {
        res.status(401);
        next(new Error('Invalid or expired authentication token'));
    }
};

module.exports = authorize;