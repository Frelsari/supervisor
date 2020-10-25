import staff from "./staff";
import user from "./user";
import guest from "./guest";
import {onCreateMachine, onUpdateMachine} from "./machine";

const admin = require('firebase-admin');
admin.initializeApp();

exports.staff = staff
exports.user = user
exports.guest = guest
exports.createMachine = onCreateMachine
exports.updateMachine = onUpdateMachine
