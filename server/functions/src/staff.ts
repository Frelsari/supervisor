import {Request} from "firebase-functions/lib/providers/https";
import {UserRecord} from "firebase-functions/lib/providers/auth";
import {isEmail, validatePermissionAndGetDocument, decryptJwt} from "./utils";
import {NewStaff, RequirementOfDeleteSpecificStaff, RequirementOfQueryAllStaff} from "./types";

const functions = require('firebase-functions');
const admin = require('firebase-admin');

export default functions.https.onRequest(async (req: Request, resp) => {
  const authJwt = async (jwt: string) => {
    // auth jwt
    const decodedToken = await decryptJwt(jwt)
    if (!decodedToken) {
      resp.status(401).send('Invalid jwt token.')
      (() => {
        throw new Error()
      })()
    }
    
    // validate permission
    if (!(await validatePermissionAndGetDocument(decodedToken!.uid, ['administrator']))) {
      resp.status(403).send('Insufficient permission, access denied.')
      (() => {
        throw new Error()
      })()
    }
  }
  
  if (req.method === 'POST') {
    const data = req.body as unknown as NewStaff
    
    // check if the request body is correct.
    if (!data || !data.jwtToken || !data.email || !data.displayName || !data.password) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    // auth
    try {
      await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
    
    // pre-fix request data.
    data.email = data.email.trim()
    data.displayName = data.displayName.trim()
    
    // check if the request body is correct.
    if (!data.email || !data.displayName || !data.password) {
      resp.status(400).send('Invalid request!')
      return
    }
    const fakeEmailDomain = '@vghtpe.tw'
    
    // validate the email.
    let email!: string
    if (isEmail(data.email)) {
      email = data.email
    } else {
      email = data.email + fakeEmailDomain
    }
    
    // validate the password.
    const isValidPassword = data.password.length >= 6
    let password!: string
    if (isValidPassword) {
      password = data.password
    } else {
      resp.status(400).send('Password is too short, at least six characters!')
      return
    }
    
    // validate the displayName.
    const isValidDisplayName = Boolean(data.displayName)
    let displayName: string | undefined
    if (isValidDisplayName) {
      displayName = data.displayName
    }
    
    // create a staff user.
    let userRecord!: UserRecord
    try {
      userRecord = (await admin.auth().createUser({
        email,
        password,
        displayName
      }))
    } catch (e) {
      resp.status(500).json(
        {
          result: 'Unable to create user.',
          messages: e
        }
      )
      return
    }
    
    // confirm whether it is established correctly.
    const userName = userRecord.displayName
    const userEmail = userRecord.email
    if (userEmail !== email || userName !== displayName) {
      resp.status(500).send('Unknown error happened when creating user in firestore')
      return
    }
    
    // save user permission data to firestore.
    const uid = userRecord.uid
    const role = 'staff'
    const newFireStoreData = {
      displayName: userName,
      email: userEmail,
      role
    }
    await admin.firestore().collection('/staffs').doc(uid).set(newFireStoreData)
    resp
      .status(201)
      .json(
        {
          message: 'Successfully created a staff.',
          staffData: {
            uid,
            ...newFireStoreData
          }
        }
      )
    return
  }
  
  if (req.method === 'GET') {
    const data = req.query as unknown as RequirementOfQueryAllStaff
    
    // check if the request body is correct.
    if (!data || !data.jwtToken) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    // auth
    try {
      await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
    
    // get all staffs
    try {
      const staffs = (await admin.firestore().collection('staffs').get()).docs
        .map(staff => Object.assign({uid: staff.id}, staff.data()))
      resp.status(200).json([...staffs])
      return
    } catch (e) {
      resp.status(500).json(
        {
          result: 'Unable to get staffs in firestore',
          messages: e
        }
      )
    }
  }
  
  if (req.method === 'DELETE') {
    const data = req.query as unknown as RequirementOfDeleteSpecificStaff
    
    // check if the request body is correct.
    if (!data || !data.jwtToken || !data.uid) {
      resp.status(400).send('Incorrect request format or lack of necessary information!')
      return
    }
    
    // auth
    try {
      await authJwt(data.jwtToken)
    } catch (e) {
      return
    }
    
    // delete staffs
    try {
      await admin.firestore().collection('staffs').doc(data.uid).delete()
      await admin.auth().deleteUser(data.uid)
      resp.status(200).json(
        {
          message: 'Successfully deleted a staff',
          uid: data.uid
        }
      )
      return
    } catch (e) {
      resp.status(500).json(
        {
          result: 'Unable to delete staff in firestore',
          messages: e
        }
      )
      return
    }
  }
  
  resp.status(405).send('Invalid request method!')
  return
})
