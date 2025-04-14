const mongoose = require('mongoose')


const communitySchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'Community name cannot be empty'],
        trim: true
    },
    description: {
        type: String,
        required: [true, 'Description cannot be empty'],
        trim: true
    },
    leader: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User'
    },
    members:
        [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User'
        }]
    ,
    tasks: [
        {
            title: {
                type: String,
            },
            description: {
                type: String,
            },
            posts: [
                {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: 'Post'
                }
            ]
        }
    ]
}, { timestamps: true })

communitySchema.index({ members: 1 });

module.exports = mongoose.model("Community", communitySchema);